import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../app_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/privilege.dart';
import '../theme.dart';
import '../ui/kit.dart';
import '../widgets/content_filter.dart';
import '../widgets/ugc_actions.dart';
import '../ui/level_gate.dart';
import 'digital_human_call_screen.dart';

/// 数字人陪聊（v0 空壳）。能量条挂在角色身上（显示成「能量/电量」不是冷冰冰剩X分钟）；
/// 聊天耗能，快用完时角色撒娇催充。v0 = 本地 mock 回复，不接 LLM、不真计费。
class AiChatScreen extends StatefulWidget {
  final AiCharacter character;
  const AiChatScreen({super.key, required this.character});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _Msg {
  final String text;
  final bool me;
  final bool nag; // 催充能量气泡
  const _Msg(this.text, this.me, {this.nag = false});
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  int _energy = 88; // 0..100 能量（mock）
  int _replyIdx = 0;

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(widget.character.greeting, false));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    // 内容过滤(苹果 G1.2):违规输入拦截,不发给 AI
    if (!ContentFilter.guard(context, t)) return;
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    _ctrl.clear();
    final c = widget.character;
    final pool = [c.greeting, ...c.lines];
    setState(() {
      _msgs.add(_Msg(t, true));
      _energy = (_energy - 9).clamp(0, 100);
      _msgs.add(_Msg(pool[_replyIdx % pool.length], false));
      _replyIdx++;
      if (_energy <= 20) {
        _msgs.add(_Msg(l.aic_lowEnergyNag, false, nag: true));
      }
    });
    _scrollDown();
  }

  void _recharge() {
    final l = AppLocalizations.of(context);
    setState(() {
      _energy = 100;
      _msgs.add(_Msg(l.aic_chargedReply, false));
    });
    _scrollDown();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: FF.panel,
      content: Text(l.aic_chargeToast,
          style: const TextStyle(color: FF.text)),
    ));
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final low = _energy <= 20;
    return Scaffold(
      backgroundColor: FF.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _topBar(c),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) => _bubble(c, _msgs[i]),
                  ),
                ),
                if (low) _nagBar(c),
                _inputBar(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: c.aura),
            ),
            child: ShaderMask(
              shaderCallback: (r) => LinearGradient(colors: c.aura).createShader(r),
              child: Text(c.emoji,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.name,
                    style: const TextStyle(
                        color: FF.text, fontSize: 15, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                _energyBar(c),
              ],
            ),
          ),
          // 只有有咱们定制脸的角色才露视频通话入口，没脸的不假装有数字人。
          if (digitalHumanFaceReady(c.id)) ...[
            const SizedBox(width: 8),
            _callButton(c),
          ],
          // 举报 AI 对话(苹果 G1.2:AI 生成内容也要可举报)
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.more_horiz, color: FF.dim),
            onPressed: () => showUgcSheet(
              context,
              contentType: 'chat',
              contentId: c.id,
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部「视频通话」入口：进数字人实时通话页（Simli 脸 + 语音对语音）。
  Widget _callButton(AiCharacter c) {
    return Bounce(
      onTap: () async {
        // V 级别门槛：视频通话 = V3（防「猫阿狗」白嫖；门≠油，进去后仍按分钟扣能量）。
        if (!await requireLevel(context, Feature.videoCall)) return;
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DigitalHumanCallScreen(character: c),
          ),
        );
      },
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: c.aura),
          boxShadow: [
            BoxShadow(
                color: c.aura.first.withValues(alpha: 0.5), blurRadius: 16),
          ],
        ),
        child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _energyBar(AiCharacter c) {
    final low = _energy <= 20;
    final fill = low ? FF.hot : c.aura.first;
    return Row(
      children: [
        Icon(low ? Icons.battery_alert_rounded : Icons.bolt_rounded,
            color: fill, size: 13),
        const SizedBox(width: 5),
        SizedBox(
          width: 120,
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                height: 6,
                width: (120 * _energy / 100).clamp(4.0, 120.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: low ? [FF.hot, FF.orange] : c.aura),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(color: fill.withValues(alpha: 0.5), blurRadius: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
            AppLocalizations.of(context).aic_energyFmt(_energy.toString()),
            style: TextStyle(
                color: fill, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _bubble(AiCharacter c, _Msg m) {
    if (m.me) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 8, left: 50),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: FF.brandGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(m.text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.4)),
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.12, curve: Curves.easeOut);
    }
    final accent = m.nag ? FF.hot : c.aura.first;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xCC15101F),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Text(m.text,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.4)),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.12, curve: Curves.easeOut);
  }

  Widget _nagBar(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GradientButton(
        label: AppLocalizations.of(context).aic_chargeBtnFmt(c.name),
        icon: Icons.bolt_rounded,
        height: 48,
        gradient: const LinearGradient(colors: [FF.hot, FF.orange]),
        glow: FF.hot,
        shimmer: true,
        onTap: _recharge,
      ),
    );
  }

  Widget _inputBar(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: c.aura.first,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).aic_hintFmt(c.name),
                  hintStyle: const TextStyle(color: FF.weak, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: c.aura),
                boxShadow: [
                  BoxShadow(
                      color: c.aura.first.withValues(alpha: 0.45),
                      blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../app_config.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/privilege.dart';
import '../theme.dart';
import '../ui/kit.dart';
import '../widgets/content_filter.dart';
import '../widgets/ugc_actions.dart';
import '../ui/level_gate.dart';
import 'digital_human_call_screen.dart';
import 'login_screen.dart';

/// 数字人陪聊。能量条挂在角色身上（显示成「能量/电量」不是冷冰冰剩X分钟）；
/// 聊天耗能，快用完时角色撒娇催充。回复走真 LLM 大脑（Api.brainChat，按 characterId
/// 套人设，服务端 gpt-4o）；充能真扣鹰币（Api.spendCoins，reason:'chat_energy'）。
/// 能量耗尽前的「每条扣能」只是客户端限速门，真正花钱的只有「充能」这一步。
class AiChatScreen extends StatefulWidget {
  final AiCharacter character;
  /// 从「深入沟通的时刻」进来时带该时刻主题，预填进输入框当开场话题（不自动发送）。
  final String? openingTopic;
  const AiChatScreen({super.key, required this.character, this.openingTopic});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _Msg {
  final String text;
  final bool me;
  final bool nag; // 催充能量气泡
  final bool error; // 网络/接口出错气泡（可重试）
  const _Msg(this.text, this.me, {this.nag = false, this.error = false});
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const int _energyPerMsg = 9; // 每条消息耗能（客户端限速门）
  static const int _refillCost = 30; // 一次充能花的鹰币
  static const int _historyTurns = 16; // 发给大脑的最近上下文轮数

  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  int _energy = 88; // 0..100 能量
  bool _typing = false; // AI 正在回复（typing 指示）
  bool _busy = false; // 防重复发送 / 充能进行中
  String? _lastSent; // 最近一条失败消息，供重试

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(widget.character.greeting, false));
    final seed = widget.openingTopic?.trim() ?? '';
    if (seed.isNotEmpty) _ctrl.text = seed; // 预填开场话题，用户点发送即真聊
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// 把已发的对话整理成大脑要的 history（最近 N 轮，去掉催充/出错气泡）。
  List<Map<String, String>> _history() {
    final turns = <Map<String, String>>[];
    for (final m in _msgs) {
      if (m.nag || m.error) continue;
      turns.add({'role': m.me ? 'user' : 'assistant', 'content': m.text});
    }
    if (turns.length > _historyTurns) {
      return turns.sublist(turns.length - _historyTurns);
    }
    return turns;
  }

  Future<void> _send() async {
    if (_busy || _typing) return;
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    // 内容过滤(苹果 G1.2):违规输入拦截,不发给 AI
    if (!ContentFilter.guard(context, t)) return;
    // 能量耗尽：挡住发送，引导去充能（不偷偷扣币）。
    if (_energy <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FF.panel,
        content: Text('能量耗尽啦，先充能再继续聊~',
            style: TextStyle(color: FF.text)),
      ));
      return;
    }
    FocusScope.of(context).unfocus();
    _ctrl.clear();
    setState(() {
      _msgs.add(_Msg(t, true));
      _energy = (_energy - _energyPerMsg).clamp(0, 100);
    });
    _scrollDown();
    await _ask(t);
  }

  /// 调真 LLM 大脑取回复。history 不含当前这条（已在 _msgs 末尾，调用前排除它）。
  Future<void> _ask(String userText) async {
    final c = widget.character;
    final l = AppLocalizations.of(context);
    // 上下文取「当前这条之前」的轮次。
    final hist = _history();
    if (hist.isNotEmpty && hist.last['role'] == 'user') {
      hist.removeLast();
    }
    setState(() {
      _typing = true;
      _busy = true;
      _lastSent = null;
    });
    _scrollDown();
    try {
      final reply = await Api.brainChat(
        characterId: c.id,
        message: userText,
        history: hist,
      );
      if (!mounted) return;
      setState(() {
        _typing = false;
        _busy = false;
        _msgs.add(_Msg(reply, false));
        if (_energy <= 20) {
          _msgs.add(_Msg(l.aic_lowEnergyNag, false, nag: true));
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _busy = false;
        _lastSent = userText; // 留着供「重试」
        _msgs.add(const _Msg('没连上，点这里重试', false, error: true));
      });
    }
    _scrollDown();
  }

  /// 重试上一条失败的消息（去掉出错气泡，重新问大脑）。
  Future<void> _retry() async {
    if (_busy || _typing) return;
    final text = _lastSent;
    if (text == null) return;
    setState(() {
      _msgs.removeWhere((m) => m.error);
      _lastSent = null;
    });
    await _ask(text);
  }

  /// 充能：真扣鹰币（reason:'chat_energy'）。未登录先登录；鹰币不足提示去充值。
  Future<void> _buyEnergy() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    // 未登录：先去登录，登录后不自动续扣（让用户重新点充能）。
    if (!auth.loggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    setState(() => _busy = true);
    String? errMsg;
    try {
      await Api.spendCoins(
        amount: _refillCost,
        reason: 'chat_energy',
        refId: widget.character.id,
        requestId:
            '${DateTime.now().microsecondsSinceEpoch}_${widget.character.id}',
      );
    } on ApiException catch (e) {
      errMsg = e.message;
    } catch (_) {
      errMsg = '充能失败，请稍后再试';
    }
    if (!mounted) return;
    if (errMsg != null) {
      setState(() => _busy = false);
      final insufficient = errMsg.contains('鹰币不足');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FF.panel,
        content: Text(insufficient ? '鹰币不足，去充值~' : errMsg,
            style: const TextStyle(color: FF.text)),
      ));
      return;
    }
    // 扣币成功：本地满能 + 同步最新余额。
    setState(() {
      _busy = false;
      _energy = 100;
      _msgs.add(_Msg(l.aic_chargedReply, false));
    });
    auth.refresh(); // 同步最新鹰币余额（充能真扣了币）。
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
                    itemCount: _msgs.length + (_typing ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_typing && i == _msgs.length) {
                        return _typingBubble(c);
                      }
                      return _bubble(c, _msgs[i]);
                    },
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
    final accent = (m.nag || m.error) ? FF.hot : c.aura.first;
    final bubble = Container(
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (m.error) ...[
            const Icon(Icons.refresh_rounded, color: FF.hot, size: 16),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(m.text,
                style: TextStyle(
                    color: m.error ? FF.hot : Colors.white,
                    fontSize: 14,
                    height: 1.4)),
          ),
        ],
      ),
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: m.error
          ? GestureDetector(onTap: _retry, child: bubble)
          : bubble,
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.12, curve: Curves.easeOut);
  }

  /// AI 正在打字的指示气泡（三个跳动的点）。
  Widget _typingBubble(AiCharacter c) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xCC15101F),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: c.aura.first.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.aura.first,
                  ),
                )
                    .animate(
                        onPlay: (ctrl) => ctrl.repeat(),
                        delay: (i * 160).ms)
                    .fadeIn(duration: 300.ms)
                    .then()
                    .fadeOut(duration: 300.ms),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
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
        onTap: _buyEnergy, // 内部按 _busy 早返回，防重复扣币
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
            child: Opacity(
              opacity: (_busy || _typing) ? 0.5 : 1,
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
                child: (_busy || _typing)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

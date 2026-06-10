// 数字人实时视频通话页：Simli 脸铺满竖屏 + 实时字幕 + 「演员在片场」过场盖冷启动 + 挂断。
// 引擎在 services/realtime_call.dart：麦克风 PCM16 → 中继 → OpenAI Realtime → 脸做口型+出声。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../services/realtime_call.dart';
import '../theme.dart';
import '../ui/kit.dart';

class DigitalHumanCallScreen extends StatefulWidget {
  final AiCharacter character;
  const DigitalHumanCallScreen({super.key, required this.character});

  @override
  State<DigitalHumanCallScreen> createState() => _DigitalHumanCallScreenState();
}

class _DigitalHumanCallScreenState extends State<DigitalHumanCallScreen> {
  late final DigitalHumanCall _call;
  ValueNotifier<bool>? _speaking; // 接通后才就绪（来自 Simli）
  bool _popping = false;

  @override
  void initState() {
    super.initState();
    _call = DigitalHumanCall(widget.character.id);
    _call.phase.addListener(_onPhase);
    _call.start();
  }

  void _onPhase() {
    final p = _call.phase.value;
    // 接通后挂上「说话」监听（Simli 的 isSpeakingNotifier 此时才存在）
    if (p == DhPhase.live && _speaking == null) {
      _speaking = _call.speaking;
      _speaking?.addListener(_onSpeaking);
    }
    // 远端结束（对方挂断/中继断线）→ 自动退出，唯一退出路径，避免重复 pop
    if (p == DhPhase.ended && !_popping) {
      _popping = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
    if (mounted) setState(() {});
  }

  void _onSpeaking() {
    if (mounted) setState(() {});
  }

  void _hangup() {
    // 只置态结束；phase→ended 经 _onPhase 统一收口退出。
    _call.stop();
  }

  @override
  void dispose() {
    _call.phase.removeListener(_onPhase);
    _speaking?.removeListener(_onSpeaking);
    _call.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _video(),
            const _Scrim(),
            _stageOverlay(c),
            SafeArea(
              child: Column(
                children: [
                  _topBar(c),
                  const Spacer(),
                  _captionArea(),
                  _controls(c),
                ],
              ),
            ),
            _errorOverlay(),
          ],
        ),
      ),
    );
  }

  // Simli 脸：首帧渲染后才有 renderer；之前盖在「演员在片场」过场下，看不到黑屏。
  Widget _video() {
    return ValueListenableBuilder<bool>(
      valueListenable: _call.videoReady,
      builder: (_, _, _) {
        final r = _call.renderer;
        if (r == null) return const ColoredBox(color: Colors.black);
        return RTCVideoView(
          r,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          mirror: false,
        );
      },
    );
  }

  // 「演员在片场」：接通中盖满全屏，首帧渲染后慢慢淡出（1.1s）。
  Widget _stageOverlay(AiCharacter c) {
    return ValueListenableBuilder<bool>(
      valueListenable: _call.videoReady,
      builder: (_, ready, _) {
        return IgnorePointer(
          ignoring: ready,
          child: AnimatedOpacity(
            opacity: ready ? 0 : 1,
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOut,
            child: _StageContent(character: c),
          ),
        );
      },
    );
  }

  Widget _topBar(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _hangup,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 8),
                        ])),
                const SizedBox(height: 3),
                _statusLine(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLine() {
    final l = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _call.videoReady,
      builder: (_, ready, _) => ValueListenableBuilder<DhPhase>(
      valueListenable: _call.phase,
      builder: (_, phase, _) {
        final (color, _) = switch (phase) {
          // 线路通了但画面还没出来时停在金色「接通中」，首帧渲染后才转青色「已接通」。
          DhPhase.live => ready
              ? (FF.teal, l.dhc_connected)
              : (FF.gold, l.dhc_connecting),
          DhPhase.connecting => (FF.gold, l.dhc_connecting),
          DhPhase.ended => (FF.weak, l.dhc_ended),
          DhPhase.error => (FF.hot, l.dhc_error),
        };
        return ValueListenableBuilder<String>(
          valueListenable: _call.status,
          builder: (_, status, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(status,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 6),
                        ])),
              ],
            );
          },
        );
      },
    ),
    );
  }

  // 实时字幕：数字人这轮在说的话。空则不占位。
  Widget _captionArea() {
    return ValueListenableBuilder<String>(
      valueListenable: _call.caption,
      builder: (_, text, _) {
        final t = text.trim();
        if (t.isEmpty) return const SizedBox(height: 6);
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Glass(
            radius: 18,
            blur: 18,
            color: const Color(0x66000000),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              t,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ),
        );
      },
    );
  }

  Widget _controls(AiCharacter c) {
    final speaking = _speaking?.value ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _call.videoReady,
            builder: (_, ready, _) => _micPill(c, speaking, ready),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _hangup,
            child: Container(
              width: 66,
              height: 66,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [FF.red, FF.hot]),
                boxShadow: [
                  BoxShadow(
                      color: FF.red.withValues(alpha: 0.5),
                      blurRadius: 22,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.call_end_rounded,
                  color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  // 麦克风/说话状态药丸：还没接通(画面未就位)时显示「正在接通…请稍等」，
  // 接通后再切换——对方说话时显示「TA 正在说」，否则「在聆听你」。
  Widget _micPill(AiCharacter c, bool speaking, bool ready) {
    final l = AppLocalizations.of(context);
    final String label;
    final IconData icon;
    final Color accent;
    if (!ready) {
      label = l.dhc_connectingHint;
      icon = Icons.hourglass_top_rounded;
      accent = FF.gold;
    } else if (speaking) {
      label = l.dhc_talkingFmt(c.name);
      icon = Icons.graphic_eq_rounded;
      accent = c.aura.first;
    } else {
      label = l.dhc_listening;
      icon = Icons.mic_rounded;
      accent = FF.teal;
    }
    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
    if (speaking || !ready) {
      pill = pill
          .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
          .fadeIn(duration: 900.ms)
          .then()
          .tint(color: accent.withValues(alpha: 0.10), duration: 900.ms);
    }
    return pill;
  }

  Widget _errorOverlay() {
    return ValueListenableBuilder<DhPhase>(
      valueListenable: _call.phase,
      builder: (_, phase, _) {
        if (phase != DhPhase.error) return const SizedBox.shrink();
        return Container(
          color: const Color(0xF2080706),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                  color: FF.hot, size: 48),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: _call.status,
                builder: (_, msg, _) => Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: FF.text, fontSize: 15, height: 1.45),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: 200,
                child: GradientButton(
                  label: AppLocalizations.of(context).dhc_backLabel,
                  icon: Icons.arrow_back_rounded,
                  height: 50,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 上下压暗 scrim：让顶部状态、底部字幕/按钮在脸上也清晰。
class _Scrim extends StatelessWidget {
  const _Scrim();
  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x8C000000),
              Color(0x00000000),
              Color(0x00000000),
              Color(0xB3000000),
            ],
            stops: [0, 0.18, 0.62, 1],
          ),
        ),
      ),
    );
  }
}

// 「演员在片场」过场：脸还没渲染前盖住冷启动延时——发光头像 + 呼吸光环 + 流光文案。
class _StageContent extends StatelessWidget {
  final AiCharacter character;
  const _StageContent({required this.character});

  @override
  Widget build(BuildContext context) {
    final c = character;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [FF.bg2, FF.bg],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              top: -60,
              right: -50,
              child: _glow(240, c.aura.first, 0.20)),
          Positioned(
              bottom: 40, left: -70, child: _glow(280, c.aura.last, 0.16)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _avatar(c),
                const SizedBox(height: 28),
                Text(c.name,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5)),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context).dhc_actorsReady,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0))
                    .animate(onPlay: (ctl) => ctl.repeat())
                    .shimmer(
                        duration: 1600.ms,
                        color: c.aura.first.withValues(alpha: 0.9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(AiCharacter c) {
    final ring = Container(
      width: 156,
      height: 156,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: c.aura),
        boxShadow: [
          BoxShadow(color: c.aura.first.withValues(alpha: 0.5), blurRadius: 40),
        ],
      ),
      child: ClipOval(
        child: (c.avatarHead != null)
            ? Image.asset(c.avatarHead!, fit: BoxFit.cover)
            : Container(
                color: FF.panel,
                alignment: Alignment.center,
                child: Text(c.emoji,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 54,
                        fontWeight: FontWeight.w900)),
              ),
      ),
    );
    // 呼吸：1.5s 慢放大一点点再收回，足一点别一闪。
    return ring
        .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.06, 1.06),
            duration: 1500.ms,
            curve: Curves.easeInOut);
  }

  Widget _glow(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

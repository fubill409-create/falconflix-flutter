import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'sheets.dart';

/// AI Spark 三步流程（按 Codex app-subflows）：设置 → 生成中 → 结果。
/// 暗色 + 主渐变，承接 AI 玩法 tab。UI 壳，生成为本地模拟。
class SparkFlowScreen extends StatefulWidget {
  final String toolName; // 进入时选中的玩法
  final String? contextTitle; // 关联短剧
  const SparkFlowScreen({super.key, required this.toolName, this.contextTitle});

  @override
  State<SparkFlowScreen> createState() => _SparkFlowScreenState();
}

enum _Phase { setup, generating, result }

class _SparkFlowScreenState extends State<SparkFlowScreen>
    with SingleTickerProviderStateMixin {
  late int _style;
  bool _hasPhoto = false;
  _Phase _phase = _Phase.setup;
  late final AnimationController _gen;

  List<(String, String, IconData)> _toolsFor(AppLocalizations l) => [
        (l.sp_toolPosterName, l.sp_toolPosterCost, Icons.image_outlined),
        (l.sp_toolVideoNameShort, l.sp_toolVideoCost,
            Icons.movie_creation_outlined),
        (l.sp_toolMakeoverName, l.sp_toolMakeoverCost,
            Icons.auto_fix_high_outlined),
        (l.sp_toolAvatarName, l.sp_toolAvatarCost,
            Icons.face_retouching_natural_outlined),
      ];

  @override
  void initState() {
    super.initState();
    // toolName passed via routing 是 zh 标签；按位置匹配兜底（找不到 = 0）
    final names = [
      '剧照海报生成', '3秒 AI 片段', 'AI 变装', 'AI 专属头像',
    ];
    _style = names.indexWhere((n) => n == widget.toolName);
    if (_style < 0) _style = 0;
    _gen = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() => _phase = _Phase.result);
        }
      });
  }

  @override
  void dispose() {
    _gen.dispose();
    super.dispose();
  }

  void _startGenerate() {
    setState(() => _phase = _Phase.generating);
    _gen.forward(from: 0);
  }

  void _regenerate() {
    setState(() => _phase = _Phase.generating);
    _gen.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      body: SafeArea(
        bottom: false,
        child: switch (_phase) {
          _Phase.setup => _setup(context),
          _Phase.generating => _generating(context),
          _Phase.result => _result(context),
        },
      ),
    );
  }

  // ── 第 1 步：设置 ──────────────────────────────
  Widget _setup(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tools = _toolsFor(l);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
      children: [
        _topbar('AI Spark'),
        const SizedBox(height: 14),
        Text(l.spf_settingsTitle,
            style: const TextStyle(
                color: FF.dim, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        gradientText(tools[_style].$1, size: 30),
        if (widget.contextTitle != null && widget.contextTitle!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.link_rounded, color: FF.blue, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l.spf_linkedToFmt(widget.contextTitle!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: FF.muted, fontSize: 12)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _uploadCard(l),
        const SizedBox(height: 18),
        Text(l.spf_chooseTool,
            style: const TextStyle(
                color: FF.text, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemCount: tools.length,
          itemBuilder: (_, i) {
            final sel = i == _style;
            return GestureDetector(
              onTap: () => setState(() => _style = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: sel ? FF.aiRemixGradient : null,
                  color: sel ? null : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? Colors.transparent : FF.line),
                ),
                child: Row(
                  children: [
                    Icon(tools[i].$3,
                        color: sel ? Colors.white : FF.muted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tools[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: sel ? Colors.white : FF.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: _hasPhoto ? _startGenerate : null,
          child: Opacity(
            opacity: _hasPhoto ? 1 : 0.45,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: FF.brandGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                      color: FF.hot.withValues(alpha: 0.3), blurRadius: 22),
                ],
              ),
              child: Text(
                  _hasPhoto
                      ? l.spf_genBtnFmt(tools[_style].$2)
                      : l.spf_noPhotoBtn,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadCard(AppLocalizations l) {
    return GestureDetector(
      onTap: () => setState(() => _hasPhoto = true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FF.line),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, gradient: FF.brandGradient),
              child: Icon(_hasPhoto ? Icons.check_rounded : Icons.add_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            Text(_hasPhoto ? l.spf_photoReady : l.spf_uploadPhoto,
                style: const TextStyle(
                    color: FF.text, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(_hasPhoto ? l.spf_photoTapToReplace : l.spf_photoHint,
                style: const TextStyle(color: FF.dim, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── 第 2 步：生成中 ────────────────────────────
  Widget _generating(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _topbar('AI Spark', showBack: false),
        const Spacer(),
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: FF.brandGradient),
          child: const Text('AI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900)),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(end: 1.08, duration: 900.ms, curve: Curves.easeInOut),
        const SizedBox(height: 24),
        gradientText(l.spf_generating, size: 22),
        const SizedBox(height: 8),
        Text(l.spf_generatingSub,
            style: const TextStyle(color: FF.muted, fontSize: 12)),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedBuilder(
            animation: _gen,
            builder: (_, _) => _progress(_gen.value),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _progress(double v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 6, color: Colors.white.withValues(alpha: 0.08)),
              FractionallySizedBox(
                widthFactor: v.clamp(0.02, 1),
                child: Container(
                  height: 6,
                  decoration: const BoxDecoration(gradient: FF.brandGradient),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('${(v * 100).round()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: FF.dim, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── 第 3 步：结果 ──────────────────────────────
  Widget _result(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tools = _toolsFor(l);
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(gradient: FF.splashGradient),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 72),
                ),
              ),
            ),
            const SizedBox(height: 260),
          ],
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FF.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: FF.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, gradient: FF.brandGradient),
                  child: const Text('AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 12),
                Text(l.spf_genDoneTag,
                    style: const TextStyle(color: FF.dim, fontSize: 12)),
                const SizedBox(height: 4),
                gradientText(l.spf_genDoneTitleFmt(tools[_style].$1),
                    size: 22),
                const SizedBox(height: 6),
                Text(l.spf_genDoneBody,
                    style: const TextStyle(color: FF.muted, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _btn(l.spf_btnSave, FF.brandGradient, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.spf_savedToast)));
                      }),
                    ),
                    const SizedBox(width: 10),
                    _iconBtn(Icons.refresh_rounded, _regenerate),
                    const SizedBox(width: 10),
                    _iconBtn(Icons.ios_share_rounded,
                        () => showShareSheet(context,
                            sceneLabel: l.spf_shareLabel)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: _backBtn(onDark: true),
        ),
      ],
    );
  }

  Widget _btn(String label, Gradient g, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: g, borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: FF.line)),
          child: Icon(icon, color: FF.text, size: 20),
        ),
      );

  Widget _topbar(String kicker, {bool showBack = true}) {
    return Row(
      children: [
        if (showBack) _backBtn() else const SizedBox(width: 40),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: FF.line)),
          child: Text(kicker,
              style: const TextStyle(
                  color: FF.muted, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _backBtn({bool onDark = false}) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
                color: onDark ? Colors.white24 : FF.line),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      );
}

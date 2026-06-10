import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'spark_flow_screen.dart';

/// AI 玩法（Spark）页 — 和短剧观看连接的轻量 AI 玩法。UI 先行。
/// 从首页/播放页「AI 入戏」进入时带 [contextTitle]（当前短剧），顶部显示创作横幅。
class SparkScreen extends StatelessWidget {
  final String? contextTitle;
  const SparkScreen({super.key, this.contextTitle});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 110),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 从首页/播放页「AI Remix」push 进来时显示返回（作为底栏 Tab 时不显示）
                    if (Navigator.canPop(context)) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x18FFFFFF),
                            border: Border.all(color: FF.line),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: FF.text, size: 20),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          gradientText(l.sp_sectionHeader,
                              size: 26, gradient: FF.aiGradient),
                          const SizedBox(height: 4),
                          Text(l.sp_subtitle,
                              style: const TextStyle(
                                  color: FF.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (contextTitle != null && contextTitle!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Glass(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: FF.teal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(l.sp_creatingFmt(contextTitle ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: FF.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
            _hero(context).animate().fadeIn(duration: 450.ms).slideY(
                begin: 0.1, curve: Curves.easeOut),
            const SizedBox(height: 14),
            _mallEntry().animate(delay: 120.ms).fadeIn(duration: 450.ms).slideY(
                begin: 0.1, curve: Curves.easeOut),
            const SizedBox(height: 14),
                _featureGrid(context)
                    .animate(delay: 240.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launch(BuildContext context, String toolName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SparkFlowScreen(toolName: toolName, contextTitle: contextTitle),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1A16), Color(0xFF16201E)],
        ),
        border: Border.all(color: FF.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniChip(l.sp_chipLinked),
          const SizedBox(height: 12),
          Text(l.sp_putInDramaTitle,
              style: const TextStyle(
                  color: FF.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(l.sp_putInDramaBody,
              style: const TextStyle(
                  color: FF.muted, fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _launch(context, l.sp_toolPosterName),
            child: Container(
              height: 44,
              width: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: FF.hotGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(l.sp_btnTryRoleplay,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 1800.ms, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _mallEntry() {
    return Builder(
      builder: (context) {
        final l = AppLocalizations.of(context);
        return Glass(
          radius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _miniChip(l.sp_chipMall),
                    const SizedBox(height: 10),
                    Text(l.sp_sceneMallTitle,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l.sp_sceneMallBody,
                        style:
                            const TextStyle(color: FF.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: FF.dim, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _featureGrid(BuildContext context) {
    final l = AppLocalizations.of(context);
    final flowNames = [
      l.sp_toolPosterName,
      l.sp_toolVideoNameShort,
      l.sp_toolMakeoverName,
      l.sp_toolAvatarName,
    ];
    final features = [
      ('Drama-linked', l.sp_toolPosterName, l.sp_toolPosterDesc,
          '5-25 cr / 10-30s', Icons.image_outlined),
      ('Video', l.sp_toolVideoName, l.sp_toolVideoDesc,
          '40 cr / 30-120s', Icons.movie_creation_outlined),
      ('Viral', l.sp_toolMakeoverName, l.sp_toolMakeoverDesc,
          '25 cr / 15-60s', Icons.auto_fix_high_outlined),
      ('Profile', l.sp_toolAvatarName, l.sp_toolAvatarDesc,
          '5-25 cr / 8-25s', Icons.face_retouching_natural_outlined),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: features.length,
      itemBuilder: (_, i) {
        final f = features[i];
        return GestureDetector(
          onTap: () => _launch(context, flowNames[i]),
          child: Glass(
          radius: 16,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 88,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    colors: [
                      FF.gold.withValues(alpha: 0.18),
                      FF.teal.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Center(child: Icon(f.$5, color: FF.brightGold, size: 30)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _miniChip(f.$1),
                    const SizedBox(height: 8),
                    Text(f.$2,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(f.$3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: FF.muted, fontSize: 11, height: 1.35)),
                    const SizedBox(height: 8),
                    Text(f.$4,
                        style: const TextStyle(
                            color: FF.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _miniChip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: FF.bg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FF.line)),
        child: Text(t,
            style: const TextStyle(
                color: FF.text, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

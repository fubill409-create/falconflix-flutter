import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../ui/kit.dart';

/// 角色元宇宙 · 世界观/玩法介绍（单独一页，从落地页顶部入口进）。
/// 一级大厅不再被大段介绍占位；想了解这个世界，进这里看全。
class CharacterUniverseIntroScreen extends StatelessWidget {
  const CharacterUniverseIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _topBar(context)),
                SliverToBoxAdapter(child: _hero(context)),
                SliverToBoxAdapter(child: _steps(context)),
                SliverToBoxAdapter(child: _footer(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 19),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlowChip(l.cui_chipAI, color: FF.hot),
              const SizedBox(width: 8),
              GlowChip(l.cui_chipMetaverse, color: FF.purple),
            ],
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.08),
          const SizedBox(height: 16),
          gradientText(l.cui_title, size: 40, gradient: FF.brandGradient)
              .animate()
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.12, curve: Curves.easeOut),
          const SizedBox(height: 12),
          Text(
            l.cui_lead,
            style: const TextStyle(
                color: FF.text,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w800),
          ).animate(delay: 160.ms).fadeIn(duration: 700.ms),
          const SizedBox(height: 10),
          Text(
            l.cui_body,
            style: const TextStyle(
                color: FF.muted,
                fontSize: 13.5,
                height: 1.7,
                letterSpacing: 0.2),
          ).animate(delay: 240.ms).fadeIn(duration: 700.ms),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  Widget _steps(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      _Step(Icons.chat_bubble_rounded, l.cui_step1Title, l.cui_step1Desc,
          const [FF.hot, FF.purple]),
      _Step(Icons.local_fire_department_rounded, l.cui_step2Title,
          l.cui_step2Desc, const [FF.orange, FF.gold]),
      _Step(Icons.movie_filter_rounded, l.cui_step3Title, l.cui_step3Desc,
          const [FF.purple, FF.blue]),
      _Step(Icons.auto_awesome_rounded, l.cui_step4Title, l.cui_step4Desc,
          const [FF.blue, FF.teal]),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _stepCard(i + 1, steps[i])
                  .animate(delay: (110 * i + 200).ms)
                  .fadeIn(duration: 560.ms)
                  .slideX(begin: 0.12, curve: Curves.easeOut),
            ),
        ],
      ),
    );
  }

  Widget _stepCard(int n, _Step s) {
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: s.colors),
              boxShadow: [
                BoxShadow(
                    color: s.colors.first.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 1),
              ],
            ),
            child: Icon(s.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('0$n',
                        style: TextStyle(
                            color: s.colors.first,
                            fontSize: 13,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Text(s.title,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(s.desc,
                    style: const TextStyle(
                        color: FF.muted, fontSize: 12.5, height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
      child: Center(
        child: gradientText(AppLocalizations.of(context).cui_footer,
                size: 14, gradient: FF.brandGradient)
            .animate(delay: 700.ms)
            .fadeIn(duration: 800.ms),
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String title;
  final String desc;
  final List<Color> colors;
  const _Step(this.icon, this.title, this.desc, this.colors);
}

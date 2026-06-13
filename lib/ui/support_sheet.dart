import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/support_store.dart';
import '../screens/login_screen.dart';
import '../theme.dart';
import 'kit.dart';

/// 应援打投仪式（已接真后端：真扣鹰币 + 真落榜）。
/// 一处实现、详情页 / 应援榜共用：选鹰币档 → 调后端送礼 → 庆祝弹层（喂服务端结果）。
/// 未登录先去登录；鹰币不足提示去充值。
Future<void> openSupportSheet(BuildContext context, AiCharacter c) async {
  // 未登录：先去登录，登录后不自动续投（让用户重新决策档位）。
  if (!auth.loggedIn) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return;
  }
  supportStore.setMyName(auth.profile?.displayName);
  final tier = await showModalBottomSheet<_Tier>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _SupportSheet(character: c),
  );
  if (tier == null || !context.mounted) return;
  HapticFeedback.mediumImpact();

  // 选完档：转圈遮罩 → 真送礼 → 关遮罩 → 成功庆祝 / 失败提示。
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: FF.gold),
    ),
  );

  SupportResult? result;
  String? errMsg;
  try {
    result = await supportStore.support(c, tier.coins);
  } on ApiException catch (e) {
    errMsg = e.message;
  } catch (_) {
    errMsg = '应援失败，请稍后再试';
  }

  if (!context.mounted) return;
  // 关掉转圈遮罩。
  Navigator.of(context, rootNavigator: true).pop();
  if (!context.mounted) return;

  if (result != null) {
    await auth.refresh(); // 同步最新鹰币余额（送礼后真扣了币）。
    if (!context.mounted) return;
    await _showCelebration(context, c, tier, result);
    return;
  }

  // 失败：鹰币不足单独提示「去充值」，其它错误普通提示。
  final insufficient = (errMsg ?? '').contains('鹰币不足');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(insufficient ? '鹰币不足，去充值~' : (errMsg ?? '应援失败')),
      backgroundColor: const Color(0xFF2A2233),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ───────────────────────── 鹰币档位（饭圈梗）─────────────────────────
class _Tier {
  final int coins;
  final String label;
  final String meaning;
  const _Tier(this.coins, this.label, this.meaning);
}

List<_Tier> _tiersFor(AppLocalizations l) => <_Tier>[
      _Tier(66, l.ss_tier66_label, l.ss_tier66_meaning),
      _Tier(188, l.ss_tier188_label, l.ss_tier188_meaning),
      _Tier(520, l.ss_tier520_label, l.ss_tier520_meaning),
      _Tier(1314, l.ss_tier1314_label, l.ss_tier1314_meaning),
      _Tier(3344, l.ss_tier3344_label, l.ss_tier3344_meaning),
      _Tier(9999, l.ss_tier9999_label, l.ss_tier9999_meaning),
    ];

// ───────────────────────── 选档底部弹层 ─────────────────────────
class _SupportSheet extends StatelessWidget {
  final AiCharacter character;
  const _SupportSheet({required this.character});

  @override
  Widget build(BuildContext context) {
    final c = character;
    final bottom = MediaQuery.of(context).padding.bottom;
    final bal = auth.profile?.balance;
    final l = AppLocalizations.of(context);
    final tiers = _tiersFor(l);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.aura.first.withValues(alpha: 0.20),
            FF.panel,
            FF.panel,
          ],
          stops: const [0, 0.32, 1],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: c.aura.first.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: c.aura.first.withValues(alpha: 0.28), blurRadius: 34),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _avatar(c, 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.ss_callForFmt(c.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(l.ss_subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: FF.muted.withValues(alpha: 0.85),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int r = 0; r < tiers.length; r += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: _tierCard(context, tiers[r], c, r)),
                  const SizedBox(width: 10),
                  Expanded(child: _tierCard(context, tiers[r + 1], c, r + 1)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          if (bal != null)
            Text(l.ss_balanceFmt(bal.round().toString()),
                style: const TextStyle(
                    color: FF.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l.ss_localNote,
              style: TextStyle(
                  color: FF.dim.withValues(alpha: 0.85), fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _tierCard(BuildContext context, _Tier t, AiCharacter c, int i) {
    return Bounce(
      onTap: () => Navigator.of(context).pop(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              c.aura.first.withValues(alpha: 0.16),
              c.aura.last.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.aura.first.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: FF.gold, size: 16),
                const SizedBox(width: 3),
                Text('${t.coins}',
                    style: const TextStyle(
                        color: FF.brightGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(width: 2),
                Text(AppLocalizations.of(context).sheets_coinsShort,
                    style: const TextStyle(
                        color: FF.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.label,
                style: const TextStyle(
                    color: FF.text, fontSize: 13.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 1),
            Text(t.meaning,
                style: const TextStyle(color: FF.dim, fontSize: 10.5)),
          ],
        ),
      )
          .animate(delay: (60 * i + 80).ms)
          .fadeIn(duration: 360.ms)
          .slideY(begin: 0.16, curve: Curves.easeOut),
    );
  }

  Widget _avatar(AiCharacter c, double d) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCC0B0913),
        border: Border.all(color: c.aura.first.withValues(alpha: 0.7), width: 2),
        boxShadow: [
          BoxShadow(color: c.aura.first.withValues(alpha: 0.4), blurRadius: 16),
        ],
      ),
      child: ClipOval(
        child: c.avatarHead == null
            ? Center(child: _initial(c, d * 0.42))
            : Image.asset(c.avatarHead!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(child: _initial(c, d * 0.42))),
      ),
    );
  }

  Widget _initial(AiCharacter c, double size) {
    return ShaderMask(
      shaderCallback: (r) => LinearGradient(colors: c.aura).createShader(r),
      child: Text(c.emoji,
          style: TextStyle(
              color: Colors.white, fontSize: size, fontWeight: FontWeight.w900)),
    );
  }
}

// ───────────────────────── 庆祝弹层 ─────────────────────────
Future<void> _showCelebration(
    BuildContext context, AiCharacter c, _Tier t, SupportResult r) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppLocalizations.of(context).ss_celebTitle,
    barrierColor: Colors.black.withValues(alpha: 0.64),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => _Celebration(character: c, tier: t, result: r),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _Celebration extends StatefulWidget {
  final AiCharacter character;
  final _Tier tier;
  final SupportResult result;
  const _Celebration(
      {required this.character, required this.tier, required this.result});

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration> {
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    // 庆祝停留够久（足一点），到点慢慢退场。
    _auto = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final t = widget.tier;
    final r = widget.result;
    final tier = levelTier(r.myLevel);
    final nowPct = (r.newProgress * 100).round();
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 爆发徽章 + 旋转光环 + 飞溅星点
              SizedBox(
                width: 168,
                height: 168,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                            colors: [c.aura.first, c.aura.last, c.aura.first]),
                      ),
                    )
                        .animate(onPlay: (a) => a.repeat())
                        .rotate(duration: 4200.ms)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scaleXY(begin: 0.5, curve: Curves.easeOut),
                    ..._sparkles(c),
                    Container(
                      width: 118,
                      height: 118,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xF21A1622),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: c.aura.first.withValues(alpha: 0.6),
                              blurRadius: 40,
                              spreadRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.local_fire_department_rounded,
                          color: FF.gold, size: 56),
                    )
                        .animate()
                        .scale(
                            begin: const Offset(0.3, 0.3),
                            end: const Offset(1, 1),
                            duration: 560.ms,
                            curve: Curves.easeOutBack)
                        .then()
                        .shake(hz: 3, rotation: 0.02, duration: 520.ms),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              gradientText(l.ss_celebTitle, size: 30, gradient: FF.goldGradient)
                  .animate(delay: 260.ms)
                  .fadeIn(duration: 460.ms)
                  .slideY(begin: 0.4, curve: Curves.easeOut),
              const SizedBox(height: 8),
              Text(l.ss_forFmt(c.name, t.label),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: FF.text, fontSize: 15, fontWeight: FontWeight.w800))
                  .animate(delay: 360.ms)
                  .fadeIn(duration: 440.ms),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: FF.goldGradient,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                        color: FF.gold.withValues(alpha: 0.4), blurRadius: 20),
                  ],
                ),
                child: Text(l.ss_pillCoinsFmt(t.coins.toString()),
                    style: const TextStyle(
                        color: Color(0xFF3A2700),
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
              )
                  .animate(delay: 440.ms)
                  .fadeIn(duration: 440.ms)
                  .scaleXY(begin: 0.7, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              _infoLine(Icons.trending_up_rounded, c.aura.first,
                  '出道进度 · 现 $nowPct%'),
              const SizedBox(height: 8),
              _infoLine(
                  r.isKing
                      ? Icons.workspace_premium_rounded
                      : Icons.favorite_rounded,
                  r.isKing ? FF.brightGold : tier.color,
                  r.isKing
                      ? l.ss_kingFmt(r.myLevel.toString(), tierName(tier, l))
                      : l.ss_guardianFmt(r.myRank.toString(),
                          r.myLevel.toString(), tierName(tier, l))),
              const SizedBox(height: 22),
              Text(l.ss_tapToContinue,
                  style: TextStyle(
                      color: FF.dim.withValues(alpha: 0.8), fontSize: 11))
                  .animate(delay: 900.ms)
                  .fadeIn(duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 7),
        Flexible(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ],
    )
        .animate(delay: 560.ms)
        .fadeIn(duration: 460.ms)
        .slideY(begin: 0.3, curve: Curves.easeOut);
  }

  // 从中心向外飞溅的小星点
  List<Widget> _sparkles(AiCharacter c) {
    final rnd = math.Random(7);
    return List.generate(10, (i) {
      final ang = (i / 10) * 2 * math.pi;
      final dist = 64 + rnd.nextDouble() * 26;
      final dx = math.cos(ang) * dist;
      final dy = math.sin(ang) * dist;
      final col = i.isEven ? c.aura.first : FF.gold;
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: col,
          boxShadow: [BoxShadow(color: col, blurRadius: 8)],
        ),
      )
          .animate(delay: (40 * i + 200).ms)
          .move(
              begin: Offset.zero,
              end: Offset(dx, dy),
              duration: 760.ms,
              curve: Curves.easeOut)
          .fadeIn(duration: 200.ms)
          .then(delay: 240.ms)
          .fadeOut(duration: 520.ms);
    });
  }
}

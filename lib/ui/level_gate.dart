import 'package:flutter/material.dart';

import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/level_curve.dart';
import '../models/privilege.dart';
import '../screens/login_screen.dart';
import '../screens/me_subpages.dart';
import '../theme.dart';

/// 级别门槛检查：够级返回 true；不够 → 弹升级引导并返回 false。
/// 用法：`if (await requireLevel(context, Feature.videoCall)) { ...进入功能... }`
/// 未登录会先引导登录（登录本身不代表够级，登录后仍按级别判）。
Future<bool> requireLevel(BuildContext context, Feature feature) async {
  if (!auth.loggedIn) {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (ok != true || !context.mounted) return false;
    await auth.refreshLevel(force: true);
  }
  if (Privilege.canUse(feature, auth.level)) return true;
  if (!context.mounted) return false;
  await showLevelUpsellSheet(context, feature);
  return false;
}

/// 升级引导弹层（暗色·仪式感）：🔒 功能锁 + 当前/目标级别 + 「再充 $X 升到 VN」+ 去充值。
Future<void> showLevelUpsellSheet(BuildContext context, Feature feature) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _LevelUpsellSheet(feature: feature),
  );
}

class _LevelUpsellSheet extends StatelessWidget {
  final Feature feature;
  const _LevelUpsellSheet({required this.feature});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final spec = Privilege.spec(feature);
    final myLevel = auth.level;
    final reqLevel = spec.level;
    final myTier = levelTier(myLevel);
    final reqTier = levelTier(reqLevel);
    final gapCoins =
        (levelFloorCoins(reqLevel) - auth.cumulativePaidCoins).clamp(0, 1 << 62);
    final gapUsd = gapCoins / 100.0;
    final gapLabel = gapUsd == gapUsd.roundToDouble()
        ? '\$${gapUsd.toStringAsFixed(0)}'
        : '\$${gapUsd.toStringAsFixed(2)}';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xF21A1622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          22, 14, 22, 22 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(999)),
          ),
          // 锁徽章（目标段位渐变 + 发光）
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: reqTier.gradient,
              boxShadow: [
                BoxShadow(
                    color: reqTier.color.withValues(alpha: 0.5), blurRadius: 22),
              ],
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 16),
          Text(l.lg_needLevelFmt(spec.name, reqLevel.toString()),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(spec.blurb,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13)),
          const SizedBox(height: 18),
          // 当前 → 目标 级别
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _levelChip(myLevel, myTier, dim: true),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded,
                    color: Colors.white38, size: 20),
              ),
              _levelChip(reqLevel, reqTier, dim: false),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.lg_topUpFmt(gapLabel, reqLevel.toString()),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: FF.brandGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(color: FF.hot.withValues(alpha: 0.3), blurRadius: 22),
                ],
              ),
              child: Text(l.lg_btnTopUp,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.lg_btnLater,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _levelChip(int level, LevelTier tier, {required bool dim}) {
    return Builder(builder: (context) {
      final l = AppLocalizations.of(context);
      return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: dim ? null : tier.gradient,
        color: dim ? Colors.white.withValues(alpha: 0.08) : null,
        border: dim ? Border.all(color: Colors.white24) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('V$level',
              style: TextStyle(
                  color: dim ? Colors.white70 : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 5),
          Text(tierName(tier, l),
              style: TextStyle(
                  color: dim ? Colors.white54 : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
    });
  }
}

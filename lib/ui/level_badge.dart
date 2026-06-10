import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';

/// V 级别徽章：段位渐变填充 + 发光，「V12 · 入门」。
/// 全 App 复用（钱包余额卡 / 我的资料卡 / 身份面板），段位颜色随级别升。
/// compact=true 只显 V{n}（小，挂头像/昵称旁）；false 显 V{n} + 段位名。
class LevelBadge extends StatelessWidget {
  final int level;
  final bool compact;
  const LevelBadge(this.level, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final tier = levelTier(level);
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12, vertical: compact ? 5 : 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: tier.gradient,
        boxShadow: [
          BoxShadow(
              color: tier.color.withValues(alpha: 0.5),
              blurRadius: compact ? 8 : 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: compact ? 12 : 15),
          SizedBox(width: compact ? 3 : 4),
          Text('V$level',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 12 : 14,
                  height: 1,
                  fontWeight: FontWeight.w900)),
          if (!compact) ...[
            const SizedBox(width: 5),
            Text(tierName(tier, l),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/support_store.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'character_board_screen.dart';
import 'character_detail_screen.dart' show LevelBadge;

/// 角色机会榜（AI 互动 L1 / v0 全 mock）。
/// 两栏切换：
///  ①「角色榜」= 角色按应援热度排名（攒满就开机出道），可按 女宝/男宝 筛；
///  ②「榜一大哥」= 全站应援者按累计鹰币排名（面子系统 V 级别），可按财力段位筛。
/// 点角色 → 进 L2「该角色应援榜」(CharacterBoardScreen)，再点头像才进 L3 简介。
/// 俗气带劲的排行榜藏二级，一级落地页保持干净。纯本地数据、不计费。
class AiRankingScreen extends StatefulWidget {
  final List<AiCharacter> characters;
  const AiRankingScreen({super.key, required this.characters});

  @override
  State<AiRankingScreen> createState() => _AiRankingScreenState();
}

class _AiRankingScreenState extends State<AiRankingScreen> {
  int _tab = 0; // 0 = 角色榜, 1 = 榜一大哥
  int _gender = 0; // 0 全部 / 1 女宝 / 2 男宝
  int _tier = 0; // 0 全部 / 1 巨鳄(≥50) / 2 封神(≥70) / 3 传奇(≥90)

  // 角色按出道热度降序（含「我」实时打投增量）
  List<AiCharacter> get _ranked => [...widget.characters]
    ..sort((a, b) =>
        supportStore.progressFor(b).compareTo(supportStore.progressFor(a)));

  // 全站应援者：把每个角色的应援榜（含「我」）摊平 + 记住应援对象，按鹰币降序
  List<_Fan> get _fans {
    final out = <_Fan>[];
    for (final c in widget.characters) {
      for (final s in supportStore.boardFor(c)) {
        out.add(_Fan(s, c));
      }
    }
    out.sort((a, b) => b.s.coins.compareTo(a.s.coins));
    return out;
  }

  List<AiCharacter> get _rankedFiltered => switch (_gender) {
        1 => _ranked.where((c) => c.female).toList(),
        2 => _ranked.where((c) => !c.female).toList(),
        _ => _ranked,
      };

  List<_Fan> get _fansFiltered {
    final min = switch (_tier) { 1 => 50, 2 => 70, 3 => 90, _ => 0 };
    return min == 0 ? _fans : _fans.where((f) => f.s.level >= min).toList();
  }

  void _openBoard(AiCharacter c) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CharacterBoardScreen(character: c),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _header(),
                _toggle(),
                const SizedBox(height: 10),
                _filterRow(),
                const SizedBox(height: 4),
                Expanded(
                  child: ListenableBuilder(
                    listenable: supportStore,
                    builder: (_, _) =>
                        _tab == 0 ? _arenaList() : _tycoonList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── 顶部：返回 + 标题 ─────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Row(
        children: [
          Bounce(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: FF.text, size: 20),
            ),
          ),
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              gradientText(AppLocalizations.of(context).air_title,
                  size: 22, gradient: FF.goldGradient),
              const SizedBox(height: 2),
              Text(AppLocalizations.of(context).air_sub,
                  style: const TextStyle(
                      color: FF.dim,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.emoji_events_rounded, color: FF.gold, size: 26),
        ],
      ),
    );
  }

  // ───────── 切换：角色榜 / 榜一大哥 ─────────
  Widget _toggle() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: Glass(
        radius: 16,
        blur: 18,
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            _seg(0, l.air_segCharRank, Icons.local_fire_department_rounded),
            _seg(1, l.air_segKingRank, Icons.workspace_premium_rounded),
          ],
        ),
      ),
    );
  }

  Widget _seg(int idx, String label, IconData icon) {
    final on = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: on ? FF.goldGradient : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: on
                ? [BoxShadow(color: FF.gold.withValues(alpha: 0.32), blurRadius: 16)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16, color: on ? const Color(0xFF3A2700) : FF.dim),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: on ? const Color(0xFF3A2700) : FF.muted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── 分类筛选条（按当前栏切换：性别 / 财力段位）─────────
  Widget _filterRow() {
    final l = AppLocalizations.of(context);
    final List<Widget> chips;
    if (_tab == 0) {
      chips = [
        _chip(l.air_chipAll, _gender == 0,
            () => setState(() => _gender = 0), FF.blue),
        _chip(l.air_chipFemale, _gender == 1,
            () => setState(() => _gender = 1), FF.hot),
        _chip(l.air_chipMale, _gender == 2,
            () => setState(() => _gender = 2), FF.teal),
      ];
    } else {
      chips = [
        _chip(l.air_chipAll, _tier == 0,
            () => setState(() => _tier = 0), FF.blue),
        _chip(l.air_chipTycoon, _tier == 1,
            () => setState(() => _tier = 1), FF.purple),
        _chip(l.air_chipDeity, _tier == 2,
            () => setState(() => _tier = 2), FF.gold),
        _chip(l.air_chipLegend, _tier == 3,
            () => setState(() => _tier = 3), FF.brightGold),
      ];
    }
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 9),
            chips[i],
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool on, VoidCallback onTap, Color accent) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: on ? accent.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: on
                  ? accent.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.10)),
          boxShadow: on
              ? [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 12)]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                color: on ? accent : FF.dim,
                fontSize: 13,
                fontWeight: FontWeight.w900)),
      ),
    );
  }

  // ───────────────── 角色榜（出道打投榜）─────────────────
  Widget _arenaList() {
    final list = _rankedFiltered;
    if (list.isEmpty) {
      return _emptyHint(AppLocalizations.of(context).air_emptyChar);
    }
    final leader = list.first;
    final rest = list.skip(1).toList();
    return ListView(
      key: ValueKey('arena$_gender'),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
      children: [
        _leaderCard(leader)
            .animate()
            .fadeIn(duration: 700.ms)
            .scaleXY(begin: 0.92, curve: Curves.easeOutBack),
        const SizedBox(height: 14),
        for (int i = 0; i < rest.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _arenaRow(i + 2, rest[i])
                .animate(delay: (70 * i + 120).ms)
                .fadeIn(duration: 460.ms)
                .slideX(begin: 0.12, curve: Curves.easeOut),
          ),
      ],
    );
  }

  // #1 领跑者：大卡 + 出道进度 + 金光庆祝
  Widget _leaderCard(AiCharacter c) {
    final l = AppLocalizations.of(context);
    final progress = supportStore.progressFor(c);
    final pct = (progress * 100).round();
    final debuted = progress >= 1.0;
    final board = supportStore.boardFor(c);
    final king = board.isNotEmpty ? board.first : null;
    return Bounce(
      onTap: () => _openBoard(c),
      child: Glass(
        radius: 22,
        border: FF.gold.withValues(alpha: 0.5),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            Row(
              children: [
                _avatar(c, 72, ring: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              color: FF.gold, size: 18),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: FF.goldGradient,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                                debuted ? l.air_debuted : l.air_leading,
                                style: const TextStyle(
                                    color: Color(0xFF3A2700),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.text,
                              fontSize: 21,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(c.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: FF.dim, size: 24),
              ],
            ),
            const SizedBox(height: 14),
            _voteBar(progress, c.aura, tall: true),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    color: c.aura.first, size: 15),
                const SizedBox(width: 4),
                Text(l.air_heatFmt(pct.toString()),
                    style: TextStyle(
                        color: c.aura.first,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(
                    debuted
                        ? l.air_doneShoot
                        : l.air_toGoFmt((100 - pct).toString()),
                    style: const TextStyle(
                        color: FF.dim,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: FF.gold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: FF.gold.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: FF.gold, size: 16),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                        l.air_supportKingFmt(
                            king?.name ?? l.air_emptyKingPlaceholder),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800)),
                  ),
                  Text(l.sheets_coinsFmt(fmtCoins(king?.coins ?? 0)),
                      style: const TextStyle(
                          color: FF.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(onPlay: (ctrl) => ctrl.repeat())
          .shimmer(
              duration: 2600.ms,
              delay: 900.ms,
              color: FF.gold.withValues(alpha: 0.18)),
    );
  }

  // #2+ 角色行
  Widget _arenaRow(int rank, AiCharacter c) {
    final progress = supportStore.progressFor(c);
    final pct = (progress * 100).round();
    return Bounce(
      onTap: () => _openBoard(c),
      child: Glass(
        radius: 16,
        blur: 16,
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        child: Row(
          children: [
            _rankNum(rank),
            const SizedBox(width: 8),
            _avatar(c, 48),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: FF.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 7),
                      Text(c.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.dim,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _voteBar(progress, c.aura),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$pct%',
                    style: TextStyle(
                        color: c.aura.first,
                        fontSize: 15,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(fmtCoins(supportStore.totalCoinsFor(c)),
                    style: const TextStyle(
                        color: FF.dim,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, color: FF.dim, size: 20),
          ],
        ),
      ),
    );
  }

  // ───────────────── 榜一大哥（全站富豪榜）─────────────────
  Widget _tycoonList() {
    final list = _fansFiltered;
    if (list.isEmpty) {
      return _emptyHint(AppLocalizations.of(context).air_emptyKing);
    }
    final king = list.first;
    final rest = list.skip(1).toList();
    return ListView(
      key: ValueKey('tycoon$_tier'),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
      children: [
        _kingCard(king)
            .animate()
            .fadeIn(duration: 700.ms)
            .scaleXY(begin: 0.92, curve: Curves.easeOutBack),
        const SizedBox(height: 14),
        for (int i = 0; i < rest.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _fanRow(i + 2, rest[i])
                .animate(delay: (60 * i + 120).ms)
                .fadeIn(duration: 440.ms)
                .slideX(begin: 0.12, curve: Curves.easeOut),
          ),
      ],
    );
  }

  // 全站榜一大哥：金色庆祝大卡
  Widget _kingCard(_Fan f) {
    final tier = levelTier(f.s.level);
    final l = AppLocalizations.of(context);
    return Bounce(
      onTap: () => _openBoard(f.c),
      child: Glass(
        radius: 22,
        border: FF.gold.withValues(alpha: 0.55),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: FF.gold, size: 22),
                const SizedBox(width: 7),
                gradientText(l.air_globalKing,
                    size: 17, gradient: FF.goldGradient),
              ],
            ),
            const SizedBox(height: 14),
            LevelBadge(level: f.s.level, scale: 1.4),
            const SizedBox(height: 10),
            Text(f.s.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: FF.text,
                    fontSize: 26,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(l.air_tierBackFmt(tierName(tier, l), f.c.name),
                style: TextStyle(
                    color: tier.color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: FF.goldGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(color: FF.gold.withValues(alpha: 0.38), blurRadius: 22),
                ],
              ),
              child: Text(l.sheets_coinsFmt(fmtCoins(f.s.coins)),
                  style: const TextStyle(
                      color: Color(0xFF3A2700),
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      )
          .animate(onPlay: (ctrl) => ctrl.repeat())
          .shimmer(
              duration: 2600.ms,
              delay: 900.ms,
              color: FF.gold.withValues(alpha: 0.22)),
    );
  }

  // #2+ 富豪行
  Widget _fanRow(int rank, _Fan f) {
    final tier = levelTier(f.s.level);
    return Bounce(
      onTap: () => _openBoard(f.c),
      child: Glass(
        radius: 16,
        blur: 16,
        padding: const EdgeInsets.fromLTRB(10, 11, 14, 11),
        child: Row(
          children: [
            _rankNum(rank),
            const SizedBox(width: 8),
            LevelBadge(level: f.s.level, scale: 0.9),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: FF.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded,
                          color: f.c.aura.first, size: 11),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                            AppLocalizations.of(context)
                                .air_guardFmt(f.c.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: FF.dim,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(fmtCoins(f.s.coins),
                style: TextStyle(
                    color: tier.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // ───────────────── 通用零件 ─────────────────
  Widget _emptyHint(String t) {
    return Center(
      child: Text(t,
          style: const TextStyle(color: FF.dim, fontWeight: FontWeight.w700)),
    );
  }

  Widget _rankNum(int rank) {
    final medal = switch (rank) {
      2 => const Color(0xFFE6E6F0),
      3 => const Color(0xFFD8A26B),
      _ => FF.dim,
    };
    return SizedBox(
      width: 26,
      child: Text('$rank',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: medal,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic)),
    );
  }

  Widget _avatar(AiCharacter c, double d, {bool ring = false}) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCC0B0913),
        border: Border.all(
            color: ring
                ? FF.gold.withValues(alpha: 0.7)
                : c.aura.first.withValues(alpha: 0.5),
            width: ring ? 2 : 1.4),
        boxShadow: [
          BoxShadow(
              color: (ring ? FF.gold : c.aura.first).withValues(alpha: 0.35),
              blurRadius: ring ? 20 : 12),
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
              color: Colors.white,
              fontSize: size,
              fontWeight: FontWeight.w900,
              height: 1.0)),
    );
  }

  Widget _voteBar(double value, List<Color> aura, {bool tall = false}) {
    final v = value.clamp(0.0, 1.0);
    final h = tall ? 9.0 : 6.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: h, color: Colors.white.withValues(alpha: 0.10)),
          FractionallySizedBox(
            widthFactor: v == 0 ? 0.001 : v,
            child: Container(
              height: h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: aura),
                boxShadow: [
                  BoxShadow(color: aura.first.withValues(alpha: 0.5), blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 一条全站应援者 = 支持者 + 他应援的角色
class _Fan {
  final Supporter s;
  final AiCharacter c;
  const _Fan(this.s, this.c);
}

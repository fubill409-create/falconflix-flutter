import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../theme.dart';
import '../ui/kit.dart';
import '../ui/support_sheet.dart';
import '../widgets/ugc_actions.dart';
import 'character_detail_screen.dart';

/// 角色应援榜（AI 互动 L2 · 已接真后端）。
/// 从「角色机会榜」点一个角色进来，看谁在为 TA 应援打投（榜一大哥 + 富豪榜）。
/// 顶部头像可点 → 才进角色个人简介（L3）。真后端：真扣鹰币、真落榜。
class CharacterBoardScreen extends StatefulWidget {
  final AiCharacter character;
  const CharacterBoardScreen({super.key, required this.character});

  @override
  State<CharacterBoardScreen> createState() => _CharacterBoardScreenState();
}

class _CharacterBoardScreenState extends State<CharacterBoardScreen> {
  List<_Backer> _board = const [];
  double _progress = 0.0;
  int _total = 0; // 该角色累计应援鹰币（榜单之和）
  int _myRank = 0; // 我在该角色榜名次（0 = 没上榜）
  int _myTotal = 0; // 我对该角色累计应援
  bool _loading = true;
  Object? _err;

  AiCharacter get _c => widget.character;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final m = await Api.giftCharBoard(_c.id);
      final data = (m['data'] as List?) ?? const [];
      final backers = <_Backer>[
        for (final r in data.whereType<Map>())
          _Backer(
            Supporter(
              _displayName(r['name']),
              (r['total'] as num?)?.toInt() ?? 0,
            ),
            (r['userId'] ?? '').toString(),
          ),
      ];
      if (!mounted) return;
      setState(() {
        _board = backers;
        _total = backers.fold(0, (s, e) => s + e.s.coins);
        _myRank = (m['myRank'] as num?)?.toInt() ?? 0;
        _myTotal = (m['myTotal'] as num?)?.toInt() ?? 0;
        _progress = (_c.voteProgress).clamp(0.0, 1.0); // 进度由角色清单给（榜接口不回进度）
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e;
        _loading = false;
      });
    }
  }

  // 服务端用户名可能为空 / UUID，空则用「鹰眼用户」。
  static String _displayName(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    return s.isEmpty ? '鹰眼用户' : s;
  }

  void _openDetail() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CharacterDetailScreen(character: _c),
    ));
  }

  // 应援完回来刷新榜单。
  Future<void> _support() async {
    await openSupportSheet(context, _c);
    if (mounted) _load();
  }

  // 是否在该应援者行展示「举报/拉黑」入口：有 userId 且不是自己。
  bool _canModerate(String userId) {
    if (userId.isEmpty) return false;
    final me = auth.profile?.id?.toString();
    return me == null || me != userId;
  }

  // 小「⋯」按钮 → 举报/拉黑（苹果 G1.2 UGC 合规）。
  Widget _moreBtn(_Backer b) {
    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      iconSize: 18,
      icon: const Icon(Icons.more_horiz, color: FF.dim),
      onPressed: () => showUgcSheet(
        context,
        contentType: 'profile',
        targetUserId: b.userId,
        targetName: b.s.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _header(context, c),
                Expanded(child: _body(context, c)),
              ],
            ),
          ),
          // 底部应援 CTA → 直接打开应援仪式
          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: GradientButton(
              label: AppLocalizations.of(context).cb_goSupport,
              icon: Icons.local_fire_department_rounded,
              gradient: LinearGradient(colors: c.aura),
              glow: c.aura.first,
              shimmer: true,
              onTap: _support,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AiCharacter c) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: FF.gold));
    }
    if (_err != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).cb_emptyBackers,
                style: const TextStyle(
                    color: FF.dim, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: c.aura.first.withValues(alpha: 0.4)),
                ),
                child: Text('重试',
                    style: TextStyle(
                        color: c.aura.first,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
    }

    final hasBoard = _board.isNotEmpty;
    final king = hasBoard ? _board.first : null;
    final rest = hasBoard ? _board.skip(1).toList() : <_Backer>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 110),
      children: [
        _hero(context, c)
            .animate()
            .fadeIn(duration: 600.ms)
            .scaleXY(begin: 0.94, curve: Curves.easeOutBack),
        const SizedBox(height: 18),
        _sectionTitle(
            AppLocalizations.of(context).cb_sectionSupport, c.aura.first),
        const SizedBox(height: 12),
        if (!hasBoard)
          _empty(context, c)
        else ...[
          _kingCard(context, king!, c)
              .animate()
              .fadeIn(duration: 520.ms, delay: 120.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
          const SizedBox(height: 10),
          for (int i = 0; i < rest.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _fanRow(context, i + 2, rest[i])
                  .animate(delay: (70 * i + 200).ms)
                  .fadeIn(duration: 440.ms)
                  .slideX(begin: 0.12, curve: Curves.easeOut),
            ),
          if (_myRank > 0) ...[
            const SizedBox(height: 6),
            _myRankLine(context, c),
          ],
        ],
      ],
    );
  }

  Widget _header(BuildContext context, AiCharacter c) {
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
          gradientText(AppLocalizations.of(context).cb_titleSupportFmt(c.name),
              size: 20, gradient: LinearGradient(colors: c.aura)),
          const Spacer(),
          Icon(Icons.local_fire_department_rounded, color: c.aura.first, size: 24),
        ],
      ),
    );
  }

  // 顶部角色卡：头像可点 → 简介
  Widget _hero(BuildContext context, AiCharacter c) {
    final progress = _progress;
    final pct = (progress * 100).round();
    final debuted = progress >= 1.0;
    return Glass(
      radius: 22,
      border: c.aura.first.withValues(alpha: 0.45),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        children: [
          Row(
            children: [
              // 只有头像是进简介的入口（按用户预设：点头像才看个人简介）
              Bounce(
                onTap: _openDetail,
                child: Column(
                  children: [
                    _avatar(c, 78, ring: true),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: c.aura.first.withValues(alpha: 0.4)),
                      ),
                      child: Text(AppLocalizations.of(context).cb_seeBio,
                          style: TextStyle(
                              color: c.aura.first,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(c.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: FF.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _voteBar(progress, c.aura),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            color: c.aura.first, size: 14),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context).cb_pollHeatPct(pct.toString()),
                            style: TextStyle(
                                color: c.aura.first,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Text(debuted
                                ? AppLocalizations.of(context).cb_debuted
                                : AppLocalizations.of(context).cb_toDebutPct((100 - pct).toString()),
                            style: const TextStyle(
                                color: FF.dim,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: FF.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: FF.gold.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: FF.gold, size: 16),
                const SizedBox(width: 7),
                Text(AppLocalizations.of(context).cb_totalSupport,
                    style: const TextStyle(
                        color: FF.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(AppLocalizations.of(context).cb_coinsFmt(fmtCoins(_total)),
                    style: const TextStyle(
                        color: FF.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 我的名次条（上了榜才显示）
  Widget _myRankLine(BuildContext context, AiCharacter c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: c.aura.first.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.aura.first.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_rounded, color: c.aura.first, size: 16),
          const SizedBox(width: 8),
          Text('我的排名 · 第 $_myRank 位',
              style: const TextStyle(
                  color: FF.text, fontSize: 13, fontWeight: FontWeight.w900)),
          const Spacer(),
          Text(AppLocalizations.of(context).cb_coinsFmt(fmtCoins(_myTotal)),
              style: TextStyle(
                  color: c.aura.first,
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // 本剧榜一大哥（金色大卡）
  Widget _kingCard(BuildContext context, _Backer b, AiCharacter c) {
    final s = b.s;
    final tier = levelTier(s.level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FF.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FF.gold.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: FF.gold.withValues(alpha: 0.18), blurRadius: 24)],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: FF.gold, size: 26),
          const SizedBox(width: 10),
          LevelBadge(level: s.level),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: FF.goldGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(AppLocalizations.of(context).cb_topBacker,
                          style: const TextStyle(
                              color: Color(0xFF3A2700),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(tierName(tier, AppLocalizations.of(context)),
                    style: TextStyle(
                        color: tier.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).cb_coinsFmt(fmtCoins(s.coins)),
              style: const TextStyle(
                  color: FF.gold, fontSize: 14, fontWeight: FontWeight.w900)),
          if (_canModerate(b.userId)) ...[
            const SizedBox(width: 2),
            _moreBtn(b),
          ],
        ],
      ),
    )
        .animate(onPlay: (ctrl) => ctrl.repeat())
        .shimmer(
            duration: 2600.ms,
            delay: 900.ms,
            color: FF.gold.withValues(alpha: 0.18));
  }

  // 富豪行
  Widget _fanRow(BuildContext context, int rank, _Backer b) {
    final s = b.s;
    final tier = levelTier(s.level);
    return Glass(
      radius: 16,
      blur: 16,
      padding: const EdgeInsets.fromLTRB(10, 11, 14, 11),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text('$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: switch (rank) {
                      2 => const Color(0xFFE6E6F0),
                      3 => const Color(0xFFD8A26B),
                      _ => FF.dim,
                    },
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic)),
          ),
          const SizedBox(width: 8),
          LevelBadge(level: s.level, scale: 0.9),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 1),
                Text(tierName(tier, AppLocalizations.of(context)),
                    style: TextStyle(
                        color: tier.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(AppLocalizations.of(context).cb_coinsFmt(fmtCoins(s.coins)),
              style: TextStyle(
                  color: tier.color,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900)),
          if (_canModerate(b.userId)) ...[
            const SizedBox(width: 2),
            _moreBtn(b),
          ],
        ],
      ),
    );
  }

  // 空榜：邀请用户当第一位守护者
  Widget _empty(BuildContext context, AiCharacter c) {
    return Glass(
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
      child: Column(
        children: [
          Icon(Icons.local_fire_department_rounded,
              color: c.aura.first, size: 38),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).cb_emptyBackers,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: FF.text, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('成为 ${c.name} 的第一位守护者，登顶榜一大哥',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: FF.dim, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, Color accent) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        Text(t,
            style: const TextStyle(
                color: FF.text, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
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
                ? c.aura.first.withValues(alpha: 0.75)
                : c.aura.first.withValues(alpha: 0.5),
            width: ring ? 2.2 : 1.4),
        boxShadow: [
          BoxShadow(color: c.aura.first.withValues(alpha: 0.4), blurRadius: 18),
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

  Widget _voteBar(double value, List<Color> aura) {
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(height: 7, color: Colors.white.withValues(alpha: 0.10)),
          FractionallySizedBox(
            widthFactor: v == 0 ? 0.001 : v,
            child: Container(
              height: 7,
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

// 一条应援者 = 展示用 [Supporter] + 后端 userId（用于举报/拉黑，可能为空）。
class _Backer {
  final Supporter s;
  final String userId;
  const _Backer(this.s, this.userId);
}

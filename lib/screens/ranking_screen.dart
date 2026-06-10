import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/short_drama.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import 'detail_screen.dart';

/// 榜单页（剧场二级）。按 Codex app-subflows 的 Search & Rank 设计：
/// 分类 chip + #1 rank-hero 横卡 + 三列海报网格（aspect 3/4）。按热度排序。
class RankingScreen extends StatefulWidget {
  final List<ShortDrama> items;
  const RankingScreen({super.key, required this.items});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _cat = 0;

  List<String> _cats(AppLocalizations l) => [
        l.air_chipAll,
        l.home_chipAiTheater,
        l.rk_chipRomance,
        l.rk_chipUrban,
        l.rk_chipFinished,
      ];

  int _heat(ShortDrama d) => d.playCount + d.likeCount;

  List<ShortDrama> get _ranked {
    Iterable<ShortDrama> list = widget.items;
    if (_cat != 0) {
      final cats = _cats(AppLocalizations.of(context));
      final key = cats[_cat];
      list = list.where((d) =>
          d.categoryName.contains(key) ||
          d.labels.any((l) => l.contains(key)));
    }
    final out = list.toList()..sort((a, b) => _heat(b).compareTo(_heat(a)));
    return out;
  }

  void _open(ShortDrama d) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          shortId: d.id,
          title: d.name,
          cover: d.image,
          intro: d.introduce,
          price: d.price,
          labels: d.labels,
          plays: _heat(d),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final ranked = _ranked;
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.pageBg2, p.pageBg],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _topbar(p),
              _chips(p),
              Expanded(
                child: ranked.isEmpty
                    ? Center(
                        child: Text(
                            AppLocalizations.of(context).rk_emptyCat,
                            style:
                                TextStyle(color: p.textMuted, fontSize: 13)),
                      )
                    : _list(p, ranked),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topbar(Pal p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.day ? Colors.white : const Color(0x18FFFFFF),
                border: Border.all(color: p.line),
              ),
              child: Icon(Icons.arrow_back_rounded, color: p.text, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).rk_hotTitle,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 20,
                      height: 1.05,
                      fontWeight: FontWeight.w900)),
              Text(AppLocalizations.of(context).rk_hotSub,
                  style: TextStyle(
                      color: p.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chips(Pal p) {
    final cats = _cats(AppLocalizations.of(context));
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final active = i == _cat;
          return GestureDetector(
            onTap: () => setState(() => _cat = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                gradient: active ? FF.brandGradient : null,
                color: active ? null : p.chipBg,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: active ? Colors.transparent : p.line),
              ),
              child: Text(cats[i],
                  style: TextStyle(
                      color: active ? Colors.white : p.chipText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ),
          );
        },
      ),
    );
  }

  Widget _list(Pal p, List<ShortDrama> ranked) {
    final hero = ranked.first;
    final rest = ranked.skip(1).toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 16),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => _open(hero),
              child: _RankHero(p: p, item: hero, plays: _heat(hero)),
            ).animate().fadeIn(duration: 460.ms).slideY(
                begin: 0.06, curve: Curves.easeOut),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 112),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.54,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => GestureDetector(
                onTap: () => _open(rest[i]),
                child: _RankPoster(p: p, rank: i + 2, item: rest[i]),
              )
                  .animate(delay: (35 * i).ms)
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOut),
              childCount: rest.length,
            ),
          ),
        ),
      ],
    );
  }
}

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

/// #1 rank-hero 横卡（Codex .rank-hero：92px 缩略图 + #1 标 + 标题 + 热度）。
class _RankHero extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  final int plays;
  const _RankHero({required this.p, required this.item, required this.plays});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.day ? Colors.white : const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.line),
        boxShadow: p.day
            ? const [
                BoxShadow(
                    color: Color(0x14251B38),
                    blurRadius: 22,
                    offset: Offset(0, 12)),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 92, height: 92, child: _poster(item.image)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: FF.brandGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(AppLocalizations.of(context).rk_top1Today,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 9),
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        height: 1.05,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        color: FF.hot, size: 15),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                          AppLocalizations.of(context)
                              .rk_heatFmt(_fmt(plays)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 海报网格卡（rank #2+）：3/4 海报 + 左上排名角标 + 标题/分类。与搜索结果同款。
class _RankPoster extends StatelessWidget {
  final Pal p;
  final int rank;
  final ShortDrama item;
  const _RankPoster(
      {required this.p, required this.rank, required this.item});

  @override
  Widget build(BuildContext context) {
    final top = rank <= 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                item.image.isEmpty
                    ? Container(color: const Color(0xFF201A15))
                    : _poster(item.image),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: top ? FF.brandGradient : null,
                      color: top ? null : const Color(0xB3000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$rank',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: p.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(
            item.categoryName.isEmpty
                ? (item.labels.isNotEmpty
                    ? item.labels.first
                    : AppLocalizations.of(context).theater_labelShort)
                : item.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: p.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

Widget _poster(String url) {
  if (url.isEmpty) return Container(color: const Color(0xFF201A15));
  return CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    placeholder: (_, _) => Container(color: const Color(0xFF201A15)),
    errorWidget: (_, _, _) => Container(color: const Color(0xFF201A15)),
  );
}

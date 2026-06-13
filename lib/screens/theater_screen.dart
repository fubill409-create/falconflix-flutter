import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../app_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/short_drama.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import 'detail_screen.dart';
import 'ranking_screen.dart';
import 'search_screen.dart';

/// 剧场 · 浏览/目录页。严格按 Codex 设计稿 theater.html/css 1:1。
/// 工具页 → 日夜自适应（白天亮色 / 夜间暗色）；海报类图上压暗字。
class TheaterScreen extends StatefulWidget {
  const TheaterScreen({super.key});

  @override
  State<TheaterScreen> createState() => _TheaterScreenState();
}

class _TheaterScreenState extends State<TheaterScreen> {
  List<ShortDrama> _items = [];
  bool _loading = true;
  String? _error;

  /// 分类标签:从真实剧目的 categoryName 动态聚合(去重),首项固定"全部"。
  /// 不再硬编码——这样标签就是后台真分类,点了真能筛(零后端依赖)。
  List<String> _genresFor(BuildContext context) {
    final all = AppLocalizations.of(context).theater_genreAll;
    final cats = <String>{};
    for (final d in _items) {
      final c = d.categoryName.trim();
      if (c.isNotEmpty) cats.add(c);
    }
    return [all, ...cats];
  }
  int _genre = 0;

  /// 按当前选中分类过滤后的剧目(_genre==0 即"全部"=不过滤)。
  List<ShortDrama> get _filtered {
    if (_genre == 0) return _items;
    final genres = _genresFor(context);
    if (_genre >= genres.length) return _items;
    final name = genres[_genre];
    return _items.where((d) => d.categoryName.trim() == name).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = kUseLocalTestFeed
          ? await Api.getTestShortList()
          : await Api.getShortList(pageNum: 1, pageSize: 30);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
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
          plays: d.playCount + d.likeCount,
          videoUrl: d.videoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
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
          child: _content(p),
        ),
      ),
    );
  }

  Widget _content(Pal p) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: FF.hot));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text('${AppLocalizations.of(context).common_loadFailed}\n${_error ?? ''}',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(AppLocalizations.of(context).common_retry),
            ),
          ],
        ),
      );
    }

    // 用过滤后的列表(分类点了真生效);"全部"时即全部。
    final list = _filtered;
    // 只有"全部"页才显示"今日推荐"头牌;分类页直接铺该分类的剧。
    final showFeature = _genre == 0;
    final feature = showFeature && list.isNotEmpty ? list.first : null;
    final rest = showFeature ? list.skip(1).toList() : list;
    final trending = _genre == 0 ? rest.take(8).toList() : <ShortDrama>[];
    final series = _genre == 0 ? rest : list;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 6),
        _genreStrip(p),
        const SizedBox(height: 4),
        if (feature != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 16),
            child: _TodayStrip(p: p, item: feature, onOpen: () => _open(feature))
                .animate()
                .fadeIn(duration: 500.ms, delay: 80.ms)
                .slideY(begin: 0.05, curve: Curves.easeOut),
          ),
        // v1 砍掉"继续观看"假条(写死第3集·08:12、进度58%、拿列表第二部冒充)。
        // 真观看进度后端还没写入接口,等接真再放回。看历史在"我的→历史"是真的。
        if (trending.isNotEmpty) ...[
          _sectionHeading(p, AppLocalizations.of(context).theater_sectionHot,
              AppLocalizations.of(context).theater_seeAll,
              onAction: _openRanking),
          const SizedBox(height: 12),
          SizedBox(
            height: 222,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: trending.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _open(trending[i]),
                child: _TrendCard(p: p, item: trending[i]),
              ).animate(delay: (70 * i).ms).fadeIn(duration: 350.ms).slideX(
                  begin: 0.12, curve: Curves.easeOut),
            ),
          ),
          const SizedBox(height: 20),
        ],
        _sectionHeading(p, AppLocalizations.of(context).theater_sectionAll,
            AppLocalizations.of(context).theater_ranking,
            onAction: _openRanking),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 18,
            crossAxisSpacing: 10,
            childAspectRatio: 0.54,
          ),
          itemCount: series.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _open(series[i]),
            child: _SeriesCard(p: p, item: series[i]),
          ).animate(delay: (40 * i).ms).fadeIn(duration: 320.ms).slideY(
              begin: 0.08, curve: Curves.easeOut),
        ),
      ],
    );
  }

  Widget _genreStrip(Pal p) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
            child: GestureDetector(
              onTap: _openSearch,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.day ? Colors.white : const Color(0x18FFFFFF),
                  border: Border.all(color: p.line),
                ),
                child: Icon(Icons.search_rounded, color: p.text, size: 19),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 6),
              itemCount: _genresFor(context).length,
              separatorBuilder: (_, _) => const SizedBox(width: 7),
              itemBuilder: (_, i) {
                final active = i == _genre;
                return GestureDetector(
                  onTap: () => setState(() => _genre = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      gradient: active ? FF.brandGradient : null,
                      color: active ? null : p.chipBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: active ? Colors.transparent : p.line),
                    ),
                    child: Text(_genresFor(context)[i],
                        style: TextStyle(
                            color: active ? Colors.white : p.chipText,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(Pal p, String title, String action,
      {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: p.text, fontSize: 20, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: p.softPillBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line)),
              child: Text(action,
                  style: TextStyle(
                      color: p.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  void _openSearch() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => SearchScreen(items: _items)));
  }

  void _openRanking() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => RankingScreen(items: _items)));
  }
}

// Codex theater 调色（彩色简约：粉/青）
const _cPink = Color(0xFFFF4F9B);
const _cCyan = Color(0xFF38D5FF);
const _cInk = Color(0xFF090611); // 播放按钮深底

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}


/// 今日推荐紧凑条（Codex theater today-hero）：左小海报 + 文案 + 圆形播放钮。
class _TodayStrip extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  final VoidCallback onOpen;
  const _TodayStrip({required this.p, required this.item, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
          boxShadow: [
            BoxShadow(
                color: _cPink.withValues(alpha: p.day ? 0.12 : 0.18),
                blurRadius: 26,
                offset: const Offset(0, 14)),
          ],
        ),
        child: Row(
          children: [
            // 小海报
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(width: 104, height: 104, child: _poster(item.image)),
            ),
            const SizedBox(width: 14),
            // 文案
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).theater_today,
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: p.text,
                          fontSize: 22,
                          height: 1.02,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Builder(builder: (ctx) {
                    final l = AppLocalizations.of(ctx);
                    final tag = item.labels.isNotEmpty ? item.labels.first : l.theater_labelShort;
                    return Text(
                        l.theater_genreHeatFmt(tag, _fmt(item.playCount + item.likeCount)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600));
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 圆形播放钮（深底 + 青色三角 + 粉色柔光，轻脉冲）
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cInk,
                boxShadow: [
                  BoxShadow(
                      color: _cPink.withValues(alpha: 0.34),
                      blurRadius: 16,
                      spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: _cCyan, size: 26),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1, end: 1.06, duration: 1100.ms, curve: Curves.easeInOut),
          ],
        ),
      ),
    );
  }
}

/// 继续观看细条（Codex continue-strip）：38px 圆角药丸，圆形缩略图 + 标题
/// + 细进度条 + 时间码。仅在有观看进度时出现，搁在 today-hero 与正在热播之间。
class _ContinueStrip extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  final VoidCallback onOpen;
  const _ContinueStrip(
      {required this.p, required this.item, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        height: 38,
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
          color: p.softPillBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(width: 30, height: 30, child: _poster(item.image)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).theater_continueWatch(item.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: p.text,
                          fontSize: 12,
                          height: 1.1,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 3,
                      child: LayoutBuilder(builder: (_, c) {
                        return Stack(
                          children: [
                            Container(color: p.line),
                            FractionallySizedBox(
                              widthFactor: 0.58,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [_cPink, _cCyan]),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('第 3 集 · 08:12',
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

/// 热播横滑卡（Codex trend-card）：海报 3:4 + 下方标题/热度（不压字在图上）。
class _TrendCard extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  const _TrendCard({required this.p, required this.item});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: SizedBox(width: double.infinity, child: _poster(item.image)),
            ),
          ),
          const SizedBox(height: 9),
          Text(item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: p.text, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).theater_heatFmt(_fmt(item.playCount + item.likeCount)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: p.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  const _SeriesCard({required this.p, required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: double.infinity, child: _poster(item.image)),
          ),
        ),
        const SizedBox(height: 7),
        Text(item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: p.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Builder(builder: (ctx) {
          final fallback = AppLocalizations.of(ctx).theater_labelShort;
          final text = item.categoryName.isEmpty
              ? (item.labels.isNotEmpty ? item.labels.first : fallback)
              : item.categoryName;
          return Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: p.textMuted, fontSize: 11, fontWeight: FontWeight.w600));
        }),
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

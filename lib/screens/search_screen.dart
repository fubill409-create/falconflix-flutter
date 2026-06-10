import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/short_drama.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import 'detail_screen.dart';

/// 搜索页（剧场二级）。按 Codex app-subflows 的 Search 设计：
/// 顶部搜索框 + 热门/历史 + 结果海报网格。复用剧场已加载的剧目数据。
class SearchScreen extends StatefulWidget {
  final List<ShortDrama> items;
  const SearchScreen({super.key, required this.items});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _q = '';
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// 热门词：从真实剧目的分类/标签里聚合，兜底几个常用词。
  List<String> _hotWords(AppLocalizations l) {
    final seen = <String>{};
    final out = <String>[];
    void add(String s) {
      final t = s.trim();
      if (t.isNotEmpty && seen.add(t)) out.add(t);
    }

    for (final d in widget.items) {
      add(d.categoryName);
      for (final lab in d.labels) add(lab);
    }
    for (final f in [
      l.home_chipAiTheater,
      l.ss2_chipCEO,
      l.ss2_chipTimeTravel,
      l.ss2_chipMystery,
      l.ss2_chipModern,
      l.ss2_chipSweetPet,
    ]) {
      add(f);
    }
    return out.take(10).toList();
  }

  List<ShortDrama> get _results {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return widget.items.where((d) {
      bool hit(String s) => s.toLowerCase().contains(q);
      return hit(d.name) ||
          hit(d.introduce) ||
          hit(d.categoryName) ||
          d.labels.any(hit);
    }).toList();
  }

  void _submit(String s) {
    final t = s.trim();
    setState(() {
      _q = t;
      if (t.isNotEmpty) {
        _history.remove(t);
        _history.insert(0, t);
        if (_history.length > 8) _history.removeLast();
      }
    });
  }

  void _fill(String s) {
    _ctrl.text = s;
    _ctrl.selection = TextSelection.collapsed(offset: s.length);
    _submit(s);
    _focus.unfocus();
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
          child: Column(
            children: [
              _topbar(p),
              Expanded(
                child: _q.isEmpty
                    ? _discover(p, AppLocalizations.of(context))
                    : _resultView(p, AppLocalizations.of(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topbar(Pal p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
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
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: p.day ? Colors.white : const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: p.line),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: p.textMuted, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _q = v),
                      onSubmitted: _submit,
                      cursorColor: FF.hot,
                      style: TextStyle(
                          color: p.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: AppLocalizations.of(context).ss2_searchHint,
                        hintStyle:
                            TextStyle(color: p.textMuted, fontSize: 14),
                      ),
                    ),
                  ),
                  if (_q.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        setState(() => _q = '');
                        _focus.requestFocus();
                      },
                      child: Icon(Icons.close_rounded,
                          color: p.textMuted, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discover(Pal p, AppLocalizations l) {
    final hot = _hotWords(l);
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 40),
      children: [
        if (_history.isNotEmpty) ...[
          _heading(p, l.ss2_history,
              trailing: l.ss2_clear, onTrailing: () {
            setState(_history.clear);
          }),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in _history)
                GestureDetector(
                  onTap: () => _fill(h),
                  child: _softChip(p, h),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _heading(p, l.ss2_hot),
        const SizedBox(height: 12),
        for (var i = 0; i < hot.length; i++)
          GestureDetector(
            onTap: () => _fill(hot[i]),
            child: _hotRow(p, i, hot[i]),
          )
              .animate(delay: (40 * i).ms)
              .fadeIn(duration: 280.ms)
              .slideX(begin: 0.08, curve: Curves.easeOut),
      ],
    );
  }

  Widget _hotRow(Pal p, int i, String word) {
    final top = i < 3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: top
                  ? ShaderMask(
                      shaderCallback: (r) => FF.brandGradient.createShader(r),
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                    )
                  : Text('${i + 1}',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 14,
                      fontWeight: top ? FontWeight.w800 : FontWeight.w600)),
            ),
            if (top)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    gradient: FF.watchGradient,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(AppLocalizations.of(context).ss2_hotBadge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _resultView(Pal p, AppLocalizations l) {
    final res = _results;
    if (res.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: p.textMuted, size: 46),
            const SizedBox(height: 12),
            Text(l.ss2_noResultFmt(_q),
                style: TextStyle(color: p.textMuted, fontSize: 13)),
          ],
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
          sliver: SliverToBoxAdapter(
            child: Text(l.ss2_foundFmt(res.length.toString()),
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.54,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => GestureDetector(
                onTap: () => _open(res[i]),
                child: _PosterCard(p: p, item: res[i]),
              )
                  .animate(delay: (35 * i).ms)
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOut),
              childCount: res.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heading(Pal p, String title,
      {String? trailing, VoidCallback? onTrailing}) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                color: p.text, fontSize: 17, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            child: Text(trailing,
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _softChip(Pal p, String text) => Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: p.chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line)),
        child: Text(text,
            style: TextStyle(
                color: p.chipText,
                fontSize: 12.5,
                fontWeight: FontWeight.w700)),
      );
}

/// 竖版海报卡（搜索结果/榜单共用风格）。
class _PosterCard extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  const _PosterCard({required this.p, required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              child: item.image.isEmpty
                  ? Container(color: const Color(0xFF201A15))
                  : CachedNetworkImage(
                      imageUrl: item.image,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: const Color(0xFF201A15)),
                      errorWidget: (_, _, _) =>
                          Container(color: const Color(0xFF201A15)),
                    ),
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

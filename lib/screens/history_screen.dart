import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/footprint.dart';
import '../models/time_label.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import 'detail_screen.dart';

/// 观看历史（足迹）页 —— me_screen「我的内容」组 / 任务 #10。
///
/// 数据接 `/record/footprint`（已部署在生产，无须新代码）；
/// 每条记录：剧封面 + 剧名 + 集名 + 进度条 + 相对时间。
/// 点击进剧详情（按 shortId）；长按或编辑模式可删除单条；右上角"清空"清全部。
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scroll = ScrollController();
  final List<Footprint> _items = [];
  int _pageNum = 1;
  static const int _pageSize = 20;
  int _total = 0;
  bool _loading = false; // 拉首屏 / 下拉刷新
  bool _loadingMore = false; // 滚到底翻下一页
  bool _editing = false; // 编辑模式：每条左侧出现勾选
  final Set<int> _selected = {}; // 已勾选的 footprint id
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    if (!auth.loggedIn) {
      setState(() {
        _items.clear();
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      if (refresh) {
        _items.clear();
        _pageNum = 1;
      }
    });
    try {
      final r = await Api.historyList(pageNum: 1, pageSize: _pageSize);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(r.list);
        _total = r.total;
        _pageNum = 1;
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

  Future<void> _loadMore() async {
    if (_loadingMore || _loading) return;
    if (_items.length >= _total) return;
    setState(() => _loadingMore = true);
    try {
      final next = _pageNum + 1;
      final r = await Api.historyList(pageNum: next, pageSize: _pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(r.list);
        _pageNum = next;
        _total = r.total;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _open(Footprint f) {
    if (_editing) {
      // 编辑模式下点卡 = 切换勾选
      setState(() {
        if (_selected.contains(f.id)) {
          _selected.remove(f.id);
        } else {
          _selected.add(f.id);
        }
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          shortId: f.shortId,
          title: f.shortName,
          cover: f.shortImage,
          intro: '',
          price: 0,
        ),
      ),
    ).then((_) {
      if (mounted) _load(refresh: true); // 看完回来刷新最新进度
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final ids = _selected.toList();
    final l = AppLocalizations.of(context);
    // 跨 await 提前抓字符串，避免 use_build_context_synchronously
    final doneMsg = l.history_toastDeleted(ids.length);
    final failPrefix = l.common_loadFailed;
    final yes = await _confirm(
        title: l.history_delConfirmTitle(ids.length),
        body: l.history_delConfirmBody,
        confirmLabel: l.common_delete);
    if (yes != true) return;
    try {
      await Api.historyDelete(ids);
      if (!mounted) return;
      setState(() {
        _items.removeWhere((f) => ids.contains(f.id));
        _selected.clear();
        _editing = false;
        _total = (_total - ids.length).clamp(0, _total);
      });
      _toast(doneMsg);
    } catch (e) {
      _toast('$failPrefix: $e');
    }
  }

  Future<void> _clearAll() async {
    final l = AppLocalizations.of(context);
    final doneMsg = l.history_toastCleared;
    final failPrefix = l.common_loadFailed;
    final yes = await _confirm(
        title: l.history_clearConfirmTitle,
        body: l.history_clearConfirmBody,
        confirmLabel: l.history_actionClearAll);
    if (yes != true) return;
    try {
      await Api.historyClearAll();
      if (!mounted) return;
      setState(() {
        _items.clear();
        _selected.clear();
        _editing = false;
        _total = 0;
      });
      _toast(doneMsg);
    } catch (e) {
      _toast('$failPrefix: $e');
    }
  }

  Future<bool?> _confirm(
      {required String title,
      required String body,
      required String confirmLabel}) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: FF.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: FF.dim, fontSize: 13, height: 1.5)),
              const SizedBox(height: 18),
              GradientButton(
                label: confirmLabel,
                height: 48,
                onTap: () => Navigator.pop(ctx, true),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context).common_cancel, style: const TextStyle(color: FF.dim)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p),
                ),
                if (_editing) _editingActionBar(p),
                Expanded(child: _content(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topbar(Pal p) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.day
                  ? Colors.black.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: p.line),
            ),
            child: Icon(Icons.arrow_back_rounded, color: p.text, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(AppLocalizations.of(context).history_title,
            style: TextStyle(
                color: p.text, fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (_items.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                _editing = !_editing;
                if (!_editing) _selected.clear();
              });
            },
            child: Text(_editing ? AppLocalizations.of(context).common_done : AppLocalizations.of(context).common_edit,
                style: TextStyle(
                    color: p.text, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _editingActionBar(Pal p) {
    final selectedCount = _selected.length;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      decoration: BoxDecoration(
        color: p.day ? p.card : FF.glassFill,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          Text(l.history_selectedCount(selectedCount),
              style: TextStyle(
                  color: p.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton(
            onPressed: selectedCount > 0 ? _deleteSelected : null,
            child: Text(
              l.history_actionDelSelected,
              style: TextStyle(
                color: selectedCount > 0 ? FF.hot : p.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearAll,
            child: Text(l.history_actionClearAll,
                style: const TextStyle(
                    color: FF.hot,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _content(Pal p) {
    final l = AppLocalizations.of(context);
    if (!auth.loggedIn) {
      return _emptyState(p,
          icon: Icons.history_rounded,
          title: l.common_pleaseLogin,
          body: l.history_loginBody);
    }
    if (_loading && _items.isEmpty) {
      return Center(child: CircularProgressIndicator(color: FF.hot));
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text('${l.common_loadFailed}\n$_error',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _load(refresh: true),
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return _emptyState(p,
          icon: Icons.history_rounded,
          title: l.history_emptyTitle,
          body: l.history_emptyBody);
    }
    return RefreshIndicator(
      color: FF.hot,
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 120),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child:
                  Center(child: CircularProgressIndicator(color: FF.hot)),
            );
          }
          final f = _items[i];
          return _HistoryCard(
            p: p,
            footprint: f,
            editing: _editing,
            selected: _selected.contains(f.id),
            onTap: () => _open(f),
          )
              .animate(delay: (30 * (i % 8)).ms)
              .fadeIn(duration: 240.ms)
              .slideY(begin: 0.06, curve: Curves.easeOut);
        },
      ),
    );
  }

  Widget _emptyState(Pal p,
      {required IconData icon,
      required String title,
      required String body}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: p.textMuted, size: 52),
            const SizedBox(height: 14),
            Text(title,
                style: TextStyle(
                    color: p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: p.textMuted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// 单条观看历史卡片：横向布局 16:9 封面 + 标题/集名/进度条/时间。
class _HistoryCard extends StatelessWidget {
  final Pal p;
  final Footprint footprint;
  final bool editing;
  final bool selected;
  final VoidCallback onTap;
  const _HistoryCard({
    required this.p,
    required this.footprint,
    required this.editing,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final f = footprint;
    final progress = f.progress;
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 14,
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (editing) ...[
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: selected ? FF.hot : p.textMuted,
                size: 22,
              ),
              const SizedBox(width: 10),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 108,
                height: 64,
                child: f.shortImage.isEmpty
                    ? Container(color: const Color(0xFF201A15))
                    : CachedNetworkImage(
                        imageUrl: f.shortImage,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: const Color(0xFF201A15)),
                        errorWidget: (_, _, _) =>
                            Container(color: const Color(0xFF201A15)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    f.shortName.isEmpty
                        ? AppLocalizations.of(context).history_unknown
                        : f.shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    f.shortPlayName?.isNotEmpty == true
                        ? f.shortPlayName!
                        : AppLocalizations.of(context).history_episodeFallback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: p.textMuted, fontSize: 12, height: 1),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: p.line,
                        valueColor: const AlwaysStoppedAnimation(FF.hot),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    relativeTimeLabel(
                        f.updateTime, AppLocalizations.of(context)),
                    style:
                        TextStyle(color: p.textMuted, fontSize: 11, height: 1),
                  ),
                ],
              ),
            ),
            if (!editing)
              Icon(Icons.chevron_right_rounded,
                  color: p.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

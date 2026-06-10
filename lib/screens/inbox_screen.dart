import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/notify.dart';
import '../models/time_label.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';

/// 消息收件箱 —— 任务 #12 / me_screen「社区」组。
///
/// 5 类 type 切换 tab：充值 / 邀请 / 系统 / 活动 / 互动剧。
/// 打开页面时自动「全部已读」+ 顶栏红点立刻清零（Api.unreadNotify ValueNotifier）。
/// 单条点击：标记已读 + 深链跳转（link 字段，如 /wallet）。
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with TickerProviderStateMixin {
  /// type → AppLocalizations getter key 后缀。null = 全部。
  static const _types = <(String?, String)>[
    (null, 'inbox_tabAll'),
    ('recharge', 'inbox_tabRecharge'),
    ('invite', 'inbox_tabInvite'),
    ('system', 'inbox_tabSystem'),
    ('activity', 'inbox_tabActivity'),
    ('interactive', 'inbox_tabInteractive'),
  ];

  String _tabLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'inbox_tabAll': return l.inbox_tabAll;
      case 'inbox_tabRecharge': return l.inbox_tabRecharge;
      case 'inbox_tabInvite': return l.inbox_tabInvite;
      case 'inbox_tabSystem': return l.inbox_tabSystem;
      case 'inbox_tabActivity': return l.inbox_tabActivity;
      case 'inbox_tabInteractive': return l.inbox_tabInteractive;
      default: return key;
    }
  }

  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _types.length, vsync: this);
    // 进页面 = 全部已读（与 iOS Mail / Gmail 一致）
    _markAllReadOnEntry();
  }

  Future<void> _markAllReadOnEntry() async {
    if (!auth.loggedIn) return;
    try {
      await Api.notifyMarkAllRead();
    } catch (_) {
      // 失败也无所谓，下次打开会再试
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 6),
                  child: _topbar(p),
                ),
                _tabBar(p),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      for (final t in _types) _InboxList(type: t.$1),
                    ],
                  ),
                ),
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
        Text(AppLocalizations.of(context).inbox_title,
            style: TextStyle(
                color: p.text, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _tabBar(Pal p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: TabBar(
        controller: _tab,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: FF.hot, width: 2.4),
          insets: EdgeInsets.symmetric(horizontal: 12),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelColor: p.text,
        unselectedLabelColor: p.textMuted,
        labelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          for (final t in _types)
            Tab(text: _tabLabel(AppLocalizations.of(context), t.$2))
        ],
      ),
    );
  }
}

class _InboxList extends StatefulWidget {
  final String? type;
  const _InboxList({this.type});

  @override
  State<_InboxList> createState() => _InboxListState();
}

class _InboxListState extends State<_InboxList>
    with AutomaticKeepAliveClientMixin {
  final _scroll = ScrollController();
  final List<NotifyMsg> _items = [];
  int _pageNum = 1;
  static const int _pageSize = 20;
  int _total = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

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
      final r = await Api.notifyInbox(
          type: widget.type, pageNum: 1, pageSize: _pageSize);
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
        _error = e is ApiException ? e.message : AppLocalizations.of(context).common_loadFailed;
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
      final r = await Api.notifyInbox(
          type: widget.type, pageNum: next, pageSize: _pageSize);
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

  Future<void> _open(NotifyMsg m) async {
    // 标记单条已读（如未读）
    if (!m.isRead) {
      try {
        await Api.notifyMarkRead(m.id);
      } catch (_) {}
      if (mounted) {
        setState(() {
          final i = _items.indexWhere((x) => x.id == m.id);
          if (i >= 0) {
            _items[i] = NotifyMsg(
              id: m.id,
              type: m.type,
              title: m.title,
              body: m.body,
              link: m.link,
              isRead: true,
              createTime: m.createTime,
            );
          }
        });
      }
    }
    // 深链处理：常见 /wallet / /short/{id} / /me/feedback/{id} / /ix/{id}
    final link = m.link;
    if (link == null || link.isEmpty) return;
    // 简化版：暂不解析复杂深链，只处理 /wallet → WalletScreen。
    // 其他链接（剧详情/互动剧/工单）按 #10/#11/#15 节奏接入后再补。
    // TODO 深链路由表：等 #15 反馈页 + 互动剧详情接入后统一在 nav 模块加 router。
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    if (!auth.loggedIn) {
      return _emptyState(p,
          icon: Icons.notifications_off_outlined,
          title: l.common_pleaseLogin,
          body: l.inbox_loginBody);
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
            Text(_error!,
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
          icon: Icons.mark_email_read_outlined,
          title: l.inbox_emptyTitle,
          body: l.inbox_emptyBody);
    }
    return RefreshIndicator(
      color: FF.hot,
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 120),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: FF.hot)),
            );
          }
          final m = _items[i];
          return _InboxCard(p: p, msg: m, onTap: () => _open(m))
              .animate(delay: (30 * (i % 8)).ms)
              .fadeIn(duration: 240.ms)
              .slideY(begin: 0.06, curve: Curves.easeOut);
        },
      ),
    );
  }
}

class _InboxCard extends StatelessWidget {
  final Pal p;
  final NotifyMsg msg;
  final VoidCallback onTap;
  const _InboxCard(
      {required this.p, required this.msg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !msg.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 14,
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型彩色圆形 icon
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _iconGradient(msg.type),
              ),
              child: Icon(_iconFor(msg.type), color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          msg.title.isEmpty
                              ? msg.typeLabel(AppLocalizations.of(context))
                              : msg.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: FF.hot),
                        ),
                      ],
                    ],
                  ),
                  if (msg.body.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      msg.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: p.textMuted, fontSize: 12, height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(msg.typeLabel(AppLocalizations.of(context)),
                          style: TextStyle(
                              color: p.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text(
                          relativeTimeLabel(msg.createTime,
                              AppLocalizations.of(context)),
                          style: TextStyle(
                              color: p.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'recharge':
        return Icons.account_balance_wallet_rounded;
      case 'invite':
        return Icons.card_giftcard_rounded;
      case 'activity':
        return Icons.celebration_rounded;
      case 'interactive':
        return Icons.auto_awesome_rounded;
      case 'system':
      default:
        return Icons.campaign_rounded;
    }
  }

  LinearGradient _iconGradient(String type) {
    // 不同类型不同主色，跟 FCM channel 视觉一致
    switch (type) {
      case 'recharge':
        return const LinearGradient(colors: [Color(0xFFFF5E79), FF.hot]);
      case 'invite':
        return const LinearGradient(colors: [Color(0xFFFFB347), FF.gold]);
      case 'activity':
        return const LinearGradient(colors: [Color(0xFF7B6CFF), Color(0xFFAC5FFF)]);
      case 'interactive':
        return const LinearGradient(colors: [FF.purple, Color(0xFFFF6FB7)]);
      case 'system':
      default:
        return const LinearGradient(colors: [Color(0xFF6F94FF), Color(0xFF4D6BFF)]);
    }
  }
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
                  color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: p.textMuted, fontSize: 13, height: 1.5)),
        ],
      ),
    ),
  );
}

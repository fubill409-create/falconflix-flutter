import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/purchase.dart';
import '../models/recharge.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import 'detail_screen.dart';

/// 我的订单页 —— 任务 #11 / me_screen「钱包」组。
///
/// 3 个 tab：
///   ① 整剧：买了整部剧的订单（/record/purchases?isShort=true）
///   ② 单集：单集购买（/record/purchases?isShort=false）
///   ③ 充值流水：鹰币充值订单（复用 Api.rechargeHistory()）
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
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
                    children: const [
                      _PurchasesTab(isShort: true),
                      _PurchasesTab(isShort: false),
                      _RechargeTab(),
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
        Text(AppLocalizations.of(context).orders_title,
            style: TextStyle(
                color: p.text, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _tabBar(Pal p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      decoration: BoxDecoration(
        color: p.day ? Colors.black.withValues(alpha: 0.04) : FF.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.line),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: FF.brandGradient,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: p.textMuted,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(text: AppLocalizations.of(context).orders_tabFull),
          Tab(text: AppLocalizations.of(context).orders_tabEpisode),
          Tab(text: AppLocalizations.of(context).orders_tabRecharge),
        ],
      ),
    );
  }
}

/// 整剧 / 单集 tab —— 共用同一组件，按 isShort 切换。
class _PurchasesTab extends StatefulWidget {
  final bool isShort;
  const _PurchasesTab({required this.isShort});

  @override
  State<_PurchasesTab> createState() => _PurchasesTabState();
}

class _PurchasesTabState extends State<_PurchasesTab>
    with AutomaticKeepAliveClientMixin {
  List<Purchase>? _items;
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!auth.loggedIn) {
      setState(() {
        _items = const [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await Api.ordersList(isShort: widget.isShort);
      if (!mounted) return;
      setState(() {
        _items = list;
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

  void _open(Purchase pu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          shortId: pu.shortId,
          title: pu.shortName,
          cover: pu.image,
          intro: pu.introduce,
          price: 0,
          labels: pu.categoryName == null || pu.categoryName!.isEmpty
              ? const []
              : [pu.categoryName!],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    if (!auth.loggedIn) {
      return _emptyState(p,
          icon: Icons.receipt_long_outlined,
          title: l.common_pleaseLogin,
          body: l.orders_loginBodyOrders);
    }
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
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }
    final items = _items ?? const [];
    if (items.isEmpty) {
      return _emptyState(p,
          icon: Icons.receipt_long_outlined,
          title: widget.isShort ? l.orders_emptyFull : l.orders_emptyEpisode,
          body: l.orders_emptyBody);
    }
    return RefreshIndicator(
      color: FF.hot,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 120),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _PurchaseCard(
          p: p,
          item: items[i],
          isShort: widget.isShort,
          onTap: () => _open(items[i]),
        )
            .animate(delay: (30 * (i % 8)).ms)
            .fadeIn(duration: 240.ms)
            .slideY(begin: 0.06, curve: Curves.easeOut),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Pal p;
  final Purchase item;
  final bool isShort;
  final VoidCallback onTap;
  const _PurchaseCard(
      {required this.p,
      required this.item,
      required this.isShort,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 14,
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 76,
                    height: 100,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.shortName.isEmpty ? l.orders_unknownTitle : item.shortName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800),
                      ),
                      if (!isShort && item.episodeName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.episodeName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: p.textMuted, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 6),
                      _kv(p, l.orders_kvAmount, item.priceLabel(l),
                          highlight: true),
                      const SizedBox(height: 3),
                      _kv(p, l.orders_kvPayMethod, item.payTypeLabel(l)),
                      const SizedBox(height: 3),
                      _kv(p, l.orders_kvTime, item.timeLabel),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: p.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            // 订单号（小字 + 可复制）
            GestureDetector(
              onTap: () async {
                if (item.orderNo.isEmpty) return;
                final copiedMsg = l.orders_orderCopied(item.orderNo);
                await Clipboard.setData(ClipboardData(text: item.orderNo));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF15101F),
                  content: Text(copiedMsg,
                      style: const TextStyle(color: Colors.white)),
                ));
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: p.day
                      ? Colors.black.withValues(alpha: 0.03)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        color: p.textMuted, size: 13),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.orderNo.isEmpty ? '—' : item.orderNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: p.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    if (item.orderNo.isNotEmpty)
                      Icon(Icons.copy_rounded, color: p.textMuted, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(Pal p, String k, String v, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 54,
          child: Text(k,
              style: TextStyle(color: p.textMuted, fontSize: 11)),
        ),
        Expanded(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlight ? FF.hot : p.text,
              fontSize: 12,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 充值流水 tab —— 复用 Api.rechargeHistory() 接现有 /order/list?type=1。
class _RechargeTab extends StatefulWidget {
  const _RechargeTab();
  @override
  State<_RechargeTab> createState() => _RechargeTabState();
}

class _RechargeTabState extends State<_RechargeTab>
    with AutomaticKeepAliveClientMixin {
  List<RechargeRecord>? _items;
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!auth.loggedIn) {
      setState(() {
        _items = const [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await Api.rechargeHistory();
      if (!mounted) return;
      setState(() {
        _items = list;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    if (!auth.loggedIn) {
      return _emptyState(p,
          icon: Icons.account_balance_wallet_outlined,
          title: l.common_pleaseLogin,
          body: l.orders_loginBodyRecharge);
    }
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
            Text(_error!,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }
    final items = _items ?? const [];
    if (items.isEmpty) {
      return _emptyState(p,
          icon: Icons.account_balance_wallet_outlined,
          title: l.orders_emptyRecharge,
          body: l.orders_emptyRechargeBody);
    }
    return RefreshIndicator(
      color: FF.hot,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 120),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _RechargeCard(p: p, item: items[i])
            .animate(delay: (30 * (i % 8)).ms)
            .fadeIn(duration: 240.ms)
            .slideY(begin: 0.06, curve: Curves.easeOut),
      ),
    );
  }
}

class _RechargeCard extends StatelessWidget {
  final Pal p;
  final RechargeRecord item;
  const _RechargeCard({required this.p, required this.item});

  @override
  Widget build(BuildContext context) {
    final paid = item.paid;
    final l = AppLocalizations.of(context);
    return Glass(
      radius: 14,
      color: p.day ? p.card : FF.glassFill,
      border: p.line,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  color: FF.hot, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.goodsName.isEmpty
                      ? l.orders_rechargeFallback
                      : localizeGoodsName(item.goodsName, l),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                item.priceLabel,
                style: TextStyle(
                    color: FF.hot,
                    fontSize: 15,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: paid
                      ? const Color(0x2231C45A)
                      : const Color(0x22FFC107),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rechargeStatusLabel(item.statusKey(), l),
                  style: TextStyle(
                    color: paid
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFFC107),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item.createTime,
                style: TextStyle(color: p.textMuted, fontSize: 11),
              ),
            ],
          ),
          if (item.orderNo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.orderNo,
              style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 空态 / 未登录 通用组件。
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

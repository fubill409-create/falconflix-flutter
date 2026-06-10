import 'dart:async';
import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart' show ProductDetails;
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../auth.dart';
import '../data/legal_content.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/level_curve.dart';
import '../models/recharge.dart';
import '../models/short_drama.dart';
import '../services/iap_service.dart';
import '../state/app_settings.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import '../version.dart';
import 'detail_screen.dart';

/// 我的二级页（按 Codex app-subflows 的 Me 分支）：钱包/VIP、伙伴中心。
/// 承接「我的」tab 的电影级暗色，钱包卡用彩色主渐变。UI 壳。

void _toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

Widget _backTopbar(BuildContext context, String title) {
  final p = Pal.now();
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
      Text(title,
          style: TextStyle(
              color: p.text, fontSize: 20, fontWeight: FontWeight.w900)),
    ],
  );
}

Widget _menuList(BuildContext context, List<String> items,
    {void Function(int index)? onItemTap}) {
  final p = Pal.now();
  final l = AppLocalizations.of(context);
  return Glass(
    radius: 16,
    padding: EdgeInsets.zero,
    color: p.day ? p.card : FF.glassFill,
    border: p.line,
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          ListTile(
            dense: true,
            title: Text(items[i],
                style: TextStyle(
                    color: p.text, fontSize: 15, fontWeight: FontWeight.w500)),
            trailing: Icon(Icons.chevron_right, color: p.textMuted, size: 18),
            onTap: () {
              if (onItemTap != null) {
                onItemTap(i);
              } else {
                _toast(context, l.common_comingSoonFmt(items[i]));
              }
            },
          ),
          if (i != items.length - 1)
            Divider(height: 1, color: p.line, indent: 16),
        ],
      ],
    ),
  );
}

/// 钱包 / VIP
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {
  List<RechargePack>? _packs;
  bool _loading = true;
  String? _error;
  int _selected = 0;
  bool _busy = false;

  // 进行中的 Checkout 订单：用户去浏览器付款，回到 App（resume）时据此查账。
  String? _pendingOrderNo;
  int _pendingCoins = 0;
  bool _verifying = false;

  // iOS 苹果内购：appleProductId → App Store 商品（价取 StoreKit 本地化价）。
  Map<String, ProductDetails> _iapProducts = const {};
  StreamSubscription<IapResult>? _iapSub;

  // 累计「等级值」鹰币（= 历史实付美金 × 100，对齐 $10k=V50 锚点）；驱动 V1–V99 面子等级。
  // null = 尚未拉到（隐藏身份卡，避免闪 V1）。数据来自 /order/list?type=1 的已到账充值单求和。
  int? _paidCoins;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (auth.loggedIn) auth.refresh();
    // iOS：订阅内购结果（全局 purchaseStream 在 IapService 里推进，这里只管 UI 反馈）。
    if (Platform.isIOS) {
      _iapSub = IapService.instance.results.listen(_onIapResult);
    }
    _load();
  }

  @override
  void dispose() {
    _iapSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 从 Stripe 托管收银台（浏览器/Custom Tab）回到 App 时触发：查这笔订单是否已到账。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _pendingOrderNo != null &&
        !_verifying) {
      _verifyPendingOrder();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packs = await Api.getRechargePacks();
      // iOS：套餐必须映射到 App Store 商品（审核 3.1.1）。缺 appleProductId
      // 或 StoreKit 查不到的套餐不展示；商店不可用则走 IapStoreException 错误重试。
      var products = const <String, ProductDetails>{};
      if (Platform.isIOS) {
        final ids = <String>{
          for (final p in packs)
            if (p.appleProductId.isNotEmpty) p.appleProductId,
        };
        products = await IapService.instance.queryProducts(ids);
        packs.retainWhere((p) => products.containsKey(p.appleProductId));
      }
      packs.sort((a, b) => a.rechargeAmount.compareTo(b.rechargeAmount));
      if (!mounted) return;
      setState(() {
        _iapProducts = products;
        _packs = packs;
        // 默认选中中间档（更易转化）
        _selected = packs.length >= 2 ? packs.length ~/ 2 : 0;
        _loading = false;
      });
      _loadPaidCoins();
    } on IapStoreException {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context).wallet_iapUnavailable;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException
            ? e.message
            : AppLocalizations.of(context).wallet_loadFailed;
        _loading = false;
      });
    }
  }

  /// 拉历史充值单求和，算「累计实付」→ 等级值鹰币（实付美金 × 100）。
  /// 失败静默（不影响充值主流程），只是 V 级别身份卡暂不显示。
  Future<void> _loadPaidCoins() async {
    if (!auth.loggedIn) return;
    try {
      final records = await Api.rechargeHistory();
      var usd = 0.0;
      for (final r in records) {
        if (r.paid) usd += double.tryParse(r.payPrice.trim()) ?? 0;
      }
      if (!mounted) return;
      setState(() => _paidCoins = (usd * 100).round());
    } catch (_) {
      // 忽略：等级身份卡保持隐藏。
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
              children: [
                _backTopbar(context, l.wallet_title),
                const SizedBox(height: 18),
                _walletCard(),
                const SizedBox(height: 18),
                Text(l.wallet_chooseRecharge,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(l.wallet_introNote,
                    style: TextStyle(color: p.textMuted, fontSize: 12)),
                const SizedBox(height: 14),
                _packsArea(),
                const SizedBox(height: 20),
                _ctaArea(),
                const SizedBox(height: 22),
                _menuList(context, [
                  l.wallet_menuAutoUnlock,
                  l.wallet_menuHistory,
                  l.wallet_menuReceipt,
                ], onItemTap: (idx) {
                  switch (idx) {
                    case 0:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AutoUnlockScreen()));
                      break;
                    case 1:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RechargeHistoryScreen()));
                      break;
                    case 2:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InvoiceEmailScreen()));
                      break;
                  }
                }),
                const SizedBox(height: 14),
                Center(
                  // iOS 走苹果内购，不能出现第三方收银台文案（审核 3.1.1）。
                  child: Text(
                      Platform.isIOS
                          ? l.wallet_appStoreNotice
                          : l.wallet_stripeNotice,
                      style: TextStyle(color: p.textMuted, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _packsArea() {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    if (_loading) return _packsSkeleton();
    if (_error != null) {
      return Glass(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, color: p.textMuted, size: 28),
            const SizedBox(height: 10),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line),
                ),
                child: Text(l.common_retry,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    }
    final packs = _packs ?? const <RechargePack>[];
    if (packs.isEmpty) {
      return Glass(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        child: Column(
          children: [
            Icon(Icons.savings_outlined, color: p.textMuted, size: 30),
            const SizedBox(height: 10),
            Text(l.wallet_packsComing,
                style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(l.wallet_packsComingBody,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: packs.length,
      itemBuilder: (_, i) => _packCard(packs[i], i),
    );
  }

  /// 赠送率最高的那档 = 「最划算」（≥5% 才算）。
  int get _bestValueIndex {
    final packs = _packs;
    if (packs == null || packs.isEmpty) return -1;
    var best = 0;
    for (var i = 1; i < packs.length; i++) {
      if (packs[i].giftPercent > packs[best].giftPercent) best = i;
    }
    return packs[best].giftPercent >= 5 ? best : -1;
  }

  Widget _packCard(RechargePack p, int i) {
    final sel = i == _selected;
    final isBest = i == _bestValueIndex;
    final pal = Pal.now();
    final unselBg =
        pal.day ? pal.card : Colors.white.withValues(alpha: 0.05);
    final unselIcon = pal.day ? FF.goldDeep : FF.gold;
    final unselPill = pal.day
        ? Colors.black.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.05);
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          gradient: sel ? FF.brandGradient : null,
          color: sel ? null : unselBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sel
                  ? Colors.transparent
                  : (isBest ? FF.gold.withValues(alpha: 0.7) : pal.line),
              width: isBest && !sel ? 1.4 : 1),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: FF.purple.withValues(alpha: 0.34),
                      blurRadius: 16)
                ]
              : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on_rounded,
                      color: sel ? Colors.white : unselIcon, size: 22),
                  const SizedBox(height: 6),
                  Text(_coins(p.coins.toDouble()),
                      style: TextStyle(
                          color: sel ? Colors.white : pal.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900)),
                  Text(AppLocalizations.of(context).wallet_coins,
                      style: TextStyle(
                          color: sel ? Colors.white70 : pal.textMuted,
                          fontSize: 10)),
                  if (p.hasGift) ...[
                    const SizedBox(height: 2),
                    Text(
                        AppLocalizations.of(context)
                            .wallet_giftFmt(fmtCoins(p.giftCoins)),
                        style: TextStyle(
                            color: sel ? Colors.white : FF.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.white.withValues(alpha: 0.22)
                          : unselPill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(_priceLabel(p),
                        style: TextStyle(
                            color: sel ? Colors.white : pal.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            // 赠送率角标（金色，越大档越诱人）。
            if (p.hasGift)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: FF.goldGradient,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(13),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text('+${p.giftPercent}%',
                      style: const TextStyle(
                          color: Color(0xFF2A1B00),
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            // 「最划算」缎带（赠送率最高那档，左上角）。
            if (isBest)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: const BoxDecoration(
                    color: FF.hot,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).wallet_bestDeal,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _packsSkeleton() {
    final p = Pal.now();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: p.day ? p.card : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.line),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
            duration: 700.ms,
            begin: 0.4,
          ),
    );
  }

  Widget _ctaArea() {
    final packs = _packs ?? const <RechargePack>[];
    final canPay = !_loading &&
        _error == null &&
        packs.isNotEmpty &&
        _selected < packs.length;
    if (_busy) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: FF.brandGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child:
              CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
        ),
      );
    }
    final priceLabel = canPay ? _priceLabel(packs[_selected]) : '';
    final l = AppLocalizations.of(context);
    return Opacity(
      opacity: canPay ? 1 : 0.5,
      child: GradientButton(
        label: canPay ? l.wallet_payNowFmt(priceLabel) : l.wallet_payNow,
        icon: Icons.bolt_rounded,
        height: 52,
        onTap: () {
          if (!canPay) return;
          // iOS 走苹果内购（审核 3.1.1）；Android 维持 Stripe 网页收银台。
          if (Platform.isIOS) {
            _startIapPurchase(packs[_selected]);
          } else {
            _startCheckout(packs[_selected]);
          }
        },
      ),
    );
  }

  /// 价签：iOS 用 App Store 本地化价（StoreKit 才是实际扣款方）；其余用后端美金价。
  String _priceLabel(RechargePack pack) {
    if (Platform.isIOS) {
      final prod = _iapProducts[pack.appleProductId];
      if (prod != null) return prod.price;
    }
    return pack.priceLabel;
  }

  // iOS 充值走苹果内购：buyConsumable 拉起 Apple 支付面板，后续由 IapService 的
  // 全局 purchaseStream 推进（后端验证→completePurchase→刷余额），结果经
  // _onIapResult 回到本页解除 _busy 并反馈。
  Future<void> _startIapPurchase(RechargePack pack) async {
    final l = AppLocalizations.of(context);
    if (!auth.loggedIn) {
      _toast(context, l.wallet_loginFirst);
      return;
    }
    final product = _iapProducts[pack.appleProductId];
    if (product == null) {
      _toast(context, l.wallet_payFail);
      return;
    }
    setState(() => _busy = true);
    try {
      final ok = await IapService.instance.buy(product);
      if (!ok && mounted) {
        setState(() => _busy = false);
        _toast(context, l.wallet_openPayFail);
      }
    } catch (_) {
      // 如 StoreKit 已有同商品在途交易等：提示失败，等 purchaseStream 收尾。
      if (mounted) {
        setState(() => _busy = false);
        _toast(context, l.wallet_payFail);
      }
    }
  }

  /// 内购结果回包：成功庆祝（余额已由 IapService 刷过）；取消静默；失败 toast。
  Future<void> _onIapResult(IapResult r) async {
    if (!mounted) return;
    setState(() => _busy = false);
    final l = AppLocalizations.of(context);
    switch (r.kind) {
      case IapResultKind.success:
        _loadPaidCoins();
        await showRechargeCelebration(context, r.coins);
        break;
      case IapResultKind.verifyFail:
        _toast(context, l.wallet_iapVerifyFail);
        break;
      case IapResultKind.error:
        _toast(context, l.wallet_payFail);
        break;
      case IapResultKind.canceled:
        break;
    }
  }

  // 充值走 Stripe Checkout 托管收银台（浏览器/Custom Tab 打开网页收银）。
  // 为什么不用原生 PaymentSheet：国产 ROM（OPPO/ColorOS 等）的「安全键盘」会劫持
  // 原生卡号输入框——卡号框无论怎么点都聚不上焦、国家/地区下拉点不开；而托管收银台是
  // 标准网页（普通系统键盘+可见光标+真实支付宝二维码+正常 HTML 国家下拉），输入顺畅。
  // 这是治本方案，不是兜底。付款在网页完成→用户返回 App→生命周期 resume 触发查账，
  // 鹰币由后端 webhook 异步到账（与原生方案同一条 webhook，零改动）。
  Future<void> _startCheckout(RechargePack pack) async {
    final l = AppLocalizations.of(context);
    // 先在 async gap 前拿 locale；之后不要再访问 context（lint：use_build_context_synchronously）。
    final locale = Localizations.localeOf(context).languageCode;
    if (!auth.loggedIn) {
      _toast(context, l.wallet_loginFirst);
      return;
    }
    setState(() => _busy = true);
    try {
      // 发票邮箱：用户在「发票邮箱」页设过就用它，否则回退到登录邮箱。
      // 透传给后端 → Stripe Checkout 预填 customer_email，收据也发到这里。
      var email = await AppSettings.invoiceEmail();
      if (email.isEmpty) email = auth.profile?.email ?? '';
      // App 当前语言透传给后端 → Stripe Checkout，托管页跟 App 语言走（中/英/日/韩/法/阿）。
      final session = await Api.createCheckoutSession(pack.id,
          email: email, locale: locale);
      final uri = Uri.parse(session.checkoutUrl);
      // 记下这笔订单，等用户从浏览器回来时查账。
      _pendingOrderNo = session.orderNo;
      _pendingCoins = session.coinsValue;
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView, // Chrome Custom Tab：付完点关闭即回 App
      );
      if (!ok) {
        // 退而用外部浏览器（极少数设备无 Custom Tab）。
        final ok2 =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok2 && mounted) {
          _pendingOrderNo = null;
          _toast(context, l.wallet_openPayFail);
        }
      }
    } on ApiException catch (e) {
      _pendingOrderNo = null;
      if (mounted) _toast(context, e.message);
    } catch (_) {
      _pendingOrderNo = null;
      if (mounted) _toast(context, l.wallet_payFail);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // 用户从 Stripe 托管收银台返回 App：轮询订单是否到账（webhook 异步记账，给它几秒窗口）。
  Future<void> _verifyPendingOrder() async {
    final orderNo = _pendingOrderNo;
    if (orderNo == null) return;
    _verifying = true;
    try {
      var paid = false;
      // 最多查 8 次 × 2s ≈ 16s，覆盖 webhook 落地延迟。
      for (var i = 0; i < 8; i++) {
        try {
          paid = await Api.isOrderPaid(orderNo);
        } catch (_) {
          paid = false;
        }
        if (paid) break;
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
      }
      if (!mounted) return;
      if (paid) {
        final coins = _pendingCoins;
        _pendingOrderNo = null;
        _pendingCoins = 0;
        await auth.refresh();
        _loadPaidCoins();
        if (!mounted) return;
        await showRechargeCelebration(context, coins);
      }
      // 未到账：可能用户取消或未付完，不打扰（保留 _pendingOrderNo=null 让其重来）。
      else {
        _pendingOrderNo = null;
      }
    } finally {
      _verifying = false;
    }
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15101D), Color(0xFF7F6BFF), Color(0xFFFF4F9B)],
          stops: [0, 0.58, 1],
        ),
        boxShadow: [
          BoxShadow(color: FF.purple.withValues(alpha: 0.35), blurRadius: 28),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.monetization_on_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).wallet_balanceLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    ListenableBuilder(
                      listenable: auth,
                      builder: (context, _) => Text(
                        auth.loggedIn
                            ? _coins(auth.profile?.balance ?? 0)
                            : AppLocalizations.of(context).wallet_loginToView,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: auth.loggedIn ? 38 : 22,
                            height: 1,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              // 右上 V 级别徽章（段位渐变 + 发光）。充得越多越尊贵。
              ListenableBuilder(
                listenable: auth,
                builder: (context, _) =>
                    (auth.loggedIn && _paidCoins != null)
                        ? _levelBadge(levelForCoins(_paidCoins!))
                        : const SizedBox.shrink(),
              ),
            ],
          ),
          // 升级进度条（面子系统：累计充值 → V 级别 → 段位光效）。
          ListenableBuilder(
            listenable: auth,
            builder: (context, _) => (auth.loggedIn && _paidCoins != null)
                ? _levelProgress(_paidCoins!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// V 级别徽章：段位渐变填充 + 发光，「V12 · 入门」。
  Widget _levelBadge(int level) {
    final tier = levelTier(level);
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: tier.gradient,
        boxShadow: [
          BoxShadow(color: tier.color.withValues(alpha: 0.5), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 15),
          const SizedBox(width: 4),
          Text('V$level',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 5),
          Text(tierName(tier, l),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  /// 升级进度：当前等级内进度 + 「再充 $X 升 V(n+1)」催充。已 V99 显示封顶。
  Widget _levelProgress(int paidCoins) {
    final l = AppLocalizations.of(context);
    final level = levelForCoins(paidCoins);
    final isMax = level >= 99;
    final progress = levelProgress(paidCoins);
    final gapUsd = _usd(coinsToNextLevel(paidCoins));
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  isMax
                      ? l.wallet_legendPeak
                      : l.wallet_toLevelFmt((level + 1).toString()),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(l.wallet_paidUsdFmt(_usd(paidCoins)),
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: isMax ? 1.0 : progress.clamp(0.04, 1.0),
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          if (!isMax) ...[
            const SizedBox(height: 6),
            Text(l.wallet_topUpToLevelFmt(gapUsd, (level + 1).toString()),
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  /// 等级值鹰币 → 美金文案（谈钱用美金）：$10 / $4.99。
  static String _usd(int coins) {
    final v = coins / 100.0;
    if (v == v.roundToDouble()) return '\$${v.toStringAsFixed(0)}';
    return '\$${v.toStringAsFixed(2)}';
  }

  /// 余额显示：≥1M → "1.2M"（避免在卡里换行 `1,000,| 000`）；
  /// <1M → 千分逗号（精确到位）。跨语言通用 ASCII。
  static String _coins(double v) {
    final n = v.toInt();
    if (n >= 1000000) {
      final m = n / 1000000;
      return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}M';
    }
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// 充值到账庆祝（仪式感：弹性冲击进场 → 停留 + 流光 + 抖一下 → 缓慢淡出）。
Future<void> showRechargeCelebration(BuildContext context, int coins) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppLocalizations.of(context).wallet_successBarrier,
    barrierColor: Colors.black.withValues(alpha: 0.64),
    transitionDuration: const Duration(milliseconds: 460),
    pageBuilder: (_, _, _) => _RechargeCelebration(coins: coins),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      child: child,
    ),
  );
}

class _RechargeCelebration extends StatefulWidget {
  final int coins;
  const _RechargeCelebration({required this.coins});
  @override
  State<_RechargeCelebration> createState() => _RechargeCelebrationState();
}

class _RechargeCelebrationState extends State<_RechargeCelebration> {
  @override
  void initState() {
    super.initState();
    // 停留足够久再慢慢退场（别一闪就没）。
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coinsText = _WalletScreenState._coins(widget.coins.toDouble());
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 124,
              height: 124,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD479),
                    Color(0xFFFF7AB8),
                    Color(0xFF8A6BFF)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                      color: FF.gold.withValues(alpha: 0.55),
                      blurRadius: 46,
                      spreadRadius: 4),
                  BoxShadow(
                      color: FF.purple.withValues(alpha: 0.45),
                      blurRadius: 60),
                ],
              ),
              child: const Icon(Icons.monetization_on_rounded,
                  color: Colors.white, size: 64),
            )
                .animate()
                .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1, 1),
                    duration: 680.ms,
                    curve: Curves.elasticOut)
                .fadeIn(duration: 240.ms)
                .then(delay: 360.ms)
                .shimmer(duration: 1100.ms, color: Colors.white)
                .then()
                .shake(
                    hz: 3,
                    rotation: 0,
                    offset: const Offset(2, 0),
                    duration: 520.ms),
            const SizedBox(height: 26),
            gradientText(
              '+$coinsText',
              size: 46,
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFD479), Color(0xFFFF7AB8)]),
            )
                .animate()
                .fadeIn(delay: 240.ms, duration: 360.ms)
                .slideY(begin: 0.4, end: 0, curve: Curves.easeOutBack),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).wallet_successTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700))
                .animate()
                .fadeIn(delay: 420.ms, duration: 360.ms),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).wallet_tapAnywhere,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12))
                .animate()
                .fadeIn(delay: 900.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

/// 剧集伙伴中心
class PartnerScreen extends StatelessWidget {
  const PartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    final metrics = [
      ('24', l.creator_statSeries),
      ('8.4M', l.creator_statPlays),
      ('¥12K', l.creator_statShare),
    ];
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
              children: [
                _backTopbar(context, l.creator_title),
                const SizedBox(height: 18),
                Glass(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Row(
                    children: [
                      for (var i = 0; i < metrics.length; i++) ...[
                        Expanded(
                          child: Column(
                            children: [
                              gradientText(metrics[i].$1, size: 22),
                              const SizedBox(height: 4),
                              Text(metrics[i].$2,
                                  style: TextStyle(
                                      color: p.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (i != metrics.length - 1)
                          Container(width: 1, height: 30, color: p.line),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: l.creator_applyLabel,
                  height: 52,
                  onTap: () => _toast(context, l.creator_applyToast),
                ),
                const SizedBox(height: 22),
                _menuList(context, [
                  l.creator_menuRequirement,
                  l.creator_menuRevenue,
                  l.creator_menuLangPriv,
                  l.about_aboutTitleFmt('FalconFlix'),
                ], onItemTap: (idx) {
                  if (idx == 3) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutScreen()));
                  } else {
                    final labels = [
                      l.creator_menuRequirement,
                      l.creator_menuRevenue,
                      l.creator_menuLangPriv,
                    ];
                    _toast(context, l.common_comingSoonFmt(labels[idx]));
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 邀请好友：把用户自己的邀请码做成可炫耀、可一键复制分享的页面。
/// 真实数据=auth.profile.inviteCode；无虚构邀请人数/收益。
class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    final steps = [
      (l.invite_step1Title, l.invite_step1Sub),
      (l.invite_step2Title, l.invite_step2Sub),
      (l.invite_step3Title, l.invite_step3Sub),
    ];
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListenableBuilder(
              listenable: auth,
              builder: (context, _) {
                final code = auth.profile?.inviteCode ?? '';
                final hasCode = auth.loggedIn && code.isNotEmpty;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
                  children: [
                    _backTopbar(context, l.invite_title),
                    const SizedBox(height: 20),
                    _hero(context),
                    const SizedBox(height: 20),
                    _codeCard(context, code, hasCode),
                    const SizedBox(height: 22),
                    Text(l.invite_stepsTitle,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Glass(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      color: p.day ? p.card : FF.glassFill,
                      border: p.line,
                      child: Column(
                        children: [
                          for (var i = 0; i < steps.length; i++)
                            _stepRow(i + 1, steps[i].$1, steps[i].$2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    GradientButton(
                      label: hasCode
                          ? l.invite_copyMessage
                          : l.invite_loginToGet,
                      icon: hasCode
                          ? Icons.ios_share_rounded
                          : Icons.lock_outline_rounded,
                      height: 52,
                      onTap: () {
                        if (!hasCode) {
                          _toast(context, l.invite_loginToGen);
                          return;
                        }
                        Clipboard.setData(
                            ClipboardData(text: l.invite_messageTemplateFmt(code)));
                        _toast(context, l.invite_messageCopied);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15101D), Color(0xFF7F6BFF), Color(0xFFFF4F9B)],
          stops: [0, 0.58, 1],
        ),
        boxShadow: [
          BoxShadow(color: FF.purple.withValues(alpha: 0.35), blurRadius: 30),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.card_giftcard_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.invite_bigTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(l.invite_bigSub,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCard(BuildContext context, String code, bool hasCode) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    return Glass(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      color: p.day ? p.card : FF.glassFill,
      border: p.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.invite_myCode,
              style: TextStyle(color: p.textMuted, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: gradientText(
                  hasCode ? code.toUpperCase() : '——————',
                  size: 34,
                  gradient: FF.brandGradient,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!hasCode) {
                    _toast(context, l.invite_loginToGen);
                    return;
                  }
                  Clipboard.setData(ClipboardData(text: code));
                  _toast(context, l.invite_codeCopiedFmt(code));
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.day
                        ? Colors.black.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, color: p.text, size: 15),
                      const SizedBox(width: 6),
                      Text(l.invite_copyBtn,
                          style: TextStyle(
                              color: p.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int n, String title, String desc) {
    final p = Pal.now();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, gradient: FF.brandGradient),
            child: Text('$n',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(desc,
                    style: TextStyle(
                        color: p.textMuted, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 关于 FalconFlix：品牌头图（图2 霓虹金鹰）+ 名称 + 版本 + 版权。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
              children: [
                _backTopbar(context, AppLocalizations.of(context).about_aboutTitleFmt('FalconFlix')),
                const SizedBox(height: 28),
                // 品牌头图：图1（金鹰 + Falcon Flix 字标），圆角 + 柔光晕。
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: FF.hot.withValues(alpha: p.day ? 0.22 : 0.40),
                          blurRadius: 38,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: FF.blue.withValues(alpha: p.day ? 0.16 : 0.30),
                          blurRadius: 46,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset('assets/brand/logo_mark.png',
                          fit: BoxFit.cover),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 520.ms)
                    .scale(
                        begin: const Offset(0.86, 0.86),
                        end: const Offset(1, 1),
                        duration: 620.ms,
                        curve: Curves.easeOutBack),
                const SizedBox(height: 22),
                Center(
                  child: Text(
                    AppLocalizations.of(context).about_tagline,
                    style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    kAppVersion,
                    style: TextStyle(
                        color: p.textMuted,
                        fontSize: 12,
                        letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 30),
                Glass(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Text(
                    AppLocalizations.of(context).about_body,
                    style: TextStyle(
                        color: p.textSecondary, fontSize: 13.5, height: 1.6),
                  ),
                ),
                const SizedBox(height: 20),
                // 法律信息入口
                Glass(
                  radius: 16,
                  padding: EdgeInsets.zero,
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Column(
                    children: [
                      _legalRow(context, Icons.description_outlined, AppLocalizations.of(context).about_userAgreement,
                          const TermsScreen()),
                      Divider(height: 1, color: p.line, indent: 52),
                      _legalRow(context, Icons.privacy_tip_outlined, AppLocalizations.of(context).about_privacyPolicy,
                          const PrivacyScreen()),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                // 公司主体落款
                Center(
                  child: Text(
                    kCompanyName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    '© 2026 $kCompanyName · All rights reserved',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11,
                        height: 1.5,
                        letterSpacing: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _legalRow(
    BuildContext context, IconData icon, String title, Widget page) {
  final p = Pal.now();
  return ListTile(
    dense: true,
    leading: Icon(icon, color: p.textMuted, size: 20),
    title: Text(title,
        style: TextStyle(
            color: p.text, fontSize: 15, fontWeight: FontWeight.w500)),
    trailing: Icon(Icons.chevron_right, color: p.textMuted, size: 18),
    onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (_) => page)),
  );
}

/// 法律长文页通用骨架：返回栏 + 标题 + 更新日期 + 分节正文 + 落款。
class _LegalDoc extends StatelessWidget {
  const _LegalDoc({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<List<String>> sections; // 每节 [小标题, 正文...]

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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 48),
              children: [
                _backTopbar(context, title),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context).about_legalUpdatedFmt(kLegalUpdated),
                  style: TextStyle(color: p.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Text(
                  intro,
                  style: TextStyle(
                      color: p.textSecondary, fontSize: 13.5, height: 1.7),
                ),
                const SizedBox(height: 8),
                for (final s in sections) ...[
                  const SizedBox(height: 18),
                  Text(
                    s.first,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  for (final para in s.skip(1)) ...[
                    Text(
                      para,
                      style: TextStyle(
                          color: p.textSecondary, fontSize: 13.5, height: 1.7),
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
                const SizedBox(height: 26),
                Divider(height: 1, color: p.line),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).about_operatingEntity,
                  style: TextStyle(
                      color: p.text, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  kCompanyUEN.isEmpty
                      ? kCompanyName
                      : '$kCompanyName（UEN：$kCompanyUEN）',
                  style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).about_contactEmailFmt(kLegalEmail),
                  style: TextStyle(
                      color: p.textSecondary, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 14),
                Text(
                  '© 2026 $kCompanyName · All rights reserved',
                  style: TextStyle(color: p.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 用户协议（服务条款）——按当前语言取内容（lib/data/legal_content.dart）
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = termsDoc(Localizations.localeOf(context).languageCode);
    return _LegalDoc(title: d.title, intro: d.intro, sections: d.sections);
  }
}

/// 隐私政策——按当前语言取内容
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = privacyDoc(Localizations.localeOf(context).languageCode);
    return _LegalDoc(title: d.title, intro: d.intro, sections: d.sections);
  }
}

/// 我的收藏：把用户点过「收藏」的剧目列出来，点进即看详情/继续追。
/// 数据来自带 token 的 /short/list（isCollect），由 Api.collectedDramas() 提供，
/// 纯前端、无需后端新端点。下拉可刷新（refresh=true 丢缓存重拉）。
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<ShortDrama>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
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
      final list = await Api.collectedDramas(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _items = list;
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
    ).then((_) {
      // 详情里可能取消了收藏：回来刷新一下（用已同步的缓存即可，不强拉网）。
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
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
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
                  child: _backTopbar(context, l.me_rowCollections),
                ),
                Expanded(child: _content(p, l)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Pal p, AppLocalizations l) {
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
    final items = _items ?? const [];
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border_rounded, color: p.textMuted, size: 52),
              const SizedBox(height: 14),
              Text(l.collect_emptyTitle,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l.collect_emptyBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.textMuted, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: FF.hot,
      onRefresh: () => _load(refresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 18,
          crossAxisSpacing: 10,
          childAspectRatio: 0.54,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _open(items[i]),
          child: _CollectCard(p: p, item: items[i]),
        ).animate(delay: (40 * i).ms).fadeIn(duration: 320.ms).slideY(
            begin: 0.08, curve: Curves.easeOut),
      ),
    );
  }
}

class _CollectCard extends StatelessWidget {
  final Pal p;
  final ShortDrama item;
  const _CollectCard({required this.p, required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.image.isEmpty)
                  Container(color: const Color(0xFF201A15))
                else
                  CachedNetworkImage(
                    imageUrl: item.image,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: const Color(0xFF201A15)),
                    errorWidget: (_, _, _) =>
                        Container(color: const Color(0xFF201A15)),
                  ),
                // 右上角金色收藏角标，呼应侧栏「已收藏」金书签。
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.42),
                    ),
                    child: const Icon(Icons.bookmark_rounded,
                        color: FF.gold, size: 15),
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

/// 自动解锁设置：开启后，点按已锁剧集直接用鹰币解锁、免每次弹窗确认。
/// 纯本地偏好（AppSettings.autoUnlock），由详情页解锁流程读取。
class AutoUnlockScreen extends StatefulWidget {
  const AutoUnlockScreen({super.key});
  @override
  State<AutoUnlockScreen> createState() => _AutoUnlockScreenState();
}

class _AutoUnlockScreenState extends State<AutoUnlockScreen> {
  bool _on = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    AppSettings.autoUnlock().then((v) {
      if (mounted) setState(() {
            _on = v;
            _loaded = true;
          });
    });
  }

  Future<void> _set(bool v) async {
    setState(() => _on = v);
    await AppSettings.setAutoUnlock(v);
    if (mounted) {
      final l = AppLocalizations.of(context);
      _toast(context, v ? l.au_toggleOnToast : l.au_toggleOffToast);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
              children: [
                _backTopbar(context, l.au_title),
                const SizedBox(height: 20),
                // 头图卡：图标 + 一句话点题
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 20),
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: FF.brandGradient,
                          boxShadow: [
                            BoxShadow(
                                color: FF.purple.withValues(alpha: 0.4),
                                blurRadius: 26),
                          ],
                        ),
                        child: Icon(
                            _on
                                ? Icons.lock_open_rounded
                                : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 34),
                      ),
                      const SizedBox(height: 14),
                      Text(l.au_introTitle,
                          style: TextStyle(
                              color: p.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(l.au_introBody,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: p.textMuted, fontSize: 12.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // 开关行
                Glass(
                  radius: 16,
                  padding: const EdgeInsets.fromLTRB(18, 6, 10, 6),
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l.au_toggleLabel,
                                style: TextStyle(
                                    color: p.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(_on ? l.au_on : l.au_off,
                                style: TextStyle(
                                    color: _on ? FF.hot : p.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _on,
                        onChanged: _loaded ? _set : null,
                        activeColor: Colors.white,
                        activeTrackColor: FF.hot,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor:
                            p.day ? Colors.black12 : Colors.white24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // 规则说明
                Glass(
                  radius: 16,
                  padding: const EdgeInsets.all(16),
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RuleLine(l.au_rule1),
                      const SizedBox(height: 10),
                      _RuleLine(l.au_rule2),
                      const SizedBox(height: 10),
                      _RuleLine(l.au_rule3),
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
}

class _RuleLine extends StatelessWidget {
  final String text;
  const _RuleLine(this.text);
  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, color: FF.purple, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: p.textSecondary, fontSize: 12.5, height: 1.5)),
        ),
      ],
    );
  }
}

/// 充值记录：本人充值订单（GET /order/list?type=1）倒序列表。
/// 显示到账鹰币 / 实付美金 / 状态 / 时间；纯真实数据，无虚构。
class RechargeHistoryScreen extends StatefulWidget {
  const RechargeHistoryScreen({super.key});
  @override
  State<RechargeHistoryScreen> createState() => _RechargeHistoryScreenState();
}

class _RechargeHistoryScreenState extends State<RechargeHistoryScreen> {
  List<RechargeRecord>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!auth.loggedIn) {
      setState(() {
        _loading = false;
        _error = null;
        _items = const [];
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
        _error = e is ApiException
            ? e.message
            : AppLocalizations.of(context).wallet_loadFailed;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                  child: _backTopbar(context, l.rh_title),
                ),
                const SizedBox(height: 12),
                Expanded(child: _body(l)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l) {
    final p = Pal.now();
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(strokeWidth: 2.4));
    }
    if (!auth.loggedIn) {
      return _empty(Icons.lock_outline_rounded, l.rh_loginToView);
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: p.textMuted, size: 30),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: p.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line),
                ),
                child: Text(l.common_retry,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    }
    final items = _items ?? const <RechargeRecord>[];
    if (items.isEmpty) {
      return _empty(Icons.receipt_long_outlined, l.rh_emptyBody);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 40),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _row(items[i]),
      ),
    );
  }

  Widget _empty(IconData icon, String text) {
    final p = Pal.now();
    return ListView(
      // 包成可滚动，保证下拉刷新手势在空态也可用
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, color: p.textMuted, size: 40),
        const SizedBox(height: 14),
        Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.textSecondary, fontSize: 13.5, height: 1.6)),
      ],
    );
  }

  Widget _row(RechargeRecord r) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    final paid = r.paid;
    final pending = r.status == '0';
    final badgeColor = paid
        ? FF.hot
        : (pending ? FF.gold : p.textMuted);
    String when = r.createTime;
    if (when.length >= 16) when = when.substring(0, 16);
    return Glass(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: p.day ? p.card : FF.glassFill,
      border: p.line,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: paid ? FF.brandGradient : null,
              color: paid
                  ? null
                  : (p.day
                      ? Colors.black.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(Icons.monetization_on_rounded,
                color: paid ? Colors.white : FF.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    r.goodsName.isEmpty
                        ? l.rh_fallback
                        : localizeGoodsName(r.goodsName, l),
                    style: TextStyle(
                        color: p.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(when,
                    style: TextStyle(color: p.textMuted, fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(r.priceLabel,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(rechargeStatusLabel(r.statusKey(), l),
                    style: TextStyle(
                        color: badgeColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 发票邮箱：设置充值收据要发送到的邮箱。
/// 本地保存（AppSettings.invoiceEmail），充值时透传给 Stripe Checkout 作 customer_email。
class InvoiceEmailScreen extends StatefulWidget {
  const InvoiceEmailScreen({super.key});
  @override
  State<InvoiceEmailScreen> createState() => _InvoiceEmailScreenState();
}

class _InvoiceEmailScreenState extends State<InvoiceEmailScreen> {
  final _ctrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  String _accountEmail = '';

  @override
  void initState() {
    super.initState();
    _accountEmail = auth.profile?.email ?? '';
    AppSettings.invoiceEmail().then((v) {
      if (!mounted) return;
      setState(() {
        _ctrl.text = v.isNotEmpty ? v : _accountEmail;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final v = _ctrl.text.trim();
    if (!AppSettings.isValidEmail(v)) {
      _toast(context, l.re_invalidEmail);
      return;
    }
    setState(() => _saving = true);
    await AppSettings.setInvoiceEmail(v);
    if (!mounted) return;
    setState(() => _saving = false);
    _toast(context, l.re_saved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 40),
              children: [
                _backTopbar(context, l.re_title),
                const SizedBox(height: 20),
                Glass(
                  radius: 16,
                  padding: const EdgeInsets.all(18),
                  color: p.day ? p.card : FF.glassFill,
                  border: p.line,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.mark_email_read_rounded,
                              color: FF.purple, size: 20),
                          const SizedBox(width: 8),
                          Text(l.re_label,
                              style: TextStyle(
                                  color: p.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(l.re_body,
                          style: TextStyle(
                              color: p.textMuted,
                              fontSize: 12.5,
                              height: 1.55)),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: p.day
                              ? Colors.black.withValues(alpha: 0.03)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.line),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _ctrl,
                          enabled: _loaded,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: TextStyle(color: p.text, fontSize: 15),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'name@example.com',
                            hintStyle:
                                TextStyle(color: p.textMuted, fontSize: 15),
                            icon: Icon(Icons.alternate_email_rounded,
                                color: p.textMuted, size: 18),
                          ),
                        ),
                      ),
                      if (_accountEmail.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _loaded
                              ? () => setState(
                                  () => _ctrl.text = _accountEmail)
                              : null,
                          child: Text(l.re_useAccountEmailFmt(_accountEmail),
                              style: TextStyle(
                                  color: FF.purple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _saving
                    ? Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: FF.brandGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        ),
                      )
                    : GradientButton(
                        label: l.re_save,
                        icon: Icons.check_rounded,
                        height: 52,
                        onTap: _loaded ? _save : () {},
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

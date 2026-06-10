import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/product.dart';
import '../theme.dart';
import '../ui/daynight.dart';

/// 带货商品流（P3）：Ghost Rail 点击 → 底部商品快卡 sheet → 商品详情 → 结算。
/// 快卡=亮色半透明玻璃（播放页之上，规则：默认亮、不大面积挡视频）。
/// 商品详情/结算=日夜自适应工具页。

const _sheetBg = Color(0xF2FFFFFF);
const _ink = Color(0xFF130F1B);
const _inkSoft = Color(0x99130F1B);
const _rowBg = Color(0xFFF4F2F8);
const _pinkCoral = LinearGradient(colors: [Color(0xFFFF4F9B), Color(0xFFFF7F62)]);

Widget productImage(String url,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (url.isEmpty) {
    return Container(width: width, height: height, color: const Color(0xFFE7E2EE));
  }
  if (url.startsWith('assets/')) {
    return Image.asset(url, width: width, height: height, fit: fit);
  }
  return CachedNetworkImage(
      imageUrl: url, width: width, height: height, fit: fit);
}

void _toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

/// 底部商品快卡（仅用户点 Ghost Rail 后弹出，非常驻）
void showProductQuickSheet(BuildContext context,
    {required List<Product> products}) {
  if (products.isEmpty) return;
  final l = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 18 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 46,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: const Color(0x2E130F1B),
                  borderRadius: BorderRadius.circular(999)),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.local_mall_rounded,
                  color: Color(0xFFFF4F9B), size: 18),
              const SizedBox(width: 6),
              Text(
                  products.length > 1
                      ? l.com_sceneSameFmt(products.length.toString())
                      : l.com_sameInDrama,
                  style: const TextStyle(
                      color: _ink, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _quickRow(context, products[i]),
          ],
        ],
      ),
    ),
  );
}

Widget _quickRow(BuildContext context, Product p) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
      _openDetail(context, p);
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: _rowBg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: productImage(p.imageUrl, width: 64, height: 64),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(p.merchant,
                    style: const TextStyle(color: _inkSoft, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(p.priceLabel,
                        style: const TextStyle(
                            color: Color(0xFFFF4F9B),
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _openCheckout(context, p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                            gradient: _pinkCoral,
                            borderRadius: BorderRadius.circular(999)),
                        child: Text(
                            AppLocalizations.of(context).com_buyNow,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
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

void _openDetail(BuildContext context, Product p) {
  Navigator.push(
      context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
}

void _openCheckout(BuildContext context, Product p) {
  Navigator.push(
      context, MaterialPageRoute(builder: (_) => CheckoutScreen(product: p)));
}

/// 商品详情（日夜工具页）
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final d = product;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  AspectRatio(
                      aspectRatio: 1, child: productImage(d.imageUrl)),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.42),
                            border: Border.all(color: Colors.white24)),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          gradient: _pinkCoral,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(d.badge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 12),
                    Text(d.title,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(d.subtitle,
                        style: TextStyle(color: p.textMuted, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(d.priceLabel,
                            style: const TextStyle(
                                color: FF.hot,
                                fontSize: 30,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                              d.inStock ? l.com_inStock : l.com_outOfStock,
                              style: TextStyle(
                                  color: d.inStock ? FF.teal : p.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _infoRow(p, l.com_infoMerchant, d.merchant),
                    _infoRow(p, l.com_infoEpisode, d.episodeId),
                    _infoRow(p, l.com_infoScene,
                        l.com_sceneTimeFmt((d.startMs / 1000).round().toString())),
                    const SizedBox(height: 18),
                    Text(l.com_descTitle,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(l.com_descBody,
                        style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 13,
                            height: 1.7)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  18, 12, 18, 12 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: p.pageBg,
                border: Border(top: BorderSide(color: p.line)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toast(context, l.com_addCartToast),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: p.chipBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: p.line)),
                      child: Text(l.com_addCart,
                          style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openCheckout(context, d),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: FF.brandGradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                                color: FF.hot.withValues(alpha: 0.3),
                                blurRadius: 20),
                          ],
                        ),
                        child: Text(l.com_buyNow,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(Pal p, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
                width: 72,
                child: Text(k,
                    style: TextStyle(color: p.textMuted, fontSize: 13))),
            Expanded(
              child: Text(v,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

/// 结算（日夜工具页）
class CheckoutScreen extends StatefulWidget {
  final Product product;
  const CheckoutScreen({super.key, required this.product});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _method = 0;

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final d = widget.product;
    final l = AppLocalizations.of(context);
    final methods = <(String, String, IconData)>[
      (
        l.com_methodCoin,
        l.com_methodCoinBalanceFmt('2,480'),
        Icons.account_balance_wallet_rounded
      ),
      (l.com_methodWechat, '', Icons.chat_rounded),
      (l.com_methodAlipay, '', Icons.account_balance_rounded),
      ('Apple Pay', '', Icons.apple_rounded),
    ];
    return Scaffold(
      backgroundColor: p.pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 18, 8),
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
                          color: p.day
                              ? Colors.white
                              : const Color(0x18FFFFFF),
                          border: Border.all(color: p.line)),
                      child: Icon(Icons.arrow_back_rounded,
                          color: p.text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l.com_confirmOrder,
                      style: TextStyle(
                          color: p.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  // 商品行
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.line)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: productImage(d.imageUrl, width: 64, height: 64),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(d.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: p.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(l.com_qtyOne,
                                  style: TextStyle(
                                      color: p.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(d.priceLabel,
                            style: TextStyle(
                                color: p.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(l.com_payMethod,
                      style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.line)),
                    child: Column(
                      children: [
                        for (var i = 0; i < methods.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => _method = i),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(methods[i].$3,
                                      color: p.text, size: 20),
                                  const SizedBox(width: 12),
                                  Text(methods[i].$1,
                                      style: TextStyle(
                                          color: p.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 8),
                                  if (methods[i].$2.isNotEmpty)
                                    Text(methods[i].$2,
                                        style: TextStyle(
                                            color: p.textMuted, fontSize: 12)),
                                  const Spacer(),
                                  Icon(
                                      i == _method
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: i == _method ? FF.hot : p.textMuted,
                                      size: 20),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _line(p, l.com_lineAmount, d.priceLabel),
                  _line(p, l.com_lineCoupon, l.com_lineCouponUnused,
                      tappable: true),
                  _line(p, l.com_lineShipping, l.com_lineShippingFree),
                ],
              ),
            ),
            // 底部结算条
            Container(
              padding: EdgeInsets.fromLTRB(
                  18, 12, 18, 12 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: p.pageBg,
                border: Border(top: BorderSide(color: p.line)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.com_total,
                          style:
                              TextStyle(color: p.textMuted, fontSize: 12)),
                      Text(d.priceLabel,
                          style: const TextStyle(
                              color: FF.hot,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _toast(context, l.com_submitToast);
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (context.mounted) Navigator.pop(context);
                        });
                      },
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: FF.brandGradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                                color: FF.hot.withValues(alpha: 0.3),
                                blurRadius: 20),
                          ],
                        ),
                        child: Text(l.com_submitOrder,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(Pal p, String k, String v, {bool tappable = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Text(k, style: TextStyle(color: p.textMuted, fontSize: 13)),
            const Spacer(),
            Text(v,
                style: TextStyle(
                    color: tappable ? FF.hot : p.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            if (tappable)
              Icon(Icons.chevron_right, color: p.textMuted, size: 16),
          ],
        ),
      );
}

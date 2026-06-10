import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';

import '../api/api.dart';
import '../auth.dart';

/// App Store 商店不可用 / 商品查询失败（钱包页据此显示错误卡 + 重试）。
class IapStoreException implements Exception {}

/// 一次内购的最终结果（钱包页订阅：成功庆祝 / 失败 toast / 取消静默）。
enum IapResultKind { success, verifyFail, error, canceled }

class IapResult {
  final IapResultKind kind;
  final int coins; // success 时本单到账鹰币
  const IapResult(this.kind, {this.coins = 0});
}

/// 苹果内购服务（仅 iOS）：充值鹰币改走 StoreKit（App Store 审核 3.1.1，
/// 数字内容禁用网页收银台）。Android 仍走 Stripe 网页流，不经过这里。
///
/// 流程：钱包页 buyConsumable 拉起支付 → 全局 purchaseStream 收到 purchased
/// → POST /recharge/apple/verify 后端向 Apple 验真并加币 → 成功才 completePurchase
/// （消耗型）→ auth.refresh 刷余额 → 广播结果给钱包页。
/// 验证失败/网络中断时不 finish：StoreKit 下次启动会自动重放未完成交易，
/// init 的全局监听把它兜回来补验证（审核员杀 App 重试就靠这条路）。
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  final StreamController<IapResult> _results =
      StreamController<IapResult>.broadcast();

  /// 购买结果广播。
  Stream<IapResult> get results => _results.stream;

  /// App 启动时调用一次（main.dart）：挂全局 purchaseStream 监听。
  /// 非 iOS 直接返回（Android 不碰 StoreKit/Billing）。
  void init() {
    if (!Platform.isIOS) return;
    _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
  }

  /// 按套餐的 appleProductId 集合查 App Store 商品，返回 id → 商品。
  /// 查不到的 id 自然缺席（调用方据此隐藏套餐）；商店不可用/查询出错抛 IapStoreException。
  Future<Map<String, ProductDetails>> queryProducts(Set<String> ids) async {
    if (ids.isEmpty) return const {};
    try {
      if (!await _iap.isAvailable()) throw IapStoreException();
      final resp = await _iap.queryProductDetails(ids);
      if (resp.error != null) throw IapStoreException();
      return {for (final p in resp.productDetails) p.id: p};
    } on IapStoreException {
      rethrow;
    } catch (_) {
      throw IapStoreException();
    }
  }

  /// 拉起消耗型购买。false = 未能拉起（调用方提示）；后续进展走 purchaseStream。
  Future<bool> buy(ProductDetails product) {
    return _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product));
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          // Apple 支付面板进行中（含家长审批 Ask to Buy）：等终态。
          break;
        case PurchaseStatus.canceled:
          // 用户在 Apple 支付面板取消：静默收尾。
          await _finishQuietly(p);
          _results.add(const IapResult(IapResultKind.canceled));
          break;
        case PurchaseStatus.error:
          await _finishQuietly(p);
          _results.add(const IapResult(IapResultKind.error));
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verify(p);
          break;
      }
    }
  }

  /// 收尾取消/失败的交易（finish 出错只吞掉，别把全局监听打挂）。
  Future<void> _finishQuietly(PurchaseDetails p) async {
    try {
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    } catch (_) {}
  }

  /// 送后端验证 → 成功才 finish。失败一律保留交易，等下次启动重放重试。
  Future<void> _verify(PurchaseDetails p) async {
    if (!Api.hasToken) {
      // 未登录（如冷启动重放时）：留着，登录后下次启动再补。
      return;
    }
    try {
      final coins = await Api.verifyApplePurchase(
        productId: p.productID,
        transactionId: p.purchaseID ?? '',
        payload: p.verificationData.serverVerificationData,
      );
      await _iap.completePurchase(p);
      await auth.refresh(); // 同步最新余额
      _results.add(IapResult(IapResultKind.success, coins: coins));
    } catch (_) {
      // 验证失败（422/400 票据无效）或网络中断：都不 finish，交易保留，
      // 下次启动 StoreKit 重放再试。给页面发一条结果，解除按钮并提示。
      _results.add(const IapResult(IapResultKind.verifyFail));
    }
  }
}

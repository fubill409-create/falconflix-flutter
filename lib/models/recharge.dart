import '../l10n/generated/app_localizations.dart';

/// 充值记录状态本地化（'paid'/'pending'/'canceled'/'processing' → 6 语标签）。
String rechargeStatusLabel(String statusKey, AppLocalizations l) {
  switch (statusKey) {
    case 'paid':
      return l.rch_statusPaid;
    case 'pending':
      return l.rch_statusPending;
    case 'canceled':
      return l.rch_statusCanceled;
    default:
      return l.rch_statusProcessing;
  }
}

/// 「N 鹰币」goodsName 客户端本地化：检测 zh 字面值并按当前语言重写。
/// 服务端目前只下发 zh 串；切英文/日韩/法/阿时这里改写。
String localizeGoodsName(String raw, AppLocalizations l) {
  if (raw.isEmpty) return raw;
  // 匹配 "100 鹰币" / "100鹰币" 这种 zh 字串
  final m = RegExp(r'^\s*(\d[\d,]*)\s*鹰币\s*$').firstMatch(raw);
  if (m != null) {
    return l.data_goodsCoinsFmt(m.group(1) ?? '');
  }
  return raw;
}

/// 充值套餐（后端 GET /recharge/list 的一行）。
/// rechargeAmount = 实付美金；amount = 总得鹰币（字符串）；giftAmount = 赠送金额。
class RechargePack {
  final int id;
  final double rechargeAmount; // 美金价
  final double giftAmount; // 赠送（美金口径，展示用）
  final String amount; // 总得鹰币

  const RechargePack({
    required this.id,
    required this.rechargeAmount,
    required this.giftAmount,
    required this.amount,
  });

  /// 总得鹰币（数字）。后端存字符串，可能带小数，统一取整展示。
  int get coins {
    final v = double.tryParse(amount.trim());
    return v == null ? 0 : v.round();
  }

  /// 美金价文案，如 $4.99 / $10。
  String get priceLabel {
    final v = rechargeAmount;
    if (v == v.roundToDouble()) return '\$${v.toStringAsFixed(0)}';
    return '\$${v.toStringAsFixed(2)}';
  }

  /// 赠送鹰币 = 总得鹰币 − 实付折算（实付美金 × 100）。后端把赠送并进了 amount。
  int get giftCoins {
    final base = (rechargeAmount * 100).round();
    final g = coins - base;
    return g > 0 ? g : 0;
  }

  /// 赠送率（%，相对实付）。用于"划算"角标，如 +10% / +30%。
  int get giftPercent {
    final base = (rechargeAmount * 100).round();
    if (base <= 0) return 0;
    return ((giftCoins / base) * 100).round();
  }

  /// 是否有「值得展示」的赠送（≥5%，过滤 +1 鹰币这种零头）。
  bool get hasGift => giftPercent >= 5;

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim()) ?? 0;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim()) ?? 0;
  }

  factory RechargePack.fromJson(Map<String, dynamic> j) => RechargePack(
        id: _i(j['id']),
        rechargeAmount: _d(j['rechargeAmount']),
        giftAmount: _d(j['giftAmount']),
        amount: (j['amount'] ?? '').toString(),
      );
}

/// 一条充值记录（后端 GET /order/list?type=1 的一行订单）。
/// 充值订单：goodsName = 「N 鹰币」、payPrice = 实付美金、status 见下、createTime = 下单时间。
class RechargeRecord {
  final String orderNo;
  final String goodsName; // 「N 鹰币」
  final String payPrice; // 实付美金（字符串，如 "19.99"）
  final String status; // 0=待支付 3=已到账 2/4=已取消 其它=处理中
  final String createTime; // 后端按 yyyy-MM-dd HH:mm:ss 序列化

  const RechargeRecord({
    required this.orderNo,
    required this.goodsName,
    required this.payPrice,
    required this.status,
    required this.createTime,
  });

  /// 是否已到账（充值订单到账状态为 "3"，与 /recharge/orderStatus 口径一致）。
  bool get paid => status == '3';

  /// 状态本地化标签（'0'/'3'/'2'/'4'/其它 → 待支付/已到账/已取消/处理中）。
  /// 需要 AppLocalizations，调用方在 build/有 context 处获取。
  /// 由调用方传 l 进来：UI 文件已有 `final l = AppLocalizations.of(context);`。
  /// 内部 key 见 ARB：`rch_statusPaid` / `rch_statusPending` / `rch_statusCanceled` / `rch_statusProcessing`.
  String statusKey() {
    switch (status) {
      case '3':
        return 'paid';
      case '0':
        return 'pending';
      case '2':
      case '4':
        return 'canceled';
      default:
        return 'processing';
    }
  }

  /// 美金价文案，如 $4.99 / $10。
  String get priceLabel {
    final v = double.tryParse(payPrice.trim());
    if (v == null) return payPrice;
    if (v == v.roundToDouble()) return '\$${v.toStringAsFixed(0)}';
    return '\$${v.toStringAsFixed(2)}';
  }

  factory RechargeRecord.fromJson(Map<String, dynamic> j) => RechargeRecord(
        orderNo: (j['orderNo'] ?? '').toString(),
        goodsName: (j['goodsName'] ?? '').toString(),
        payPrice: (j['payPrice'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        createTime: (j['createTime'] ?? '').toString(),
      );
}

/// 后端 POST /recharge/createPaymentIntent 的返回：拉起 Stripe PaymentSheet 所需。
class RechargeIntent {
  final String clientSecret;
  final String publishableKey;
  final String orderNo;
  final String coins; // 本单到账鹰币
  final String amount; // 本单实付美金
  final String currency;

  const RechargeIntent({
    required this.clientSecret,
    required this.publishableKey,
    required this.orderNo,
    required this.coins,
    required this.amount,
    required this.currency,
  });

  int get coinsValue {
    final v = double.tryParse(coins.trim());
    return v == null ? 0 : v.round();
  }

  factory RechargeIntent.fromJson(Map<String, dynamic> j) => RechargeIntent(
        clientSecret: (j['clientSecret'] ?? '').toString(),
        publishableKey: (j['publishableKey'] ?? '').toString(),
        orderNo: (j['orderNo'] ?? '').toString(),
        coins: (j['coins'] ?? '').toString(),
        amount: (j['amount'] ?? '').toString(),
        currency: (j['currency'] ?? 'usd').toString(),
      );
}

/// 后端 POST /recharge/createCheckoutSession 的返回：Stripe 托管收银台网页。
/// App 用浏览器（Chrome Custom Tab）打开 checkoutUrl，付完返回后轮询 /recharge/orderStatus。
/// 选托管页是因为国产 ROM 安全键盘会劫持原生 PaymentSheet 卡号框（点不进去、国家下拉点不开），
/// 而托管页是标准 HTML 输入（普通键盘+可见光标）+ HTML 国家下拉 + 真实支付宝二维码。
class CheckoutSession {
  final String checkoutUrl;
  final String orderNo;
  final String coins; // 本单到账鹰币
  final String amount; // 本单实付美金
  final String currency;

  const CheckoutSession({
    required this.checkoutUrl,
    required this.orderNo,
    required this.coins,
    required this.amount,
    required this.currency,
  });

  int get coinsValue {
    final v = double.tryParse(coins.trim());
    return v == null ? 0 : v.round();
  }

  factory CheckoutSession.fromJson(Map<String, dynamic> j) => CheckoutSession(
        checkoutUrl: (j['checkoutUrl'] ?? '').toString(),
        orderNo: (j['orderNo'] ?? '').toString(),
        coins: (j['coins'] ?? '').toString(),
        amount: (j['amount'] ?? '').toString(),
        currency: (j['currency'] ?? 'usd').toString(),
      );
}

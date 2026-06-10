import '../l10n/generated/app_localizations.dart';

/// 已购订单（整剧 / 单集）。对应后端 PlayletPurchasesPageVO（/record/purchases）。
class Purchase {
  final String orderNo;
  final String shortId;
  final String shortName;
  final String image;
  final String introduce;
  final String? categoryName;

  /// 单集购买时填，整剧时为 null。
  final String? episodeId;
  final String? episodeName;

  /// 订单实付金额 + 货币（如 "USD" / "CNY" / "EAGLE"）。
  final double payPrice;
  final String currencyType;

  /// 支付方式：1=鹰币 2=第三方（Stripe 等）。
  final String payType;

  final DateTime createTime;

  Purchase({
    required this.orderNo,
    required this.shortId,
    required this.shortName,
    required this.image,
    this.introduce = '',
    this.categoryName,
    this.episodeId,
    this.episodeName,
    required this.payPrice,
    required this.currencyType,
    required this.payType,
    required this.createTime,
  });

  /// 支付方式 i18n key（'coin'/'stripe'）。显示用 `payTypeLabel(l)`。
  String get payTypeKey {
    switch (payType) {
      case '1':
        return 'coin';
      case '2':
        return 'stripe';
      default:
        return 'other';
    }
  }

  String payTypeLabel(AppLocalizations l) {
    switch (payTypeKey) {
      case 'coin':
        return l.sheets_coinsShort;
      case 'stripe':
        return 'Stripe';
      default:
        return payType;
    }
  }

  /// 时间标签：详细到分钟的本地时间。
  String get timeLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    final t = createTime.toLocal();
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  /// 金额显示：USD/EAGLE/其他。鹰币位本地化。
  String priceLabel(AppLocalizations l) {
    if (currencyType.toUpperCase() == 'USD') {
      return '\$${payPrice.toStringAsFixed(2)} USD';
    }
    if (currencyType.toUpperCase() == 'EAGLE' || payType == '1') {
      // 鹰币按整数显示
      return l.data_goodsCoinsFmt(payPrice.toStringAsFixed(0));
    }
    return '${payPrice.toStringAsFixed(2)} $currencyType';
  }

  factory Purchase.fromJson(Map<String, dynamic> j) {
    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    double parsePrice(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return Purchase(
      orderNo: j['orderNo']?.toString() ?? '',
      shortId: j['shortId']?.toString() ?? '',
      shortName: j['shortName']?.toString() ?? '',
      image: j['image']?.toString() ?? '',
      introduce: j['introduce']?.toString() ?? '',
      categoryName: j['categoryName']?.toString(),
      episodeId: j['episodeId']?.toString(),
      episodeName: j['episodeName']?.toString(),
      payPrice: parsePrice(j['payPrice']),
      currencyType: j['currencyType']?.toString() ?? '',
      payType: j['payType']?.toString() ?? '',
      createTime: parseTime(j['createTime']),
    );
  }
}

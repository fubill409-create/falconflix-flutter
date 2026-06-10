import 'commerce_cue.dart';

/// 场景商品（带货）。字段按未来真实后端「商品绑定接口」设计；当前为 mock。
/// imageUrl 先用打包素材 assets/products/jewelry-product.jpg；
/// 后端就绪后改成真实 goodsPreId / scene goods 返回即可。
class Product {
  final String id;
  final String dramaId;
  final String episodeId;
  final String sceneId;
  final int startMs;
  final int endMs;
  final String title;
  final String subtitle;
  final String imageUrl; // asset 路径或 http URL
  final double price;
  final String currency; // CNY / USD …
  final String merchant;
  final String badge; // 角标，如「剧中同款」
  final String productUrl; // 外部商品页（暂不跳转，留字段）
  final bool inStock;
  final int matchScore; // AI 场景匹配度（百分比 0~100），展示在商品卡上

  const Product({
    required this.id,
    required this.dramaId,
    required this.episodeId,
    required this.sceneId,
    required this.startMs,
    required this.endMs,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    this.currency = 'CNY',
    this.merchant = 'FalconFlix 严选',
    this.badge = '剧中同款',
    this.productUrl = '',
    this.inStock = true,
    this.matchScore = 96,
  });

  String get priceLabel {
    final symbol = currency == 'USD' ? '\$' : '¥';
    return '$symbol${price.toStringAsFixed(0)}';
  }

  /// 由商品 cue 适配成富商品卡。真实后端给了商品图(http)就用真实图，
  /// 没有(mock/空)再退回打包的 jewelry 素材，保证永远有图。
  factory Product.fromCue(CommerceCue cue, {required String dramaId}) {
    final img = cue.productImage;
    final hasRealImage = img.startsWith('http') || img.startsWith('assets/');
    return Product(
      id: cue.productId,
      dramaId: dramaId,
      episodeId: cue.episodeId,
      sceneId: cue.groupKey,
      startMs: cue.start.inMilliseconds,
      endMs: cue.end.inMilliseconds,
      title: cue.productName,
      subtitle: '${cue.timelineSource.zh} · 出现在 ${cue.start.inSeconds}s 场景',
      imageUrl: hasRealImage ? img : 'assets/products/jewelry-product.jpg',
      price: cue.price,
      merchant: 'FalconFlix 严选',
      badge: '剧中同款',
      inStock: true,
      matchScore: (cue.confidence * 100).round().clamp(0, 99),
    );
  }
}

/// 一集（来自后端 GET /short/info/{id} 的 data.episodeVOS[]）
class Episode {
  final String id;
  final String shortId;
  final String name; // 「第一集」
  final String videoUrl; // 真实 CDN 视频地址
  final double price;
  final bool isBuy; // 是否已解锁（免费集后端直接 true）
  final int sort;
  final String? goodsPreId;
  final String? goodsMidId;
  final String? goodsAfterId;

  Episode({
    required this.id,
    required this.shortId,
    required this.name,
    required this.videoUrl,
    required this.price,
    required this.isBuy,
    required this.sort,
    this.goodsPreId,
    this.goodsMidId,
    this.goodsAfterId,
  });

  /// 免费或已购 → 可直接播放
  bool get unlocked => isBuy || price <= 0;

  static String? _id(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty || s == '0') ? null : s;
  }

  factory Episode.fromJson(Map<String, dynamic> j) {
    return Episode(
      id: '${j['id'] ?? ''}',
      shortId: '${j['shortId'] ?? ''}',
      name: '${j['name'] ?? ''}',
      videoUrl: '${j['videoUrl'] ?? j['sectionUrl'] ?? ''}',
      price: double.tryParse('${j['price'] ?? 0}') ?? 0,
      isBuy: j['isBuy'] == true || '${j['isBuy']}'.toLowerCase() == 'true',
      sort: int.tryParse('${j['sort'] ?? 0}') ?? 0,
      goodsPreId: _id(j['goodsPreId']),
      goodsMidId: _id(j['goodsMidId']),
      goodsAfterId: _id(j['goodsAfterId']),
    );
  }
}

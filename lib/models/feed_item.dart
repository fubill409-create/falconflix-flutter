/// 首页短剧视频流的一条（来自后端 GET /home/recommend 的 data.rows[]）
class FeedItem {
  final String shortId;
  final String episodeId; // 本条对应的剧集 id（/home/recommend 的 j['id']），带货时间轴按它取 cue
  final String shortName; // 剧名，如「念念勿忘」
  final String episodeName; // 集名，如「第一集」
  final String introduce; // 简介
  final String videoUrl; // 视频地址 sectionUrl
  final String poster; // 封面/头像 avatar
  final int likeCount;
  final int collectCount;
  final int thumbsUpCount;
  final double price;
  final String? goodsPreId; // 片头场景商品（AI 关联）
  final String? goodsMidId;
  final String? goodsAfterId;

  FeedItem({
    required this.shortId,
    this.episodeId = '',
    required this.shortName,
    required this.episodeName,
    required this.introduce,
    required this.videoUrl,
    required this.poster,
    required this.likeCount,
    required this.collectCount,
    required this.thumbsUpCount,
    required this.price,
    this.goodsPreId,
    this.goodsMidId,
    this.goodsAfterId,
  });

  static int _toInt(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;
  static String? _id(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty || s == '0') ? null : s;
  }

  // iOS ATS 会静默拦截 http 媒体地址 → 落进被吞掉的 catch → 看着像死按钮。
  // 解析时把 http 升级成 https，防御性兜底（视频与封面同此处理）。
  static String _https(String u) =>
      u.startsWith('http://') ? u.replaceFirst('http://', 'https://') : u;

  factory FeedItem.fromJson(Map<String, dynamic> j) {
    return FeedItem(
      shortId: '${j['shortId'] ?? j['id'] ?? ''}',
      episodeId: '${j['id'] ?? ''}',
      shortName: '${j['shortName'] ?? ''}',
      episodeName: '${j['name'] ?? ''}',
      introduce: '${j['introduce'] ?? ''}',
      videoUrl: _https('${j['sectionUrl'] ?? j['videoUrl'] ?? ''}'),
      poster: _https('${j['avatar'] ?? ''}'),
      likeCount: _toInt(j['likeCount']),
      collectCount: _toInt(j['collectCount']),
      thumbsUpCount: _toInt(j['thumbsUpCount']),
      price: double.tryParse('${j['price'] ?? 0}') ?? 0,
      goodsPreId: _id(j['goodsPreId']),
      goodsMidId: _id(j['goodsMidId']),
      goodsAfterId: _id(j['goodsAfterId']),
    );
  }
}

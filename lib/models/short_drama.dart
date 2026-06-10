/// 剧目目录的一条（来自后端 GET /short/list 的 data.rows[]）
class ShortDrama {
  final String id;
  final String name;
  final String image; // 竖版封面
  final String introduce;
  final String categoryName;
  final List<String> labels;
  final int playCount;
  final int likeCount;
  final double price;
  final String videoUrl; // 本地测试清单带过来的可播放地址（后端目录为空）

  ShortDrama({
    required this.id,
    required this.name,
    required this.image,
    required this.introduce,
    required this.categoryName,
    required this.labels,
    required this.playCount,
    required this.likeCount,
    required this.price,
    this.videoUrl = '',
  });

  static int _sum(dynamic a, dynamic b) =>
      (int.tryParse('${a ?? 0}') ?? 0) + (int.tryParse('${b ?? 0}') ?? 0);

  factory ShortDrama.fromJson(Map<String, dynamic> j) {
    final labelList = (j['labelList'] as List?) ?? const [];
    return ShortDrama(
      id: '${j['id'] ?? ''}',
      name: '${j['name'] ?? ''}',
      image: '${j['image'] ?? ''}',
      introduce: '${j['introduce'] ?? ''}',
      categoryName: '${j['categoryName'] ?? ''}',
      labels: labelList
          .whereType<Map>()
          .map((e) => '${e['name'] ?? ''}')
          .where((s) => s.isNotEmpty)
          .toList(),
      playCount: _sum(j['playCount'], j['playAddCount']),
      likeCount: _sum(j['likeCount'], j['likeAddCount']),
      price: double.tryParse('${j['price'] ?? 0}') ?? 0,
    );
  }
}

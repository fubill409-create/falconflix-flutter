// 剧情商品时间轴的一条 cue（spec 第 8 节字段）。
// 字段按「正式后端接口」设计；当前后端暂无 cue 接口，先由
// CommerceCueAdapter 产出结构一致的模拟数据，将来直接换成后端返回即可。
// 切记：商品 cue 必须数据驱动，不要写死在页面结构里。

enum TimelineSource {
  novaGenerated, // Nova 生成剧情时自动带出
  aiScanned, // 老视频导入后 AI 扫描识别
  manualReviewed, // 人工确认
}

extension TimelineSourceLabel on TimelineSource {
  /// 后端字段值
  String get wire {
    switch (this) {
      case TimelineSource.novaGenerated:
        return 'nova_generated';
      case TimelineSource.aiScanned:
        return 'ai_scanned';
      case TimelineSource.manualReviewed:
        return 'manual_reviewed';
    }
  }

  /// 中文展示（中文先行）
  String get zh {
    switch (this) {
      case TimelineSource.novaGenerated:
        return 'Nova 生成';
      case TimelineSource.aiScanned:
        return 'AI 扫描';
      case TimelineSource.manualReviewed:
        return '人工确认';
    }
  }

  static TimelineSource fromWire(String? v) {
    switch (v) {
      case 'nova_generated':
        return TimelineSource.novaGenerated;
      case 'manual_reviewed':
        return TimelineSource.manualReviewed;
      case 'ai_scanned':
      default:
        return TimelineSource.aiScanned;
    }
  }
}

class CommerceCue {
  final String episodeId;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final Duration start;
  final Duration end;
  final String anchor; // 锚点位置，如 "left rail"
  final String trigger; // 触发方式，如 "auto + pause"
  final double confidence; // 0~1，AI 识别置信度
  final TimelineSource timelineSource;
  final String status; // published / draft / hidden

  const CommerceCue({
    required this.episodeId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.start,
    required this.end,
    this.anchor = 'left rail',
    this.trigger = 'auto + pause',
    this.confidence = 1.0,
    this.timelineSource = TimelineSource.manualReviewed,
    this.status = 'published',
  });

  /// 同一时间点（同 start）的多个商品归为一组 → 展开成小货架。
  String get groupKey => '$episodeId@${start.inSeconds}';

  bool activeAt(Duration t) => t >= start && t <= end;

  // iOS ATS 会静默拦截 http 媒体地址 → 落进被吞掉的 catch。
  // 解析时把 http 升级成 https，防御性兜底。
  static String _https(String u) =>
      u.startsWith('http://') ? u.replaceFirst('http://', 'https://') : u;

  factory CommerceCue.fromJson(Map<String, dynamic> j) {
    int _ms(dynamic v) => ((double.tryParse('${v ?? 0}') ?? 0) * 1000).round();
    return CommerceCue(
      episodeId: '${j['episodeId'] ?? ''}',
      productId: '${j['productId'] ?? ''}',
      productName: '${j['productName'] ?? ''}',
      productImage: _https('${j['productImage'] ?? ''}'),
      price: double.tryParse('${j['price'] ?? 0}') ?? 0,
      start: Duration(milliseconds: _ms(j['start'])),
      end: Duration(milliseconds: _ms(j['end'])),
      anchor: '${j['anchor'] ?? 'left rail'}',
      trigger: '${j['trigger'] ?? 'auto + pause'}',
      confidence: double.tryParse('${j['confidence'] ?? 1}') ?? 1,
      timelineSource: TimelineSourceLabel.fromWire(j['timelineSource'] as String?),
      status: '${j['status'] ?? 'published'}',
    );
  }
}

/// 商品时间轴数据来源。现为模拟，后端就绪后只改本类。
class CommerceCueAdapter {
  /// TODO(后端): 换成 GET /commerce/timeline?episodeId=... 的真实返回。
  /// 现阶段：用剧目封面当商品图，按固定时间点产出几条 cue 方便手机上肉眼验证。
  static List<CommerceCue> forEpisode({
    required String episodeId,
    required String fallbackImage,
  }) {
    return [
      // 开场场景（3-11s）—— 同一时间窗多件，展开成「场景同款」一溜可滑商品列。
      CommerceCue(
        episodeId: episodeId,
        productId: 'p_coat',
        productName: '女主同款 · 米色长风衣',
        productImage: fallbackImage,
        price: 459,
        start: const Duration(seconds: 3),
        end: const Duration(seconds: 11),
        confidence: 0.98,
        timelineSource: TimelineSource.novaGenerated,
      ),
      CommerceCue(
        episodeId: episodeId,
        productId: 'p_watch',
        productName: '男主腕表 · 经典款',
        productImage: fallbackImage,
        price: 1680,
        start: const Duration(seconds: 3),
        end: const Duration(seconds: 11),
        confidence: 0.96,
        timelineSource: TimelineSource.manualReviewed,
      ),
      CommerceCue(
        episodeId: episodeId,
        productId: 'p_bag',
        productName: '同款链条小方包',
        productImage: fallbackImage,
        price: 899,
        start: const Duration(seconds: 3),
        end: const Duration(seconds: 11),
        confidence: 0.94,
        timelineSource: TimelineSource.aiScanned,
      ),
      CommerceCue(
        episodeId: episodeId,
        productId: 'p_lip',
        productName: '剧中同色号唇釉 · #枫叶红',
        productImage: fallbackImage,
        price: 129,
        start: const Duration(seconds: 3),
        end: const Duration(seconds: 11),
        confidence: 0.99,
        timelineSource: TimelineSource.aiScanned,
      ),
      // 后续场景（15-24s）—— 又一组，演示时间轴随剧情切换。
      CommerceCue(
        episodeId: episodeId,
        productId: 'p_glasses',
        productName: '男主同款 · 飞行员墨镜',
        productImage: fallbackImage,
        price: 329,
        start: const Duration(seconds: 15),
        end: const Duration(seconds: 24),
        confidence: 0.95,
        timelineSource: TimelineSource.aiScanned,
      ),
      CommerceCue(
        episodeId: episodeId,
        productId: 'p_scarf',
        productName: '同款真丝印花围巾',
        productImage: fallbackImage,
        price: 259,
        start: const Duration(seconds: 15),
        end: const Duration(seconds: 24),
        confidence: 0.92,
        timelineSource: TimelineSource.aiScanned,
      ),
    ];
  }
}

import 'dart:convert';

/// Nova interactive_manifest.v1 模型（FalconFlix 播放端）。
/// 按 Nova「导出器真实输出」实现：节点只有 scene + ending_fixed；决策 = 带 choices 的 scene。
/// 视频地址在 import 时已被后端 fetch-and-store 重写成 falconflix CDN 永久地址。
/// 契约：falconflix-real-system/docs/INTERACTIVE_IMPORT_FALCONFLIX_ENDPOINT.md
class IxChoice {
  final String id; // 跨版本稳定，记「已解锁」用
  final String label;
  final String target;
  final int price; // 0=免费；>0=付费分支（Phase 2 接真鹰币）
  final Map<String, dynamic> setFlags; // 选后写状态
  final Map<String, dynamic>? requires; // 结构化门控（隐藏/置灰）
  final bool hidden; // requires 不满足时：true=隐藏 / false=置灰

  const IxChoice({
    required this.id,
    required this.label,
    required this.target,
    this.price = 0,
    this.setFlags = const {},
    this.requires,
    this.hidden = false,
  });

  bool get locked => price > 0;

  factory IxChoice.fromJson(Map<String, dynamic> j) => IxChoice(
        id: '${j['id'] ?? ''}',
        label: '${j['label'] ?? ''}',
        target: '${j['target'] ?? ''}',
        price: (j['price'] is num) ? (j['price'] as num).toInt() : 0,
        setFlags: (j['setFlags'] is Map)
            ? (j['setFlags'] as Map).cast<String, dynamic>()
            : const {},
        requires: (j['requires'] is Map)
            ? (j['requires'] as Map).cast<String, dynamic>()
            : null,
        hidden: j['hidden'] == true,
      );
}

class IxNode {
  final String id;
  final String type; // scene | ending_fixed
  final String? videoUrl; // 单段视频（旧字段，向后兼容）
  final List<String> clips; // Nova v1 §5.1.1：节点多段连播；非空时优先于 videoUrl
  final String title;
  final String? next; // 线性续播（无 choices 时）
  final List<IxChoice> choices; // 非空 = 抉择点
  final String endingType; // ending_fixed: good|bad|hidden|open

  const IxNode({
    required this.id,
    required this.type,
    this.videoUrl,
    this.clips = const [],
    this.title = '',
    this.next,
    this.choices = const [],
    this.endingType = '',
  });

  bool get isEnding => type == 'ending_fixed';
  bool get isDecision => choices.isNotEmpty;

  /// 实际要连播的视频 URL 序列：clips 非空走 clips，否则 [videoUrl]，再否则空。
  List<String> get playUrls {
    if (clips.isNotEmpty) return clips;
    if (videoUrl != null && videoUrl!.isNotEmpty) return [videoUrl!];
    return const [];
  }

  factory IxNode.fromJson(Map<String, dynamic> j) => IxNode(
        id: '${j['id'] ?? ''}',
        type: '${j['type'] ?? ''}',
        videoUrl: _s(j['videoUrl']),
        clips: (j['clips'] is List)
            ? [
                for (final c in (j['clips'] as List))
                  if (c != null && '$c'.isNotEmpty) '$c'
              ]
            : const [],
        title: '${j['title'] ?? ''}',
        next: _s(j['next']),
        choices: (j['choices'] is List)
            ? [
                for (final c in (j['choices'] as List))
                  if (c is Map) IxChoice.fromJson(c.cast<String, dynamic>())
              ]
            : const [],
        endingType: '${j['endingType'] ?? ''}',
      );
}

class IxDrama {
  final String dramaId;
  final int version;
  final String title;
  final String rootNodeId;
  final String freeEndingNodeId;
  final Map<String, dynamic> vars; // flag 初值
  final Map<String, IxNode> nodes;

  const IxDrama({
    required this.dramaId,
    required this.version,
    required this.title,
    required this.rootNodeId,
    required this.freeEndingNodeId,
    required this.vars,
    required this.nodes,
  });

  IxNode? node(String? id) => id == null ? null : nodes[id];
  IxNode? get root => nodes[rootNodeId];
  List<IxNode> get endings =>
      nodes.values.where((n) => n.isEnding).toList(growable: false);

  factory IxDrama.fromJson(Map<String, dynamic> j) {
    final map = <String, IxNode>{};
    if (j['nodes'] is List) {
      for (final raw in (j['nodes'] as List)) {
        if (raw is Map) {
          final n = IxNode.fromJson(raw.cast<String, dynamic>());
          if (n.id.isNotEmpty) map[n.id] = n;
        }
      }
    }
    return IxDrama(
      dramaId: '${j['dramaId'] ?? ''}',
      version: (j['version'] is num) ? (j['version'] as num).toInt() : 1,
      title: '${j['title'] ?? ''}',
      rootNodeId: '${j['rootNodeId'] ?? ''}',
      freeEndingNodeId: '${j['freeEndingNodeId'] ?? ''}',
      vars: (j['vars'] is Map) ? (j['vars'] as Map).cast<String, dynamic>() : const {},
      nodes: map,
    );
  }

  factory IxDrama.fromString(String s) =>
      IxDrama.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

/// 片单条目（GET /ix/list）。
class IxDramaCard {
  final String dramaId;
  final String title;
  final String status;
  final int nodeCount;
  final int endingCount;
  final String? coverVideo;

  const IxDramaCard({
    required this.dramaId,
    required this.title,
    required this.status,
    this.nodeCount = 0,
    this.endingCount = 0,
    this.coverVideo,
  });

  factory IxDramaCard.fromJson(Map<String, dynamic> j) => IxDramaCard(
        dramaId: '${j['dramaId'] ?? ''}',
        title: '${j['title'] ?? ''}',
        status: '${j['status'] ?? ''}',
        nodeCount: (j['nodeCount'] is num) ? (j['nodeCount'] as num).toInt() : 0,
        endingCount: (j['endingCount'] is num) ? (j['endingCount'] as num).toInt() : 0,
        coverVideo: _s(j['coverVideo']),
      );
}

/// 结构化条件求值（requires / when）：flag/eq/gte/lte + allOf/anyOf/not。禁 eval、纯数据。
bool ixEval(Map<String, dynamic>? cond, Map<String, dynamic> flags) {
  if (cond == null) return true;
  if (cond.containsKey('flag')) {
    final v = flags[cond['flag']];
    if (cond.containsKey('eq')) return v == cond['eq'];
    if (cond.containsKey('gte')) {
      final n = v is num ? v : num.tryParse('$v') ?? 0;
      return n >= ((cond['gte'] as num?) ?? 0);
    }
    if (cond.containsKey('lte')) {
      final n = v is num ? v : num.tryParse('$v') ?? 0;
      return n <= ((cond['lte'] as num?) ?? 0);
    }
    return true;
  }
  if (cond['allOf'] is List) {
    return (cond['allOf'] as List)
        .every((c) => c is Map ? ixEval(c.cast<String, dynamic>(), flags) : true);
  }
  if (cond['anyOf'] is List) {
    return (cond['anyOf'] as List)
        .any((c) => c is Map ? ixEval(c.cast<String, dynamic>(), flags) : false);
  }
  if (cond['not'] is Map) {
    return !ixEval((cond['not'] as Map).cast<String, dynamic>(), flags);
  }
  return true;
}

String? _s(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

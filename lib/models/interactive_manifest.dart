import 'dart:convert';

/// 互动剧 manifest —— FalconFlix ↔ Nova 对接契约（离线批量导入格式）。
///
/// 设计见 docs/PRICING_SYSTEM_IMPLEMENTATION_PLAN.md §4。Nova 批量生成剧情树 + 视频后，
/// 吐一份 manifest.json（节点树 + 选项边 + 收费标记 + 资产 URL），FalconFlix:
///   离线：`POST /interactive/import` 吃下校验写库 → 上线；
///   在线：末端开放式结局付 2888 → `POST /interactive/generateEnding` 调 Nova 生成 API。
///
/// 节点类型：
///   scene        —— 一幕（视频/海报 + 旁白），有 next 指向下一节点；
///   decision     —— 抉择点，choices[] 每条 {label,target,price,teaser,vote}；
///   ending_fixed —— 成品固定结局（好/坏/隐藏/留白），多个；
///   ending_ai_slot —— 开放式自定义口子（现场为单用户烧 API 生成专属结局），price=2888。
///
/// 收费三档（清单 §三）：第 2 层（首个岔路）免费；第 3 层起预制分支 60 鹰币；
/// 末端开放式自定义结局 2888 鹰币。免费路径必须能走到至少 1 个完整结局。
enum IxNodeType { scene, decision, endingFixed, endingAiSlot, unknown }

IxNodeType _typeFrom(String? s) {
  switch (s) {
    case 'scene':
      return IxNodeType.scene;
    case 'decision':
      return IxNodeType.decision;
    case 'ending_fixed':
      return IxNodeType.endingFixed;
    case 'ending_ai_slot':
      return IxNodeType.endingAiSlot;
    default:
      return IxNodeType.unknown;
  }
}

class IxChoice {
  final String label; // 选项文案
  final String target; // 目标节点 id
  final int price; // 0=免费(钩子层)；>0=预制分支(默认 60)
  final String? teaserPoster; // 锁前「预览诱饵」模糊帧
  final String? teaserLine; // 钩子台词（悬念峰值）
  final int vote; // 人群投票百分比（0-100，社会认同）

  const IxChoice({
    required this.label,
    required this.target,
    this.price = 0,
    this.teaserPoster,
    this.teaserLine,
    this.vote = 0,
  });

  bool get locked => price > 0;

  factory IxChoice.fromJson(Map<String, dynamic> j) => IxChoice(
        label: (j['label'] ?? '').toString(),
        target: (j['target'] ?? '').toString(),
        price: _int(j['price']),
        teaserPoster: _str(j['teaserPoster']),
        teaserLine: _str(j['teaserLine']),
        vote: _int(j['vote']),
      );
}

class IxNode {
  final String id;
  final IxNodeType type;

  // —— scene ——
  final String? videoUrl; // 真实 CDN 视频
  final String? poster; // 海报/首帧（无视频时铺底）
  final String chip; // 章节/层标，如「第 3 层 · 雨夜」
  final String beat; // 旁白 / 台词
  final String? next; // scene 的下一节点 id

  // —— decision ——
  final String question;
  final List<IxChoice> choices;

  // —— ending ——
  final String endingTitle;
  final String rarity; // 普通/稀有/隐藏/真结局…
  final String endingText;
  final int price; // ending_ai_slot=2888；fixed=0

  const IxNode({
    required this.id,
    required this.type,
    this.videoUrl,
    this.poster,
    this.chip = '',
    this.beat = '',
    this.next,
    this.question = '',
    this.choices = const [],
    this.endingTitle = '',
    this.rarity = '',
    this.endingText = '',
    this.price = 0,
  });

  bool get isEnding =>
      type == IxNodeType.endingFixed || type == IxNodeType.endingAiSlot;

  factory IxNode.fromJson(Map<String, dynamic> j) {
    final type = _typeFrom(_str(j['type']));
    return IxNode(
      id: (j['id'] ?? '').toString(),
      type: type,
      videoUrl: _str(j['videoUrl']),
      poster: _str(j['poster']),
      chip: (j['chip'] ?? '').toString(),
      beat: (j['beat'] ?? '').toString(),
      next: _str(j['next']),
      question: (j['question'] ?? '').toString(),
      choices: (j['choices'] is List)
          ? [
              for (final c in (j['choices'] as List))
                if (c is Map) IxChoice.fromJson(c.cast<String, dynamic>())
            ]
          : const [],
      endingTitle: (j['endingTitle'] ?? '').toString(),
      rarity: (j['rarity'] ?? '').toString(),
      endingText: (j['endingText'] ?? '').toString(),
      price: _int(j['price']),
    );
  }
}

class InteractiveManifest {
  final String dramaId;
  final int version;
  final String title;
  final String cover; // 剧封面（样板剧卡 / 标题屏）
  final String synopsis; // 一句简介
  final String rootNodeId;
  final Map<String, IxNode> nodes;

  const InteractiveManifest({
    required this.dramaId,
    required this.version,
    required this.title,
    required this.cover,
    required this.synopsis,
    required this.rootNodeId,
    required this.nodes,
  });

  IxNode? node(String id) => nodes[id];
  IxNode? get root => nodes[rootNodeId];

  /// 所有结局节点（图鉴用）。
  List<IxNode> get endings =>
      nodes.values.where((n) => n.isEnding).toList(growable: false);

  int get endingCount => endings.length;

  factory InteractiveManifest.fromJson(Map<String, dynamic> j) {
    final list = (j['nodes'] is List) ? (j['nodes'] as List) : const [];
    final map = <String, IxNode>{};
    for (final raw in list) {
      if (raw is Map) {
        final n = IxNode.fromJson(raw.cast<String, dynamic>());
        if (n.id.isNotEmpty) map[n.id] = n;
      }
    }
    return InteractiveManifest(
      dramaId: (j['dramaId'] ?? '').toString(),
      version: _int(j['version']),
      title: (j['title'] ?? '').toString(),
      cover: (j['cover'] ?? '').toString(),
      synopsis: (j['synopsis'] ?? '').toString(),
      rootNodeId: (j['rootNodeId'] ?? '').toString(),
      nodes: map,
    );
  }

  factory InteractiveManifest.fromJsonString(String s) =>
      InteractiveManifest.fromJson(jsonDecode(s) as Map<String, dynamic>);

  /// 校验：无断头 / 无死链 / 根可达 / 免费路径必达至少 1 个完整结局。
  /// 返回错误列表（空 = 通过）。导入前后端也要再校一遍（前端只为 demo 早失败）。
  List<String> validate() {
    final errs = <String>[];
    if (nodes.isEmpty) {
      errs.add('节点为空');
      return errs;
    }
    if (root == null) {
      errs.add('rootNodeId「$rootNodeId」不存在');
    }
    // 死链 + 断头
    for (final n in nodes.values) {
      switch (n.type) {
        case IxNodeType.scene:
          if (n.next == null || n.next!.isEmpty) {
            errs.add('scene「${n.id}」缺 next（断头）');
          } else if (!nodes.containsKey(n.next)) {
            errs.add('scene「${n.id}」.next→「${n.next}」死链');
          }
          break;
        case IxNodeType.decision:
          if (n.choices.isEmpty) {
            errs.add('decision「${n.id}」无选项（断头）');
          }
          for (final c in n.choices) {
            if (!nodes.containsKey(c.target)) {
              errs.add('decision「${n.id}」选项「${c.label}」→「${c.target}」死链');
            }
          }
          break;
        case IxNodeType.endingFixed:
        case IxNodeType.endingAiSlot:
          break;
        case IxNodeType.unknown:
          errs.add('节点「${n.id}」类型未知');
          break;
      }
    }
    // 免费路径必达至少 1 个完整结局（只走 price==0 的边 BFS）。
    if (root != null && !_freePathReachesEnding()) {
      errs.add('免费路径走不到任何完整结局（白嫖也要能看完一个像样故事）');
    }
    return errs;
  }

  bool _freePathReachesEnding() {
    final seen = <String>{};
    final stack = <String>[rootNodeId];
    while (stack.isNotEmpty) {
      final id = stack.removeLast();
      if (!seen.add(id)) continue;
      final n = nodes[id];
      if (n == null) continue;
      if (n.isEnding) return true;
      if (n.type == IxNodeType.scene && n.next != null) {
        stack.add(n.next!);
      } else if (n.type == IxNodeType.decision) {
        for (final c in n.choices) {
          if (c.price == 0) stack.add(c.target); // 只走免费边
        }
      }
    }
    return false;
  }
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().trim()) ?? 0;
}

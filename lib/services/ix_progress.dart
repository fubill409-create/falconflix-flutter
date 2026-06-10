import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 互动剧本地存档：每剧的进度（节点/clip/flag）+ 结局图鉴。
///
/// key 命名：`ix_prog_{dramaId}` / `ix_dex_{dramaId}`
class IxProgress {
  /// 全局变化通知（图鉴/进度更新时 +1）。UI 监听它自动 reload，避免"必须重启 App 才刷"。
  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  static String _kProg(String dramaId) => 'ix_prog_$dramaId';
  static String _kDex(String dramaId) => 'ix_dex_$dramaId';

  /// 写进度（进入新节点/clip 时调）。失败静默忽略——存档不能阻塞播放。
  static Future<void> save({
    required String dramaId,
    required String nodeId,
    required int clipIdx,
    required Map<String, dynamic> flags,
  }) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final j = jsonEncode({
        'nodeId': nodeId,
        'clipIdx': clipIdx,
        'flags': flags,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      await sp.setString(_kProg(dramaId), j);
    } catch (_) {}
  }

  /// 读进度（null = 没存档/坏档）。
  static Future<IxSave?> load(String dramaId) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString(_kProg(dramaId));
      if (s == null || s.isEmpty) return null;
      final j = jsonDecode(s) as Map<String, dynamic>;
      return IxSave(
        nodeId: '${j['nodeId'] ?? ''}',
        clipIdx: (j['clipIdx'] is num) ? (j['clipIdx'] as num).toInt() : 0,
        flags: (j['flags'] is Map)
            ? (j['flags'] as Map).cast<String, dynamic>()
            : <String, dynamic>{},
        ts: (j['ts'] is num) ? (j['ts'] as num).toInt() : 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// 清进度（通关或用户「从头看」时）。
  static Future<void> clear(String dramaId) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kProg(dramaId));
      tick.value++; // 广播：进度变化
    } catch (_) {}
  }

  /// 图鉴：加入一个 endingId（看到这个结局了）。
  static Future<void> unlockEnding({
    required String dramaId,
    required String endingId,
  }) async {
    if (endingId.isEmpty) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final cur = (sp.getStringList(_kDex(dramaId)) ?? <String>[]).toSet();
      if (cur.add(endingId)) {
        await sp.setStringList(_kDex(dramaId), cur.toList());
        tick.value++; // 广播：图鉴+1，监听者刷新
      }
    } catch (_) {}
  }

  /// 图鉴：已解锁的结局 id 集合（剧目卡显示「X / Y」）。
  static Future<Set<String>> dex(String dramaId) async {
    try {
      final sp = await SharedPreferences.getInstance();
      return (sp.getStringList(_kDex(dramaId)) ?? const <String>[]).toSet();
    } catch (_) {
      return <String>{};
    }
  }
}

/// 一次存档读出来的快照。
class IxSave {
  final String nodeId;
  final int clipIdx;
  final Map<String, dynamic> flags;
  final int ts;
  IxSave({
    required this.nodeId,
    required this.clipIdx,
    required this.flags,
    required this.ts,
  });
}

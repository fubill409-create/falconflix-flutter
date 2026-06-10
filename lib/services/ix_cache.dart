import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 互动剧视频本地缓存 —— 看过一遍就缓存到磁盘，重看/续看零下载。
///
/// 位置：`getApplicationDocumentsDirectory()/ix_cache/v_<len>_<hash>.mp4`
/// 容量：1GB 上限，超出按 access 时间 LRU 淘汰。
class IxCache {
  static const int _maxBytes = 1024 * 1024 * 1024; // 1GB
  static Directory? _dir;
  static final Map<String, Completer<File>> _inflight = {};

  static String _fileName(String url) {
    // 32-bit hashCode + url 长度 = 文件级稳定命名（碰撞概率可忽略）
    final h = url.hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
    return 'v_${url.length}_$h.mp4';
  }

  /// 启动时调一次（init 目录）。
  static Future<void> ensureReady() async {
    if (_dir != null) return;
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/ix_cache');
    if (!await d.exists()) await d.create(recursive: true);
    _dir = d;
  }

  /// 同步查本地已缓存的文件（已 ensureReady 后才有意义）。命中返回 File，否则 null。
  static File? fileFor(String url) {
    if (_dir == null) return null;
    final f = File('${_dir!.path}/${_fileName(url)}');
    if (f.existsSync() && f.lengthSync() > 0) return f;
    return null;
  }

  /// 确保 url 对应文件已落地。已在下载中则复用同一个 Future。
  static Future<File> ensure(String url) async {
    await ensureReady();
    final hit = fileFor(url);
    if (hit != null) return hit;
    final inflight = _inflight[url];
    if (inflight != null) return inflight.future;
    final comp = Completer<File>();
    _inflight[url] = comp;
    Future<void>(() async {
      try {
        final f = File('${_dir!.path}/${_fileName(url)}');
        final tmp = File('${f.path}.tmp');
        final r = await http
            .get(Uri.parse(url))
            .timeout(const Duration(minutes: 5));
        if (r.statusCode != 200) {
          throw 'HTTP ${r.statusCode}';
        }
        if (r.bodyBytes.isEmpty) throw '空文件';
        await tmp.writeAsBytes(r.bodyBytes);
        await tmp.rename(f.path);
        comp.complete(f);
        unawaited(_evict());
      } catch (e, st) {
        comp.completeError(e, st);
      } finally {
        _inflight.remove(url);
      }
    });
    return comp.future;
  }

  /// 后台批量预热（最多并行 3 路，避免抢光带宽影响当前播放）。
  /// 已缓存或正在下载的 url 自动跳过。
  static Future<void> prefetchAll(Iterable<String> urls) async {
    await ensureReady();
    final pending = <String>[];
    for (final u in urls) {
      if (u.isEmpty) continue;
      if (fileFor(u) != null) continue;
      if (_inflight.containsKey(u)) continue;
      pending.add(u);
    }
    if (pending.isEmpty) return;
    var i = 0;
    Future<void> worker() async {
      while (i < pending.length) {
        final url = pending[i++];
        try {
          await ensure(url);
        } catch (_) {
          /* 单个失败不影响其他 */
        }
      }
    }
    final pool = <Future>[];
    for (int k = 0; k < 3; k++) {
      pool.add(worker());
    }
    await Future.wait(pool);
  }

  /// LRU 淘汰（超过 maxBytes 时按 access 时间删旧）。
  static Future<void> _evict() async {
    final d = _dir;
    if (d == null) return;
    final entries = <(File, FileStat)>[];
    int total = 0;
    await for (final e in d.list()) {
      if (e is! File || !e.path.endsWith('.mp4')) continue;
      try {
        final s = await e.stat();
        total += s.size;
        entries.add((e, s));
      } catch (_) {}
    }
    if (total <= _maxBytes) return;
    entries.sort((a, b) => a.$2.accessed.compareTo(b.$2.accessed));
    var rest = total;
    for (final (f, s) in entries) {
      if (rest <= _maxBytes) break;
      try {
        await f.delete();
        rest -= s.size;
      } catch (_) {}
    }
  }

  /// 当前缓存总字节数（给"我的缓存"页用）。
  static Future<int> totalBytes() async {
    await ensureReady();
    var sum = 0;
    await for (final e in _dir!.list()) {
      if (e is File) {
        try {
          sum += await e.length();
        } catch (_) {}
      }
    }
    return sum;
  }

  /// 清空所有缓存文件。返回删了多少字节（给 toast 提示用）。
  static Future<int> clear() async {
    await ensureReady();
    var freed = 0;
    await for (final e in _dir!.list()) {
      if (e is File) {
        try {
          freed += await e.length();
          await e.delete();
        } catch (_) {}
      }
    }
    return freed;
  }
}

import 'package:video_player/video_player.dart';

import 'api/api.dart';

/// 开机预热：在金鹰 splash 动画播放的 2.4 秒里，
/// 后台把首页流拉好、并把**第一条视频**初始化好。
/// 这样劈开进首页时第一条直接能播，不再「黑屏 → FF → 等几秒缓冲」。
class BootWarm {
  static VideoPlayerController? _firstVideo;
  static String? _firstUrl;
  static Future<void>? _firstInit;
  static Future<void>? _warming;

  // “下一条”预热槽（单槽、有界）：滑动时提前缓冲下一条视频，最多多占一个 controller。
  static VideoPlayerController? _nextVideo;
  static String? _nextUrl;
  static Future<void>? _nextInit;

  /// splash 启动时调用（已在预热则忽略）。
  static Future<void> warm() => _warming ??= _doWarm();

  static Future<void> _doWarm() async {
    try {
      final items = await Api.feed();
      if (items.isEmpty) return;
      final url = items.first.videoUrl;
      if (url.isEmpty) return;
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      _firstVideo = c;
      _firstUrl = url;
      // 立刻存下 controller + 它的 initialize future：
      // 即使进首页时还没缓冲完，首页 await 的也是这条「已经在跑」的 future，比现场新建快。
      _firstInit = c.initialize();
    } catch (_) {
      Api.resetFeed();
    }
  }

  /// 预热“下一条”视频（单槽、有界）：若与当前槽不同则替换，旧的未被取走就释放。
  /// 已是第一条/已在预热同一条则忽略，避免重复建 controller。
  static void prewarmNext(String url) {
    if (url.isEmpty || url == _nextUrl || url == _firstUrl) return;
    _nextVideo?.dispose(); // 上一个没被取走的下一条，丢弃释放。
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _nextVideo = c;
    _nextUrl = url;
    _nextInit = c.initialize();
  }

  /// 取走预热好的 controller + 它的 initialize future（只给一次，转移所有权）。
  /// 先看 splash 预热的第一条，再看“下一条”预热槽。
  static (VideoPlayerController, Future<void>)? take(String url) {
    if (_firstUrl == url && _firstVideo != null && _firstInit != null) {
      final rec = (_firstVideo!, _firstInit!);
      _firstVideo = null;
      _firstUrl = null;
      _firstInit = null;
      return rec;
    }
    if (_nextUrl == url && _nextVideo != null && _nextInit != null) {
      final rec = (_nextVideo!, _nextInit!);
      _nextVideo = null;
      _nextUrl = null;
      _nextInit = null;
      return rec;
    }
    return null;
  }
}

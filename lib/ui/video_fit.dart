import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../app_config.dart';

/// 受控裁切视频：把 9:16 视频铺到更长的手机屏上时，
/// 不做满屏 cover（两侧约裁 10%），而是只裁两侧各 [kVideoSideCrop]、画面顶对齐，
/// 不够高的部分在底部留一条窄暗边（[background]，默认黑）。原比例不拉伸。
class FittedVideo extends StatelessWidget {
  final VideoPlayerController? controller;

  /// 视频未就绪时显示的占位封面（同样的裁法），为空则只显示 [background]。
  final String poster;

  /// 底部窄边 / 加载时的底，默认黑。首页流可传品牌占位。
  final Widget? background;

  const FittedVideo({
    super.key,
    required this.controller,
    this.poster = '',
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    final ready = ctrl != null && ctrl.value.isInitialized;
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, c) {
          final boxW = c.maxWidth;
          final aspect = ready ? ctrl.value.aspectRatio : 9 / 16; // 宽/高
          final scaledW = boxW / (1 - 2 * kVideoSideCrop); // 放大到两侧各溢出 kVideoSideCrop
          final scaledH = scaledW / aspect; // 保持原比例
          final left = (boxW - scaledW) / 2; // 两侧等量裁切
          return Stack(
            fit: StackFit.expand,
            children: [
              background ?? const ColoredBox(color: Colors.black),
              Positioned(
                left: left,
                top: 0,
                width: scaledW,
                height: scaledH,
                child: ready
                    ? VideoPlayer(ctrl)
                    : (poster.isNotEmpty
                        ? CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover)
                        : const SizedBox.shrink()),
              ),
            ],
          );
        },
      ),
    );
  }
}

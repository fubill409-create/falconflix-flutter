import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../boot_warm.dart';
import '../ui/daynight.dart';
import 'app_shell.dart';

/// 开机揭幕（品牌大片版 · 曲线劈开仪式）：
/// 按本机时间日夜切换整张金鹰开机大图——白天用 splash_day.png（白底），
/// 夜晚用 splash_night.png（深空底）。整张全屏 cover，配足时长的仪式入场：
///   01 暗→大图柔光浮现(放大回落) →
///   02 一道金/彩高光线沿中线 S 形曲线自下而上「噌」地升起到顶 → 闪一下 →
///   03 沿这条「弯弯的」曲线把整张图慢慢劈成左右两半、缓缓向两侧扒开(露出中缝彩光) →
///   04 化入首页。
/// 节奏「足」：全程 ~4.6s，劈开是慢高潮，曲线扒开不一闪即过。
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final bool _day;
  late final String _asset;
  bool _ready = false;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _day = isDayNow();
    _asset =
        _day ? 'assets/brand/splash_day.png' : 'assets/brand/splash_night.png';
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed && !_gone) {
          _gone = true;
          _goHome();
        }
      });
    // 动画一开始就后台拉首页流 + 预热第一条视频，跑完进首页直接能播。
    BootWarm.warm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    // 先把开机大图解码好，再放动画——保证原生启动屏退场后用户看得到完整揭幕。
    precacheImage(AssetImage(_asset), context).whenComplete(() {
      if (!mounted) return;
      setState(() => _ready = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _c.forward();
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 480),
        pageBuilder: (_, _, _) => const AppShell(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 底色与大图边缘一致：白天纯白、夜晚深空，避免 cover 留边露出突兀底色。
    final bg = _day ? const Color(0xFFFDFCFB) : const Color(0xFF06040A);
    return Scaffold(
      backgroundColor: bg,
      body: _ready
          ? AnimatedBuilder(
              animation: _c,
              builder: (context, _) => _SplashStage(
                v: _c.value,
                day: _day,
                asset: _asset,
                bg: bg,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// 中线 S 形曲线 seam：x = cx + bow·sin(2π·y/h)——上半向一侧弯、下半向另一侧弯。
double _seamX(double y, double cx, double bow, double h) =>
    cx + bow * math.sin(2 * math.pi * (y / h));

class _SplashStage extends StatelessWidget {
  const _SplashStage({
    required this.v,
    required this.day,
    required this.asset,
    required this.bg,
  });

  final double v;
  final bool day;
  final String asset;
  final Color bg;

  double _seg(double a, double b, [Curve c = Curves.linear]) {
    final t = ((v - a) / (b - a)).clamp(0.0, 1.0);
    return c.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width, h = size.height;

    // 01 浮现：透明度 0→1，缩放 1.07→1.0（easeOutBack 末尾轻微回弹=定帧抖一下）。
    final reveal = _seg(0.0, 0.15, Curves.easeOut);
    final scale = 1.07 - 0.07 * _seg(0.0, 0.28, Curves.easeOutBack);
    // 02 彩色大 S 曲线自下而上升起：0.15→0.40。
    final rise = _seg(0.15, 0.40, Curves.easeOutCubic);
    // 到顶瞬间「闪一下」：0.34→0.46 起→落。
    final flash = math.sin(_seg(0.34, 0.46, Curves.easeInOut) * math.pi);
    // 03 中间「砰」地绽放一团彩色光晕：0.44→0.66（峰值 ~0.55），作为劈开的引子。
    final halo = math.sin(_seg(0.44, 0.66, Curves.easeInOut) * math.pi);
    // 04 慢慢劈开：两半沿大 S 曲线向左右扒开 0.56→0.94（~1.9s，慢高潮）。
    final split = _seg(0.56, 0.94, Curves.easeInOutCubic);
    // 收尾整屏轻微提亮再交给首页转场（不死黑切换）。
    final exitFade = _seg(0.92, 1.0);

    // 曲线幅度：大 S——升起就明显弯，随劈开更弯（0.14w→0.28w）。
    final bow = w * (0.14 + 0.14 * split);
    // 每半外移：慢慢扒开，足够清场露出中缝。
    final gap = split * w * 0.66;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 大图：浮现缩放 + 沿 S 曲线劈成左右两半，向两侧扒开。
          Opacity(
            opacity: reveal,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _half(left: true, gap: gap, bow: bow, w: w, h: h),
                  _half(left: false, gap: gap, bow: bow, w: w, h: h),
                ],
              ),
            ),
          ),
          // 金/彩曲线（升起 + 到顶闪光），劈开后化成开口彩光并淡出。
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _SeamLinePainter(
                rise: rise,
                flash: flash,
                halo: halo,
                split: split,
                bow: bow,
                day: day,
              ),
            ),
          ),
          // 收尾柔光（白天提亮/夜晚发蓝），随后 480ms 化入首页。
          if (exitFade > 0)
            IgnorePointer(
              child: Container(
                color: (day ? Colors.white : const Color(0xFF0A0712))
                    .withValues(alpha: 0.24 * exitFade),
              ),
            ),
        ],
      ),
    );
  }

  // 半张大图：左半/右半各自沿 S 曲线裁切，再向外平移 gap。
  Widget _half({
    required bool left,
    required double gap,
    required double bow,
    required double w,
    required double h,
  }) {
    return Transform.translate(
      offset: Offset(left ? -gap : gap, 0),
      child: ClipPath(
        clipper: _CurvedHalfClipper(left: left, bow: bow),
        child: SizedBox(
          width: w,
          height: h,
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// 沿中线 S 曲线裁出左半或右半（两半共用同一条 seam，劈开前严丝合缝）。
class _CurvedHalfClipper extends CustomClipper<Path> {
  _CurvedHalfClipper({required this.left, required this.bow});
  final bool left;
  final double bow;

  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2;
    const n = 44;
    final p = Path();
    if (left) {
      p.moveTo(0, 0);
      p.lineTo(_seamX(0, cx, bow, h), 0);
      for (var i = 1; i <= n; i++) {
        final y = h * i / n;
        p.lineTo(_seamX(y, cx, bow, h), y);
      }
      p.lineTo(0, h);
    } else {
      p.moveTo(w, 0);
      p.lineTo(_seamX(0, cx, bow, h), 0);
      for (var i = 1; i <= n; i++) {
        final y = h * i / n;
        p.lineTo(_seamX(y, cx, bow, h), y);
      }
      p.lineTo(w, h);
    }
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant _CurvedHalfClipper old) =>
      old.left != left || old.bow != bow;
}

/// 中缝金/彩曲线：沿 S 曲线自下而上升起→到顶闪光→随劈开化成开口柔光并淡出。
class _SeamLinePainter extends CustomPainter {
  _SeamLinePainter({
    required this.rise,
    required this.flash,
    required this.halo,
    required this.split,
    required this.bow,
    required this.day,
  });
  final double rise; // 0→1 线从底升到顶
  final double flash; // 0→1→0 到顶闪光
  final double halo; // 0→1→0 中间彩色光晕绽放
  final double split; // 0→1 劈开（线随之化成开口光并淡出）
  final double bow; // 曲线幅度
  final bool day;

  @override
  void paint(Canvas canvas, Size size) {
    if (rise <= 0.001) return;
    final w = size.width, h = size.height;
    final cx = w / 2;
    final topY = h * (1 - rise); // 线顶端：随 rise 上升

    // 00 中间彩色光晕：劈开前在屏幕正中「砰」地绽放一团白热→金→粉→紫→蓝的大光团。
    if (halo > 0.001) {
      final center = Offset(cx, h * 0.5);
      final r = w * 0.20 + w * 0.62 * halo;
      final haloRect = Rect.fromCircle(center: center, radius: r);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.90 * halo),
              const Color(0xFFFFE08A).withValues(alpha: 0.62 * halo), // 金
              const Color(0xFFFF6FA5).withValues(alpha: 0.42 * halo), // 粉
              const Color(0xFFA35CFF).withValues(alpha: 0.26 * halo), // 紫
              const Color(0xFF4F8CFF).withValues(alpha: 0.0), // 蓝→透明
            ],
            stops: const [0.0, 0.22, 0.46, 0.72, 1.0],
          ).createShader(haloRect),
      );
    }

    // 沿 S 曲线构建从 topY 到底部的路径。
    final path = Path();
    const n = 44;
    path.moveTo(_seamX(topY, cx, bow, h), topY);
    for (var i = 1; i <= n; i++) {
      final y = topY + (h - topY) * i / n;
      path.lineTo(_seamX(y, cx, bow, h), y);
    }

    final lineAlpha = (1.0 - split).clamp(0.0, 1.0); // 劈开越大线越淡
    final bloom = Curves.easeOut.transform(split.clamp(0.0, 1.0)); // 开口彩光

    final glowColor = day ? const Color(0xFFFFC36A) : const Color(0xFFBFE3FF);

    // 1) 外发光带：线的柔光 + 劈开后开口透出的彩光（越开越宽越亮）。
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 14 + 26 * flash + 78 * bloom
        ..blendMode = BlendMode.plus
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, 8 + 16 * flash + 28 * bloom)
        ..color = glowColor.withValues(
            alpha: (0.16 * lineAlpha + 0.20 * bloom).clamp(0.0, 0.6)),
    );

    // 2) 亮核：沿线长方向走品牌金→粉→紫→蓝渐变（"彩色金线"）。
    final coreRect = Rect.fromLTRB(0, topY, w, h);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3 + 6 * flash
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE08A).withValues(alpha: 0.95 * lineAlpha), // 金
            const Color(0xFFFF6FA5).withValues(alpha: 0.95 * lineAlpha), // 粉
            const Color(0xFFA35CFF).withValues(alpha: 0.95 * lineAlpha), // 紫
            const Color(0xFF4F8CFF).withValues(alpha: 0.95 * lineAlpha), // 蓝
          ],
        ).createShader(coreRect),
    );

    // 3) 线头亮点 + 到顶闪光。
    final headR = 4.0 + 12.0 * flash;
    canvas.drawCircle(
      Offset(_seamX(topY, cx, bow, h), topY),
      headR,
      Paint()
        ..blendMode = BlendMode.plus
        ..color =
            Colors.white.withValues(alpha: (0.5 + 0.5 * flash) * lineAlpha),
    );
  }

  @override
  bool shouldRepaint(_SeamLinePainter old) =>
      old.rise != rise ||
      old.flash != flash ||
      old.halo != halo ||
      old.split != split ||
      old.bow != bow ||
      old.day != day;
}

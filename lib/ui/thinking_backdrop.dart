import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 「浮起的 AI 四角星」小星片——延续 v0.8.5 用户拍板的「凸起·呼吸」neumorphic 四角星
/// （原话「白的更有感觉」，勿再改形状）。做成**小浮片**嵌进现有页面上方的空白区，
/// 而不是整屏切白把正文/选择都盖没——用户 2026-06-05 明确要求：
/// 「正文和布局都留着、字还看得见，只在上面那块空的地方浮起一个呼吸的星」。
class FloatingAiStar extends StatelessWidget {
  final double size; // 浮片直径
  const FloatingAiStar({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        // 浅薰衣草瓷片，给 neumorphic 星留出立体光位。
        gradient: const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 1.1,
          colors: [Color(0xFFF3F1FA), Color(0xFFDAD6E8)],
        ),
        boxShadow: [
          // 浮起：下方落影 + 上方淡描边光。
          BoxShadow(
              color: const Color(0x55120E22),
              blurRadius: 22,
              offset: const Offset(0, 12)),
          BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1),
      ),
      child: SizedBox(
        width: size * 0.62,
        height: size * 0.62,
        child: const CustomPaint(painter: _EmbossedStarPainter()),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 0.86, end: 1.12, duration: 1250.ms, curve: Curves.easeInOut),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -3, end: 3, duration: 2400.ms, curve: Curves.easeInOut);
  }
}

/// 四角星（AI 标志）路径：四个外尖 + 向心收腰的凹边。
Path _sparklePath(Offset c, double r, double waist) {
  final pts = [
    Offset(c.dx, c.dy - r),
    Offset(c.dx + r, c.dy),
    Offset(c.dx, c.dy + r),
    Offset(c.dx - r, c.dy),
  ];
  final ctrl = [
    Offset(c.dx + waist, c.dy - waist),
    Offset(c.dx + waist, c.dy + waist),
    Offset(c.dx - waist, c.dy + waist),
    Offset(c.dx - waist, c.dy - waist),
  ];
  final p = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < 4; i++) {
    final next = pts[(i + 1) % 4];
    p.quadraticBezierTo(ctrl[i].dx, ctrl[i].dy, next.dx, next.dy);
  }
  return p..close();
}

/// 凸起、有质感的四角星：右下暗影 + 左上高光 + 斜向渐变体（白→淡薰衣紫）+ 边缘薄反光。
class _EmbossedStarPainter extends CustomPainter {
  const _EmbossedStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.46;
    final waist = r * 0.17;
    final path = _sparklePath(c, r, waist);

    canvas.drawPath(
      path.shift(const Offset(4, 6)),
      Paint()
        ..color = const Color(0x40221C3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawPath(
      path.shift(const Offset(-3, -4)),
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEDECF7), Color(0xFFCFCDE2)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );
  }

  @override
  bool shouldRepaint(covariant _EmbossedStarPainter old) => false;
}

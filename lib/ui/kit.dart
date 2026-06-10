import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme.dart';

/// FalconFlix 设计系统 —— 全屏复用，保证整体观感统一、高级。
/// 电影级深色 + 环境光 + 毛玻璃 + 渐变发光。

/// 环境光背景：深色渐变 + 几团柔光，让暗色有纵深、不死板。
/// 用法：作为页面最底层 Stack，内容压在上面。
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [FF.bg2, FF.bg],
              ),
            ),
          ),
          Positioned(top: -90, right: -70, child: _Blob(260, FF.gold, 0.14)),
          Positioned(bottom: 80, left: -90, child: _Blob(300, FF.teal, 0.12)),
          Positioned(top: 280, left: 30, child: _Blob(220, FF.hot, 0.10)),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double alpha;
  const _Blob(this.size, this.color, this.alpha);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// 毛玻璃面板。
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsets padding;
  final Color color;
  final Color? border;
  const Glass({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 22,
    this.padding = const EdgeInsets.all(16),
    this.color = FF.glassFill,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border ?? FF.glassStroke),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x47000000), blurRadius: 48, offset: Offset(0, 18)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 渐变发光按钮（药丸）。
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;
  final double height;
  final IconData? icon;
  final bool shimmer;
  final Color glow;
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = FF.hotGradient,
    this.height = 54,
    this.icon,
    this.shimmer = false,
    this.glow = const Color(0xFFFF5A3A),
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
              color: glow.withValues(alpha: 0.36),
              blurRadius: 34,
              offset: const Offset(0, 14)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3)),
        ],
      ),
    );
    if (shimmer) {
      btn = btn
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 2200.ms, color: Colors.white30);
    }
    return GestureDetector(onTap: onTap, child: btn);
  }
}

/// 点击微缩放（scale 0.95）反馈，全局复用。
class Bounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const Bounce({super.key, required this.child, required this.onTap});

  @override
  State<Bounce> createState() => _BounceState();
}

class _BounceState extends State<Bounce> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// 渐变标题（默认金色）。
Widget gradientText(String text,
    {double size = 26,
    FontWeight weight = FontWeight.w900,
    Gradient gradient = FF.goldGradient}) {
  return ShaderMask(
    shaderCallback: (r) => gradient.createShader(r),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: weight,
        height: 1.1,
        letterSpacing: 0.5,
      ),
    ),
  );
}

/// 小标签（玻璃感）。
class GlowChip extends StatelessWidget {
  final String text;
  final Color color;
  const GlowChip(this.text, {super.key, this.color = FF.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// 区块标题 + 右侧操作。
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                gradient: FF.hotGradient,
                borderRadius: BorderRadius.circular(2)),
          ),
          Text(title,
              style: const TextStyle(
                  color: FF.text, fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: FF.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

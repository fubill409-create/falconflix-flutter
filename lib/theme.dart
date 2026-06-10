import 'package:flutter/material.dart';

/// FalconFlix 设计令牌 —— 严格对齐 Codex 的 falconflix-design-tokens.css（唯一真源）。
/// 颜色/渐变/字号都翻自 tokens.css，不从截图取色。
class FF {
  // 表面 surfaces
  static const bg = Color(0xFF080706); // page-bg
  static const bg2 = Color(0xFF120F0C); // page-bg-soft
  static const panelSecondary = Color(0xFF15120F);
  static const panel = Color(0xFF201A15); // panel-raised（卡片）
  static const panelSoft = Color(0xFF15120F);
  static const cardDark = Color(0xFF17120F);

  // 文字 text（暖白系）
  static const text = Color(0xFFFFF8EE); // primary
  static const muted = Color(0xC2FFF8EE); // secondary 0.76
  static const dim = Color(0x94FFF8EE); // muted 0.58
  static const weak = Color(0x5CFFF8EE); // 0.36
  static const textDark = Color(0xFF17120F);

  // 线 / 玻璃描边
  static const line = Color(0x29FFFFFF); // glass-stroke 0.16

  // 统一彩色系统（Codex app-color-system）：粉 #ff4f9b / 珊瑚 #ff7f62 / 紫 #7f6bff / 蓝 #38d5ff
  static const hot = Color(0xFFFF4F9B); // 主粉（沿用旧名 hot）
  static const pink = Color(0xFFFF4F9B);
  static const red = Color(0xFFEE2F42);
  static const orange = Color(0xFFFF7F62);
  static const hot2 = Color(0xFFFF7F62); // 珊瑚（沿用旧名）
  static const orangeDeep = Color(0xFFF25A2B);
  static const gold = Color(0xFFFFD875);
  static const goldDeep = Color(0xFFC8942E);
  static const teal = Color(0xFF15D1B2);
  static const lime = Color(0xFFC6F26A);
  static const brightGold = Color(0xFFFFF1A8);
  static const blue = Color(0xFF38D5FF); // 粉蓝/青蓝
  static const cyan = Color(0xFF38D5FF);
  static const purple = Color(0xFF7F6BFF);
  static const pinkSoft = Color(0xFFFF6FA5);

  // 视频/封面之上
  static const onVideo = Colors.white;
  static const onVideoDim = Colors.white70;

  // 唯一主渐变（统一全 App 按钮/强调）：粉 → 紫 → 蓝
  static const brandGradient = LinearGradient(
    colors: [Color(0xFFFF4F9B), Color(0xFF7F6BFF), Color(0xFF38D5FF)],
    stops: [0, 0.58, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // 进度条/细条：粉 → 蓝
  static const progressGradient = LinearGradient(
    colors: [Color(0xFFFF4F9B), Color(0xFF38D5FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  // 观看按钮：粉 → 珊瑚（暖，和 AI Remix 的冷渐变区分）
  static const watchGradient = LinearGradient(
    colors: [Color(0xFFFF4F9B), Color(0xFFFF7F62)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  // 渐变 gradients（hotGradient 指向统一主渐变，旧用法自动统一）
  static const hotGradient = brandGradient;
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFFF1A8), Color(0xFFFFD875), Color(0xFFC8942E)],
    stops: [0, 0.42, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const aiGradient = LinearGradient(
    colors: [Color(0xFF15D1B2), Color(0xFF87F7D4), Color(0xFFFFD875)],
    stops: [0, 0.58, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // AI Remix / AI 玩法：统一用主渐变
  static const aiRemixGradient = brandGradient;
  // 开机动画：粉→珊瑚→紫→蓝 全屏彩色
  static const splashGradient = LinearGradient(
    colors: [
      Color(0xFFFF4F9B),
      Color(0xFFFF7F62),
      Color(0xFF7F6BFF),
      Color(0xFF38D5FF),
    ],
    stops: [0, 0.32, 0.66, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 视频压暗 scrim（to top）
  static const videoScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xF0060503), // 0.94
      Color(0xB8060503), // 0.72
      Color(0x2E060503), // 0.18
      Color(0x6B060503), // 0.42
    ],
    stops: [0, 0.22, 0.58, 1],
  );

  // 玻璃配方
  static const glassFill = Color(0x85161210); // rgba(22,18,15,0.52)
  static const glassFillStrong = Color(0xAD161210); // 0.68
  static const glassStroke = Color(0x29FFFFFF); // 0.16

  // 字号阶（px → Flutter fontSize）
  static const tDisplay = 40.0;
  static const tTitle = 28.0;
  static const tSection = 20.0;
  static const tBody = 15.0;
  static const tCaption = 12.0;
  static const tMicro = 10.0;
}

ThemeData buildFalconTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  return base.copyWith(
    scaffoldBackgroundColor: FF.bg,
    colorScheme: base.colorScheme.copyWith(
      surface: FF.bg,
      primary: FF.hot,
      secondary: FF.gold,
      brightness: Brightness.dark,
    ),
    textTheme: base.textTheme.apply(bodyColor: FF.text, displayColor: FF.text),
    canvasColor: FF.panel,
    dividerColor: FF.line,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: FF.panel,
      contentTextStyle: TextStyle(color: FF.text),
    ),
  );
}

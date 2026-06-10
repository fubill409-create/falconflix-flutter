import 'package:flutter/material.dart';

/// 日夜判定（参照 Nova SunTheme 的本地小时兜底：6:00–19:00 算白天）。
/// 后续可升级为按地理位置算日出/日落。
bool isDayNow() {
  final h = DateTime.now().hour;
  return h >= 6 && h < 19;
}

/// 工具页（剧场/我的/详情等）用的日夜调色板：白天=Codex 亮色令牌，夜间=暗色。
/// 沉浸页（首页/主播放页/AI互动角色星球）不用这个，始终电影级暗色 video-first。
/// ⚠️ 互动剧「播放器」(interactive_player_screen) **跟日夜**（用户 2026-06-05 拍板）——
/// 它是通用功能（甜蜜爱情剧/悬疑剧什么都能放），不该被某个剧的调调锁死暗黑。
class Pal {
  final bool day;
  const Pal(this.day);
  factory Pal.now() => Pal(isDayNow());

  // 表面
  Color get pageBg => day ? const Color(0xFFF7F4ED) : const Color(0xFF080706);
  Color get pageBg2 => day ? const Color(0xFFFFFAF1) : const Color(0xFF120F0C);
  Color get card => day ? Colors.white : const Color(0xFF161B24);
  Color get topbarBg =>
      day ? const Color(0xD1F7F4ED) : const Color(0xCC15120F);

  // 文字
  Color get text => day ? const Color(0xFF1F1914) : const Color(0xFFFFF8EE);
  Color get textSecondary =>
      day ? const Color(0xB81F1914) : const Color(0xC2FFF8EE);
  Color get textMuted => day ? const Color(0x8A1F1914) : const Color(0x94FFF8EE);

  // 线
  Color get line => day ? const Color(0x141F1914) : const Color(0x1FFFFFFF);

  // 类型筛选 chip
  Color get chipBg => day ? const Color(0xC7FFFFFF) : const Color(0x14FFFFFF);
  Color get chipText =>
      day ? const Color(0xB81F1914) : const Color(0xC2FFF8EE);
  Color get chipActiveBg =>
      day ? const Color(0xFF201A15) : const Color(0xFFFF3D4F);
  Color get chipActiveText => const Color(0xFFFFF8EE);

  // 小药丸（See all / 排序）
  Color get softPillBg =>
      day ? const Color(0xB8FFFFFF) : const Color(0x14FFFFFF);
}

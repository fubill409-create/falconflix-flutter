import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局界面语言状态。`MaterialApp` 用 `ValueListenableBuilder` 监听它，切语言整 App 立刻刷新。
/// 持久化到 SharedPreferences（重启 App 仍是上次选的）。
class LocaleNotifier extends ValueNotifier<Locale> {
  static const _key = 'ff_locale';

  /// 当前支持的 6 种语言。新增语言要：①加这里 ②加 `lib/l10n/app_xx.arb`
  /// ③`flutter gen-l10n` ④`main.dart` 的 `supportedLocales` 也加。
  static const List<Locale> supported = [
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('ar'),
    Locale('fr'),
  ];

  LocaleNotifier() : super(const Locale('zh'));

  /// 启动时从本地恢复上次选的语言。
  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final code = sp.getString(_key);
      if (code != null && code.isNotEmpty) {
        if (supported.any((l) => l.languageCode == code)) {
          value = Locale(code);
        }
      }
    } catch (_) {}
  }

  /// 切语言（立刻广播 → MaterialApp 重建 → 整 App 文本切换）。
  Future<void> setLocale(String code) async {
    if (!supported.any((l) => l.languageCode == code)) return;
    value = Locale(code);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key, code);
    } catch (_) {}
  }

  /// 阿拉伯语是 RTL（从右往左），其余 LTR。
  bool get isRtl => value.languageCode == 'ar';
}

/// 全局单例（main.dart 启动时 load()）。
final localeNotifier = LocaleNotifier();

import '../l10n/generated/app_localizations.dart';

/// 友好相对时间的 i18n helper：刚刚 / X 分钟前 / X 小时前 / X 天前 / 月-日。
/// 共用于 community_post / footprint / notify 等 3 处 timeLabel。
String relativeTimeLabel(DateTime when, AppLocalizations l) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return l.time_justNow;
  if (diff.inMinutes < 60) {
    return l.time_minutesAgoFmt(diff.inMinutes.toString());
  }
  if (diff.inHours < 24) {
    return l.time_hoursAgoFmt(diff.inHours.toString());
  }
  if (diff.inDays < 7) {
    return l.time_daysAgoFmt(diff.inDays.toString());
  }
  // 一周以上=纯数字月-日，跨语言安全。
  return '${when.month}-${when.day.toString().padLeft(2, '0')}';
}

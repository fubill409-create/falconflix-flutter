import '../l10n/generated/app_localizations.dart';

/// 站内消息（收件箱条目）。对应后端 d_notify / GET /notify/inbox 的 row。
///
/// 5 类 type：recharge / invite / system / activity / interactive
class NotifyMsg {
  final int id;
  final String type;
  final String title;
  final String body;

  /// App 内深链（如 /wallet、/short/123、/me/feedback/45），可空。
  final String? link;
  final bool isRead;
  final DateTime createTime;

  NotifyMsg({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.link,
    this.isRead = false,
    required this.createTime,
  });

  /// 类型显示标签（i18n）。
  String typeLabel(AppLocalizations l) {
    switch (type) {
      case 'recharge':
        return l.notify_typeRecharge;
      case 'invite':
        return l.notify_typeInvite;
      case 'system':
        return l.notify_typeSystem;
      case 'activity':
        return l.notify_typeActivity;
      case 'interactive':
        return l.notify_typeInteractive;
      default:
        return type;
    }
  }

  /// 相对时间：刚刚 / x分钟前 / x小时前 / x天前 / 月-日。
  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(createTime);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${createTime.month}-${createTime.day.toString().padLeft(2, '0')}';
  }

  factory NotifyMsg.fromJson(Map<String, dynamic> j) {
    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return NotifyMsg(
      id: parseInt(j['id']),
      type: j['type']?.toString() ?? 'system',
      title: j['title']?.toString() ?? '',
      body: j['body']?.toString() ?? '',
      link: j['link']?.toString(),
      isRead: parseInt(j['isRead']) == 1,
      createTime: parseTime(j['createTime']),
    );
  }
}

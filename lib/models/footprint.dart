/// 观看历史 / 足迹模型。对应后端 FootprintPageVO（/record/footprint）。
///
/// 一条记录代表用户对某剧的某一集（或整剧）的一次播放足迹；按 updateTime 倒序列出。
/// playTime / playTotalTime 是后端存的字符串，前端用来算 0-1 进度条。
class Footprint {
  final int id;
  final String shortId;
  final String shortName;
  final String shortImage;
  final bool isVip;

  final String? shortPlayId;
  final String? shortPlayName;

  /// 播放进度（秒，字符串形式存）
  final String? playTime;

  /// 总时长（秒，字符串形式存）
  final String? playTotalTime;

  final DateTime updateTime;

  Footprint({
    required this.id,
    required this.shortId,
    required this.shortName,
    required this.shortImage,
    this.isVip = false,
    this.shortPlayId,
    this.shortPlayName,
    this.playTime,
    this.playTotalTime,
    required this.updateTime,
  });

  /// 0-1 播放进度。无法解析时返回 null（前端不画进度条）。
  double? get progress {
    final cur = double.tryParse(playTime ?? '');
    final total = double.tryParse(playTotalTime ?? '');
    if (cur == null || total == null || total <= 0) return null;
    final p = cur / total;
    if (p.isNaN || p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  /// 相对时间标签：刚刚 / x分钟前 / x小时前 / x天前 / 月-日。
  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(updateTime);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${updateTime.month}-${updateTime.day.toString().padLeft(2, '0')}';
  }

  factory Footprint.fromJson(Map<String, dynamic> j) {
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

    return Footprint(
      id: parseInt(j['id']),
      shortId: j['shortId']?.toString() ?? '',
      shortName: j['shortName']?.toString() ?? '',
      shortImage: j['shortImage']?.toString() ?? '',
      isVip: j['isVip']?.toString() == '1',
      shortPlayId: j['shortPlayId']?.toString(),
      shortPlayName: j['shortPlayName']?.toString(),
      playTime: j['playTime']?.toString(),
      playTotalTime: j['playTotalTime']?.toString(),
      updateTime: parseTime(j['updateTime'] ?? j['createTime']),
    );
  }
}

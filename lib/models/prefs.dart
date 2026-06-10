/// 通知偏好 + 播放偏好（对应后端 d_notify_prefs / d_play_prefs）。
/// 字段全部用 bool / String，跟后端 Integer 0/1 互转。
library;

class NotifyPrefs {
  final bool pushEnabled; // 总开关
  final bool pushRecharge;
  final bool pushInvite;
  final bool pushSystem;
  final bool pushActivity;
  final bool pushInteractive;

  const NotifyPrefs({
    this.pushEnabled = true,
    this.pushRecharge = true,
    this.pushInvite = true,
    this.pushSystem = true,
    this.pushActivity = true,
    this.pushInteractive = true,
  });

  NotifyPrefs copyWith({
    bool? pushEnabled,
    bool? pushRecharge,
    bool? pushInvite,
    bool? pushSystem,
    bool? pushActivity,
    bool? pushInteractive,
  }) =>
      NotifyPrefs(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        pushRecharge: pushRecharge ?? this.pushRecharge,
        pushInvite: pushInvite ?? this.pushInvite,
        pushSystem: pushSystem ?? this.pushSystem,
        pushActivity: pushActivity ?? this.pushActivity,
        pushInteractive: pushInteractive ?? this.pushInteractive,
      );

  Map<String, dynamic> toJson() => {
        'pushEnabled': pushEnabled ? 1 : 0,
        'pushRecharge': pushRecharge ? 1 : 0,
        'pushInvite': pushInvite ? 1 : 0,
        'pushSystem': pushSystem ? 1 : 0,
        'pushActivity': pushActivity ? 1 : 0,
        'pushInteractive': pushInteractive ? 1 : 0,
      };

  factory NotifyPrefs.fromJson(Map<String, dynamic> j) {
    bool b(dynamic v) {
      if (v == null) return true; // 未设过 = 默认开
      if (v is bool) return v;
      if (v is num) return v != 0;
      return v.toString() == '1' || v.toString().toLowerCase() == 'true';
    }
    return NotifyPrefs(
      pushEnabled: b(j['pushEnabled']),
      pushRecharge: b(j['pushRecharge']),
      pushInvite: b(j['pushInvite']),
      pushSystem: b(j['pushSystem']),
      pushActivity: b(j['pushActivity']),
      pushInteractive: b(j['pushInteractive']),
    );
  }
}

class PlayPrefs {
  /// 首页自动播放下一条
  final bool autoplay;

  /// auto / 480 / 720 / 1080
  final String quality;

  /// 仅 Wi-Fi 下载
  final bool wifiOnlyDownload;

  /// 仅 Wi-Fi 自动播放
  final bool wifiOnlyAutoplay;

  const PlayPrefs({
    this.autoplay = true,
    this.quality = 'auto',
    this.wifiOnlyDownload = true,
    this.wifiOnlyAutoplay = false,
  });

  PlayPrefs copyWith({
    bool? autoplay,
    String? quality,
    bool? wifiOnlyDownload,
    bool? wifiOnlyAutoplay,
  }) =>
      PlayPrefs(
        autoplay: autoplay ?? this.autoplay,
        quality: quality ?? this.quality,
        wifiOnlyDownload: wifiOnlyDownload ?? this.wifiOnlyDownload,
        wifiOnlyAutoplay: wifiOnlyAutoplay ?? this.wifiOnlyAutoplay,
      );

  Map<String, dynamic> toJson() => {
        'autoplay': autoplay ? 1 : 0,
        'quality': quality,
        'wifiOnlyDownload': wifiOnlyDownload ? 1 : 0,
        'wifiOnlyAutoplay': wifiOnlyAutoplay ? 1 : 0,
      };

  factory PlayPrefs.fromJson(Map<String, dynamic> j) {
    bool b(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      return v.toString() == '1' || v.toString().toLowerCase() == 'true';
    }
    return PlayPrefs(
      autoplay: j['autoplay'] == null ? true : b(j['autoplay']),
      quality: (j['quality']?.toString() ?? 'auto'),
      wifiOnlyDownload: j['wifiOnlyDownload'] == null
          ? true
          : b(j['wifiOnlyDownload']),
      wifiOnlyAutoplay: b(j['wifiOnlyAutoplay']),
    );
  }
}

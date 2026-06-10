import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../api/api.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/prefs.dart';
import '../services/ix_cache.dart';
import '../state/locale_notifier.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import 'account_compliance_screens.dart';
import 'me_subpages.dart' show PrivacyScreen;

/// 设置主入口 —— me_screen「设置」组的折叠子页（任务 #13）。
///
/// 6 个分项，每项可能是 inline toggle / push 到子屏 / 弹 bottom sheet。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int? _cacheBytes; // 缓存总字节（异步算）

  @override
  void initState() {
    super.initState();
    _computeCache();
  }

  Future<void> _computeCache() async {
    try {
      final n = await IxCache.totalBytes();
      if (!mounted) return;
      setState(() => _cacheBytes = n);
    } catch (_) {
      if (!mounted) return;
      setState(() => _cacheBytes = 0);
    }
  }

  String _humanBytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(b / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  String get _langLabel {
    switch (localeNotifier.value.languageCode) {
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      case 'zh':
      default:
        return '中文';
    }
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: FF.dim, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(AppLocalizations.of(context).settings_rowLanguage,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            // 语言选项显示各自语言的原文名（不翻译），方便用户认出自己的语言
            for (final lng in const [
              ('zh', '中文'),
              ('en', 'English'),
              ('ja', '日本語'),
              ('ko', '한국어'),
              ('fr', 'Français'),
              ('ar', 'العربية'),
            ])
              ListTile(
                title: Text(lng.$2,
                    style: const TextStyle(color: FF.text, fontSize: 15)),
                trailing: lng.$1 == localeNotifier.value.languageCode
                    ? const Icon(Icons.check_rounded, color: FF.hot, size: 20)
                    : null,
                onTap: () async {
                  await localeNotifier.setLocale(lng.$1);
                  if (!mounted) return;
                  setState(() {});
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _clearCache() async {
    final l = AppLocalizations.of(context);
    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.settings_clearCacheTitle,
                  style: const TextStyle(
                      color: FF.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(l.settings_clearCacheBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: FF.dim, fontSize: 13, height: 1.5)),
              const SizedBox(height: 18),
              GradientButton(
                label: l.settings_clearCacheAction,
                height: 48,
                onTap: () => Navigator.pop(ctx, true),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.common_cancel, style: const TextStyle(color: FF.dim)),
              ),
            ],
          ),
        ),
      ),
    );
    if (yes != true) return;
    int freed = 0;
    try {
      freed = await IxCache.clear();
    } catch (_) {}
    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _cacheBytes = 0);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(l.settings_clearCacheDone(_humanBytes(freed)),
          style: const TextStyle(color: Colors.white)),
    ));
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p, AppLocalizations.of(context).settings_title),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    final l = AppLocalizations.of(context);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
                      children: [
                        _group(p, l.settings_sectionNotificationPlayback, [
                          _row(p, Icons.notifications_active_outlined, l.settings_rowNotifyPrefs,
                              onTap: () =>
                                  _push(const NotifyPrefsScreen())),
                          _row(p, Icons.play_circle_outline_rounded,
                              l.settings_rowPlayPrefs,
                              onTap: () => _push(const PlayPrefsScreen())),
                        ]),
                        _group(p, l.settings_sectionAccount, [
                          _row(p, Icons.shield_outlined, l.settings_rowAccountSecurity,
                              onTap: () =>
                                  _push(const AccountSecurityScreen())),
                          _row(p, Icons.privacy_tip_outlined, l.settings_rowPrivacy,
                              onTap: () =>
                                  _push(const PrivacyPrefsScreen())),
                        ]),
                        _group(p, l.settings_sectionUIStorage, [
                          _row(p, Icons.translate_rounded, l.settings_rowLanguage,
                              value: _langLabel, onTap: _pickLanguage),
                          _row(p, Icons.cleaning_services_outlined, l.settings_rowClearCache,
                              value: _cacheBytes == null
                                  ? null
                                  : _humanBytes(_cacheBytes!),
                              onTap: _clearCache),
                        ]),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(Pal p, String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text(title,
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6)),
          ),
          Glass(
            radius: 16,
            color: p.day ? p.card : FF.glassFill,
            border: p.line,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(height: 1, color: p.line, indent: 52),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Pal p, IconData icon, String title,
      {String? value, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: p.textMuted, size: 20),
      title: Text(title,
          style: TextStyle(
              color: p.text, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: TextStyle(color: p.textMuted, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: p.textMuted, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}

// =============================================================
// 通知偏好子页：5 类 push + 总开关
// =============================================================
class NotifyPrefsScreen extends StatefulWidget {
  const NotifyPrefsScreen({super.key});

  @override
  State<NotifyPrefsScreen> createState() => _NotifyPrefsScreenState();
}

class _NotifyPrefsScreenState extends State<NotifyPrefsScreen> {
  NotifyPrefs? _prefs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await Api.getNotifyPrefs();
      if (!mounted) return;
      setState(() {
        _prefs = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : AppLocalizations.of(context).common_loadFailed;
        _loading = false;
      });
    }
  }

  Future<void> _save(NotifyPrefs next) async {
    // 乐观更新 UI；接口失败回滚
    final prev = _prefs;
    setState(() => _prefs = next);
    try {
      final saved = await Api.updateNotifyPrefs(next);
      if (!mounted) return;
      setState(() => _prefs = saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _prefs = prev);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(AppLocalizations.of(context).notifyPrefs_saveFailed(e is ApiException ? e.message : '$e'),
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p, AppLocalizations.of(context).notifyPrefs_title),
                ),
                Expanded(child: _content(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Pal p) {
    final l = AppLocalizations.of(context);
    if (_loading) return Center(child: CircularProgressIndicator(color: FF.hot));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }
    final pr = _prefs!;
    final disabled = !pr.pushEnabled;
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
      children: [
        _switchGroup(p, [
          _switchRow(p, l.notifyPrefs_pushMaster, l.notifyPrefs_pushMasterDesc,
              pr.pushEnabled,
              (v) => _save(pr.copyWith(pushEnabled: v))),
        ]),
        _switchGroup(p, [
          _switchRow(p, l.notifyPrefs_recharge, l.notifyPrefs_rechargeDesc, pr.pushRecharge,
              disabled ? null : (v) => _save(pr.copyWith(pushRecharge: v))),
          _switchRow(p, l.notifyPrefs_invite, l.notifyPrefs_inviteDesc, pr.pushInvite,
              disabled ? null : (v) => _save(pr.copyWith(pushInvite: v))),
          _switchRow(p, l.notifyPrefs_system, l.notifyPrefs_systemDesc, pr.pushSystem,
              disabled ? null : (v) => _save(pr.copyWith(pushSystem: v))),
          _switchRow(p, l.notifyPrefs_activity, l.notifyPrefs_activityDesc, pr.pushActivity,
              disabled ? null : (v) => _save(pr.copyWith(pushActivity: v))),
          _switchRow(p, l.notifyPrefs_interactive, l.notifyPrefs_interactiveDesc, pr.pushInteractive,
              disabled
                  ? null
                  : (v) => _save(pr.copyWith(pushInteractive: v))),
        ]),
      ],
    );
  }

  Widget _switchGroup(Pal p, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Glass(
        radius: 16,
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1)
                Divider(height: 1, color: p.line, indent: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _switchRow(
      Pal p, String title, String subtitle, bool value, ValueChanged<bool>? onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: onChanged == null ? p.textMuted : p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        color: p.textMuted, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: FF.hot,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// 播放与下载偏好子页
// =============================================================
class PlayPrefsScreen extends StatefulWidget {
  const PlayPrefsScreen({super.key});

  @override
  State<PlayPrefsScreen> createState() => _PlayPrefsScreenState();
}

class _PlayPrefsScreenState extends State<PlayPrefsScreen> {
  PlayPrefs? _prefs;
  bool _loading = true;
  String? _error;

  /// quality 值 → AppLocalizations 的 getter 名（运行时翻译）
  static const _qualityOpts = [
    ('auto', 'playPrefs_qualityAuto'),
    ('480', 'playPrefs_quality480'),
    ('720', 'playPrefs_quality720'),
    ('1080', 'playPrefs_quality1080'),
  ];

  String _qualityLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'playPrefs_qualityAuto': return l.playPrefs_qualityAuto;
      case 'playPrefs_quality480': return l.playPrefs_quality480;
      case 'playPrefs_quality720': return l.playPrefs_quality720;
      case 'playPrefs_quality1080': return l.playPrefs_quality1080;
      default: return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await Api.getPlayPrefs();
      if (!mounted) return;
      setState(() {
        _prefs = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : AppLocalizations.of(context).common_loadFailed;
        _loading = false;
      });
    }
  }

  Future<void> _save(PlayPrefs next) async {
    final prev = _prefs;
    setState(() => _prefs = next);
    try {
      final saved = await Api.updatePlayPrefs(next);
      if (!mounted) return;
      setState(() => _prefs = saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _prefs = prev);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(AppLocalizations.of(context).notifyPrefs_saveFailed(e is ApiException ? e.message : '$e'),
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  void _pickQuality() {
    if (_prefs == null) return;
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: FF.dim, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.playPrefs_quality,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            for (final q in _qualityOpts)
              ListTile(
                title: Text(_qualityLabel(l, q.$2),
                    style: const TextStyle(color: FF.text, fontSize: 15)),
                trailing: q.$1 == _prefs!.quality
                    ? const Icon(Icons.check_rounded, color: FF.hot, size: 20)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _save(_prefs!.copyWith(quality: q.$1));
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p, AppLocalizations.of(context).playPrefs_title),
                ),
                Expanded(child: _content(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Pal p) {
    final l = AppLocalizations.of(context);
    if (_loading) return Center(child: CircularProgressIndicator(color: FF.hot));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }
    final pr = _prefs!;
    final qKey = _qualityOpts
        .firstWhere((q) => q.$1 == pr.quality, orElse: () => _qualityOpts.first)
        .$2;
    final qLabel = _qualityLabel(l, qKey);
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Glass(
            radius: 16,
            color: p.day ? p.card : FF.glassFill,
            border: p.line,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _switchRow(p, l.playPrefs_autoplay, l.playPrefs_autoplayDesc,
                    pr.autoplay,
                    (v) => _save(pr.copyWith(autoplay: v))),
                Divider(height: 1, color: p.line, indent: 16),
                _switchRow(p, l.playPrefs_wifiOnlyAutoplay,
                    l.playPrefs_wifiOnlyAutoplayDesc, pr.wifiOnlyAutoplay,
                    (v) => _save(pr.copyWith(wifiOnlyAutoplay: v))),
                Divider(height: 1, color: p.line, indent: 16),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  title: Text(l.playPrefs_quality,
                      style: TextStyle(
                          color: p.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  subtitle: Text(qLabel,
                      style:
                          TextStyle(color: p.textMuted, fontSize: 11)),
                  trailing:
                      Icon(Icons.chevron_right, color: p.textMuted, size: 18),
                  onTap: _pickQuality,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Glass(
            radius: 16,
            color: p.day ? p.card : FF.glassFill,
            border: p.line,
            padding: EdgeInsets.zero,
            child: _switchRow(p, l.playPrefs_wifiOnlyDownload,
                l.playPrefs_wifiOnlyDownloadDesc, pr.wifiOnlyDownload,
                (v) => _save(pr.copyWith(wifiOnlyDownload: v))),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
      Pal p, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        color: p.textMuted, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: FF.hot,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// 账号与安全子页：改密 + 注销账号入口
// =============================================================
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p, AppLocalizations.of(context).accountSec_title),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    final l = AppLocalizations.of(context);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
                      children: [
                        _group(p, l.accountSec_sectionLogin, [
                          _row(p, Icons.lock_outline_rounded, l.accountSec_rowChangePwd,
                              subtitle: l.accountSec_rowChangePwdDesc,
                              onTap: _changePassword),
                        ]),
                        _group(p, l.accountSec_sectionDeletion, [
                          _row(p, Icons.no_accounts_outlined, l.accountSec_rowDelete,
                              subtitle: l.accountSec_rowDeleteDesc,
                              danger: true,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DeleteAccountScreen()))),
                        ]),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final oldPw = TextEditingController();
    final pw1 = TextEditingController();
    final pw2 = TextEditingController();
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool busy = false;
        bool obscure = true;
        String? err;
        return StatefulBuilder(builder: (ctx, setSheet) {
          Widget box(TextEditingController c, String hint) => Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FF.line),
                ),
                child: TextField(
                  controller: c,
                  obscureText: obscure,
                  keyboardType: TextInputType.visiblePassword,
                  style: const TextStyle(
                      color: FF.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  cursorColor: FF.hot,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 14),
                    hintText: hint,
                    hintStyle: TextStyle(
                        color: FF.dim.withValues(alpha: 0.8), fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              );
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.accountSec_rowChangePwd,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setSheet(() => obscure = !obscure),
                      child: Icon(
                          obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: FF.dim,
                          size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                box(oldPw, l.accountSec_oldPwHint),
                const SizedBox(height: 10),
                box(pw1, l.accountSec_newPwHint),
                const SizedBox(height: 10),
                box(pw2, l.accountSec_confirmPwHint),
                if (err != null) ...[
                  const SizedBox(height: 10),
                  Text(err!,
                      style: const TextStyle(color: FF.hot, fontSize: 12)),
                ],
                const SizedBox(height: 18),
                GradientButton(
                  label: busy ? l.accountSec_saving : l.accountSec_saveNewPw,
                  height: 48,
                  onTap: busy
                      ? () {}
                      : () async {
                          if (pw1.text.length < 8) {
                            setSheet(() => err = l.accountSec_errMinLen);
                            return;
                          }
                          if (pw1.text != pw2.text) {
                            setSheet(() => err = l.accountSec_errMismatch);
                            return;
                          }
                          setSheet(() {
                            busy = true;
                            err = null;
                          });
                          try {
                            await Api.changePassword(
                              oldPassword: oldPw.text.isEmpty
                                  ? null
                                  : oldPw.text,
                              newPassword: pw1.text,
                            );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF15101F),
                                  content: Text(l.accountSec_pwUpdated,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ));
                          } on ApiException catch (e) {
                            setSheet(() {
                              busy = false;
                              err = e.message;
                            });
                          } catch (_) {
                            setSheet(() {
                              busy = false;
                              err = l.common_loadFailed;
                            });
                          }
                        },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.common_cancel,
                      style: const TextStyle(color: FF.dim)),
                ),
              ],
            ),
          );
        });
      },
    );
    oldPw.dispose();
    pw1.dispose();
    pw2.dispose();
  }

  Widget _group(Pal p, String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text(title,
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6)),
          ),
          Glass(
            radius: 16,
            color: p.day ? p.card : FF.glassFill,
            border: p.line,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(height: 1, color: p.line, indent: 52),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Pal p, IconData icon, String title,
      {String? subtitle, VoidCallback? onTap, bool danger = false}) {
    final fg = danger ? FF.hot : p.text;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: danger ? FF.hot : p.textMuted, size: 20),
      title: Text(title,
          style: TextStyle(
              color: fg, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle,
              style: TextStyle(color: p.textMuted, fontSize: 11)),
      trailing: Icon(Icons.chevron_right, color: p.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

// =============================================================
// 隐私子页：数据下载入口 + 隐私政策
// =============================================================
class PrivacyPrefsScreen extends StatelessWidget {
  const PrivacyPrefsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p, AppLocalizations.of(context).privacyPrefs_title),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    final l = AppLocalizations.of(context);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
                      children: [
                        _group(p, l.privacyPrefs_sectionData, [
                          _row(p, Icons.download_for_offline_outlined, l.privacyPrefs_rowExport,
                              subtitle: l.privacyPrefs_rowExportDesc,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DataExportScreen()))),
                        ]),
                        _group(p, l.privacyPrefs_sectionLegal, [
                          _row(p, Icons.shield_moon_outlined, l.privacyPrefs_rowPolicy,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PrivacyScreen()))),
                        ]),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(Pal p, String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text(title,
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6)),
          ),
          Glass(
            radius: 16,
            color: p.day ? p.card : FF.glassFill,
            border: p.line,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(height: 1, color: p.line, indent: 52),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Pal p, IconData icon, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: p.textMuted, size: 20),
      title: Text(title,
          style: TextStyle(
              color: p.text, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle,
              style: TextStyle(color: p.textMuted, fontSize: 11)),
      trailing: Icon(Icons.chevron_right, color: p.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

// =============================================================
// 通用 topbar（设置类子页共用）
// =============================================================
Widget _topbar(Pal p, String title) {
  return Builder(
    builder: (context) => Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.day
                  ? Colors.black.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: p.line),
            ),
            child: Icon(Icons.arrow_back_rounded, color: p.text, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(
                color: p.text, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

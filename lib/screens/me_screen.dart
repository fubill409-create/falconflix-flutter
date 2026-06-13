import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/level_curve.dart';
import '../state/locale_notifier.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import '../ui/level_badge.dart';
import 'community_screen.dart';
import 'help_about_screen.dart';
import 'history_screen.dart';
import 'inbox_screen.dart';
import 'login_screen.dart';
import 'me_subpages.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';

/// 个人中心（UI 先行，演示数据）。电影级深色：环境光 + 毛玻璃卡 + 头像发光。
class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  // 语言列表（code, 显示名）。显示名固定每语言原文，不翻译——方便用户找自己的语言。
  static const _langs = [
    ('zh', '中文'),
    ('en', 'English'),
    ('ja', '日本語'),
    ('ko', '한국어'),
    ('fr', 'Français'),
    ('ar', 'العربية'),
  ];

  String get _lang => localeNotifier.value.languageCode;
  String get _langLabel =>
      _langs.firstWhere((l) => l.$1 == _lang, orElse: () => _langs.first).$2;

  int? _collectCount; // 收藏剧目数（null=未加载/未登录显「—」）
  int? _boughtCount; // 已购剧集数（null=未加载/未登录显「—」）

  @override
  void initState() {
    super.initState();
    if (auth.loggedIn) auth.refresh();
    _loadCollectCount();
    _loadBoughtCount();
    Api.refreshUnreadCount(); // 进我的页时刷新一次未读数（顶栏红点用）
    auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    // 登录/登出后收藏数会变：登出清空、登录重拉。
    if (!auth.loggedIn) {
      if (mounted) {
        setState(() {
          _collectCount = null;
          _boughtCount = null;
        });
      }
      Api.unreadNotify.value = 0; // 登出立刻清红点
    } else {
      _loadCollectCount(refresh: true);
      _loadBoughtCount();
      Api.refreshUnreadCount(); // 登录后拉一次未读数
    }
  }

  Future<void> _loadBoughtCount() async {
    if (!auth.loggedIn) {
      if (mounted) setState(() => _boughtCount = null);
      return;
    }
    try {
      // 已购剧集 = 已购整剧 + 已购单集（真接 /record/purchases）
      final shorts = await Api.ordersList(isShort: true);
      final eps = await Api.ordersList(isShort: false);
      if (mounted) setState(() => _boughtCount = shorts.length + eps.length);
    } catch (_) {
      // 失败不打扰，保持上次值。
    }
  }

  Future<void> _loadCollectCount({bool refresh = false}) async {
    if (!auth.loggedIn) {
      if (mounted) setState(() => _collectCount = null);
      return;
    }
    try {
      final n = await Api.collectedCount(refresh: refresh);
      if (mounted) setState(() => _collectCount = n);
    } catch (_) {
      // 失败不打扰，保持上次值。
    }
  }

  void _openCollection() {
    if (!auth.loggedIn) {
      _goLogin();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CollectionScreen()),
    ).then((_) => _loadCollectCount()); // 回来刷新计数（可能在详情里取消了收藏）
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _goLogin() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (ok == true) auth.refresh();
  }

  Future<void> _confirmLogout() async {
    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18),
            Text(AppLocalizations.of(context).me_logoutConfirm,
                style: const TextStyle(
                    color: FF.text, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GradientButton(
                label: AppLocalizations.of(context).common_logout,
                height: 48,
                onTap: () => Navigator.pop(ctx, true),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context).common_cancel, style: const TextStyle(color: FF.dim)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (yes == true) await auth.logout();
  }

  /// 设置/修改登录密码（旧路径，已不在主菜单暴露）。
  /// 改密入口已迁移至 SettingsScreen → 账号与安全。
  // ignore: unused_element
  Future<void> _setPassword() async {
    final pw1 = TextEditingController();
    final pw2 = TextEditingController();
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
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Widget pwBox(TextEditingController c, String hint) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: FF.line),
                  ),
                  child: TextField(
                    controller: c,
                    obscureText: obscure,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (_) {
                      if (err != null) setSheet(() => err = null);
                    },
                    style: const TextStyle(
                        color: FF.text, fontSize: 15, fontWeight: FontWeight.w600),
                    cursorColor: FF.hot,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 14),
                      hintText: hint,
                      hintStyle:
                          TextStyle(color: FF.dim.withValues(alpha: 0.8), fontSize: 14),
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
                      const Text('设置登录密码',
                          style: TextStyle(
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
                  const SizedBox(height: 16),
                  pwBox(pw1, '请输入新密码（至少 6 位）'),
                  const SizedBox(height: 10),
                  pwBox(pw2, '再次输入新密码'),
                  if (err != null) ...[
                    const SizedBox(height: 10),
                    Text(err!,
                        style: const TextStyle(color: FF.hot, fontSize: 12)),
                  ],
                  const SizedBox(height: 18),
                  GradientButton(
                    label: busy ? '保存中…' : '保存密码',
                    height: 48,
                    onTap: busy
                        ? () {}
                        : () async {
                            final a = pw1.text;
                            final b = pw2.text;
                            if (a.length < 6) {
                              setSheet(() => err = '密码至少 6 位');
                              return;
                            }
                            if (a != b) {
                              setSheet(() => err = '两次输入的密码不一致');
                              return;
                            }
                            setSheet(() {
                              busy = true;
                              err = null;
                            });
                            try {
                              await Api.setPassword(a);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Color(0xFF15101F),
                                  content: Text('密码已设置，下次可用密码登录',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              );
                            } on ApiException catch (e) {
                              setSheet(() {
                                busy = false;
                                err = e.message;
                              });
                            } catch (_) {
                              setSheet(() {
                                busy = false;
                                err = '保存失败，请检查网络后重试';
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消', style: TextStyle(color: FF.dim)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    pw1.dispose();
    pw2.dispose();
  }

  /// 语言选择器（旧路径，已不在主菜单暴露）。
  /// 入口已迁移至 SettingsScreen → 界面与存储 → 界面语言。
  // ignore: unused_element
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
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                    AppLocalizations.of(context).settings_rowLanguage,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            for (final l in _langs)
              ListTile(
                title: Text(l.$2,
                    style: const TextStyle(color: FF.text, fontSize: 15)),
                trailing: l.$1 == _lang
                    ? const Icon(Icons.check_rounded, color: FF.hot, size: 20)
                    : null,
                onTap: () async {
                  await localeNotifier.setLocale(l.$1);
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

  @override
  Widget build(BuildContext context) {
    final pal = Pal.now();
    return Scaffold(
      backgroundColor: pal.pageBg,
      body: Stack(
        children: [
          if (!pal.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListenableBuilder(
              listenable: auth,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(6, 16, 6, 110),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: gradientText(AppLocalizations.of(context).me_title, size: 26)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Bounce(
                    onTap: auth.loggedIn ? _openAccountSheet : _goLogin,
                    child: Glass(
                        radius: 18,
                        color: pal.day ? pal.card : FF.glassFill,
                        border: pal.line,
                        child: _profile(pal)),
                  ),
                  const SizedBox(height: 16),
                  _stats(pal),
                  const SizedBox(height: 18),
                  _groupedEntries(pal),
                  if (auth.loggedIn) ...[
                    const SizedBox(height: 22),
                    _logoutButton(pal),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profile(Pal pal) {
    if (!auth.loggedIn) {
      return Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: FF.brandGradient,
                boxShadow: [
                  BoxShadow(color: FF.hot.withValues(alpha: 0.5), blurRadius: 18),
                ]),
            child: const Icon(Icons.person_outline_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).me_loginPrompt,
                    style: TextStyle(
                        color: pal.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(AppLocalizations.of(context).me_loginSubtitle,
                    style: TextStyle(color: pal.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: pal.textMuted, size: 20),
        ],
      );
    }

    final p = auth.profile;
    final l = AppLocalizations.of(context);
    final name = p?.displayName ?? l.me_title;
    final initial = name.isNotEmpty ? name.characters.first : 'F';
    final sub = p == null
        ? l.common_loading
        : '${p.isVip ? l.me_membershipVip : l.me_membershipNormal} · ${l.me_inviteCode} ${p.inviteCode.isEmpty ? "—" : p.inviteCode}';
    final hasAvatar = (p?.avatar ?? '').startsWith('http');
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: FF.brandGradient,
              boxShadow: [
                BoxShadow(color: FF.hot.withValues(alpha: 0.5), blurRadius: 18),
              ]),
          child: hasAvatar
              ? Image.network(p!.avatar, width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initialText(initial))
              : _initialText(initial),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: pal.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: pal.textMuted, fontSize: 12)),
            ],
          ),
        ),
        if (p?.isVip == true) ...[
          const GlowChip('VIP'),
          const SizedBox(width: 6),
        ],
        LevelBadge(auth.level, compact: true),
      ],
    );
  }

  Widget _initialText(String s) => Text(s.toUpperCase(),
      style: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700));

  Widget _bigInitial(String s) => Text(s.toUpperCase(),
      style: const TextStyle(
          color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800));

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  /// 点资料卡弹出的「身份资料」面板：V 级别身份卡 + 基本信息（邮箱/邀请码/鹰币/会员）+ 换头像。
  void _openAccountSheet() {
    auth.refreshLevel(force: true); // 打开即刷新累计充值 → V 级别
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final l = AppLocalizations.of(context);
        bool busy = false;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final p = auth.profile;
            final name = p?.displayName ?? l.me_defaultName;
            final initial = name.isNotEmpty ? name.characters.first : 'F';
            final hasAvatar = (p?.avatar ?? '').startsWith('http');
            final email = p?.email ?? '';
            final emailShown = email.isNotEmpty
                ? email
                : ((p?.mobile.isNotEmpty ?? false) ? p!.mobile : '—');
            final level = auth.level;
            final tier = levelTier(level);
            final isMax = level >= 99;

            Future<void> pick() async {
              if (busy) return;
              try {
                // 头像无需大图：压到 512、质量 80。OBS 上传是带宽瓶颈
                // （日志 write data 17s），缩小后服务端→OBS 大幅提速。
                final x = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                if (x == null) return;
                setSheet(() => busy = true);
                final url = await Api.uploadImage(File(x.path));
                await Api.updateAvatar(url);
                await auth.refresh();
                if (!ctx.mounted) return;
                setSheet(() => busy = false);
                _toast(l.me_avatarUpdated);
              } on ApiException catch (e) {
                setSheet(() => busy = false);
                _toast(e.message);
              } catch (_) {
                setSheet(() => busy = false);
                _toast(l.me_avatarUpdateFailed);
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: FF.dim,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: GestureDetector(
                        onTap: pick,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: FF.brandGradient,
                                boxShadow: [
                                  BoxShadow(
                                      color: FF.hot.withValues(alpha: 0.5),
                                      blurRadius: 26),
                                ],
                              ),
                              child: busy
                                  ? const SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white))
                                  : hasAvatar
                                      ? Image.network(p!.avatar,
                                          width: 92,
                                          height: 92,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _bigInitial(initial))
                                      : _bigInitial(initial),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: FF.hot,
                                  border:
                                      Border.all(color: FF.panel, width: 2.5),
                                ),
                                child: const Icon(Icons.photo_camera_rounded,
                                    color: Colors.white, size: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: FF.text,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 8),
                          LevelBadge(level, compact: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(l.me_tapAvatarToChange,
                          style: const TextStyle(color: FF.dim, fontSize: 12)),
                    ),
                    const SizedBox(height: 20),
                    // V 级别身份卡（段位 + 升级进度 + 累计充值）
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1B1430), Color(0xFF33254C)],
                        ),
                        border: Border.all(
                            color: tier.color.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(l.me_myLevel,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              const Spacer(),
                              LevelBadge(level),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isMax)
                            Text(l.wallet_legendPeak,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800))
                          else ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value:
                                    levelProgress(auth.cumulativePaidCoins)
                                        .clamp(0.04, 1.0),
                                minHeight: 7,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.16),
                                valueColor: const AlwaysStoppedAnimation(
                                    Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                    l.wallet_topUpToLevelFmt(
                                        _usd(coinsToNextLevel(
                                            auth.cumulativePaidCoins)),
                                        (level + 1).toString()),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text(
                                    l.wallet_paidUsdFmt(
                                        _usd(auth.cumulativePaidCoins)),
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 基本信息
                    Glass(
                      radius: 16,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _infoRow(l.me_loginEmail, emailShown,
                              copyable: email.isNotEmpty),
                          const Divider(
                              height: 1,
                              color: FF.line,
                              indent: 16,
                              endIndent: 16),
                          _infoRow(
                              l.me_inviteCode,
                              (p?.inviteCode.isNotEmpty ?? false)
                                  ? p!.inviteCode
                                  : '—',
                              copyable: p?.inviteCode.isNotEmpty ?? false),
                          const Divider(
                              height: 1,
                              color: FF.line,
                              indent: 16,
                              endIndent: 16),
                          _infoRow(
                              l.wallet_balanceLabel,
                              l.sheets_coinsFmt(
                                  ((p?.balance ?? 0).toInt()).toString())),
                          const Divider(
                              height: 1,
                              color: FF.line,
                              indent: 16,
                              endIndent: 16),
                          _infoRow(
                              l.me_membership,
                              p?.isVip == true
                                  ? l.me_membershipVip
                                  : l.me_membershipNormal),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: busy ? l.me_uploading : l.me_changeAvatar,
                      height: 50,
                      onTap: busy ? () {} : pick,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.common_close,
                          style: const TextStyle(color: FF.dim)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {bool copyable = false}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          // 标签定宽，值紧跟其后左对齐——不再被 Spacer 顶到最右、留一大段空。
          SizedBox(
            width: 84,
            child:
                Text(label, style: const TextStyle(color: FF.dim, fontSize: 14)),
          ),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    color: FF.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            const Icon(Icons.copy_rounded, color: FF.dim, size: 15),
          ],
        ],
      ),
    );
    if (!copyable) return row;
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        _toast(AppLocalizations.of(context).me_copiedFmt(value));
      },
      child: row,
    );
  }

  Widget _stats(Pal pal) {
    final p = auth.profile;
    final coins = auth.loggedIn ? _fmt(p?.balance ?? 0) : '—';
    final collect =
        auth.loggedIn && _collectCount != null ? '$_collectCount' : '—';
    return Glass(
      radius: 16,
      color: pal.day ? pal.card : FF.glassFill,
      border: pal.line,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: _Stat(pal: pal, value: coins, label: AppLocalizations.of(context).me_statEagleCoins)),
          _VDivider(color: pal.line),
          Expanded(child: _Stat(pal: pal, value: auth.loggedIn && _boughtCount != null ? '$_boughtCount' : '—', label: AppLocalizations.of(context).me_statBoughtEpisodes)),
          _VDivider(color: pal.line),
          // 收藏可点：进「我的收藏」列表。
          Expanded(
            child: _Stat(
              pal: pal,
              value: collect,
              label: AppLocalizations.of(context).me_statCollections,
              onTap: _openCollection,
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}K';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(0);
  }

  /// 等级值鹰币 → 美金（谈钱用美金）：$10 / $4.99。
  static String _usd(int coins) {
    final v = coins / 100.0;
    if (v == v.roundToDouble()) return '\$${v.toStringAsFixed(0)}';
    return '\$${v.toStringAsFixed(2)}';
  }

  /// 我的页 v2.1 — 六组分组结构（2026-06-08 重整，[[feedback-no-stopgap]] 没有占位）。
  /// 当前每个入口都对应**真实可工作**的页面；新入口（观看历史/订单/收件箱/设置子页/反馈）
  /// 用 TODO 注释占位，等对应子任务（#10-#15）做完后反注释 + 把入口加进来。
  Widget _groupedEntries(Pal pal) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(pal, l.me_sectionMyContent, [
          _row(Icons.bookmark_outline_rounded, l.me_rowCollections,
              value: auth.loggedIn && _collectCount != null
                  ? '$_collectCount'
                  : null,
              onTap: _openCollection),
          _row(Icons.history_rounded, l.me_rowHistory,
              onTap: () {
            if (!auth.loggedIn) {
              _goLogin();
              return;
            }
            _push(const HistoryScreen());
          }),
        ]),

        _section(pal, l.me_sectionWallet, [
          _row(Icons.account_balance_wallet_outlined, l.me_rowWallet,
              onTap: () => _push(const WalletScreen())),
          _row(Icons.receipt_long_outlined, l.me_rowOrders,
              onTap: () {
            if (!auth.loggedIn) {
              _goLogin();
              return;
            }
            _push(const OrdersScreen());
          }),
          _row(Icons.card_giftcard_outlined, l.me_rowInvite,
              onTap: () => _push(const InviteScreen())),
        ]),

        // v1 隐藏社区入口:社区(点赞/评论/发帖)还是内存 mock,真做好再放出来。
        // 通知设置是真的,挪到这一组里单独留着。
        _section(pal, l.me_sectionCommunity, [
          _notifyRow(pal),
        ]),

        // v1 隐藏"创作者→聚集伙伴":伙伴招募短期不上、点进去功能还在开发,先去掉。
        _section(pal, l.me_sectionSettings, [
          _row(Icons.tune_rounded, l.me_rowSettings,
              value: _langLabel,
              onTap: () => _push(const SettingsScreen())),
        ]),

        _section(pal, l.me_sectionHelpAbout, [
          _row(Icons.help_outline_rounded, l.me_rowHelpAbout,
              onTap: () => _push(const HelpAboutScreen())),
        ]),
      ],
    );
  }

  /// 一组分组：标题（小写灰字带左缩进）+ 单张毛玻璃卡片包裹所有 row。
  Widget _section(Pal pal, String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text(
              title,
              style: TextStyle(
                color: pal.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Glass(
            radius: 16,
            color: pal.day ? pal.card : FF.glassFill,
            border: pal.line,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(height: 1, color: pal.line, indent: 52),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 退出登录 —— 单独红色按钮放底部，跟「设置类」入口物理隔离，
  /// 防止误点（之前所有入口在一张卡里时偶发误触发退出）。
  Widget _logoutButton(Pal pal) {
    return Glass(
      radius: 16,
      color: pal.day ? pal.card : FF.glassFill,
      border: pal.line,
      padding: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        leading: Icon(Icons.logout_rounded, color: FF.hot, size: 20),
        title: Text(AppLocalizations.of(context).common_logout,
            style: const TextStyle(
                color: FF.hot, fontSize: 15, fontWeight: FontWeight.w600)),
        onTap: _confirmLogout,
      ),
    );
  }

  Widget _row(IconData icon, String title, {String? value, VoidCallback? onTap}) {
    final pal = Pal.now();
    return ListTile(
      dense: true,
      leading: Icon(icon, color: pal.textMuted, size: 20),
      title: Text(title,
          style: TextStyle(
              color: pal.text, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: TextStyle(color: pal.textMuted, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: pal.textMuted, size: 18),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  /// 消息通知行：trailing 实时显示未读红点（订阅 Api.unreadNotify）。
  Widget _notifyRow(Pal pal) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.notifications_none_rounded,
          color: pal.textMuted, size: 20),
      title: Text(AppLocalizations.of(context).me_rowNotifications,
          style: TextStyle(
              color: pal.text, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: Api.unreadNotify,
            builder: (_, n, _) {
              if (n <= 0) return const SizedBox.shrink();
              final label = n > 99 ? '99+' : '$n';
              return Container(
                margin: const EdgeInsetsDirectional.only(end: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: FF.hot,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints:
                    const BoxConstraints(minWidth: 20, minHeight: 18),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.0),
                ),
              );
            },
          ),
          Icon(Icons.chevron_right, color: pal.textMuted, size: 18),
        ],
      ),
      onTap: () {
        if (!auth.loggedIn) {
          _goLogin();
          return;
        }
        _push(const InboxScreen());
      },
    );
  }
}

class _VDivider extends StatelessWidget {
  final Color color;
  const _VDivider({required this.color});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: color);
}

class _Stat extends StatelessWidget {
  final Pal pal;
  final String value;
  final String label;
  final VoidCallback? onTap;
  const _Stat(
      {required this.pal,
      required this.value,
      required this.label,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final col = Column(
      children: [
        Text(value,
            style: TextStyle(
                color: pal.text, fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: pal.textMuted, fontSize: 12)),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, color: pal.textMuted, size: 13),
            ],
          ],
        ),
      ],
    );
    if (onTap == null) return col;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: col,
    );
  }
}

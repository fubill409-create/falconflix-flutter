import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../api/api.dart';
import '../app_config.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import 'me_subpages.dart' show TermsScreen, PrivacyScreen;
import '../theme.dart';
import '../ui/kit.dart';

/// 仪式感登录页：金鹰品牌 + 渐变环境光 + 玻璃卡。
/// 邮箱 + 验证码登录。成功后 pop(true)。
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _emailFocus = FocusNode();

  // false=验证码登录，true=密码登录（密码人自己记，老板回头登录不用每次收码）。
  bool _passwordMode = false;
  bool _pwObscure = true;

  bool _sending = false;
  bool _submitting = false;
  bool _socialBusy = false;
  bool _googleInited = false;
  bool _success = false;
  String? _error;
  int _countdown = 0;
  Timer? _timer;

  // 用过的邮箱：聚焦邮箱框时弹历史，点一下即填，免每次重输。
  List<String> _emailHistory = [];
  bool _emailFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (mounted) setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _loadEmailHistory();
  }

  Future<void> _loadEmailHistory() async {
    final list = await Api.emailHistory();
    if (!mounted) return;
    setState(() {
      _emailHistory = list;
      // 只有一个历史邮箱时直接预填，连点都省了。
      if (_emailCtrl.text.isEmpty && list.length == 1) {
        _emailCtrl.text = list.first;
      }
    });
  }

  /// 当前应展示的历史邮箱（聚焦时、按输入过滤、排除完全相同项）。
  List<String> get _emailSuggestions {
    if (!_emailFocused) return const [];
    final q = _emailCtrl.text.trim().toLowerCase();
    return _emailHistory
        .where((e) => e.toLowerCase() != q && e.toLowerCase().contains(q))
        .toList();
  }

  void _pickEmail(String email) {
    setState(() {
      _emailCtrl.text = email;
      _emailCtrl.selection =
          TextSelection.collapsed(offset: email.length);
      _error = null;
    });
    _emailFocus.unfocus();
  }

  Future<void> _removeEmail(String email) async {
    await Api.forgetEmail(email);
    if (!mounted) return;
    setState(() => _emailHistory.remove(email));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _pwCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool get _emailOk {
    final e = _emailCtrl.text.trim();
    return e.contains('@') && e.contains('.');
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  Future<void> _sendCode() async {
    final l = AppLocalizations.of(context);
    if (!_emailOk) {
      setState(() => _error = l.login_emailInvalid);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final codeSentMsg = l.login_codeSent;
    final notConfiguredMsg = l.login_emailNotConfigured;
    try {
      await Api.sendEmailCode(_emailCtrl.text.trim());
      if (!mounted) return;
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(codeSentMsg, style: const TextStyle(color: Colors.white)),
      ));
    } catch (_) {
      // 本地后端常没配 SMTP：发不出去也别堵死，提示用测试码。
      if (!mounted) return;
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(notConfiguredMsg,
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _login() async {
    final l = AppLocalizations.of(context);
    if (!_emailOk) {
      setState(() => _error = l.login_emailRequired);
      return;
    }
    final code = _codeCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (_passwordMode) {
      if (pw.isEmpty) {
        setState(() => _error = l.login_passwordRequired);
        return;
      }
    } else if (code.isEmpty) {
      setState(() => _error = l.login_codeRequired);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });
    final netErrMsg = l.login_networkError;
    try {
      if (_passwordMode) {
        await auth.loginByPassword(_emailCtrl.text.trim(), pw);
      } else {
        await auth.loginByEmail(_emailCtrl.text.trim(), code);
      }
      if (!mounted) return;
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 850));
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = netErrMsg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _topbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _brand(),
                        const SizedBox(height: 22),
                        _card(),
                        const SizedBox(height: 22),
                        _socialLogin(),
                        const SizedBox(height: 18),
                        // 协议提示 + 用户协议/隐私政策可点链接(苹果 G4/G1.2:必须可访问)
                        const Center(child: _AgreementLinks()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_success) _successOverlay(),
        ],
      ),
    );
  }

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: FF.line),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: FF.purple.withValues(alpha: 0.3), blurRadius: 20),
              BoxShadow(color: FF.hot.withValues(alpha: 0.18), blurRadius: 20),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/brand/logo_eagle.png',
                width: 56, height: 56, fit: BoxFit.cover),
          ),
        )
            .animate()
            .scaleXY(begin: 0.7, duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 500.ms),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              gradientText(AppLocalizations.of(context).login_welcome,
                      size: 19, gradient: FF.brandGradient)
                  .animate(delay: 120.ms)
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: 0.12, curve: Curves.easeOut),
              const SizedBox(height: 5),
              Text(AppLocalizations.of(context).login_subtitle,
                      style: TextStyle(
                          color: FF.muted, fontSize: 12, height: 1.4))
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card() {
    return Glass(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(AppLocalizations.of(context).login_emailLabel),
          const SizedBox(height: 8),
          _field(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hint: 'you@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() => _error = null),
          ),
          _emailSuggestionList(),
          const SizedBox(height: 16),
          _modeToggle(),
          const SizedBox(height: 16),
          if (_passwordMode) ...[
            _label(AppLocalizations.of(context).login_passwordLabel),
            const SizedBox(height: 8),
            _passwordField(),
          ] else ...[
            _label(AppLocalizations.of(context).login_codeLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _codeCtrl,
                    hint: AppLocalizations.of(context).login_codeHint,
                    icon: Icons.shield_outlined,
                    keyboardType: TextInputType.text,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ),
                const SizedBox(width: 10),
                _codeButton(),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: FF.hot, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_error!,
                      style: const TextStyle(color: FF.hot, fontSize: 12)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          GradientButton(
            label: _submitting
                ? AppLocalizations.of(context).login_loggingIn
                : AppLocalizations.of(context).login_loginOrRegister,
            height: 52,
            shimmer: !_submitting,
            gradient: FF.brandGradient,
            glow: FF.purple,
            onTap: _submitting ? () {} : _login,
          ),
          if (_passwordMode) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(AppLocalizations.of(context).login_pwHint,
                  style: TextStyle(
                      color: FF.dim.withValues(alpha: 0.7), fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  /// 快捷登录区：分隔线 + 一排精致小圆图标（Google/Apple 标「推荐」）。
  /// 借用同公司已注册的 Google/Apple 账号，不重复注册；接入完成前先走「正在接入」提示。
  Widget _socialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: FF.line, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(AppLocalizations.of(context).login_quickLogin,
                  style: TextStyle(
                      color: FF.dim,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
            ),
            Expanded(child: Divider(color: FF.line, thickness: 1)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIconBtn(
              glyph: const _GoogleGlyph(size: 20),
              bg: Colors.white,
              label: 'Google',
              recommended: true,
              onTap: _googleLogin,
            ),
            const SizedBox(width: 26),
            _socialIconBtn(
              glyph: const Icon(Icons.apple, color: Colors.white, size: 23),
              bg: const Color(0xFF0E1014),
              border: FF.line,
              label: 'Apple',
              recommended: true,
              onTap: _appleLogin,
            ),
            const SizedBox(width: 26),
            _socialIconBtn(
              glyph: const Icon(Icons.chat_bubble, color: Colors.white, size: 16),
              bg: const Color(0xFF06C755),
              label: 'LINE',
              onTap: _lineLogin,
            ),
            // Facebook 未配置 AppId 时整个按钮不渲染——绝不给审核员留"正在接入中"的半成品入口
            if (kFacebookAppId.isNotEmpty) ...[
              const SizedBox(width: 26),
              _socialIconBtn(
                glyph: const _FacebookGlyph(size: 18),
                bg: const Color(0xFF1877F2),
                label: 'Facebook',
                onTap: _facebookLogin,
              ),
            ],
          ],
        ),
      ],
    )
        .animate(delay: 280.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  /// 单个圆形社交图标：44px 圆 + 下方极小文案；推荐项右上角挂一颗小渐变标。
  Widget _socialIconBtn({
    required Widget glyph,
    required Color bg,
    required String label,
    required VoidCallback onTap,
    Color? border,
    bool recommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: border != null ? Border.all(color: border) : null,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: glyph,
              ),
              if (recommended)
                Positioned(
                  top: -5,
                  right: -7,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      gradient: FF.brandGradient,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: FF.bg, width: 1.2),
                    ),
                    child: Text(AppLocalizations.of(context).login_recommended,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            height: 1)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(
                  color: FF.dim,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1)),
        ],
      ),
    );
  }

  /// Google 真登录：原生授权拿 idToken → 后端 /call/login/google 验真 → 我们的 JWT。
  /// 还没配 Web client ID（kGoogleServerClientId 为空）时先走「正在接入中」，不报错。
  Future<void> _googleLogin() async {
    if (kGoogleServerClientId.isEmpty) {
      _onSocial('Google');
      return;
    }
    if (_socialBusy) return;
    setState(() {
      _socialBusy = true;
      _error = null;
    });
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInited) {
        await signIn.initialize(serverClientId: kGoogleServerClientId);
        _googleInited = true;
      }
      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw ApiException('Google 未返回 idToken，请检查凭证配置');
      }
      await auth.loginByGoogle(idToken, email: account.email);
      if (!mounted) return;
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 850));
      if (mounted) Navigator.pop(context, true);
    } on GoogleSignInException catch (e) {
      // 用户主动取消：静默；其它配置/网络错误：提示。
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      if (mounted) setState(() => _error = 'Google 登录失败：${e.code.name}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Google 登录失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _socialBusy = false);
    }
  }

  /// Apple 真登录：网页授权拿回我们后端发的 JWT（流程见 Api.loginByApple）。
  /// 还没配 Service ID（kAppleServiceId 为空）时先走「正在接入中」，不报错。
  Future<void> _appleLogin() async {
    // iOS：原生 Sign in with Apple（苹果 4.8 强制，给了 Google/LINE 就必须有它）。
    if (Platform.isIOS) {
      if (_socialBusy) return;
      setState(() {
        _socialBusy = true;
        _error = null;
      });
      try {
        final cred = await SignInWithApple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final idt = cred.identityToken;
        if (idt == null || idt.isEmpty) {
          throw ApiException('Apple 未返回 identityToken');
        }
        await auth.loginByAppleNative(idt);
        if (!mounted) return;
        setState(() => _success = true);
        await Future.delayed(const Duration(milliseconds: 850));
        if (mounted) Navigator.pop(context, true);
      } on SignInWithAppleAuthorizationException catch (e) {
        // 用户取消：静默；其它授权错误：提示。
        if (e.code == AuthorizationErrorCode.canceled) return;
        if (mounted) setState(() => _error = 'Apple 登录失败：${e.code.name}');
      } on ApiException catch (e) {
        if (mounted) setState(() => _error = e.message);
      } catch (_) {
        if (mounted) setState(() => _error = 'Apple 登录失败，请稍后重试');
      } finally {
        if (mounted) setState(() => _socialBusy = false);
      }
      return;
    }
    // 非 iOS（Android 等）：维持网页授权流；未配 Service ID 时先走「正在接入」。
    if (kAppleServiceId.isEmpty) {
      _onSocial('Apple');
      return;
    }
    if (_socialBusy) return;
    setState(() {
      _socialBusy = true;
      _error = null;
    });
    try {
      await auth.loginByApple();
      if (!mounted) return;
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 850));
      if (mounted) Navigator.pop(context, true);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED' || e.code == 'CANCELLED') return;
      if (mounted) setState(() => _error = 'Apple 登录失败：${e.code}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Apple 登录失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _socialBusy = false);
    }
  }

  /// LINE 真登录：网页授权拿回我们后端发的 JWT（流程见 Api.loginByLine）。
  /// 还没配 Channel ID（kLineChannelId 为空）时先走「正在接入中」，不报错。
  Future<void> _lineLogin() async {
    if (kLineChannelId.isEmpty) {
      _onSocial('LINE');
      return;
    }
    if (_socialBusy) return;
    setState(() {
      _socialBusy = true;
      _error = null;
    });
    try {
      await auth.loginByLine();
      if (!mounted) return;
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 850));
      if (mounted) Navigator.pop(context, true);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED' || e.code == 'CANCELLED') return;
      if (mounted) setState(() => _error = 'LINE 登录失败：${e.code}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'LINE 登录失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _socialBusy = false);
    }
  }

  /// Facebook 真登录：网页授权拿回我们后端发的 JWT（流程见 Api.loginByFacebook）。
  /// 还没配 App ID（kFacebookAppId 为空）时先走「正在接入中」，不报错。
  Future<void> _facebookLogin() async {
    if (kFacebookAppId.isEmpty) {
      _onSocial('Facebook');
      return;
    }
    if (_socialBusy) return;
    setState(() {
      _socialBusy = true;
      _error = null;
    });
    try {
      await auth.loginByFacebook();
      if (!mounted) return;
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 850));
      if (mounted) Navigator.pop(context, true);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED' || e.code == 'CANCELLED') return;
      if (mounted) setState(() => _error = 'Facebook 登录失败：${e.code}');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Facebook 登录失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _socialBusy = false);
    }
  }

  /// 第三方登录暂未接通：弹一个有品的提示，引导先用邮箱/密码，避免死按钮。
  void _onSocial(String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF15101F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: FF.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: FF.brandGradient,
                boxShadow: [
                  BoxShadow(
                      color: FF.purple.withValues(alpha: 0.45), blurRadius: 24),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text('$name 登录正在接入中',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('马上就好～现在可以先用邮箱验证码或密码登录。',
                textAlign: TextAlign.center,
                style: TextStyle(color: FF.muted, fontSize: 13, height: 1.5)),
            const SizedBox(height: 22),
            GradientButton(
              label: '我知道了',
              height: 50,
              gradient: FF.brandGradient,
              glow: FF.purple,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: FF.muted, fontSize: 13, fontWeight: FontWeight.w700));

  /// 验证码/密码 二选一切换条：滑块跟随选中项，整段平滑过渡。
  Widget _modeToggle() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: FF.line),
      ),
      child: Row(
        children: [
          _modeTab(AppLocalizations.of(context).login_modeOtp, !_passwordMode, () {
            if (_passwordMode) {
              setState(() {
                _passwordMode = false;
                _error = null;
              });
            }
          }),
          _modeTab(AppLocalizations.of(context).login_modePassword, _passwordMode, () {
            if (!_passwordMode) {
              setState(() {
                _passwordMode = true;
                _error = null;
              });
            }
          }),
        ],
      ),
    );
  }

  Widget _modeTab(String t, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active ? FF.brandGradient : null,
            boxShadow: active
                ? [BoxShadow(color: FF.purple.withValues(alpha: 0.4), blurRadius: 14)]
                : null,
          ),
          child: Text(t,
              style: TextStyle(
                  color: active ? Colors.white : FF.dim,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  /// 密码输入框：默认遮挡，右侧眼睛可显隐。
  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FF.line),
      ),
      child: TextField(
        controller: _pwCtrl,
        obscureText: _pwObscure,
        keyboardType: TextInputType.visiblePassword,
        onChanged: (_) => setState(() => _error = null),
        onSubmitted: (_) => _submitting ? null : _login(),
        style: const TextStyle(
            color: FF.text, fontSize: 15, fontWeight: FontWeight.w600),
        cursorColor: FF.hot,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: FF.dim, size: 19),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _pwObscure = !_pwObscure),
            child: Icon(
                _pwObscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: FF.dim,
                size: 19),
          ),
          hintText: AppLocalizations.of(context).login_pwInputHint,
          hintStyle: TextStyle(color: FF.dim.withValues(alpha: 0.8), fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  /// 聚焦邮箱框时弹出的历史邮箱列表：点一下即填，右侧 × 删除该条。
  Widget _emailSuggestionList() {
    final items = _emailSuggestions;
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF15101F).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FF.line),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: FF.line.withValues(alpha: 0.6)),
            InkWell(
              onTap: () => _pickEmail(items[i]),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: FF.dim, size: 17),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(items[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () => _removeEmail(items[i]),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.close_rounded,
                            color: FF.dim, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.06, duration: 220.ms, curve: Curves.easeOut);
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FF.line),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
            color: FF.text, fontSize: 15, fontWeight: FontWeight.w600),
        cursorColor: FF.hot,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: Icon(icon, color: FF.dim, size: 19),
          hintText: hint,
          hintStyle: TextStyle(color: FF.dim.withValues(alpha: 0.8), fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _codeButton() {
    final onCooldown = _countdown > 0;
    final disabled = onCooldown || _sending;
    return GestureDetector(
      onTap: disabled ? null : _sendCode,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: disabled ? Colors.white.withValues(alpha: 0.05) : null,
          gradient: disabled ? null : FF.goldGradient,
          border: Border.all(
              color: disabled ? FF.line : Colors.transparent),
        ),
        child: Text(
          onCooldown
              ? '${_countdown}s'
              : (_sending
                  ? AppLocalizations.of(context).login_sending
                  : AppLocalizations.of(context).login_getCode),
          style: TextStyle(
            color: disabled ? FF.dim : const Color(0xFF1B1404),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _successOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: FF.brandGradient,
                boxShadow: [
                  BoxShadow(color: FF.hot.withValues(alpha: 0.6), blurRadius: 36),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 48),
            )
                .animate()
                .scaleXY(begin: 0.4, duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 18),
            Text(AppLocalizations.of(context).login_success,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900))
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

/// 官方四色 Google「G」——CustomPainter 画环 + 蓝色横杆，非渐变文字近似。
class _GoogleGlyph extends StatelessWidget {
  final double size;
  const _GoogleGlyph({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  static double _rad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = w * 0.27;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, w - stroke, w - stroke);
    final cx = w / 2, cy = w / 2;

    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // 0°=3点钟，顺时针。缺口（嘴）在右上 304°→344°，蓝色横杆从 0° 出。
    p.color = _blue;
    canvas.drawArc(rect, _rad(344), _rad(86), false, p); // 右→右下
    p.color = _green;
    canvas.drawArc(rect, _rad(70), _rad(74), false, p); // 底部
    p.color = _yellow;
    canvas.drawArc(rect, _rad(144), _rad(74), false, p); // 左侧
    p.color = _red;
    canvas.drawArc(rect, _rad(218), _rad(86), false, p); // 顶部

    // 蓝色横杆：中心向右伸到环内壁，高度=描边。
    final bar = Paint()
      ..color = _blue
      ..style = PaintingStyle.fill;
    final barRect = RRect.fromLTRBR(
      cx - stroke * 0.05,
      cy - stroke / 2,
      cx + (w / 2 - stroke / 2),
      cy + stroke / 2,
      Radius.circular(stroke * 0.1),
    );
    canvas.drawRRect(barRect, bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Facebook「f」字标。
class _FacebookGlyph extends StatelessWidget {
  final double size;
  const _FacebookGlyph({this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Text('f',
        style: TextStyle(
            color: Colors.white,
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 1));
  }
}

/// 登录页底部:协议提示 + 「用户协议」「隐私政策」可点链接(苹果 G4/G1.2 要求可访问)。
class _AgreementLinks extends StatelessWidget {
  const _AgreementLinks();

  @override
  Widget build(BuildContext context) {
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final dim = TextStyle(color: FF.dim.withValues(alpha: 0.7), fontSize: 11);
    final link = const TextStyle(
        color: FF.purple, fontSize: 11, fontWeight: FontWeight.w600);
    void open(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(zh ? '登录即表示同意 ' : 'By continuing you agree to our ', style: dim),
        GestureDetector(
            onTap: () => open(const TermsScreen()),
            child: Text(zh ? '用户协议' : 'Terms', style: link)),
        Text(zh ? ' 和 ' : ' & ', style: dim),
        GestureDetector(
            onTap: () => open(const PrivacyScreen()),
            child: Text(zh ? '隐私政策' : 'Privacy Policy', style: link)),
      ],
    );
  }
}

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/push_service.dart';
import 'state/locale_notifier.dart';
import 'theme.dart';
import 'version.dart';
import 'nav.dart';
import 'auth.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 把 simli_client 等 logging 包的日志透到 logcat（release 也打），方便真机排查数字人连接
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    // ignore: avoid_print
    print('[${r.loggerName}] ${r.level.name}: ${r.message}');
  });
  // 恢复登录态（本地读 token，很快；有则后台拉资料）
  await auth.init();
  // 恢复上次选的界面语言
  await localeNotifier.load();
  // 推送服务：初始化 Firebase + 注册 FCM/APNs token（已登录则立即上报后端）
  // 失败不抛——降级到无推送模式仍可用 App
  if (kPushEnabled) {
    // ignore: discarded_futures
    PushService.init();
  }
  // 竖屏短剧 App：全局锁竖屏（横屏会破版，且审核员旋转 iPad 必试）
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  // 全屏 edge-to-edge：视频画到系统状态栏/手势条底下，消除上下黑边
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FalconFlixApp());
}

class FalconFlixApp extends StatelessWidget {
  const FalconFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => MaterialApp(
        title: 'FalconFlix',
        debugShowCheckedModeBanner: false,
        theme: buildFalconTheme(),
        navigatorObservers: [routeObserver],
        // i18n：6 种语言 + 阿拉伯语自动 RTL
        locale: locale,
        supportedLocales: LocaleNotifier.supported,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const SplashScreen(),
        // 全局版本角标——一处覆盖所有页面，右上角，不挡操作。
        // 仅内测包显示；正式包（App Store 审核/上架）必须隐藏，否则像测试版。
        builder: (context, child) {
          if (kReleaseMode) return child!;
          return Stack(
            children: [
              ?child,
              const _GlobalVersionBadge(),
            ],
          );
        },
      ),
    );
  }
}

class _GlobalVersionBadge extends StatelessWidget {
  const _GlobalVersionBadge();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topInset + 6,
      right: 10,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0x4D000000), // 黑 30%，浅色页/视频上都可读
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Text(
            kAppVersion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              height: 1.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

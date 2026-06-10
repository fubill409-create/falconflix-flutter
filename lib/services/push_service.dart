import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../api/api.dart';
import '../auth.dart';
import '../version.dart';

/// 推送服务封装（FCM Android + APNs iOS）。
///
/// 职责：
///  - App 启动时 Firebase.initializeApp()。
///  - 拿 FCM token（Android 直接拿；iOS 是 APNs token，需先获取权限）。
///  - 登录后把 token 上报后端 /notify/registerToken。
///  - 前台收消息时刷新 Api.unreadNotify。
///  - 点击系统通知（应用打开 / 后台 / 杀进程）三态都能解析 data.link 路由。
///
/// 后端 push 服务（PushService.java）已配置 FCM Admin SDK + APNs Pushy，
/// 凭据已就位 (fcm-admin.json / apns-auth-key.p8)。
class PushService {
  static final _log = Logger('push');
  static FirebaseMessaging? _fm;
  static bool _initialized = false;

  /// 最近一次拿到的 token（未上报后端时也保留，登录成功再补传）。
  static String? _pendingToken;

  /// 待处理的 deep link（杀进程被推送唤醒时，main.dart 还没建好 Navigator，
  /// 先把 link 放这里，等 first frame 后 handleInitialMessage 消费）。
  static String? _pendingLink;
  static String? get pendingLink => _pendingLink;
  static void consumePendingLink() => _pendingLink = null;

  /// App 启动调用（main.dart 里在 runApp 之前）。失败不抛，降级到无推送模式。
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _fm = FirebaseMessaging.instance;
      _initialized = true;
      _log.info('Firebase initialized');
    } catch (e, st) {
      _log.warning('Firebase init failed: $e', e, st);
      return;
    }

    // 权限：iOS / Android 13+ 需要弹用户授权
    try {
      final settings = await _fm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _log.info('notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      _log.warning('requestPermission failed: $e');
    }

    // 前台收到 → 后台/前台都展示（Android：channel 已在 PushService.java 配 ff_*）
    try {
      await _fm!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}

    // 监听 token 变化（很少触发，但首次 / Google Play 刷新时会变）
    _fm!.onTokenRefresh.listen((token) {
      _log.info('FCM token refreshed: ${_mask(token)}');
      _pendingToken = token;
      _maybeRegister();
    });

    // 取首次 token（Android 是 FCM token；iOS 需要先有 APNs token 才能拿）
    try {
      final t = await _fm!.getToken();
      if (t != null && t.isNotEmpty) {
        _pendingToken = t;
        _log.info('FCM token: ${_mask(t)}');
      }
    } catch (e) {
      _log.warning('getToken failed: $e');
    }

    // 前台消息：刷新未读数（顶栏红点立刻反应）。
    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      _log.info('foreground msg: ${m.notification?.title} | data=${m.data}');
      Api.refreshUnreadCount(); // 立刻同步红点
    });

    // 后台 → 用户点击通知打开 app（app 还在内存里）
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      _log.info('opened from background: data=${m.data}');
      final link = m.data['link']?.toString();
      if (link != null && link.isNotEmpty) _pendingLink = link;
      Api.refreshUnreadCount();
    });

    // 杀进程 → 用户点通知冷启动
    try {
      final initial = await _fm!.getInitialMessage();
      if (initial != null) {
        final link = initial.data['link']?.toString();
        if (link != null && link.isNotEmpty) _pendingLink = link;
        _log.info('cold start from notif: data=${initial.data}');
      }
    } catch (_) {}

    // 登录态变化时：登录就传 token，登出就注销 token
    auth.addListener(() {
      if (auth.loggedIn) {
        _maybeRegister();
      } else {
        _unregister();
      }
    });

    // 当前已登录就立刻注册一次
    if (auth.loggedIn) _maybeRegister();
  }

  /// 已有 token + 已登录 = 调后端 registerPushToken。
  static Future<void> _maybeRegister() async {
    if (!_initialized) return;
    if (!auth.loggedIn) return;
    final t = _pendingToken;
    if (t == null || t.isEmpty) {
      // 还没拿到 token；token 是异步的，等 onTokenRefresh 触发再来
      return;
    }
    try {
      await Api.registerPushToken(
        platform: Platform.isIOS ? 'ios' : 'android',
        token: t,
        deviceInfo: _deviceInfo(),
        appVersion: kAppVersion,
      );
      _log.info('push token registered to backend: ${_mask(t)}');
    } catch (e) {
      _log.warning('register push token failed: $e');
    }
  }

  /// 登出 → 注销当前 token（让后端立刻停止推这台设备）。
  static Future<void> _unregister() async {
    final t = _pendingToken;
    if (t == null || t.isEmpty) return;
    try {
      await Api.unregisterPushToken(t);
      _log.info('push token unregistered: ${_mask(t)}');
    } catch (_) {
      // 失败不影响登出主流程
    }
  }

  static String _deviceInfo() {
    return Platform.operatingSystem;
  }

  static String _mask(String token) {
    if (token.length < 12) return '***';
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}

/// 给 main.dart 一个便捷开关：true 时启用推送（开发期可关）。
const bool kPushEnabled = !kIsWeb;

/// 处理 deep link：把 PushService.pendingLink 翻译成实际页面跳转。
/// 当前支持的协议（部分占位，按需扩）：
///   /wallet           → 钱包页（充值和会员）
///   /inbox            → 消息收件箱
///   /me/feedback/{id} → 工单详情
///   /short/{id}       → 剧详情
///   /ix/{id}          → 互动剧（暂未接入，先 toast）
class PushLinkHandler {
  /// 在 App 第一帧后调用一次（main.dart 里 onGenerateRoute 或 WidgetsBinding 回调）。
  static void handlePending(BuildContext context) {
    final link = PushService.pendingLink;
    if (link == null || link.isEmpty) return;
    PushService.consumePendingLink();
    // 当前 push link 处理简化为 SnackBar 提示，按需扩到 Navigator routing。
    // 等业务路由表稳定后再串具体页面 push（避免引入循环依赖）。
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text('打开通知链接：$link',
          style: const TextStyle(color: Colors.white)),
    ));
  }
}

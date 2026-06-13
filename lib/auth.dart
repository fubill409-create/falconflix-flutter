import 'package:flutter/foundation.dart';

import 'api/api.dart';
import 'models/level_curve.dart';
import 'models/user_profile.dart';

/// 全局登录态。启动时 init() 从本地恢复 token 并拉资料；
/// me/wallet 等页用 ListenableBuilder 监听它实时刷新。
class AuthState extends ChangeNotifier {
  UserProfile? profile;

  bool get loggedIn => Api.hasToken;

  // —— 面子系统 V 级别（累计「付费」鹰币 = 历史实付美金 × 100，免费票不计）——
  // 全局唯一来源：钱包页 V 级别身份卡、AI 互动功能门槛(privilege)都读它。
  int cumulativePaidCoins = 0;
  int get level => levelForCoins(cumulativePaidCoins);
  DateTime? _lastLevelFetch;

  /// 拉历史充值单求和 → 累计付费鹰币 → 驱动 V 级别。30s 节流（避免频繁 /order/list）。
  /// 充值到账后调用方传 force:true 立即刷新。失败静默（保持旧值）。
  Future<void> refreshLevel({bool force = false}) async {
    if (!Api.hasToken) return;
    if (!force &&
        _lastLevelFetch != null &&
        DateTime.now().difference(_lastLevelFetch!) <
            const Duration(seconds: 30)) {
      return;
    }
    try {
      final records = await Api.rechargeHistory();
      var usd = 0.0;
      for (final r in records) {
        if (r.paid) usd += double.tryParse(r.payPrice.trim()) ?? 0;
      }
      cumulativePaidCoins = (usd * 100).round();
      _lastLevelFetch = DateTime.now();
      notifyListeners();
    } catch (_) {
      // 拉取失败：保持旧 level（保守，不误放行高门槛功能）。
    }
  }

  /// 启动恢复：本地读 token（快），有则后台拉一次资料。
  Future<void> init() async {
    await Api.loadToken();
    if (Api.hasToken) {
      // 不 await，避免后端慢/不可达卡住开机；好了再 notify。
      refresh();
    }
  }

  Future<void> refresh() async {
    if (!Api.hasToken) return;
    try {
      profile = await Api.userInfo();
      notifyListeners();
    } catch (_) {
      // 后端不可达等：保持已登录态（token 在），资料留空，下次再刷。
    }
    refreshLevel(); // 顺带刷 V 级别（30s 节流，便宜；功能门槛 privilege 读它）
  }

  Future<void> loginByEmail(String email, String code) async {
    await Api.loginByEmail(email, code);
    await refresh();
    notifyListeners();
  }

  Future<void> loginByPassword(String email, String password) async {
    await Api.loginByPassword(email, password);
    await refresh();
    notifyListeners();
  }

  Future<void> loginByGoogle(String idToken, {String? email}) async {
    await Api.loginByGoogle(idToken, email: email);
    await refresh();
    notifyListeners();
  }

  Future<void> loginByApple() async {
    await Api.loginByApple();
    await refresh();
    notifyListeners();
  }

  Future<void> loginByAppleNative(String identityToken) async {
    await Api.loginByAppleNative(identityToken);
    await refresh();
    notifyListeners();
  }

  Future<void> loginByLine() async {
    await Api.loginByLine();
    await refresh();
    notifyListeners();
  }

  Future<void> loginByFacebook() async {
    await Api.loginByFacebook();
    await refresh();
    notifyListeners();
  }

  Future<void> logout() async {
    await Api.logout();
    profile = null;
    cumulativePaidCoins = 0;
    _lastLevelFetch = null;
    notifyListeners();
  }
}

final auth = AuthState();

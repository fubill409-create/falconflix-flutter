import 'package:shared_preferences/shared_preferences.dart';

/// 本地用户偏好（自动解锁 / 发票邮箱）——纯本地 shared_preferences，跨会话保留。
///
/// 这两项都是「设备行为偏好」，不需要服务端：
///  - 自动解锁：点已锁剧集时是否直接用鹰币解锁、免每次确认（解锁流程读它）。
///  - 发票邮箱：Stripe Checkout 收据要发到的邮箱（充值时随会话带给 Stripe customer_email）。
class AppSettings {
  static const _kAutoUnlock = 'ff_auto_unlock';
  static const _kInvoiceEmail = 'ff_invoice_email';

  // —— 自动解锁下一集 ——

  /// 是否开启自动解锁（默认关闭：花钱的事默认要确认，开了才静默扣）。
  static Future<bool> autoUnlock() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kAutoUnlock) ?? false;
  }

  static Future<void> setAutoUnlock(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kAutoUnlock, v);
  }

  // —— 发票 / 收据邮箱 ——

  /// 读发票邮箱（未设置则空串，调用方可回退到登录邮箱）。
  static Future<String> invoiceEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kInvoiceEmail) ?? '';
  }

  static Future<void> setInvoiceEmail(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kInvoiceEmail, v.trim());
  }

  /// 简单邮箱格式校验（与登录页一致的宽松规则：a@b.c）。
  static bool isValidEmail(String s) {
    final e = s.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);
  }
}

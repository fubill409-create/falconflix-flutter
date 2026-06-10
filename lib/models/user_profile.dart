/// 映射后端 /users/info 返回的 UsersVO。
/// balance=鹰币余额（App 内消费币）；money=现金余额；vipStatus 0未开通/1生效/2过期。
class UserProfile {
  final int? id;
  final String avatar;
  final String userName;
  final String mobile;
  final String email;
  final String type; // 0 普通 / 1 商家 / 2 代理商
  final double balance; // 鹰币
  final double money; // 余额
  final double withdrawalMoney; // 可提现
  final String inviteCode; // 我的邀请码（后端字段 code）
  final String vipStatus; // 0/1/2
  final String vipValidityTime;

  const UserProfile({
    this.id,
    this.avatar = '',
    this.userName = '',
    this.mobile = '',
    this.email = '',
    this.type = '0',
    this.balance = 0,
    this.money = 0,
    this.withdrawalMoney = 0,
    this.inviteCode = '',
    this.vipStatus = '0',
    this.vipValidityTime = '',
  });

  bool get isVip => vipStatus == '1';

  static final _uuidLike = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  /// 后端给邮箱/游客用户的 userName 是自动生成的 UUID，别原样显示。
  String get displayName {
    if (userName.isNotEmpty && !_uuidLike.hasMatch(userName)) return userName;
    if (mobile.isNotEmpty) return mobile;
    return '鹰眼用户';
  }

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    return UserProfile(
      id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id'] ?? ''}'),
      avatar: '${j['avatar'] ?? ''}',
      userName: '${j['userName'] ?? ''}',
      mobile: '${j['mobile'] ?? ''}',
      email: '${j['email'] ?? ''}',
      type: '${j['type'] ?? '0'}',
      balance: _num(j['balance']),
      money: _num(j['money']),
      withdrawalMoney: _num(j['withdrawalMoney']),
      inviteCode: '${j['code'] ?? ''}',
      vipStatus: '${j['vipStatus'] ?? '0'}',
      vipValidityTime: '${j['vipValidityTime'] ?? ''}',
    );
  }
}

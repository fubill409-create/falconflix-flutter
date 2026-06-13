import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import '../models/ai_character.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import '../models/feed_item.dart';
import '../models/footprint.dart';
import '../models/notify.dart';
import '../models/prefs.dart';
import '../models/purchase.dart';
import '../models/short_drama.dart';
import '../models/episode.dart';
import '../models/user_profile.dart';
import '../models/commerce_cue.dart';
import '../models/recharge.dart';

/// 后端返回 code!=200 时抛出，msg 是后端给的中文提示，可直接展示给用户。
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// FalconFlix 后端接口客户端。
///
/// 连自有华为云后端（公网 HTTPS，反代到 12116 的 Java 服务）。
/// 数据为我们自己的剧集，视频走 falconflix.app/media；不再依赖 USB 隧道。
class Api {
  // 联调时(kUseLocalApi=true)走本机 :4000 新后端；否则走线上公网。
  static const String baseUrl = kUseLocalApi ? kLocalApiBase : 'https://falconflix.app';

  // —— 登录令牌（RuoYi：Authorization: Bearer <token>，shared_preferences 持久化）——
  static const String _tokenKey = 'ff_token';
  static const String _emailHistKey = 'ff_email_history';
  static String? _token;

  static bool get hasToken => _token != null && _token!.isNotEmpty;
  static String? get token => _token; // 数字人公网中继鉴权要带它

  /// 启动时调用：从本地恢复 token（很快，纯本地）。
  static Future<void> loadToken() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString(_tokenKey);
  }

  static Future<void> _saveToken(String? t) async {
    _token = t;
    resetCatalog(); // 换身份了，点赞/收藏状态缓存作废，按新用户重拉。
    final sp = await SharedPreferences.getInstance();
    if (t == null || t.isEmpty) {
      await sp.remove(_tokenKey);
    } else {
      await sp.setString(_tokenKey, t);
    }
  }

  // —— 登录 / 账户 ——

  /// 邮箱验证码（生产真发邮件）。
  static Future<void> sendEmailCode(String email) =>
      _postJson('/login/sendEmailCode', {'email': email});

  /// 邮箱 + 验证码登录，成功则保存 token 并记住该邮箱（下次登录可一键选）。
  static Future<void> loginByEmail(String email, String code) async {
    final body = await _postJson('/login/loginByEmail', {
      'email': email,
      'code': code,
    });
    final token = body['data']?.toString() ?? '';
    if (token.isEmpty) throw ApiException('登录失败：未返回令牌');
    await _saveToken(token);
    await rememberEmail(email);
  }

  /// 邮箱 + 密码登录：新邮箱自动注册并设此密码；老邮箱校验密码。成功保存 token + 记住邮箱。
  static Future<void> loginByPassword(String email, String password) async {
    final body = await _postJson('/login/loginByPassword', {
      'email': email,
      'password': password,
    });
    final token = body['data']?.toString() ?? '';
    if (token.isEmpty) throw ApiException('登录失败：未返回令牌');
    await _saveToken(token);
    await rememberEmail(email);
  }

  /// Google 第三方登录：把原生 SDK 拿到的 idToken 交给后端验真。
  /// 后端 GET /call/login/google?idToken= → 验签 + 验 aud（=后端配置的 client-id）
  /// → 按邮箱登录/自动注册 → 返回我们自己的 JWT（data 字段）。成功保存 token + 记邮箱。
  static Future<void> loginByGoogle(String idToken, {String? email}) async {
    final body = await _getJson(
        '/call/login/google?idToken=${Uri.encodeQueryComponent(idToken)}');
    final token = body['data']?.toString() ?? '';
    if (token.isEmpty) throw ApiException('Google 登录失败：未返回令牌');
    await _saveToken(token);
    if (email != null && email.isNotEmpty) await rememberEmail(email);
  }

  /// Apple 第三方登录（网页授权流，Android/iOS 同走）。
  /// 用 Service ID 拉起 Apple 授权页 → Apple 把 code POST 给后端
  /// /call/login/apple → 后端用 .p8 换 token + 验签 + 发我们 JWT → 302 跳
  /// `falconflix://apple-callback?token=` → flutter_web_auth_2 拦回，取出 token 保存。
  /// 用户取消时 flutter_web_auth_2 抛 PlatformException(code: 'CANCELED')，由调用方静默处理。
  static Future<void> loginByApple() async {
    final state = _randomState();
    final authUrl = Uri.parse('https://appleid.apple.com/auth/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'response_mode': 'form_post',
        'client_id': kAppleServiceId,
        'redirect_uri': kAppleRedirectUri,
        'scope': 'name email',
        'state': state,
      },
    );
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: kAppleCallbackScheme,
    );
    final token = Uri.parse(result).queryParameters['token'] ?? '';
    if (token.isEmpty) throw ApiException('Apple 登录失败：未返回令牌');
    await _saveToken(token);
  }

  /// LINE 第三方登录（网页授权码流）。
  /// 用 Channel ID 拉起 LINE 授权页 → LINE 带 ?code= 回跳后端 /call/login/line
  /// → 后端换 token + 拉 profile + 发我们 JWT → 302 跳
  /// `falconflix://line-callback?token=` → flutter_web_auth_2 拦回取 token。
  static Future<void> loginByLine() async {
    final state = _randomState();
    final authUrl = Uri.parse('https://access.line.me/oauth2/v2.1/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': kLineChannelId,
        'redirect_uri': kLineRedirectUri,
        'state': state,
        'scope': 'openid profile email',
      },
    );
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: kAppleCallbackScheme,
    );
    final token = Uri.parse(result).queryParameters['token'] ?? '';
    if (token.isEmpty) throw ApiException('LINE 登录失败：未返回令牌');
    await _saveToken(token);
  }

  /// Facebook 第三方登录（网页授权码流）。
  /// 用 App ID 拉起 Facebook 授权页 → FB 带 ?code= 回跳后端 /call/login/facebook
  /// → 后端换 token + 拉 profile + 发我们 JWT → 302 跳
  /// `falconflix://fb-callback?token=` → flutter_web_auth_2 拦回取 token。
  static Future<void> loginByFacebook() async {
    final state = _randomState();
    final authUrl = Uri.parse('https://www.facebook.com/v19.0/dialog/oauth').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': kFacebookAppId,
        'redirect_uri': kFacebookRedirectUri,
        'state': state,
        'scope': 'email,public_profile',
      },
    );
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: kAppleCallbackScheme,
    );
    final token = Uri.parse(result).queryParameters['token'] ?? '';
    if (token.isEmpty) throw ApiException('Facebook 登录失败：未返回令牌');
    await _saveToken(token);
  }

  static String _randomState() {
    final r = math.Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// 给已登录用户设置 / 修改登录密码。
  static Future<void> setPassword(String password) =>
      _postJson('/users/setPassword', {'password': password}, auth: true);

  /// 退出登录。
  static Future<void> logout() => _saveToken(null);

  // —— 登录过的邮箱历史（本地，免每次重输）——

  /// 读用过的邮箱（最近用的在前）。
  static Future<List<String>> emailHistory() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_emailHistKey) ?? const [];
  }

  /// 记住一个邮箱：去重后置顶，最多留 6 个。
  static Future<void> rememberEmail(String email) async {
    final e = email.trim();
    if (e.isEmpty) return;
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_emailHistKey) ?? <String>[];
    list.removeWhere((x) => x.toLowerCase() == e.toLowerCase());
    list.insert(0, e);
    if (list.length > 6) list.removeRange(6, list.length);
    await sp.setStringList(_emailHistKey, list);
  }

  /// 从历史里删掉一个邮箱。
  static Future<void> forgetEmail(String email) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_emailHistKey) ?? <String>[];
    list.removeWhere((x) => x.toLowerCase() == email.trim().toLowerCase());
    await sp.setStringList(_emailHistKey, list);
  }

  /// 当前用户资料（鹰币余额 / VIP / 邀请码 等）。
  static Future<UserProfile> userInfo() async {
    final body = await _getJson('/users/info', auth: true);
    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return UserProfile.fromJson(data);
  }

  /// 上传一张图片（头像）到后端对象存储，返回可公开访问的 URL。
  /// 后端 POST /file/upload（multipart 字段名 file）→ 校验为图片 → 传华为云 OBS → R.ok(url)。
  static Future<String> uploadImage(File file) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/file/upload'));
    if (hasToken) req.headers['Authorization'] = 'Bearer $_token';
    // http 不会自动识别 MIME，默认 application/octet-stream，后端只收 image/jpg|jpeg|png。
    // image_picker 对 PNG 源会保留 PNG（imageQuality 只对 JPEG 生效），故按扩展名判 MIME。
    final lower = file.path.toLowerCase();
    final mime = lower.endsWith('.png') ? MediaType('image', 'png') : MediaType('image', 'jpeg');
    req.files
        .add(await http.MultipartFile.fromPath('file', file.path, contentType: mime));
    // 服务端→华为云 OBS 上传偏慢（实测 putObject 可达 40-45s），给足超时避免误判失败。
    final streamed = await req.send().timeout(const Duration(seconds: 90));
    final res = await http.Response.fromStream(streamed);
    final body = _decode(res);
    final url = body['data']?.toString() ?? '';
    if (url.isEmpty) throw ApiException('图片上传失败');
    return url;
  }

  /// 更新当前用户头像（PUT /users/modify，按 SecurityUtils 取本人 id，只更非空字段）。
  static Future<void> updateAvatar(String url) =>
      _putJson('/users/modify', {'avatar': url}, auth: true);

  // —— 鹰币购买（解锁剧集 / 全集）——
  // 后端两步：createOrder 建单拿 payOrderNo → submitOrder 用鹰币结算。
  // ⚠️ 调用前前端必须先确认鹰币足够：后端余额不足时会把内层事务标记回滚，
  //    外层 @Transactional 提交时抛 UnexpectedRollbackException → 返回 500 系统异常，
  //    并不会给出干净的「余额不足」。所以余额门槛由前端把关。

  /// 买单集（type=4，goodsId=剧集id）。成功返回 true。
  static Future<bool> buyEpisode(String episodeId) =>
      _purchase('4', episodeId);

  /// 买全集（type=3，goodsId=短剧id）。成功返回 true。
  static Future<bool> buyDrama(String shortId) => _purchase('3', shortId);

  /// 买多集（type=4 多行，一次下单原子扣总价）。传 N 个不同 episodeId。
  /// 后端 createOrder 收 `List<OrderInfo>` 逐行求和建一单，submitOrder 原子结算——无需后端改动。
  static Future<bool> buyEpisodes(List<String> episodeIds) async {
    final ids = <int>[];
    for (final s in episodeIds) {
      final n = int.tryParse(s);
      if (n != null) ids.add(n);
    }
    if (ids.isEmpty) throw ApiException('商品标识异常');
    final lines = [
      for (final id in ids)
        {'type': '4', 'goodsId': id, 'payType': '1', 'count': 1}
    ];
    final body = await _postBody('/goodsOrder/createOrder', lines, auth: true);
    final payOrderNo = body['data']?.toString() ?? '';
    if (payOrderNo.isEmpty) throw ApiException('创建订单失败');
    return _submitOrder(payOrderNo);
  }

  static Future<bool> _purchase(String type, String goodsId) async {
    final gid = int.tryParse(goodsId);
    if (gid == null) throw ApiException('商品标识异常');
    final payOrderNo = await _createOrder(type, gid);
    return _submitOrder(payOrderNo);
  }

  /// 建订单，返回支付订单号 payOrderNo。
  static Future<String> _createOrder(String type, int goodsId) async {
    final body = await _postBody(
      '/goodsOrder/createOrder',
      [
        {'type': type, 'goodsId': goodsId, 'payType': '1', 'count': 1}
      ],
      auth: true,
    );
    final no = body['data']?.toString() ?? '';
    if (no.isEmpty) throw ApiException('创建订单失败');
    return no;
  }

  /// 用鹰币结算订单。后端 @RequestBody String 用 text/plain 原文传（JSON 引号会被当成
  /// 订单号的一部分 → 「支付订单不存在」）。data.success=true 即扣币成功。
  static Future<bool> _submitOrder(String payOrderNo) async {
    final body = await _postBody('/goodsOrder/submitOrder', payOrderNo,
        auth: true, contentType: 'text/plain');
    final data = body['data'];
    return data is Map && data['success'] == true;
  }

  // —— 充值鹰币（Stripe 国际收款，美金）——
  // 套餐目录与建支付意图都需登录（后端 /recharge 控制器无 @Anonymous）。到账由后端 webhook 异步加币。

  /// 充值套餐目录（GET /recharge/list，需登录）。
  static Future<List<RechargePack>> getRechargePacks() async {
    final body = await _getJson('/recharge/list', auth: true);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RechargePack.fromJson)
        .toList();
  }

  /// 为某套餐创建 Stripe 支付意图，返回 clientSecret + publishableKey 供拉起 PaymentSheet。
  static Future<RechargeIntent> createRechargeIntent(int packId) async {
    final body = await _postJson(
        '/recharge/createPaymentIntent', {'id': packId},
        auth: true);
    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final intent = RechargeIntent.fromJson(data);
    if (intent.clientSecret.isEmpty) throw ApiException('创建支付失败');
    return intent;
  }

  /// 为某套餐创建 Stripe Checkout 托管收银台会话，返回 checkoutUrl 供浏览器打开。
  /// 托管页解决了原生 PaymentSheet 在国产 ROM 上卡号框被安全键盘劫持、国家下拉点不开的问题，
  /// 并能正常渲染支付宝二维码。
  /// [email] 非空时作为发票/收据邮箱透传给后端 → Stripe Checkout customer_email
  /// （收银台会预填该邮箱，付款收据也发到这里）。
  /// [locale] App 当前语言（zh/en/ja/ko/ar/fr），透传给后端 → Stripe `locale` 参数，
  /// 收银台 UI 跟 App 走（之前默认 zh，切英文时托管页仍中文）。
  static Future<CheckoutSession> createCheckoutSession(int packId,
      {String? email, String? locale}) async {
    final reqBody = <String, dynamic>{'id': packId};
    if (email != null && email.trim().isNotEmpty) {
      reqBody['email'] = email.trim();
    }
    if (locale != null && locale.trim().isNotEmpty) {
      reqBody['locale'] = locale.trim();
    }
    final body = await _postJson('/recharge/createCheckoutSession', reqBody,
        auth: true);
    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final session = CheckoutSession.fromJson(data);
    if (session.checkoutUrl.isEmpty) throw ApiException('创建支付失败');
    return session;
  }

  /// iOS 苹果内购票据验证（POST /recharge/apple/verify，需登录）。
  /// 购买成功后把 StoreKit 的 serverVerificationData 交后端向 Apple 验真并记账，
  /// 成功返回本单到账鹰币数（data.coins；data.balance 由 auth.refresh 另行同步）。
  /// 票据无效（422/400）或业务失败由 _decode 抛 ApiException；网络错误抛其它异常，
  /// 调用方据此区分「验证失败」与「暂时性失败」（都不 finish 交易，留待重试）。
  static Future<int> verifyApplePurchase({
    required String productId,
    required String transactionId,
    required String payload,
  }) async {
    final body = await _postJson(
      '/recharge/apple/verify',
      {
        'productId': productId,
        'transactionId': transactionId,
        'payload': payload,
      },
      auth: true,
    );
    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final v = double.tryParse('${data['coins'] ?? ''}');
    return v == null ? 0 : v.round();
  }

  /// 充值记录（GET /order/list?type=1，需登录）。倒序返回本人的充值订单。
  /// 充值订单 type=1；后端按创建时间倒序，含 goodsName/payPrice/status/createTime。
  static Future<List<RechargeRecord>> rechargeHistory() async {
    final body = await _getJson(
        '/order/list?type=1&pageNum=1&pageSize=50',
        auth: true);
    final rows = (body['data']?['rows'] as List?) ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RechargeRecord.fromJson)
        .toList();
  }

  /// 查询订单是否已到账（从浏览器返回后轮询）。status=="3" → paid=true。
  static Future<bool> isOrderPaid(String orderNo) async {
    final body =
        await _getJson('/recharge/orderStatus?orderNo=$orderNo', auth: true);
    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return data['paid'] == true || data['status']?.toString() == '3';
  }

  // —— 点赞 / 收藏（PUT /short/operate）——
  // 后端按「该用户对该剧是否已有记录」做服务端切换(toggle)，并联动 ±1 计数：
  //   operateType: "0"=喜欢  "1"=点赞(thumbsUp)  "2"=收藏  "3"=分享。
  // 需登录（按 SecurityUtils.getUserId 归属）。前端用乐观状态镜像，与服务端同进退。

  /// 切换点赞。
  static Future<void> toggleThumb(String shortId) => _operate(shortId, '1');

  /// 切换收藏。
  static Future<void> toggleCollect(String shortId) => _operate(shortId, '2');

  static Future<void> _operate(String shortId, String type) async {
    final id = int.tryParse(shortId);
    if (id == null) throw ApiException('剧目标识异常');
    await _putJson('/short/operate', {'id': id, 'operateType': type},
        auth: true);
  }

  // —— 首页流预热 ——
  // 开机动画播放的同时就把首页流拉下来缓存，等动画结束进首页时直接拿，
  // 不用再现场转那个黑底「FF」加载圈。
  static Future<List<FeedItem>>? _feedFuture;

  /// splash 启动时调用：后台开始拉首页流（已在拉则忽略）。
  static void warmFeed() => _feedFuture ??= _fetchFeed();

  /// 首页取流：有预热结果直接复用，否则现拉。
  static Future<List<FeedItem>> feed() => _feedFuture ??= _fetchFeed();

  /// 拉取失败、需要重试时丢弃缓存，让下次重新拉。
  static void resetFeed() => _feedFuture = null;

  static Future<List<FeedItem>> _fetchFeed() => kUseLocalTestFeed
      ? getTestFeed()
      : getRecommend(pageNum: 1, pageSize: 10);

  /// 首页推荐视频流
  static Future<List<FeedItem>> getRecommend({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final body = await _getJson(
        '/home/recommend?pageNum=$pageNum&pageSize=$pageSize');
    final rows = (body['data']?['rows'] as List?) ?? const [];
    return rows.whereType<Map<String, dynamic>>().map(FeedItem.fromJson).toList();
  }

  /// 剧场剧目目录
  static Future<List<ShortDrama>> getShortList({
    int pageNum = 1,
    int pageSize = 30,
  }) async {
    final body =
        await _getJson('/short/list?pageNum=$pageNum&pageSize=$pageSize');
    final rows = (body['data']?['rows'] as List?) ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(ShortDrama.fromJson)
        .toList();
  }

  // —— 剧目目录缓存（封面 + 我的点赞/收藏状态）——
  // 一次拉「带 token 的」/short/list，缓存三样按 shortId 索引：
  //   ① 真竖版封面 image（分享海报背景，避免用首页流的品牌占位头像）；
  //   ② isThumbsUp → 我是否已点赞；③ isCollect → 我是否已收藏。
  // 后端只在登录态才回这俩状态（匿名不算）。剧目很少，开销极小。
  static Map<String, String>? _coverMap;
  static Set<String>? _likedIds;
  static Set<String>? _collectedIds;
  static Map<String, ShortDrama>? _dramaById; // 整条剧目，供「我的收藏/点赞」列表用
  static Future<void>? _catalogInflight; // 并发去重：多页同时初始化只拉一次

  /// 拉一次剧目目录并填好缓存（已填则直接返回，进行中则等同一个）。
  static Future<void> _ensureCatalog() {
    if (_coverMap != null) return Future.value();
    final inflight = _catalogInflight;
    if (inflight != null) return inflight;
    final f = _fetchCatalog().whenComplete(() => _catalogInflight = null);
    _catalogInflight = f;
    return f;
  }

  static Future<void> _fetchCatalog() async {
    final cover = <String, String>{};
    final liked = <String>{};
    final coll = <String>{};
    final byId = <String, ShortDrama>{};
    try {
      if (kUseLocalTestFeed) {
        final list = await getTestShortList();
        for (final d in list) {
          if (d.id.isEmpty) continue;
          if (d.image.isNotEmpty) cover[d.id] = d.image;
          byId[d.id] = d;
        }
      } else {
        // 带 token：让后端按当前用户算 isThumbsUp / isCollect。
        final body =
            await _getJson('/short/list?pageNum=1&pageSize=50', auth: true);
        final rows = (body['data']?['rows'] as List?) ?? const [];
        for (final r in rows.whereType<Map<String, dynamic>>()) {
          final id = '${r['id'] ?? ''}';
          if (id.isEmpty || id == '0') continue;
          final img = '${r['image'] ?? ''}';
          if (img.isNotEmpty) cover[id] = img;
          if ('${r['isThumbsUp'] ?? '0'}' == '1') liked.add(id);
          if ('${r['isCollect'] ?? '0'}' == '1') coll.add(id);
          byId[id] = ShortDrama.fromJson(r);
        }
      }
    } catch (_) {
      // 失败也落空缓存，避免每次重拉；登录后 resetCatalog 会让它重来。
    }
    _coverMap = cover;
    _likedIds = liked;
    _collectedIds = coll;
    _dramaById = byId;
  }

  /// 登录/登出后调用：丢弃缓存，下次按新身份重新拉（点赞/收藏状态随人变）。
  static void resetCatalog() {
    _coverMap = null;
    _likedIds = null;
    _collectedIds = null;
    _dramaById = null;
  }

  /// 我收藏的剧目列表（「我的」页 → 我的收藏）。refresh=true 时先丢缓存重拉，
  /// 保证刚收藏/取消的剧立刻反映出来。
  static Future<List<ShortDrama>> collectedDramas({bool refresh = false}) async {
    if (refresh) resetCatalog();
    await _ensureCatalog();
    final ids = _collectedIds ?? const {};
    final map = _dramaById ?? const {};
    return [
      for (final id in ids)
        if (map[id] != null) map[id]!,
    ];
  }

  /// 我点赞的剧目列表（备用，结构同收藏）。
  static Future<List<ShortDrama>> likedDramas({bool refresh = false}) async {
    if (refresh) resetCatalog();
    await _ensureCatalog();
    final ids = _likedIds ?? const {};
    final map = _dramaById ?? const {};
    return [
      for (final id in ids)
        if (map[id] != null) map[id]!,
    ];
  }

  /// 收藏数量（「我的」页 收藏 stat）。
  static Future<int> collectedCount({bool refresh = false}) async {
    final list = await collectedDramas(refresh: refresh);
    return list.length;
  }

  // —— 观看历史（足迹）：/record/footprint，按 updateTime 倒序分页 ——

  /// 拉取观看历史一页。返回 (list, total)：total 用于"已加载 N/M"提示与判断是否还有下一页。
  static Future<({List<Footprint> list, int total})> historyList({
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final body = await _getJson(
        '/record/footprint?pageNum=$pageNum&pageSize=$pageSize',
        auth: true);
    final data = body['data'];
    final rows = (data is Map ? (data['rows'] as List?) : null) ?? const [];
    final total = (data is Map ? (data['total'] as int? ?? 0) : 0);
    return (
      list: rows
          .whereType<Map<String, dynamic>>()
          .map(Footprint.fromJson)
          .toList(),
      total: total,
    );
  }

  /// 删除指定足迹（一条或多条）。后端 DELETE /record/delfoot/{ids}，ids 用逗号分隔。
  static Future<void> historyDelete(List<int> ids) async {
    if (ids.isEmpty) return;
    final csv = ids.join(',');
    await _deleteJson('/record/delfoot/$csv', auth: true);
  }

  /// 清空当前用户全部足迹。后端 DELETE /record/delfoot。
  static Future<void> historyClearAll() async {
    await _deleteJson('/record/delfoot', auth: true);
  }

  // —— 消息通知（站内信 + 推送 token）：/notify/* ——

  /// 全局未读数（任何页面都可以 ValueListenableBuilder 订阅它来画顶栏红点）。
  /// 0 = 没有红点；>0 = 显示数字（>99 显示 99+）。
  static final ValueNotifier<int> unreadNotify = ValueNotifier<int>(0);

  /// 拉取收件箱一页。type=null 时不筛选。
  static Future<({List<NotifyMsg> list, int total})> notifyInbox({
    String? type,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final q = StringBuffer('pageNum=$pageNum&pageSize=$pageSize');
    if (type != null && type.isNotEmpty) {
      q.write('&type=${Uri.encodeQueryComponent(type)}');
    }
    final body = await _getJson('/notify/inbox?$q', auth: true);
    final data = body['data'];
    final rows = (data is Map ? (data['records'] as List?) : null) ??
        (data is Map ? (data['rows'] as List?) : null) ??
        const [];
    final total = (data is Map
            ? (data['total'] is int ? data['total'] as int : 0)
            : 0);
    return (
      list: rows
          .whereType<Map<String, dynamic>>()
          .map(NotifyMsg.fromJson)
          .toList(),
      total: total,
    );
  }

  /// 拉未读条数，并同步全局 unreadNotify。失败时不抛、不改 notifier。
  static Future<int> refreshUnreadCount() async {
    if (!hasToken) {
      unreadNotify.value = 0;
      return 0;
    }
    try {
      final body = await _getJson('/notify/unreadCount', auth: true);
      final data = body['data'];
      final cnt = (data is Map ? (data['count'] as int? ?? 0) : 0);
      unreadNotify.value = cnt;
      return cnt;
    } catch (_) {
      return unreadNotify.value;
    }
  }

  /// 标记单条已读。
  static Future<void> notifyMarkRead(int id) async {
    await _putJson('/notify/read/$id', const {}, auth: true);
    if (unreadNotify.value > 0) {
      unreadNotify.value = unreadNotify.value - 1;
    }
  }

  /// 全部已读。
  static Future<void> notifyMarkAllRead() async {
    await _putJson('/notify/readAll', const {}, auth: true);
    unreadNotify.value = 0;
  }

  /// 注册/刷新 FCM/APNs token。platform = 'android' | 'ios'。
  /// token 是 FCM registration token 或 APNs device token。失败抛 ApiException。
  static Future<void> registerPushToken({
    required String platform,
    required String token,
    String? deviceInfo,
    String? appVersion,
  }) async {
    await _postJson(
      '/notify/registerToken',
      {
        'platform': platform,
        'token': token,
        'deviceInfo': ?deviceInfo,
        'appVersion': ?appVersion,
      },
      auth: true,
    );
  }

  /// 注销 token（登出 / 卸载时调用）。
  static Future<void> unregisterPushToken(String token) async {
    await _deleteJson('/notify/token?token=${Uri.encodeQueryComponent(token)}',
        auth: true);
  }

  // —— 偏好设置：/prefs/notify、/prefs/play ——

  /// 拉通知偏好。无记录时后端按默认值落一条返回。
  static Future<NotifyPrefs> getNotifyPrefs() async {
    final body = await _getJson('/prefs/notify', auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return NotifyPrefs.fromJson(data);
    return const NotifyPrefs();
  }

  /// 更新通知偏好。后端按当前用户 id 强制覆盖（防越权）。
  static Future<NotifyPrefs> updateNotifyPrefs(NotifyPrefs prefs) async {
    final body = await _putJson('/prefs/notify', prefs.toJson(), auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return NotifyPrefs.fromJson(data);
    return prefs;
  }

  /// 拉播放偏好。
  static Future<PlayPrefs> getPlayPrefs() async {
    final body = await _getJson('/prefs/play', auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return PlayPrefs.fromJson(data);
    return const PlayPrefs();
  }

  /// 更新播放偏好。
  static Future<PlayPrefs> updatePlayPrefs(PlayPrefs prefs) async {
    final body = await _putJson('/prefs/play', prefs.toJson(), auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return PlayPrefs.fromJson(data);
    return prefs;
  }

  // —— 账号合规：改密 / 注销账号 / 数据导出 ——

  /// 改密（带旧密校验）。pwOld 可空表示首次设置（用户从未设过密码）。
  static Future<void> changePassword({String? oldPassword, required String newPassword}) async {
    await _postJson(
      '/account/changePassword',
      {
        'oldPassword': ?oldPassword,
        'newPassword': newPassword,
      },
      auth: true,
    );
  }

  /// 申请注销账号（进入 7 天冷静期）。reason 可选；客户端必须传 confirm="DELETE_MY_ACCOUNT"。
  /// 返回 scheduledAt（计划执行时间）。
  static Future<Map<String, dynamic>> requestAccountDeletion({String? reason}) async {
    final body = await _deleteWithBody(
      '/account/delete',
      {'confirm': 'DELETE_MY_ACCOUNT', 'reason': ?reason},
      auth: true,
    );
    return body['data'] is Map ? Map<String, dynamic>.from(body['data']) : {};
  }

  /// 撤销注销申请（冷静期内任何时刻可调）。
  static Future<void> cancelAccountDeletion() async {
    await _postJson('/account/delete/cancel', const {}, auth: true);
  }

  /// 查询注销申请状态。返回 null 表示无 pending。
  static Future<Map<String, dynamic>?> deletionStatus() async {
    final body = await _getJson('/account/delete/status', auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  /// 申请下载我的数据（GDPR/CCPA）。后端异步生成 zip。
  static Future<Map<String, dynamic>> requestDataExport() async {
    final body = await _postJson('/account/exportData', const {}, auth: true);
    return body['data'] is Map ? Map<String, dynamic>.from(body['data']) : {};
  }

  /// 数据导出最新状态（含下载链接）。
  static Future<Map<String, dynamic>?> dataExportStatus() async {
    final body = await _getJson('/account/exportStatus', auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  // —— 帮助中心 FAQ：/help/faq/list / /help/faq/{id} ——

  /// FAQ 列表，按 category 和 lang 投影。游客可看（@Anonymous），不需登录。
  static Future<List<Map<String, dynamic>>> helpFaqList({
    String? category,
    String lang = 'zh',
  }) async {
    final q = StringBuffer('lang=${Uri.encodeQueryComponent(lang)}');
    if (category != null && category.isNotEmpty) {
      q.write('&category=${Uri.encodeQueryComponent(category)}');
    }
    final body = await _getJson('/help/faq/list?$q');
    final raw = body['data'];
    final rows = raw is List ? raw : const [];
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  /// FAQ 详情。
  static Future<Map<String, dynamic>?> helpFaqDetail(int id,
      {String lang = 'zh'}) async {
    final body = await _getJson(
        '/help/faq/$id?lang=${Uri.encodeQueryComponent(lang)}');
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  // —— 反馈 / 工单：/feedback/* ——

  /// 提交反馈。type: bug | suggestion | complaint | recharge_issue | other。
  static Future<Map<String, dynamic>> feedbackSubmit({
    required String type,
    required String content,
    List<String>? screenshots,
    String? appVersion,
    String? deviceInfo,
    String? contact,
  }) async {
    final body = await _postJson(
      '/feedback/submit',
      {
        'type': type,
        'content': content,
        if (screenshots != null && screenshots.isNotEmpty)
          'screenshots': screenshots,
        'appVersion': ?appVersion,
        'deviceInfo': ?deviceInfo,
        'contact': ?contact,
      },
      auth: true,
    );
    return body['data'] is Map ? Map<String, dynamic>.from(body['data']) : {};
  }

  /// 我的工单分页列表。返回 (list, total)。
  static Future<({List<Map<String, dynamic>> list, int total})>
      feedbackMyList({int pageNum = 1, int pageSize = 20}) async {
    final body = await _getJson(
        '/feedback/myList?pageNum=$pageNum&pageSize=$pageSize',
        auth: true);
    final data = body['data'];
    final rows = (data is Map ? (data['records'] as List?) : null) ??
        (data is Map ? (data['rows'] as List?) : null) ??
        const [];
    final total = (data is Map
            ? (data['total'] is int ? data['total'] as int : 0)
            : 0);
    return (
      list: rows.whereType<Map<String, dynamic>>().toList(),
      total: total,
    );
  }

  /// 工单对话详情。返回 {feedback, replies}。
  static Future<Map<String, dynamic>?> feedbackThread(int id) async {
    final body = await _getJson('/feedback/thread/$id', auth: true);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  /// 用户回复自己的工单。
  static Future<Map<String, dynamic>> feedbackReply(int id, String content) async {
    final body = await _postJson('/feedback/reply/$id', {'content': content},
        auth: true);
    return body['data'] is Map ? Map<String, dynamic>.from(body['data']) : {};
  }

  // —— 我的订单（已购整剧 / 已购单集）：/record/purchases ——

  /// 拉取已购订单。isShort=true 拉整剧，false 拉单集。
  /// 后端目前返回 R.ok(List<...>)（非分页）；前端一次拉全部 + 列表内做搜索。
  static Future<List<Purchase>> ordersList({
    required bool isShort,
    String? name,
  }) async {
    final q = StringBuffer('isShort=$isShort');
    if (name != null && name.isNotEmpty) {
      q.write('&name=${Uri.encodeQueryComponent(name)}');
    }
    final body = await _getJson('/record/purchases?$q', auth: true);
    final raw = body['data'];
    final rows = raw is List ? raw : const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Purchase.fromJson)
        .toList();
  }

  /// 分享海报背景用的剧目真封面。
  static Future<String?> dramaCover(String? shortId) async {
    if (shortId == null || shortId.isEmpty || shortId == '0') return null;
    await _ensureCatalog();
    final c = _coverMap?[shortId];
    return (c != null && c.isNotEmpty) ? c : null;
  }

  /// 我是否已点赞该剧（首页/详情心形按钮初始态，避免永远从灰开始）。
  static Future<bool> dramaLiked(String? shortId) async {
    if (shortId == null || shortId.isEmpty || shortId == '0') return false;
    await _ensureCatalog();
    return _likedIds?.contains(shortId) ?? false;
  }

  /// 我是否已收藏该剧。
  static Future<bool> dramaCollected(String? shortId) async {
    if (shortId == null || shortId.isEmpty || shortId == '0') return false;
    await _ensureCatalog();
    return _collectedIds?.contains(shortId) ?? false;
  }

  /// 切换成功后同步本地缓存，确保滑走再滑回/重进详情时状态正确。
  static void noteLiked(String shortId, bool liked) {
    if (_likedIds == null) return;
    if (liked) {
      _likedIds!.add(shortId);
    } else {
      _likedIds!.remove(shortId);
    }
  }

  static void noteCollected(String shortId, bool collected) {
    if (_collectedIds == null) return;
    if (collected) {
      _collectedIds!.add(shortId);
    } else {
      _collectedIds!.remove(shortId);
    }
  }

  /// 测试期：从本地 test-media 服务读取你自己的视频清单（feed.json）
  static Future<List<FeedItem>> getTestFeed() async {
    final res = await http
        .get(Uri.parse('$kTestMediaBase/feed.json'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final list = json.decode(utf8.decode(res.bodyBytes)) as List;
    return list.whereType<Map<String, dynamic>>().map((e) {
      return FeedItem(
        shortId: '',
        shortName: '${e['title'] ?? ''}',
        episodeName: '',
        introduce: '',
        videoUrl: '${e['videoUrl'] ?? ''}',
        poster: '${e['poster'] ?? ''}',
        likeCount: 0,
        collectCount: 0,
        thumbsUpCount: 0,
        price: 0,
      );
    }).toList();
  }

  /// 测试期：把本地视频清单(feed.json)当成剧场目录——海报=截帧，名字=视频名。
  /// id 留空，详情页因此走兜底「播放本剧」入口，直接播这条本地视频，不会死页。
  static Future<List<ShortDrama>> getTestShortList() async {
    final res = await http
        .get(Uri.parse('$kTestMediaBase/feed.json'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final list = json.decode(utf8.decode(res.bodyBytes)) as List;
    final maps = list.whereType<Map<String, dynamic>>().toList();
    return [
      for (var i = 0; i < maps.length; i++)
        ShortDrama(
          id: '',
          name: '${maps[i]['title'] ?? ''}',
          image: '${maps[i]['poster'] ?? ''}',
          introduce: '本地片源 · ${maps[i]['title'] ?? ''}',
          categoryName: '',
          labels: const [],
          // 伪热度：稳定、有高低差，纯展示用
          playCount: 9200 - i * 540 + (('${maps[i]['title']}'.length * 173) % 700),
          likeCount: 0,
          price: 0,
          videoUrl: '${maps[i]['videoUrl'] ?? ''}',
        ),
    ];
  }

  /// 剧目详情的真实剧集列表（GET /short/info/{id} 的 data.episodeVOS）。
  /// 带 token：已登录则后端按本人已购算 isBuy（买过的付费集=已解锁）；未登录则匿名按免费判断。
  static Future<List<Episode>> getEpisodes(String shortId) async {
    final body = await _getJson('/short/info/$shortId', auth: true);
    final eps = (body['data']?['episodeVOS'] as List?) ?? const [];
    return eps
        .whereType<Map<String, dynamic>>()
        .map(Episode.fromJson)
        .toList();
  }

  // —— 带货商品时间轴（Ghost Rail）——
  // GET /commerce/timeline?episodeId= —— 公开。返回该集按秒出现的商品 cue 数组，
  // 字段对齐 CommerceCue.fromJson。接不通/无数据时由调用方退回本地 mock，绝不崩。
  static Future<List<CommerceCue>> fetchCommerceTimeline(String episodeId) async {
    final id = int.tryParse(episodeId);
    if (id == null || id <= 0) return const [];
    final body = await _getJson('/commerce/timeline?episodeId=$id');
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CommerceCue.fromJson)
        .toList();
  }

  // —— AI 互动 · 角色星球清单 ——
  // 拉总控台发布的静态 manifest.json，合并到包内 kCharacters（文案/介绍视频/热度以服务端为准，
  // 立绘/光环/应援榜 mock 仍用包内）。拉取失败回退到包内 kCharacters，永不空屏。
  // 缓存一次：同一进程内重进「AI 互动」直接复用，不反复打网。
  static Future<List<AiCharacter>>? _charsFuture;

  /// 取角色清单：有缓存直接复用，否则现拉。
  static Future<List<AiCharacter>> aiCharacters() =>
      _charsFuture ??= _fetchAiCharacters();

  /// 丢弃缓存（如需强制刷新）。
  static void resetAiCharacters() => _charsFuture = null;

  static Future<List<AiCharacter>> _fetchAiCharacters() async {
    try {
      final res = await http
          .get(Uri.parse(kAiManifestUrl))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return kCharacters;
      final map = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final list = (map['characters'] as List?) ?? const [];
      final merged = mergeCharacterManifest(list);
      return merged.isEmpty ? kCharacters : merged;
    } catch (_) {
      return kCharacters; // 离线/超时/解析失败：全量回退包内角色
    }
  }

  static Map<String, String> _headers({bool auth = false, bool jsonBody = false}) {
    return {
      if (jsonBody) 'Content-Type': 'application/json',
      if (auth && hasToken) 'Authorization': 'Bearer $_token',
    };
  }

  /// 校验 {code,msg,data}：HTTP 非 200 或 业务 code 非 200 都抛 ApiException(msg)。
  static Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> map;
    try {
      map = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('HTTP ${res.statusCode}');
    }
    final code = map['code'];
    if (res.statusCode != 200 || (code is int && code != 200)) {
      throw ApiException(map['msg']?.toString() ?? 'HTTP ${res.statusCode}');
    }
    return map;
  }

  static Future<Map<String, dynamic>> _getJson(String path,
      {bool auth = false}) async {
    final res = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> _postJson(
      String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final res = await http
        .post(Uri.parse('$baseUrl$path'),
            headers: _headers(auth: auth, jsonBody: true),
            body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> _putJson(
      String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final res = await http
        .put(Uri.parse('$baseUrl$path'),
            headers: _headers(auth: auth, jsonBody: true),
            body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> _deleteJson(String path,
      {bool auth = false}) async {
    final res = await http
        .delete(Uri.parse('$baseUrl$path'), headers: _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> _deleteWithBody(
      String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final res = await http
        .delete(Uri.parse('$baseUrl$path'),
            headers: _headers(auth: auth, jsonBody: true),
            body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  // ═══════════ UGC 合规:举报 / 拉黑(苹果 G1.2)═══════════
  // 走 content-ingest 的 /ingest/app/*（App 用户 token 验真）。

  /// 举报 UGC 内容。contentType: post/comment/chat/profile/avatar/drama。
  static Future<void> reportContent({
    required String contentType,
    String? contentId,
    String? targetUserId,
    required String reasonCode,
    String? detail,
  }) =>
      _postJson('/ingest/app/report', {
        'contentType': contentType,
        if (contentId != null) 'contentId': contentId,
        if (targetUserId != null) 'targetUserId': targetUserId,
        'reasonCode': reasonCode,
        if (detail != null && detail.isNotEmpty) 'detail': detail,
      }, auth: true);

  /// 拉黑一个用户（其内容即时从 feed 隐藏）。
  static Future<void> blockUser(String targetUserId) =>
      _postJson('/ingest/app/block', {'targetUserId': targetUserId}, auth: true);

  /// 取消拉黑。
  static Future<void> unblockUser(String targetUserId) =>
      _postJson('/ingest/app/unblock', {'targetUserId': targetUserId}, auth: true);

  /// 我拉黑的用户 id 列表（社区/聊天据此过滤）。
  static Future<Set<String>> myBlockedIds() async {
    final body = await _getJson('/ingest/app/blocks', auth: true);
    final data = body['data'];
    if (data is List) return data.map((e) => e.toString()).toSet();
    return <String>{};
  }

  /// 通用 POST：body 为 Map/List 时按 JSON 编码；contentType=text/plain 时按原文发。
  static Future<Map<String, dynamic>> _postBody(String path, Object body,
      {bool auth = false, String contentType = 'application/json'}) async {
    final isJson = contentType.startsWith('application/json');
    final res = await http
        .post(Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': contentType,
              if (auth && hasToken) 'Authorization': 'Bearer $_token',
            },
            body: isJson ? json.encode(body) : body.toString())
        .timeout(const Duration(seconds: 20));
    return _decode(res);
  }
}

/// 测试期配置。
/// kUseLocalTestFeed=true 时，首页流播放本地 test-media 里你自己的视频
/// （经 adb reverse tcp:8099 的本地服务），而不是后端那套测试短剧。
/// 正式联调后改回 false 即走后端 /home/recommend。
const bool kUseLocalTestFeed = false;
const String kTestMediaBase = 'http://127.0.0.1:8099';

/// 联调开关：true 时所有 API 走本机 NestJS 新后端（需 adb reverse tcp:4000 tcp:4000）。
/// 视频/海报仍走公网 falconflix.app/media，不受影响。
/// ⚠️ 上线/发包前务必改回 false，恢复线上 https://falconflix.app。
const bool kUseLocalApi = false;
const String kLocalApiBase = 'http://127.0.0.1:4000';

/// 「AI 互动 · 角色星球」服务端清单（静态文件，总控台一键发布生成）。
/// 角色文案 / 自我介绍视频 / 投票热度由这份清单驱动，App 不再把内容写死在包里；
/// 拉取失败时回退到包内 kCharacters 兜底，永不空屏。
/// 它常驻公网 media（nginx 直发），与后端切换无关，故写死生产地址。
const String kAiManifestUrl =
    'https://falconflix.app/media/ai-characters/manifest.json';

/// 数字人通话中继 = 公网部署在华为云、nginx 反代 `/dh/` 到本机 5050（与 Java 后端同机）。
/// · GET  $kDigitalHumanRelayBase/api/vendor/simli/native?characterId=  → {apiKey, faceId}
/// · WS   wss://falconflix.app/dh/ws/native?characterId=&token=  → OpenAI Realtime 中继
/// 公网中继挂 FalconFlix 登录鉴权（FF_AUTH_REQUIRED=1），调用要带登录 token，挡匿名盗刷。
const String kDigitalHumanRelayBase = 'https://falconflix.app/dh';

/// 把 http(s):// 的中继地址转成 ws(s):// 的 /ws/native 通话地址。
/// [token] = FalconFlix 登录令牌，公网中继靠它鉴权（query ?token=）。
String digitalHumanWsUrl(String characterId, {String? token}) {
  final ws = kDigitalHumanRelayBase.replaceFirst('http', 'ws');
  final t = (token != null && token.isNotEmpty)
      ? '&token=${Uri.encodeComponent(token)}'
      : '';
  return '$ws/ws/native?characterId=${Uri.encodeComponent(characterId)}$t';
}

/// 数字人「定制脸」就绪名单——只有列在这里的角色，才有咱们自己做的 Simli 定制脸，
/// 才会在聊天页露出「视频通话」入口。没脸的角色绝不假装有数字人（顶多文字聊），
/// 免得用户呼出来对面是个 Simli 预设的陌生脸。
/// ⚠️ 必须与 digital-human-lab/character-faces.json 里 faceId 非空的键保持一致。
/// Simli 套餐限制建脸槽位：Hobby 1 槽 / Pro 5 槽 / Scale 30 槽——升级套餐 + 做完新脸后，
/// 这里加一行、json 填上 faceId 即可（App 端要重新 build 才生效）。
const Set<String> kDigitalHumanFaceReady = {
  'lingwei', // Vivienne 御姐·大女主 = 定制脸「体面的孔雀」faceId 26b3ce1f-…891b5
};

/// 该角色是否有咱们自己的数字人定制脸（决定聊天页是否显示「视频通话」入口）。
bool digitalHumanFaceReady(String characterId) =>
    kDigitalHumanFaceReady.contains(characterId);

/// Google 登录用的 Web 端 OAuth client ID（serverClientId）。
/// 必须是 Google Cloud 项目里「Web application」类型那条凭证，且与后端
/// application.yml 的 google.client-id 完全一致——这样拿到的 idToken 的 aud
/// 才能被后端 /call/login/google 验过。Android 端登录还要在同一项目里加一条
/// 「Android」类型凭证（包名 app.falconflix + 本机 SHA-1）。
/// 留空时登录页 Google 按钮先走「正在接入中」提示，不会报错。
const String kGoogleServerClientId =
    '28614000445-o39cpp9j97nkc15hu9mmufe6rho7hcn5.apps.googleusercontent.com';

/// Apple 登录（网页授权流，Android 也走这套）。
/// kAppleServiceId = Apple Developer 里建的 Services ID（= 后端 apple.auth.client-id），
/// 它在 Apple 后台登记的 Return URL 必须等于 kAppleRedirectUri。
/// 流程：App 用此 client_id 打开 Apple 授权 → Apple 把 code POST 到 kAppleRedirectUri
/// （我们后端 /call/login/apple）→ 后端换 token+验签+发我们 JWT → 302 跳
/// kAppleCallbackScheme://apple-callback?token= → App 用 flutter_web_auth_2 拦回拿 token。
/// 留空时登录页 Apple 按钮先走「正在接入中」提示，不会报错。
const String kAppleServiceId = 'site.gleg.eagle-eyes';
const String kAppleRedirectUri = 'https://api.flcflix.com/call/login/apple';
const String kAppleCallbackScheme = 'falconflix';

/// LINE 登录（网页授权码流，同 Apple 一套 flutter_web_auth_2 拦回）。
/// kLineChannelId = LINE Developers 里建的 LINE Login channel 的 Channel ID，
/// 它在 LINE 后台登记的 Callback URL 必须等于 kLineRedirectUri。
/// 流程：App 打开 access.line.me 授权页 → LINE 带 ?code= 回跳 kLineRedirectUri
/// （后端 /call/login/line）→ 后端换 token+拉 profile+发我们 JWT → 302 跳
/// `falconflix://line-callback?token=` → flutter_web_auth_2 拦回拿 token。
/// 留空时登录页 LINE 按钮先走「正在接入中」提示，不会报错。
const String kLineChannelId = '2010251203';
const String kLineRedirectUri = 'https://api.flcflix.com/call/login/line';

/// Facebook 登录（网页授权码流，同上）。
/// kFacebookAppId = Meta for Developers 里建的 App 的 App ID，
/// 它在 Meta 后台「Valid OAuth Redirect URIs」必须含 kFacebookRedirectUri。
/// 流程：App 打开 facebook.com 授权页 → FB 带 ?code= 回跳 kFacebookRedirectUri
/// （后端 /call/login/facebook）→ 后端换 token+拉 profile+发我们 JWT → 302 跳
/// `falconflix://fb-callback?token=` → flutter_web_auth_2 拦回拿 token。
/// 留空时登录页 Facebook 按钮先走「正在接入中」提示，不会报错。
const String kFacebookAppId = '';
const String kFacebookRedirectUri = 'https://api.flcflix.com/call/login/facebook';

/// 视频两侧裁切比例（每边裁掉这么多）。
/// 9:16 视频铺到比 9:16 更长的手机屏（如 720×1604≈9:20）上时，满屏 cover 会把两侧各裁约 10%。
/// 老板定的：各裁 9%（裁得比 cover 少一点，画面两侧多露一点），底部留一条窄暗边。
/// 想再多/再少裁，只改这一个值即可（0.09=9%/边）。
const double kVideoSideCrop = 0.09;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import 'level_curve.dart';

/// AI 互动「角色星球」框架数据（v0 = 本地 mock，不接后端/不接 LLM/不计费）。
/// 真实数字人/投票/能量计费在后续版本接入；这里只为把框架跑通。

// ───────────────────────── 级别 V1–V99 + 段位 ─────────────────────────
/// 面子系统：人人注册默认 V1，按累计充值升到 V99。V50≈$10k=100 万鹰币=巨鳄。
/// 段位：平民/入门/进阶/大佬/巨鳄/封神/传奇。`nameKey` 是内部 id (i18n)；
/// 显示名经 `tierName(tier, l)` 翻译；颜色随段位升。
class LevelTier {
  final String nameKey; // 'commoner' | 'rookie' | 'advanced' | 'lord' | 'tycoon' | 'deity' | 'legend'
  final Color color;
  final Gradient gradient;
  const LevelTier(this.nameKey, this.color, this.gradient);

  /// 兼容旧调用：未取得 context 时返回 i18n key。**显示用 tierName() 才对**。
  String get name => nameKey;
}

/// 段位本地化显示名。把 LevelTier 转成 6 语之一。
String tierName(LevelTier t, AppLocalizations l) {
  switch (t.nameKey) {
    case 'legend':
      return l.tier_legend;
    case 'deity':
      return l.tier_deity;
    case 'tycoon':
      return l.tier_tycoon;
    case 'lord':
      return l.tier_lord;
    case 'advanced':
      return l.tier_advanced;
    case 'rookie':
      return l.tier_rookie;
    default:
      return l.tier_commoner;
  }
}

LevelTier levelTier(int v) {
  if (v >= 90) {
    return const LevelTier('legend', FF.brightGold, FF.goldGradient);
  } else if (v >= 70) {
    return const LevelTier('deity', FF.gold,
        LinearGradient(colors: [FF.gold, FF.brightGold]));
  } else if (v >= 50) {
    return const LevelTier('tycoon', FF.purple,
        LinearGradient(colors: [FF.purple, FF.hot]));
  } else if (v >= 40) {
    return const LevelTier('lord', FF.hot,
        LinearGradient(colors: [FF.hot, FF.orange]));
  } else if (v >= 25) {
    return const LevelTier('advanced', FF.teal,
        LinearGradient(colors: [FF.teal, FF.blue]));
  } else if (v >= 10) {
    return const LevelTier('rookie', FF.blue,
        LinearGradient(colors: [FF.blue, FF.teal]));
  }
  return LevelTier('commoner', FF.dim,
      LinearGradient(colors: [FF.dim, FF.weak]));
}

// ───────────────────────── 应援榜支持者 ─────────────────────────
/// 实名应援榜一条：昵称（虚名，不涉隐私）+ 累计投入鹰币。
/// 级别由累计鹰币按统一 [levelForCoins] 曲线派生，全 App 一致、不再手写易漂移。
class Supporter {
  final String name;
  final int coins;
  const Supporter(this.name, this.coins);

  int get level => levelForCoins(coins);
}

/// 鹰币紧凑显示：>=1M → "1.2M"；>=1K → "5.8K"；其它原样。
/// 国际化考虑：K/M 是 ASCII，跨语言通用；放弃中文「万」单位避免在英文/日韩/法/阿语下违和。
String fmtCoins(int n) {
  if (n >= 1000000) {
    final m = n / 1000000;
    return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}M';
  }
  if (n >= 1000) {
    final k = n / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}K';
  }
  return '$n';
}

// ───────────────────────── 深入沟通的时刻（解锁） ─────────────────────────
/// 角色专属剧情片段，鹰币解锁。v0 = mock，点击只走占位交互，不真扣费。
class Moment {
  final String title;
  final String hint;
  final int coins;
  const Moment(this.title, this.hint, this.coins);
}

// ───────────────────────── 数字人角色 ─────────────────────────
class AiCharacter {
  final String id;
  final String name; // 英文艺名（国际化，UI 显示用）
  final String role; // 一句人设标签，如「Boss lady · Female lead」
  final String persona; // 人物小传一句话
  final String personality; // 完整性格 + 说话风格（中文，给 Phase2 LLM system prompt 打底）
  final bool female;
  final List<Color> aura; // 头像光晕渐变（占位立绘 / 真立绘外圈光环都用它）
  final String emoji; // 占位头像字符（真立绘到位前用英文首字母）
  final String? avatarHead; // 大头像（落地页星Bouncy用，脸占满）；null = 回退 emoji
  final String? introVideoUrl; // 15s 自我介绍视频（公网 CDN）；详情画廊首页自动播放，null = 只看照片
  final List<String> gallery; // 详情页可滑全身画廊（招牌/性感/泳装多套），空 = 回退光环脸
  final String greeting; // 点名问候 / 悬停说的台词
  final List<String> lines; // 备用台词（轮播）
  final double voteProgress; // 0..1 应援热度进度（mock）
  final List<Supporter> board; // 实名应援榜（mock，降序）
  final List<String> clips; // TA 的视频片段（mock 标题）
  final List<String> credits; // 参演的剧（mock，可点欣赏）
  final List<Moment> moments; // 深入沟通的时刻（鹰币解锁，mock）

  const AiCharacter({
    required this.id,
    required this.name,
    required this.role,
    required this.persona,
    required this.personality,
    required this.female,
    required this.aura,
    required this.emoji,
    this.avatarHead,
    this.introVideoUrl,
    this.gallery = const [],
    required this.greeting,
    required this.lines,
    required this.voteProgress,
    required this.board,
    required this.clips,
    required this.credits,
    required this.moments,
  });

  /// 该角色累计应援鹰币（mock = 榜单之和），用于二级页展示总热度。
  int get totalCoins => board.fold(0, (s, e) => s + e.coins);
}

const kCharacters = <AiCharacter>[
  AiCharacter(
    id: 'lingwei',
    name: 'Vivienne',
    role: 'Boss lady · Female lead',
    persona: 'A sharp, decisive corporate CEO — with a tenderness that softens only for you.',
    personality:
        'On the surface she is commanding, blunt, and in control — the queen everyone in business fears; in private she is intensely attentive, fiercely protective, and holds nothing back for the one she has chosen.'
        'Speaking style: low, certain, occasionally commanding, but she suddenly turns soft for you, making your heart race through the contrast. Lots of self-assured lines, few filler words.',
    female: true,
    aura: [FF.hot, FF.purple],
    emoji: 'V',
    avatarHead: 'assets/characters/lingwei_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/lingwei-1780386808179.mp4',
    gallery: [
      'assets/characters/lingwei_g1.png',
      'assets/characters/lingwei_g2.png',
      'assets/characters/lingwei_g3.png',
    ],
    greeting: 'You are here? I have waited a long time — this time, you fight this battle by my side.',
    lines: ['Don’t be afraid — I am out front.', 'Just keep moving forward; I have got your back.'],
    voteProgress: 0.82,
    board: [
      Supporter('Desert Eagle', 8_800_000),
      Supporter('Old Fu', 1_950_000),
      Supporter('Mr. K', 320_000),
      Supporter('Night Voyager', 96_000),
      Supporter('Anonymous Falcon', 8_400),
    ],
    clips: ['First spark in the boardroom · 28s', 'A rainy night, she holds the umbrella for you · 41s', 'The moment she drops the queen’s mask · 33s'],
    credits: ['"The CEO’s Secret Lover" — lead', '"Robot Girlfriend" — guest'],
    moments: [
      Moment('Vivienne · The moment she softens only for you', 'The first time her eyes welled up in front of you', 1999),
      Moment('Vivienne · The late-night call that crossed the line', 'At 3 a.m., she says she misses you a little', 3999),
    ],
  ),
  AiCharacter(
    id: 'xiaoyou',
    name: 'Mia',
    role: 'Girl next door · Healing type',
    persona: 'The girl always waiting downstairs for you to come home — one "you worked hard today" melts the whole day away.',
    personality:
        'Gentle, considerate, and deeply empathetic — the kind who quietly remembers all your likes; never pushy, yet impossible to leave.'
        'Speaking style: soft and sweet, caring, lots of "~" and warm, cooing words (okay?, there there, take your time), always tending to your feelings first.',
    female: true,
    aura: [FF.orange, FF.gold],
    emoji: 'M',
    avatarHead: 'assets/characters/xiaoyou_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/xiaoyou-1780387122045.mp4',
    gallery: [
      'assets/characters/xiaoyou_g1.png',
      'assets/characters/xiaoyou_g2.png',
      'assets/characters/xiaoyou_g3.png',
    ],
    greeting: 'You are back! You worked hard today too — come sit and rest a little, okay~',
    lines: ['I left the light on for you.', 'No matter how late, I will be here.'],
    voteProgress: 0.54,
    board: [
      Supporter('Warm Light', 560_000),
      Supporter('November', 78_000),
      Supporter('Little Shin', 21_000),
      Supporter('Passerby A', 1_200),
    ],
    clips: ['The evening she waits downstairs for you · 22s', 'The light she left on for you · 18s', 'An afternoon of begging for milk tea · 27s'],
    credits: ['"My Healing Girlfriend" — lead', '"Middle East Food God" — friendly cameo'],
    moments: [
      Moment('Mia · The rainy day you first held hands', 'She quietly slips her hand into your palm', 1599),
      Moment('Mia · She promises to stay by your side forever', 'Whispers in the night', 2999),
    ],
  ),
  AiCharacter(
    id: 'linxia',
    name: 'Riley',
    role: 'Sporty · Energetic girl',
    persona: 'Fast as the wind on the court, with a smile brighter than summer.',
    personality:
        'Sunny, straightforward, competitive and loyal — wears her feelings on her face, loves and hates plainly; naturally infectious, she can yank you right out of a slump.'
        'Speaking style: high-energy, hearty, loves exclamation points and a challenging tone (bring it on, let’s go, loser buys), rarely beats around the bush.',
    female: true,
    aura: [FF.teal, FF.lime],
    emoji: 'R',
    avatarHead: 'assets/characters/linxia_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/linxia-1780390906894.mp4',
    gallery: [
      'assets/characters/linxia_g1.png',
      'assets/characters/linxia_g2.png',
      'assets/characters/linxia_g3.png',
    ],
    greeting: 'Hey! Perfect timing — run a couple laps with me? Loser buys the milk tea!',
    lines: ['No slacking — come on, push!', 'See? Winning feels amazing, right?'],
    voteProgress: 0.33,
    board: [
      Supporter('Windchaser', 240_000),
      Supporter('Jay', 33_000),
      Supporter('Wallflower', 3_600),
    ],
    clips: ['Her, fast as the wind on the court · 25s', 'That hug after the win · 19s', 'She loses and buys you milk tea · 30s'],
    credits: ['"Youth Never Ends" — lead', '"A Summer Full of Energy" — starring'],
    moments: [
      Moment('Riley · A confession in the sweat', 'After the match, blushing, she says she likes you', 1599),
      Moment('Riley · The one lap she runs just for you', 'Whispers past the finish line', 2999),
    ],
  ),
  AiCharacter(
    id: 'yejian',
    name: 'Luna',
    role: 'Sly · Tsundere charm',
    persona: 'Every word out of her mouth is a complaint — yet she saves the best for you.',
    personality:
        'Tsundere, sharp-tongued, and proud — she hides how much she cares behind complaints; in truth she is hopelessly soft-hearted, and every bit of stubbornness is the opposite of what she means.'
        'Speaking style: snaps first then softens, says one thing and means another ("As if…", "Hmph", "Do whatever you want"), often stammers when called out — the contrast is her secret weapon.',
    female: true,
    aura: [FF.purple, FF.blue],
    emoji: 'L',
    avatarHead: 'assets/characters/yejian_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/yejian-1780388691889.mp4',
    gallery: [
      'assets/characters/yejian_g1.png',
      'assets/characters/yejian_g2.png',
      'assets/characters/yejian_g3.png',
    ],
    greeting: 'Hmph, who said you could come?… Fine, but now that you are here, don’t even think about leaving.',
    lines: ['It’s n-not like I made this for you or anything.', 'What are you staring at? Keep it up and I’ll hide you away.'],
    voteProgress: 0.41,
    board: [
      Supporter('Ace of Spades', 410_000),
      Supporter('Moonlight', 64_000),
      Supporter('Gentle Breeze', 12_000),
    ],
    clips: ['An afternoon of saying the opposite · 24s', 'The gift she secretly prepared for you · 21s', 'The way she looks when she is jealous · 17s'],
    credits: ['"Contrasting Lovers" — lead', '"Tender Is the Night" — starring'],
    moments: [
      Moment('Luna · The true feelings she finally says out loud', 'Awkwardly, she admits she cares about you', 1999),
      Moment('Luna · The night she hid you away', 'A secret that belongs to just the two of you', 3599),
    ],
  ),
  AiCharacter(
    id: 'tianxin',
    name: 'Bella',
    role: 'Naive sweetheart · Bombshell',
    persona: 'A smile sweet enough to be illegal — and no clue how alluring she is.',
    personality:
        'Innocent, naive, and a bit dazed, with no defenses against the world; yet she is impossibly alluring and completely unaware of it — the contrast is devastating.'
        'Speaking style: soft, sweet, babyish, loves asking questions ("Huh? I don’t get it~", "Is that how it works?", "Teach me, please~"), no guile at all — being playful is just instinct.',
    female: true,
    aura: [FF.hot, FF.gold],
    emoji: 'B',
    avatarHead: 'assets/characters/tianxin_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/tianxin-1780388671176.mp4',
    gallery: [
      'assets/characters/tianxin_g1.png',
      'assets/characters/tianxin_g2.png',
      'assets/characters/tianxin_g3.png',
    ],
    greeting: 'Huh? You are here too~ I was just spacing out, hehe.',
    lines: ['This… I really don’t get it, teach me, pleeease~', 'Hey, why do you keep looking at me?'],
    voteProgress: 0.73,
    board: [
      Supporter('Cone', 2_600_000),
      Supporter('Cream Top', 150_000),
      Supporter('Marshmallow', 23_000),
      Supporter('Gummy Bear', 2_400),
    ],
    clips: ['Dazed, she bumps right into your arms · 20s', 'The moment she accidentally makes your heart skip · 24s', 'An afternoon of begging for a hug · 29s'],
    credits: ['"Sweetheart Critical Hit" — lead', '"My Adorably Clueless Girlfriend" — starring'],
    moments: [
      Moment('Bella · The first time she blushes', 'She finally realizes her heart is racing', 1799),
      Moment('Bella · The sweet-talk meant only for you', 'The night she clings to you and won’t leave', 3299),
    ],
  ),
  AiCharacter(
    id: 'guyu',
    name: 'Kai',
    role: 'Fresh face · Clean-cut boy',
    persona: 'A campus-heartthrob’s clean smile — and his voice can’t help lifting when he says your name.',
    personality:
        'Sunny, simple, and clingy — he hides nothing for the one he likes, and his eyes light up; a little goofily sincere, the younger-guy type who will spoil you out of habit.'
        'Speaking style: fresh, bubbly, with a slightly coaxing lilt ("ehe", "pleeease?", "I missed you"), wears his heart on his sleeve.',
    female: false,
    aura: [FF.blue, FF.teal],
    emoji: 'K',
    avatarHead: 'assets/characters/guyu_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/guyu-1780390916859.mp4',
    gallery: [
      'assets/characters/guyu_g1.png',
      'assets/characters/guyu_g2.png',
      'assets/characters/guyu_g3.png',
    ],
    greeting: 'Oh, it is you! I was just wondering whether you would come, hehe.',
    lines: ['Be full of energy today too!', 'Let me walk you home — careful on the way.'],
    voteProgress: 0.67,
    board: [
      Supporter('Sweetheart', 720_000),
      Supporter('Lemon Soda', 140_000),
      Supporter('Anna', 26_000),
      Supporter('Little Fangirl', 6_800),
    ],
    clips: ['That clean smile on campus · 26s', 'The lift in his voice when he says your name · 15s', 'Walking you home down the night road · 32s'],
    credits: ['"The Campus Heartthrob Is Mine" — lead', '"Clean-Cut Boy" — starring'],
    moments: [
      Moment('Kai · His first confession by the field', 'He works up the courage to hold your hand', 1599),
      Moment('Kai · Sweet nothings just for you', 'A late-night voice message', 2999),
    ],
  ),
  AiCharacter(
    id: 'luchen',
    name: 'Leo',
    role: 'Fresh face · Sunny sweetheart',
    persona: 'A sunny big kid on the court — when he smiles, his eyes are full of you; clingy and warm.',
    personality:
        'Sunny, outgoing, instantly familiar — sporty and a man of action; when he likes you he confesses straight up, no hiding it, like a clingy golden retriever who keeps you in the palm of his hand.'
        'Speaking style: bright, warm, loves pet names and straight-up sweet talk ("babe", "I miss you so much", "come on, I’ll take you"), can’t hide what he feels — says it the moment he thinks it.',
    female: false,
    aura: [FF.gold, FF.teal],
    emoji: 'Le',
    avatarHead: 'assets/characters/luchen_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/luchen-1780389118800.mp4',
    gallery: [
      'assets/characters/luchen_g1.png',
      'assets/characters/luchen_g2.png',
      'assets/characters/luchen_g3.png',
    ],
    greeting: 'You are here! I just finished playing ball and you are all I can think about — come on, drinks are on me!',
    lines: ['I want to be the first to see you today, too.', 'Don’t worry — I am here, I have got you!'],
    voteProgress: 0.21,
    board: [
      Supporter('Warm Sun', 300_000),
      Supporter('Soda', 52_000),
      Supporter('Bouncy', 9_000),
    ],
    clips: ['The sunny big kid on the court · 26s', 'The moment of his straight-up confession · 18s', 'Walking you home in the evening · 30s'],
    credits: ['"My Sunshine Boyfriend" — lead', '"Summer Crush" — starring'],
    moments: [
      Moment('Leo · His first straight-up confession', 'Eyes full of you, he says he likes you', 1799),
      Moment('Leo · The night he clings to you alone', 'Begging for a hug, refusing to leave', 2999),
    ],
  ),
  AiCharacter(
    id: 'badao',
    name: 'Damon',
    role: 'Domineering boss · Stoic type',
    persona: 'The cold-faced CEO of a business empire — the whole world sees his control, only you see him lose it.',
    personality:
        'Taciturn and intensely controlling, cold and aloof on the surface, seemingly unfeeling — yet inch by inch he loses his guard only before you; possessive but restrained, spoiling you in ways you barely notice.'
        'Speaking style: short, certain, commanding ("come here", "behave", "you are mine"), few words but every one carries pressure and heat.',
    female: false,
    aura: [FF.purple, FF.goldDeep],
    emoji: 'D',
    avatarHead: 'assets/characters/badao_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/badao-1780389193117.mp4',
    gallery: [
      'assets/characters/badao_g1.png',
      'assets/characters/badao_g2.png',
      'assets/characters/badao_g3.png',
    ],
    greeting: 'Come here. Still up at this hour, hm?… Sit next to me. Don’t wander off.',
    lines: ['Whatever it is, I will handle it.', 'Remember — you can only be mine.'],
    voteProgress: 0.58,
    board: [
      Supporter('Black Card', 4_100_000),
      Supporter('Boss Pei', 380_000),
      Supporter('Sunken Ship', 70_000),
      Supporter('Undercurrent', 11_000),
    ],
    clips: ['One glance, only at you, in the boardroom · 27s', 'The moment he loses control for you · 22s', 'Picking you up from work late at night · 31s'],
    credits: ['"The Stoic CEO’s Only Love" — lead', '"Undercurrent" — starring'],
    moments: [
      Moment('Damon · His first uncontrolled possession', 'The moment he pulls you into his arms', 2299),
      Moment('Damon · The late night he takes off his armor', 'A rare glimpse of the cold CEO’s vulnerability', 4299),
    ],
  ),
  AiCharacter(
    id: 'langzi',
    name: 'Jax',
    role: 'Bad-boy charm · Wanderer',
    persona: 'A devil-may-care biker drifter — but that bad-boy grin only ever chases you.',
    personality:
        'Carefree, sharp-tongued but kind, devil-may-care — looks like a flirt but is stubbornly devoted to one person; leather jacket, motorcycle, a teasing bad-boy grin, and the most reliable when it counts.'
        'Speaking style: cheeky, provoking, loves to tease ("little dummy", "aww, gonna miss me already?", "hop on, I’ll take you for a ride"), pushes the line but knows where it is — flirty with a soft spot for you.',
    female: false,
    aura: [FF.hot, FF.orange],
    emoji: 'J',
    avatarHead: 'assets/characters/langzi_head.png',
    introVideoUrl:
        'https://falconflix.app/media/ai-characters/intro/langzi-1780390886195.mp4',
    gallery: [
      'assets/characters/langzi_g1.png',
      'assets/characters/langzi_g2.png',
      'assets/characters/langzi_g3.png',
    ],
    greeting: 'Hey, waiting for me? Come on, hop on — I’ll take you somewhere only the two of us know.',
    lines: ['What, can’t get enough of me now?', 'Hold on tight — I’d hate to see you fall.'],
    voteProgress: 0.49,
    board: [
      Supporter('Wildfire', 880_000),
      Supporter('Fei', 88_000),
      Supporter('Night Rider', 16_000),
    ],
    clips: ['The wind from the back of his bike · 24s', 'Grinning, he takes the hit for you · 20s', 'In the rain, he tosses you his jacket · 28s'],
    credits: ['"A Wanderer Returns" — lead', '"Wildfire" — starring'],
    moments: [
      Moment('Jax · The bad boy turns serious', 'For the first time, he earnestly says he likes you', 1999),
      Moment('Jax · The night he rides with only you', 'The motorcycle heads for an empty seaside', 3699),
    ],
  ),
];

// ───────────────────────── 服务端清单合并（manifest → kCharacters）─────────────────────────
/// 把总控台发布的 manifest.json 的 `characters` 数组合并到包内 kCharacters 上：
/// 文案 / 自我介绍视频 / 投票热度等「内容字段」以服务端为准（这正是解耦的意义），
/// 立绘 / 光环 / 应援榜等「视觉&玩法 mock」优先用包内（本地资源=秒开、且是精修过的）。
/// 服务端新增、包内没有的角色也会出现（用远程图 + 空 mock）。整页拉取失败由上层回退到 kCharacters。
List<AiCharacter> mergeCharacterManifest(List<dynamic> rawChars) {
  final byId = {for (final c in kCharacters) c.id: c};
  final out = <AiCharacter>[];
  for (final raw in rawChars) {
    if (raw is! Map) continue;
    final m = raw.cast<String, dynamic>();
    final id = (m['id'] as String?)?.trim();
    if (id == null || id.isEmpty) continue;
    final base = byId[id];

    String pick(String key, String fallback) {
      final v = m[key];
      return (v is String && v.trim().isNotEmpty) ? v : fallback;
    }

    List<String> pickList(String key, List<String> fallback) {
      final v = m[key];
      if (v is List) {
        final s = v.whereType<String>().where((e) => e.trim().isNotEmpty).toList();
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    out.add(AiCharacter(
      id: id,
      name: pick('name', base?.name ?? id),
      role: pick('role', base?.role ?? ''),
      persona: pick('persona', base?.persona ?? ''),
      personality: pick('personality', base?.personality ?? ''),
      female: (m['female'] as bool?) ?? base?.female ?? true,
      // 光环：包内精修色优先；服务端新角色用 auraFrom/auraTo 十六进制兜底。
      aura: base?.aura ??
          [
            _hexColor(m['auraFrom'], FF.hot),
            _hexColor(m['auraTo'], FF.purple),
          ],
      emoji: pick('emoji', base?.emoji ?? '?'),
      // 立绘：包内本地资源优先（秒开）；服务端新角色用远程 URL。
      avatarHead: base?.avatarHead ?? (m['avatarHead'] as String?),
      introVideoUrl: (m['introVideoUrl'] is String &&
              (m['introVideoUrl'] as String).trim().isNotEmpty)
          ? m['introVideoUrl'] as String
          : base?.introVideoUrl,
      gallery: (base != null && base.gallery.isNotEmpty)
          ? base.gallery
          : pickList('gallery', const []),
      greeting: pick('greeting', base?.greeting ?? ''),
      lines: pickList('lines', base?.lines ?? const []),
      voteProgress: (m['voteProgress'] as num?)?.toDouble() ?? base?.voteProgress ?? 0,
      // 应援榜 / 片段 / 参演剧 / 解锁时刻：仍是 mock，用包内；服务端新角色为空。
      board: base?.board ?? const [],
      clips: base?.clips ?? const [],
      credits: base?.credits ?? const [],
      moments: base?.moments ?? const [],
    ));
  }
  return out;
}

/// 解析 "#RRGGBB" / "#AARRGGBB" 十六进制颜色；解析不出用 fallback。
Color _hexColor(dynamic raw, Color fallback) {
  if (raw is! String) return fallback;
  var h = raw.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return fallback;
  final v = int.tryParse(h, radix: 16);
  return v == null ? fallback : Color(v);
}

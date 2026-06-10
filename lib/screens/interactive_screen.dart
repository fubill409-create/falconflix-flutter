import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme.dart';
import 'sheets.dart';

/// 互动剧 · video-first 三态玩法（按 Codex falconflix-visual-upgrade 落地）。
///   ① 选择点 choice：全屏静态场景帧 + 旋转影院光束 + 底部毛玻璃选择卡
///      （问题 + 选项含人群投票% + 缺线索锁 + 内联「自己说」AI 改写）。
///   ② 分支进行中 generating：AI 青球 conic 旋转 + spell lines + 预览台词
///      + 心动上升信号 + 道具线索 chip。
///   ③ 结局 ending：结局面板（稀有度 + 抵达% + 6 点结局图）+ 分支记录抽屉。
/// 剧本《机器人女友 · 雨夜重启》：6 个结局 + 1 个线索门控隐藏真结局；
/// 心动值贯穿，线索（出厂密钥）跨重玩保留，集齐后开场解锁真结局。
/// 当前背景用静态帧 + 本地 mock AI 续写，后端剧情树/实时生成待接。
class InteractiveScreen extends StatefulWidget {
  const InteractiveScreen({super.key});

  @override
  State<InteractiveScreen> createState() => _InteractiveScreenState();
}

enum _Phase { intro, choice, generating, ending }

// 设计令牌（对齐 visual-upgrade.css）
const _pink = Color(0xFFFF4F9B);
const _cyan = Color(0xFF26F0FF);
const _blue = Color(0xFF36CAFF);
const _purple = Color(0xFF8C64FF);
const _glassCard = Color(0xA30A0811); // rgba(10,8,17,.64)

// ───────────────────────── 剧情树数据 ─────────────────────────
class _Opt {
  final String label;
  final String vote; // 人群投票百分比
  final String next;
  final int love;
  final String preview; // 生成态展示的下一幕预览台词
  final String? grantClue; // 选后获得线索
  final String? needClue; // 需持有该线索才解锁
  final String? propLabel; // 道具线索 chip 文案
  final String? propImg; // 道具线索 chip 图
  final bool hot; // 高亮推荐项（青色描边）
  const _Opt(
    this.label, {
    required this.vote,
    required this.next,
    this.love = 0,
    this.preview = '',
    this.grantClue,
    this.needClue,
    this.propLabel,
    this.propImg,
    this.hot = false,
  });
}

class _End {
  final String title;
  final String rarity;
  final String text;
  final List<Color> badge;
  final bool secret;
  const _End(this.title, this.rarity, this.text, this.badge,
      {this.secret = false});
}

class _Node {
  final String bg;
  final String chip;
  final String beat;
  final String question;
  final List<_Opt> options;
  final _End? ending;
  const _Node({
    required this.bg,
    this.chip = '',
    this.beat = '',
    this.question = '',
    this.options = const [],
    this.ending,
  });
}

const _kKey = '出厂密钥';

const _nodes = <String, _Node>{
  'n1': _Node(
    bg: 'assets/drama/rg1.jpg',
    chip: '第 1 节 · 重启',
    beat: '选择点 · 纸箱堆里',
    question: '凌晨，你拆开最后一个纸箱。她在里面睁开眼，怯生生地看着你：「你……是我的新主人吗？」',
    options: [
      _Opt('轻轻把她扶起来',
          vote: '71%',
          next: 'n2a',
          love: 5,
          hot: true,
          preview: '米卡的瞳孔亮了一下，像是重新接通了电源。'),
      _Opt('后退半步，戒备地看着她',
          vote: '22%', next: 'n2b', love: -3, preview: '她的笑容僵在半空，腕关节发出细小的嗡鸣。'),
      _Opt('翻出箱底那张全家福',
          vote: '7%',
          next: 'e_true',
          needClue: _kKey,
          preview: '泛黄照片的背面，刻着一行出厂编号——和她腕间的一模一样。'),
    ],
  ),
  'n2a': _Node(
    bg: 'assets/drama/rg4.jpg',
    chip: '第 2 节 · 同居',
    beat: '选择点 · 清晨厨房',
    question: '米卡笨拙地煎着蛋，油花溅到手背也没躲。她回头冲你笑：「我想给你做第一顿早饭。」',
    options: [
      _Opt('「慢慢来，有我在」',
          vote: '64%',
          next: 'n3a',
          love: 6,
          hot: true,
          preview: '灶台的火光映在她脸上，她第一次笑出了声。'),
      _Opt('帮她整理腕中卡住的旧照片',
          vote: '36%',
          next: 'n3a',
          love: 3,
          grantClue: _kKey,
          propLabel: '线索 · 出厂密钥',
          propImg: 'assets/products/jewelry-product.jpg',
          preview: '你在她腕间的存储槽里，翻出一张被锁住的照片。'),
    ],
  ),
  'n3a': _Node(
    bg: 'assets/drama/rg2.jpg',
    chip: '第 3 节 · 靠近',
    beat: '选择点 · 雾气浴室',
    question: '热水汽里，她忽然低声说：「我的记忆只有三天。明天醒来，我可能就不记得你了。」',
    options: [
      _Opt('「那我们就造只属于今天的记忆」',
          vote: '58%', next: 'e_home', love: 8, hot: true),
      _Opt('「告诉我，你到底是谁造的」', vote: '42%', next: 'e_memory', love: 2),
    ],
  ),
  'n2b': _Node(
    bg: 'assets/drama/rg3.jpg',
    chip: '第 2 节 · 雨夜',
    beat: '选择点 · 窗前',
    question: '她背对你看着窗外的雨：「如果我说，我是被丢掉的型号呢？你……还会留我吗？」',
    options: [
      _Opt('「你到底是谁，说清楚」', vote: '40%', next: 'e_stranger', love: -2),
      _Opt('心软，拉她进屋擦干头发',
          vote: '60%',
          next: 'n3b',
          love: 4,
          hot: true,
          preview: '她怔住了，雨水顺着脸颊滑下，分不清是雨还是别的。'),
    ],
  ),
  'n3b': _Node(
    bg: 'assets/drama/rg2.jpg',
    chip: '第 3 节 · 留宿',
    beat: '选择点 · 深夜',
    question: '雨没停。她攥着你的衣角，小声问：「今晚……我可以不进充电舱吗？」',
    options: [
      _Opt('「留下来，就在我身边」', vote: '55%', next: 'e_rain', love: 5, hot: true),
      _Opt('「天亮我送你回工厂」', vote: '45%', next: 'e_letgo', love: 0),
    ],
  ),
  // ── 结局节点 ──
  'e_home': _Node(
    bg: 'assets/drama/rg4.jpg',
    ending: _End('家 · 暖灯', '温暖结局 · 47% 观众抵达',
        '你们没再提记忆的事。她每天醒来都重新爱上你一次，而你，每天都把昨天的故事讲给她听。这盏暖灯，从此不灭。',
        [FF.teal, FF.lime]),
  ),
  'e_memory': _Node(
    bg: 'assets/drama/rg2.jpg',
    ending: _End('记忆 · 编号 00', '深情结局 · 29% 抵达',
        '她调出出厂数据：第一任主人的脸，和你一模一样。「原来我，是照着你的回忆，一点点造出来的。」',
        [FF.gold, FF.brightGold]),
  ),
  'e_rain': _Node(
    bg: 'assets/drama/rg2.jpg',
    ending: _End('雨夜 · 不眠', '缠绵结局 · 33% 抵达',
        '那一夜充电舱空着。窗外的雨敲了整晚，屋里只有两个人的呼吸，和一句没说完的「别走」。',
        [_pink, FF.hot2]),
  ),
  'e_letgo': _Node(
    bg: 'assets/drama/rg3.jpg',
    ending: _End('放手 · 天亮', '遗憾结局 · 38% 抵达',
        '你把她送回了工厂。临别她笑得很乖：「谢谢你陪我的三天。」转身那刻，你才发现自己红了眼。',
        [FF.muted, FF.dim]),
  ),
  'e_stranger': _Node(
    bg: 'assets/drama/rg3.jpg',
    ending: _End('陌生人 · 关机', '冷线结局 · 19% 抵达',
        '她安静地走进充电舱，再没醒来。系统提示：型号已注销。有些人一旦被推远，就再也开不了机。',
        [_pink, _purple]),
  ),
  'e_true': _Node(
    bg: 'assets/drama/rg1.jpg',
    ending: _End('真结局 · 出厂密钥', '稀有真结局 · 只有 8% 抵达',
        '全家福背面的编号解开了她的记忆锁——她不是被丢掉的型号，而是有人花十年，照着逝去的爱人把她一点点重造出来。那个人，是未来的你。',
        [FF.brightGold, FF.gold],
        secret: true),
  ),
};

// 结局图鉴顺序（6 点；e_true 为隐藏点）
const _endingOrder = [
  'e_home',
  'e_memory',
  'e_rain',
  'e_letgo',
  'e_stranger',
  'e_true',
];

class _InteractiveScreenState extends State<InteractiveScreen> {
  _Phase _phase = _Phase.intro;
  String _nodeId = 'n1';
  int _affinity = 30;
  int _step = 0;
  final Set<String> _clues = {}; // 跨重玩保留
  final Set<String> _seen = {}; // 已解锁结局（含 e_ai）
  final List<(String, String)> _history = [];
  final TextEditingController _speakCtrl = TextEditingController();
  Timer? _genTimer;
  int _thinkStyle = 1; // AI 思考态风格：0=星云 CG，1=极简（默认，用户选定）；可现场切换对比

  // 生成态待展示信息
  String _genPreview = '';
  String? _genPropLabel;
  String? _genPropImg;
  int _genDelta = 0;
  bool _genUnlock = false;
  bool _isAiRun = false;
  String _pendingNext = '';
  String _aiText = '';
  String _aiPrompt = '';

  @override
  void dispose() {
    _genTimer?.cancel();
    _speakCtrl.dispose();
    super.dispose();
  }

  void _start() {
    _genTimer?.cancel();
    setState(() {
      _nodeId = 'n1';
      _affinity = 30;
      _step = 0;
      _history.clear();
      _phase = _Phase.choice;
    });
  }

  void _exitToIntro() {
    _genTimer?.cancel();
    setState(() => _phase = _Phase.intro);
  }

  /// 现场切换 AI 思考态的两套概念，并重置推进计时器，让你能停下来从容对比。
  void _toggleThinkStyle() {
    if (_phase != _Phase.generating) return;
    _genTimer?.cancel();
    setState(() => _thinkStyle = _thinkStyle == 0 ? 1 : 0);
    _genTimer = Timer(
        const Duration(milliseconds: 8500), _isAiRun ? _advanceAi : _advance);
  }

  void _choose(_Opt o) {
    final node = _nodes[_nodeId]!;
    if (o.needClue != null && !_clues.contains(o.needClue)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text('缺少线索 · 需要「${o.needClue}」才能走这条隐藏线',
            style: const TextStyle(color: Colors.white)),
      ));
      return;
    }
    FocusScope.of(context).unfocus();
    final justUnlocked = o.grantClue != null && !_clues.contains(o.grantClue);
    setState(() {
      _affinity += o.love;
      if (o.grantClue != null) _clues.add(o.grantClue!);
      _history.add((node.chip, o.label));
      _isAiRun = false;
      _genPreview = o.preview.isEmpty ? '剧情正在向下一幕展开……' : o.preview;
      _genDelta = o.love;
      _genPropLabel = o.propLabel;
      _genPropImg = o.propImg;
      _genUnlock = justUnlocked;
      _pendingNext = o.next;
      _phase = _Phase.generating;
    });
    _genTimer?.cancel();
    _genTimer = Timer(const Duration(milliseconds: 8500), _advance);
  }

  void _advance() {
    if (!mounted) return;
    final node = _nodes[_pendingNext]!;
    setState(() {
      _nodeId = _pendingNext;
      if (node.ending != null) {
        _seen.add(_pendingNext);
        _phase = _Phase.ending;
      } else {
        _step += 1;
        _phase = _Phase.choice;
      }
    });
  }

  void _submitSpeak() {
    final t = _speakCtrl.text.trim();
    if (t.isEmpty) return;
    FocusScope.of(context).unfocus();
    final node = _nodes[_nodeId]!;
    setState(() {
      _affinity += 3;
      _aiPrompt = t;
      _history.add((node.chip, '自己说：$t'));
      _isAiRun = true;
      _genPreview = '米卡眨了眨眼：「好，我就按你说的——$t」';
      _genDelta = 3;
      _genPropLabel = null;
      _genPropImg = null;
      _genUnlock = false;
      _phase = _Phase.generating;
    });
    _speakCtrl.clear();
    _genTimer?.cancel();
    _genTimer = Timer(const Duration(milliseconds: 8500), _advanceAi);
  }

  void _advanceAi() {
    if (!mounted) return;
    setState(() {
      _aiText = '画面随你的台词重组——\n\n'
          '「$_aiPrompt」\n\n'
          '米卡照做了。这一幕只属于你，没有第二个人见过同样的米卡。\n\n'
          '（AI 续写 · 示意版，正式版将接入实时生成）';
      _nodeId = 'e_ai';
      _seen.add('e_ai');
      _phase = _Phase.ending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = _nodes[_nodeId];
    final bg = node?.bg ?? 'assets/drama/rg4.jpg';
    final List<Color> beams = switch (_phase) {
      _Phase.ending => const [FF.gold, FF.brightGold, _pink, FF.gold, FF.brightGold, _pink],
      _Phase.generating => const [_cyan, _pink, _blue, _cyan, _pink, _blue],
      _ => const [_pink, _cyan, _blue, _pink, _cyan, _blue],
    };
    final sceneBg = _phase == _Phase.intro ? 'assets/drama/rg4.jpg' : bg;
    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // AI 思考态：两套可现场切换的概念背景——
          //   ① 星云 CG 暗背景（光球/光芒）  ② 极简白·凸起星
          if (_phase == _Phase.generating)
            (_thinkStyle == 0
                ? const _AiThinkingBackdrop()
                : const _MinimalThinkingBackdrop())
          else
            _SceneBackdrop(
              asset: sceneBg,
              beams: beams,
              opacity: 0.72,
            ),
          SafeArea(
            bottom: false,
            child: switch (_phase) {
              _Phase.intro => _introView(),
              _Phase.choice => _choiceView(node!),
              _Phase.generating =>
                _thinkStyle == 0 ? _generatingView() : _minimalThinkingView(),
              _Phase.ending => _endingView(),
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 开场 ─────────────────────────
  Widget _introView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              _goldTitle('互动剧场', size: 20),
              const Spacer(),
              if (_seen.isNotEmpty)
                _chapterChip(
                    '已解锁 ${_seen.where(_endingOrder.contains).length}/6', FF.brightGold),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _tag('互动', filled: false),
              const SizedBox(width: 8),
              _tag('多结局 · 心动值 · AI 改写', filled: true),
            ],
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
          const SizedBox(height: 14),
          const Text('机器人女友',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1.02))
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.12, curve: Curves.easeOut),
          const SizedBox(height: 2),
          _goldTitle('雨夜重启', size: 26)
              .animate(delay: 120.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.12, curve: Curves.easeOut),
          const SizedBox(height: 12),
          const Text('你拆开纸箱，唤醒了她。她的记忆只有三天，\n而你的每一次选择，都在决定她记不记得你。',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.6))
              .animate(delay: 220.ms)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 22),
          _BigButton(
            label: '开始这一夜',
            icon: Icons.play_arrow_rounded,
            onTap: _start,
          )
              .animate(delay: 360.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutBack)
              .then()
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2200.ms, color: Colors.white30),
          if (_clues.contains(_kKey)) ...[
            const SizedBox(height: 12),
            const Center(
              child: Text('✦ 你已持有「出厂密钥」，开场可解锁隐藏真结局',
                  style: TextStyle(
                      color: _cyan, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(String t, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: filled
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999),
          border: filled ? null : Border.all(color: Colors.white24)),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  // ───────────────────────── ① 选择点（全屏星座式）─────────────────────────
  // 场景满铺；剧情做电影字幕；选项异形散布、用光丝连到中心决策核；
  // 「自己说」收成浮动药丸，点开走全屏 composer。
  Widget _choiceView(_Node node) {
    return Column(
      children: [
        _topRow(node.chip, Colors.white),
        Expanded(
          child: LayoutBuilder(builder: (ctx, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            const topPad = 184.0; // 题面下方
            const bottomReserve = 156.0; // 浮动导航 + 自己说药丸
            const cardHalf = 42.0;
            final cTop = topPad + cardHalf;
            final cBot = (h - bottomReserve - cardHalf).clamp(cTop + 80, h);
            final core = Offset(w * 0.5, (cTop + cBot) / 2);
            final anchors = _optionAnchors(node.options.length, w, cTop, cBot);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 光丝：中心核 → 各选项
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FilamentPainter(core: core, targets: anchors),
                    ),
                  ),
                ),
                // 中心决策核
                Positioned(
                  left: core.dx - 27,
                  top: core.dy - 27,
                  child: const _DecisionCore(),
                ),
                Positioned(top: 2, right: 4, child: _AffinitySigil(value: _affinity)),
                Positioned(top: 6, left: 12, child: _branchTree()),
                // 题面（电影字幕）
                Positioned(
                  top: 80,
                  left: 22,
                  right: 22,
                  child: _questionBlock(node),
                ),
                // 选项（异形散布）
                for (var i = 0; i < node.options.length; i++)
                  _positionedOption(node.options[i], anchors[i], i, w),
                // 自己说浮动药丸
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 100,
                  child: Center(child: _speakPill()),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // 选项中心坐标（异形左右错落 + 上下铺开）
  List<Offset> _optionAnchors(int n, double w, double top, double bottom) {
    final xs = n >= 3 ? [0.30, 0.70, 0.34] : [0.32, 0.67];
    final res = <Offset>[];
    for (var i = 0; i < n; i++) {
      final f = n == 1 ? 0.5 : i / (n - 1);
      res.add(Offset(w * xs[i % xs.length], top + (bottom - top) * f));
    }
    return res;
  }

  Widget _positionedOption(_Opt o, Offset center, int i, double w) {
    final cardW = (w * 0.58).clamp(186.0, 232.0);
    return Positioned(
      left: (center.dx - cardW / 2).clamp(8.0, w - cardW - 8),
      top: center.dy - 42,
      width: cardW,
      child: _orbOption(o, i)
          .animate(delay: (150 * i + 140).ms)
          .fadeIn(duration: 460.ms)
          .scaleXY(begin: 0.6, curve: Curves.easeOutBack)
          .moveY(begin: 16, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _orbOption(_Opt o, int i) {
    final locked = o.needClue != null && !_clues.contains(o.needClue);
    final accent = locked ? FF.gold : (o.hot ? _cyan : _blue);
    return GestureDetector(
      onTap: () => _choose(o),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xCC0B0913),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: accent.withValues(alpha: 0.62), width: 1.2),
              boxShadow: [
                BoxShadow(
                    color: accent.withValues(alpha: locked ? 0.2 : 0.34),
                    blurRadius: 26),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: locked
                                ? const [FF.gold, FF.brightGold]
                                : const [_pink, _purple, _blue]),
                      ),
                      child: locked
                          ? const Icon(Icons.lock_rounded,
                              color: Colors.white, size: 11)
                          : Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(locked ? '缺线索' : o.vote,
                          style: TextStyle(
                              color: locked ? FF.gold : accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(locked ? '？？？ · 隐藏线' : o.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: locked
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white,
                        fontSize: 13.5,
                        height: 1.22,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _questionBlock(_Node node) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(node.beat,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: FF.brightGold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        Container(width: 26, height: 2, color: FF.gold.withValues(alpha: 0.7)),
        const SizedBox(height: 10),
        Text(node.question,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.32,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 16, offset: Offset(0, 2))
                ])),
      ],
    ).animate().fadeIn(duration: 540.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _speakPill() {
    return GestureDetector(
      onTap: _openSpeakComposer,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x990A0811),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _cyan.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(color: _cyan.withValues(alpha: 0.2), blurRadius: 20),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: _cyan, size: 15),
                SizedBox(width: 8),
                Text('替米卡写一句台词',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Text('AI 改写',
                    style: TextStyle(
                        color: _cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2600.ms, color: _cyan.withValues(alpha: 0.5));
  }

  void _openSpeakComposer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                decoration: BoxDecoration(
                  color: const Color(0xF20A0811),
                  border: Border(
                      top: BorderSide(color: _cyan.withValues(alpha: 0.4))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: _cyan, size: 16),
                        SizedBox(width: 8),
                        Text('替米卡写一句台词',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('AI 会照你说的，把下一幕改写成只属于你的版本',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _speakCtrl,
                      autofocus: true,
                      maxLength: 40,
                      minLines: 1,
                      maxLines: 3,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, height: 1.4),
                      cursorColor: _cyan,
                      decoration: InputDecoration(
                        counterStyle: const TextStyle(color: Colors.white38),
                        hintText: '例：她突然抱住了我……',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) {
                        Navigator.pop(ctx);
                        _submitSpeak();
                      },
                    ),
                    const SizedBox(height: 4),
                    _BigButton(
                      label: '让米卡照做',
                      icon: Icons.auto_awesome,
                      height: 52,
                      onTap: () {
                        Navigator.pop(ctx);
                        _submitSpeak();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── ② 分支进行中（全屏·光芒万丈）─────────────────────────
  // AI 接管整屏：大旋转 conic 球 + 24 道放射光线 + 径向闪光底图 + AI 在中心闪，
  // 预览台词做电影字幕，状态收成发光药丸——不是底部小卡。
  Widget _generatingView() {
    final hasProp = _genPropLabel != null;
    return Column(
      children: [
        _topRow(_isAiRun ? '米卡正在改写剧情' : '下一段 · 生成中', _cyan),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                  top: 2,
                  right: 4,
                  child: _AffinitySigil(value: _affinity, delta: _genDelta)),
              Positioned(top: 6, left: 12, child: _branchTree()),
              Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Center(child: _styleToggle(onLight: false))),
              Align(
                alignment: const Alignment(0, -0.16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 光芒万丈：放射光线 + 径向闪光 + AI 球叠在中心
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: const [
                            _RayBurst(),
                            _ConicOrb(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                          _isAiRun
                              ? '根据你的台词，米卡正在改写剧情'
                              : '根据你的选择，生成下一段剧情',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                      const SizedBox(height: 12),
                      Text(_genPreview,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  height: 1.28,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black,
                                        blurRadius: 18,
                                        offset: Offset(0, 2))
                                  ]))
                          .animate(key: ValueKey(_genPreview))
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.16, curve: Curves.easeOut),
                      const SizedBox(height: 20),
                      const _SpellLines(),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _branchStatusChip(),
                      if (hasProp) ...[
                        const SizedBox(height: 10),
                        _propChip(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────── AI 思考态 · 概念二：极简白 + 凸起星（一呼一吸）─────────────
  Widget _minimalThinkingView() {
    return Stack(
      children: [
        // 顶部：极简返回 + 风格切换
        Positioned(
          top: 8,
          left: 10,
          right: 10,
          child: Row(
            children: [
              _minIconBtn(Icons.arrow_back_ios_new, _exitToIntro),
              const Spacer(),
              _styleToggle(onLight: true),
            ],
          ),
        ),
        // 居中：有质感的凸起四角星，缓慢一呼一吸
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: const CustomPaint(painter: _EmbossedStarPainter()),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.9,
                  end: 1.1,
                  duration: 1250.ms,
                  curve: Curves.easeInOut),
        ),
        // 底部：一行小字
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 134),
            child: Text(
              _isAiRun ? 'AI 正在照你说的，改写这一幕' : 'AI 正在生成下一段剧情',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8A93A3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.45, end: 1.0, duration: 1600.ms),
          ),
        ),
      ],
    );
  }

  // 极简白底上的圆形软质按钮（neumorphic）
  Widget _minIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F5FA),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
            BoxShadow(
                color: Color(0x22000000), offset: Offset(3, 3), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF55607A)),
      ),
    );
  }

  // 两套思考态间的切换胶囊：onLight=白底版（暗字软按钮）/ 否则=暗底毛玻璃版
  Widget _styleToggle({required bool onLight}) {
    final label = _thinkStyle == 0 ? '切换 · 极简白' : '切换 · 星云';
    if (onLight) {
      return GestureDetector(
        onTap: _toggleThinkStyle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: const BoxDecoration(
            color: Color(0xFFF2F5FA),
            borderRadius: BorderRadius.all(Radius.circular(999)),
            boxShadow: [
              BoxShadow(
                  color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
              BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(2, 3),
                  blurRadius: 6),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz, size: 14, color: Color(0xFF55607A)),
              SizedBox(width: 6),
              Text('切换 · 星云',
                  style: TextStyle(
                      color: Color(0xFF55607A),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _toggleThinkStyle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x66090611),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, size: 14, color: _cyan),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _branchStatusChip() {
    final nextChip = _nodes[_isAiRun ? 'e_ai' : _pendingNext]?.chip;
    final nextName = _isAiRun
        ? '你的专属结局'
        : (_nodes[_pendingNext]?.ending != null
            ? _nodes[_pendingNext]!.ending!.title
            : (nextChip == null || nextChip.isEmpty ? '下一幕' : nextChip));
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0x99090611),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: FF.gold.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: FF.gold.withValues(alpha: 0.16), blurRadius: 24),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('分支进行中',
                  style: TextStyle(
                      color: FF.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(nextName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
              ),
              if (_genUnlock) ...[
                const SizedBox(width: 10),
                Container(width: 1, height: 14, color: Colors.white24),
                const SizedBox(width: 10),
                const Text('隐藏分支已解锁',
                    style: TextStyle(
                        color: _cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _propChip() {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FF.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(_genPropImg!,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                    width: 34, height: 34, color: const Color(0xFF2A2030))),
          ),
          const SizedBox(width: 10),
          Text(_genPropLabel!,
              style: const TextStyle(
                  color: FF.gold, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(width: 6),
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 500.ms)
        .scaleXY(begin: 0.9, curve: Curves.easeOutBack);
  }

  // ───────────────────────── ③ 结局 ─────────────────────────
  Widget _endingView() {
    final isAi = _nodeId == 'e_ai';
    final end = isAi
        ? const _End('你的专属结局', 'AI 生成线 · 独一无二', '', [FF.teal, _cyan])
        : _nodes[_nodeId]!.ending!;
    final body = isAi ? _aiText : end.text;
    return Column(
      children: [
        _topRow(end.secret ? '稀有真结局' : '结局达成', FF.gold),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                  top: 6, right: 6, child: _AffinitySigil(value: _affinity)),
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
                  child: Column(
                    children: [
                      _endingPanel(end, body)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scaleXY(begin: 0.92, curve: Curves.easeOutBack),
                      const SizedBox(height: 12),
                      _historyDrawer()
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 450.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _endingPanel(_End end, String body) {
    return _Glass(
      radius: 26,
      blur: 24,
      color: _glassCard,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('你解锁了',
              style: TextStyle(
                  color: FF.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          const SizedBox(height: 8),
          _goldTitle(end.title, size: 30),
          const SizedBox(height: 8),
          Text(end.rarity,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.7,
                    fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 16),
          _endingMap(),
          const SizedBox(height: 12),
          Text('与米卡的心动值 · $_affinity',
              style: const TextStyle(
                  color: _cyan, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _BigButton(
            label: '继续寻找隐藏结局',
            icon: Icons.replay_rounded,
            height: 50,
            onTap: _start,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _ghostBtn(Icons.home_rounded, '回到开场', _exitToIntro)),
              const SizedBox(width: 10),
              Expanded(
                  child: _ghostBtn(Icons.ios_share_rounded, '分享结局',
                      () => showShareSheet(context, sceneLabel: end.title))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _endingMap() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final id in _endingOrder) ...[
          _endingDot(id),
          if (id != _endingOrder.last) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _endingDot(String id) {
    final current = id == _nodeId;
    final seen = _seen.contains(id);
    final secret = id == 'e_true';
    late final BoxDecoration deco;
    double size = 9;
    if (current) {
      size = 14;
      deco = BoxDecoration(
        shape: BoxShape.circle,
        color: _cyan,
        boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.62), blurRadius: 18)],
      );
    } else if (secret) {
      deco = const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [_pink, _purple]),
      );
    } else if (seen) {
      deco = const BoxDecoration(shape: BoxShape.circle, color: FF.gold);
    } else {
      deco = BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.26));
    }
    return Opacity(
      opacity: (secret && !seen) ? 0.72 : 1,
      child: Container(width: size, height: size, decoration: deco),
    );
  }

  Widget _historyDrawer() {
    return _Glass(
      radius: 22,
      blur: 18,
      color: const Color(0x14FFFFFF),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('分支记录 · BRANCH HISTORY',
              style: TextStyle(
                  color: FF.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          if (_history.isEmpty)
            Text('（这一条线没有岔路）',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          for (var i = 0; i < _history.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text('0${i + 1}',
                        style: const TextStyle(
                            color: FF.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ),
                  Expanded(
                    child: Text('${_history[i].$1} → ${_history[i].$2}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── 公共小部件 ─────────────────────────
  Widget _topRow(String chip, Color chipColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            // intro 阶段无内部可回退态 → 弹出整个路由回到角色星球（避免死路）
            onTap: _phase == _Phase.intro
                ? () => Navigator.of(context).maybePop()
                : _exitToIntro,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          _chapterChip(chip, chipColor),
        ],
      ),
    );
  }

  Widget _chapterChip(String text, Color color) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: color == _cyan
            ? [BoxShadow(color: _cyan.withValues(alpha: 0.18), blurRadius: 24)]
            : null,
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _branchTree() {
    final dots = <Widget>[];
    for (var i = 0; i < 5; i++) {
      double size = 9;
      late final BoxDecoration deco;
      if (i == 4) {
        deco = const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_pink, _purple]));
      } else if (i < _step) {
        deco = const BoxDecoration(shape: BoxShape.circle, color: FF.gold);
      } else if (i == _step) {
        size = 13;
        deco = BoxDecoration(
          shape: BoxShape.circle,
          color: _cyan,
          boxShadow: [
            BoxShadow(color: _cyan.withValues(alpha: 0.62), blurRadius: 16)
          ],
        );
      } else {
        deco = BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.26));
      }
      if (i > 0) dots.add(const SizedBox(width: 8));
      dots.add(Container(width: size, height: size, decoration: deco));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: dots);
  }
}

// ───────────────────────── 场景背景：静态帧 + 旋转影院光束 + scrim ─────────────────────────
class _SceneBackdrop extends StatelessWidget {
  final String asset;
  final List<Color> beams;
  final double opacity;
  const _SceneBackdrop(
      {required this.asset, required this.beams, this.opacity = 0.72});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, _, _) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [Color(0xFF17202B), Color(0xFF080A0E)],
              ),
            ),
          );
        }),
        Opacity(
          opacity: opacity,
          child: Center(
            child: SizedBox(
              width: 620,
              height: 620,
              child: CustomPaint(painter: _GlowPainter(beams)),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(
              begin: 0, end: 1, duration: 28.seconds),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66000000), Color(0x33000000), Color(0xCC05050A)],
              stops: [0.0, 0.42, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowPainter extends CustomPainter {
  final List<Color> colors;
  const _GlowPainter(this.colors);

  static const _starts = [0.0, 1.1, 2.2, 3.3, 4.4, 5.3];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.6;
    const sweep = 0.9;
    for (var i = 0; i < _starts.length; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: radius), _starts[i],
            sweep, false)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

// ───────────────────────── 心动印记（角标）─────────────────────────
class _AffinitySigil extends StatelessWidget {
  final int value;
  final int? delta;
  const _AffinitySigil({required this.value, this.delta});

  @override
  Widget build(BuildContext context) {
    final rising = delta != null && delta! != 0;
    final label = rising
        ? '${delta! > 0 ? '+' : ''}$delta'
        : '$value';
    Widget sigil = Container(
      width: 60,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                  colors: [_cyan, _pink, _blue, _cyan]),
              boxShadow: [
                BoxShadow(color: _cyan.withValues(alpha: 0.4), blurRadius: 16)
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.92, end: 1.06, duration: 1500.ms),
          const SizedBox(height: 4),
          const Text('米卡',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: _cyan, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
    if (rising) {
      sigil = sigil
          .animate(onPlay: (c) => c.repeat())
          .moveY(begin: 0, end: -4, duration: 800.ms, curve: Curves.easeInOut)
          .then()
          .moveY(begin: 0, end: 4, duration: 800.ms, curve: Curves.easeInOut);
    }
    return sigil;
  }
}

// ───────────────────────── AI conic 旋转球 ─────────────────────────
class _ConicOrb extends StatelessWidget {
  const _ConicOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 184,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ① 软外晕：大范围径向辉光，无硬边，缓慢呼吸（缩放 + 透明度）
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _cyan.withValues(alpha: 0.30),
                  _pink.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.82,
                  end: 1.12,
                  duration: 2600.ms,
                  curve: Curves.easeInOut)
              .fade(
                  begin: 0.5,
                  end: 1.0,
                  duration: 2600.ms,
                  curve: Curves.easeInOut),
          // ② 缓旋柔色环：模糊的 sweep，转得慢，像流动的极光（不再是硬边光环）
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    _cyan.withValues(alpha: 0.75),
                    _purple.withValues(alpha: 0.55),
                    _pink.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(
              begin: 0, end: 1, duration: 9.seconds),
          // ③ 毛玻璃盘：把背后的星云和色环柔柔地虚化进来
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 122,
                height: 122,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
              ),
            ),
          ),
          // ④ 内核辉光：亮心向外淡出（无实心盘），呼吸
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  _cyan.withValues(alpha: 0.55),
                  _purple.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.34, 0.62, 1.0],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.88,
                  end: 1.08,
                  duration: 1500.ms,
                  curve: Curves.easeInOut)
              .fade(
                  begin: 0.72,
                  end: 1.0,
                  duration: 1500.ms,
                  curve: Curves.easeInOut),
          // ⑤ 错峰闪烁的火花（闪光感）
          for (var i = 0; i < 3; i++)
            Align(
              alignment: const [
                Alignment(0.62, -0.5),
                Alignment(-0.58, 0.46),
                Alignment(0.22, 0.68),
              ][i],
              child: Icon(Icons.auto_awesome,
                      size: const [11.0, 8.0, 9.0][i],
                      color: i.isEven ? _cyan : Colors.white)
                  .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                      delay: (420 * i).ms)
                  .fade(begin: 0.0, end: 1.0, duration: 900.ms)
                  .scaleXY(begin: 0.5, end: 1.0, duration: 900.ms),
            ),
          // ⑥ AI 字：白色发光，不再黑实心
          Text('AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                            color: _cyan.withValues(alpha: 0.9),
                            blurRadius: 18),
                        const Shadow(color: Colors.black54, blurRadius: 6),
                      ]))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.78, end: 1.0, duration: 1500.ms),
        ],
      ),
    );
  }
}

// ───────────────────────── spell lines（生成进度光条）─────────────────────────
class _SpellLines extends StatelessWidget {
  const _SpellLines();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            )
                .animate(onPlay: (c) => c.repeat(), delay: (160 * i).ms)
                .shimmer(
                    duration: 1200.ms,
                    color: _cyan,
                    angle: 0),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── 中心决策核（选择态）─────────────────────────
// 旋转 sweep 光环 + 径向核 + auto_awesome，外层缓慢呼吸——光丝从这里发散到各选项。
class _DecisionCore extends StatelessWidget {
  const _DecisionCore();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [Colors.transparent, _cyan, _pink, _blue, Colors.transparent],
              ),
              boxShadow: [
                BoxShadow(color: _cyan.withValues(alpha: 0.3), blurRadius: 28)
              ],
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(
              begin: 0, end: 1, duration: 6.seconds),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFEAF7FF), Color(0xFF8C64FF), Color(0xE608070D)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Color(0xFF071014), size: 14),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.92, end: 1.08, duration: 1400.ms, curve: Curves.easeInOut);
  }
}

// ───────────────────────── 光丝：决策核 → 各选项（选择态）─────────────────────────
class _FilamentPainter extends CustomPainter {
  final Offset core;
  final List<Offset> targets;
  const _FilamentPainter({required this.core, required this.targets});

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in targets) {
      final mid = Offset((core.dx + t.dx) / 2,
          (core.dy + t.dy) / 2 - (t.dy - core.dy).abs() * 0.18 - 24);
      final path = Path()
        ..moveTo(core.dx, core.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, t.dx, t.dy);
      // 外发光
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = _cyan.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glow);
      // 细光线（渐变）
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          colors: [_cyan.withValues(alpha: 0.7), _pink.withValues(alpha: 0.32)],
        ).createShader(Rect.fromPoints(core, t));
      canvas.drawPath(path, line);
      // 选项端节点
      canvas.drawCircle(
          t,
          3,
          Paint()
            ..color = _cyan.withValues(alpha: 0.9)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
    // 核心微光
    canvas.drawCircle(
        core,
        22,
        Paint()
          ..color = _purple.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
  }

  @override
  bool shouldRepaint(covariant _FilamentPainter old) =>
      old.core != core || old.targets != targets;
}

// ───────────────────────── 放射光线爆发（生成态·光芒万丈）─────────────────────────
class _RayBurst extends StatelessWidget {
  const _RayBurst();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 径向闪光底：柔柔呼吸（缩放 + 透明度）
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _cyan.withValues(alpha: 0.24),
                  _pink.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  begin: 0.82,
                  end: 1.08,
                  duration: 2200.ms,
                  curve: Curves.easeInOut)
              .fade(
                  begin: 0.55,
                  end: 1.0,
                  duration: 2200.ms,
                  curve: Curves.easeInOut),
          // 柔光线：慢转 + 整体明暗呼吸（不再是硬实的放射线）
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(painter: _RayPainter()),
          )
              .animate(onPlay: (c) => c.repeat())
              .rotate(begin: 0, end: 1, duration: 26.seconds)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(
                  begin: 0.45,
                  end: 1.0,
                  duration: 2400.ms,
                  curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class _RayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const inner = 62.0;
    final maxOuter = size.width / 2;
    const n = 18;
    var s = 1234567;
    double rnd() {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      return s / 0x7fffffff;
    }

    for (var i = 0; i < n; i++) {
      final a = (i / n) * 2 * math.pi;
      final dir = Offset(math.cos(a), math.sin(a));
      // 长短不一，少了机械的整齐感
      final outer = inner + (maxOuter - inner) * (0.5 + rnd() * 0.5);
      final p1 = center + dir * inner;
      final p2 = center + dir * outer;
      final color = i.isEven ? _cyan : _pink;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i.isEven ? 2.4 : 1.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.22), Colors.transparent],
        ).createShader(Rect.fromPoints(p1, p2))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RayPainter old) => false;
}

// ──────────────────── AI 思考态 · 专属 CG 背景 ────────────────────
/// 铺满屏的电影级动态背景：竖向星云渐变 + 缓旋星云光晕 + 斜扫体积光束
/// + 双层漂浮 bokeh 光斑 + 细颗粒噪点。不依赖任何视频帧，纯手绘可控。
class _AiThinkingBackdrop extends StatelessWidget {
  const _AiThinkingBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ① 竖向星云底：深紫 → 紫红 → 洋红黑 → 近黑
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1B0B33),
                Color(0xFF3A1145),
                Color(0xFF160516),
                Color(0xFF05030A),
              ],
              stops: [0.0, 0.34, 0.72, 1.0],
            ),
          ),
        ),
        // ② 缓慢旋转的星云光晕（重度模糊的彩色扇形）
        Center(
          child: SizedBox(
            width: 760,
            height: 760,
            child: CustomPaint(
              painter:
                  _GlowPainter(const [_purple, _pink, _blue, _purple, _cyan, _pink]),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(
              begin: 0, end: 1, duration: 44.seconds),
        ),
        // ③ 斜扫体积光束（左右极缓来回扫）
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: const _BeamSweepPainter())
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(
                    begin: -36,
                    end: 36,
                    duration: 7.seconds,
                    curve: Curves.easeInOut),
          ),
        ),
        // ④ 远层 bokeh：小、暗、慢飘
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
                    painter: const _BokehPainter(
                        seed: 11, count: 16, maxR: 30, alpha: 0.14))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    begin: 10,
                    end: -10,
                    duration: 9.seconds,
                    curve: Curves.easeInOut),
          ),
        ),
        // ⑤ 近层 bokeh：大、亮、稍快
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
                    painter: const _BokehPainter(
                        seed: 29, count: 9, maxR: 58, alpha: 0.20))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    begin: -14,
                    end: 14,
                    duration: 6.seconds,
                    curve: Curves.easeInOut),
          ),
        ),
        // ⑥ 细颗粒噪点（静态，加电影质感）
        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _GrainPainter())),
        ),
        // ⑦ 上下压暗，保证中部台词 + 底部 chip 可读
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x55000000), Color(0x1A000000), Color(0xDD05030A)],
              stops: [0.0, 0.42, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// 斜扫的体积光束：几条沿对角线的柔光带。
class _BeamSweepPainter extends CustomPainter {
  const _BeamSweepPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.42);
    canvas.rotate(-0.52); // ≈ -30°
    final h = size.height * 1.9;
    final bands = <(double, double, Color, double)>[
      (-size.width * 0.42, 64, _cyan, 0.10),
      (0.0, 128, _pink, 0.085),
      (size.width * 0.44, 52, _blue, 0.10),
    ];
    for (final (cx, w, color, a) in bands) {
      final rect = Rect.fromCenter(center: Offset(cx, 0), width: w, height: h);
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, color.withValues(alpha: a), Colors.transparent],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawRect(rect, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeamSweepPainter old) => false;
}

/// 漂浮的 bokeh 光斑：确定性随机分布的柔光圆。
class _BokehPainter extends CustomPainter {
  final int seed;
  final int count;
  final double maxR;
  final double alpha;
  const _BokehPainter(
      {required this.seed,
      required this.count,
      required this.maxR,
      required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    var s = (seed * 2654435761) & 0x7fffffff;
    double rnd() {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      return s / 0x7fffffff;
    }

    const palette = [_pink, _cyan, _purple, _blue];
    for (var i = 0; i < count; i++) {
      final cx = rnd() * size.width;
      final cy = rnd() * size.height;
      final r = maxR * (0.42 + rnd() * 0.58);
      final color = palette[(i + (rnd() * 4).floor()) % palette.length];
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.45);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BokehPainter old) => false;
}

/// 细颗粒噪点：满屏低透明小点，给画面加一层胶片质感。
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    var s = 99991;
    double rnd() {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      return s / 0x7fffffff;
    }

    final pts = <Offset>[
      for (var i = 0; i < 540; i++)
        Offset(rnd() * size.width, rnd() * size.height),
    ];
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, pts, paint);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}

// ──────────────── AI 思考态 · 概念二：极简白底 + 凸起星 ────────────────
class _MinimalThinkingBackdrop extends StatelessWidget {
  const _MinimalThinkingBackdrop();

  @override
  Widget build(BuildContext context) {
    // 微弱径向：中心略亮、四周略沉，给凸起星留出立体的光位。
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.12),
          radius: 1.18,
          colors: [Color(0xFFEAE7F3), Color(0xFFC9C7D9)],
        ),
      ),
    );
  }
}

/// 四角星（AI 标志）路径：四个外尖 + 向心收腰的凹边。
Path _sparklePath(Offset c, double r, double waist) {
  final pts = [
    Offset(c.dx, c.dy - r), // 上
    Offset(c.dx + r, c.dy), // 右
    Offset(c.dx, c.dy + r), // 下
    Offset(c.dx - r, c.dy), // 左
  ];
  final ctrl = [
    Offset(c.dx + waist, c.dy - waist),
    Offset(c.dx + waist, c.dy + waist),
    Offset(c.dx - waist, c.dy + waist),
    Offset(c.dx - waist, c.dy - waist),
  ];
  final p = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < 4; i++) {
    final next = pts[(i + 1) % 4];
    p.quadraticBezierTo(ctrl[i].dx, ctrl[i].dy, next.dx, next.dy);
  }
  return p..close();
}

/// 凸起、有质感的四角星：双向投影（左上高光 / 右下暗影）+ 斜向渐变体 + 边缘反光。
class _EmbossedStarPainter extends CustomPainter {
  const _EmbossedStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.46;
    final waist = r * 0.17;
    final path = _sparklePath(c, r, waist);

    // ① 右下暗影（略加深、外扩，让凸起更明显）
    canvas.drawPath(
      path.shift(const Offset(8, 11)),
      Paint()
        ..color = const Color(0x40221C3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    // ② 左上高光
    canvas.drawPath(
      path.shift(const Offset(-7, -9)),
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    // ③ 主体：左上亮 → 右下暗 的斜向渐变（凸起立体感，带一丝冷紫调）
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEDECF7), Color(0xFFCFCDE2)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    // ④ 边缘薄反光
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
    // ⑤ 中心一点冷色微光（极淡的品牌气息）
    canvas.drawCircle(
      c,
      r * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [_cyan.withValues(alpha: 0.16), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.5)),
    );
  }

  @override
  bool shouldRepaint(covariant _EmbossedStarPainter old) => false;
}

// ───────────────────────── 通用毛玻璃 ─────────────────────────
class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsets padding;
  final Color color;
  const _Glass({
    required this.child,
    this.radius = 20,
    this.blur = 16,
    this.padding = const EdgeInsets.all(16),
    this.color = const Color(0x40121820),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget _goldTitle(String text, {double size = 28}) {
  return ShaderMask(
    shaderCallback: (r) => const LinearGradient(
      colors: [FF.brightGold, Color(0xFFF6E3A6), FF.gold],
    ).createShader(r),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ───────────────────────── 通用按钮 ─────────────────────────
class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  const _BigButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_pink, _purple, _blue]),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
                color: _pink.withValues(alpha: 0.34),
                blurRadius: 26,
                offset: const Offset(0, 9)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

Widget _ghostBtn(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    ),
  );
}

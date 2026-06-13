import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../app_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/support_store.dart';
import '../models/short_drama.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'ai_ranking_screen.dart';
import 'character_detail_screen.dart';
import 'character_universe_intro_screen.dart';
import 'detail_screen.dart';
import 'interactive_player_screen.dart';
import 'spark_screen.dart';

/// AI 互动 · 角色星球（招牌核心功能落地页 / v0 框架壳）。
/// 一级 = 「角色星云」：数字人发光头像锚在一个松散的星座阵里，只在小范围内轻轻游离
/// （有规矩撑着、不到处乱跑、所以黑缝少、头像能做大）；每次进来谁落哪格是随机的。
/// 系统自动轮流给某个角色打聚光：缓慢放大到约 2 倍、把旁边挤开、停留约 3 秒、再慢慢缩回。
/// 也可以摁住头像拖动、把别人挤开；点一下进二级详情（才有实名应援榜）。
/// 应援热度 = 绕头像外圈的发光弧环（满圈=100%），顶部小火苗+数字点题。
/// 名字压在头像底部；人设标签不在这儿露，点进去才有。
/// 同屏必须有真实剧集：已上线剧 + 候选剧 + 一部可玩样板剧（接现有互动剧 demo）。
/// v0 全是本地 mock，不接后端/LLM/计费。
class AiInteractiveScreen extends StatefulWidget {
  const AiInteractiveScreen({super.key});

  @override
  State<AiInteractiveScreen> createState() => _AiInteractiveScreenState();
}

class _AiInteractiveScreenState extends State<AiInteractiveScreen> {
  String? _speakingId; // 当前正在「说话」的角色（摁住触发，几秒后自动收起）
  Timer? _speakTimer;

  // 先用包内角色秒开（图片是本地资源，无需等网），服务端清单到了再静默替换文案/介绍视频。
  List<AiCharacter> _characters = kCharacters;

  // 「在播 & 候选剧」横滑用真实剧集（同剧场一套接口/详情/播放，点进去真能看）。
  List<ShortDrama> _dramas = [];
  bool _dramasLoading = true;

  @override
  void initState() {
    super.initState();
    Api.aiCharacters().then((list) {
      if (mounted && list.isNotEmpty) setState(() => _characters = list);
    });
    // 拉真实出道热度榜→填 supportStore：头顶"应援值"/进度环显示真数据，送礼后实时涨。
    Api.giftCharRank().then((rows) => supportStore.applyCharRank(rows)).catchError((_) {});
    _loadDramas();
  }

  Future<void> _loadDramas() async {
    try {
      final items = kUseLocalTestFeed
          ? await Api.getTestShortList()
          : await Api.getShortList(pageNum: 1, pageSize: 12);
      if (!mounted) return;
      setState(() {
        _dramas = items;
        _dramasLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _dramasLoading = false); // 拉不到就只剩互动样板，不空屏、不死页
    }
  }

  @override
  void dispose() {
    _speakTimer?.cancel();
    super.dispose();
  }

  void _speak(String id) {
    _speakTimer?.cancel();
    setState(() => _speakingId = id);
    _speakTimer = Timer(const Duration(milliseconds: 3600), () {
      if (mounted) setState(() => _speakingId = null);
    });
  }

  void _openCharacter(AiCharacter c) {
    _speakTimer?.cancel();
    setState(() => _speakingId = null);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CharacterDetailScreen(character: c),
    ));
  }

  void _openIntro() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const CharacterUniverseIntroScreen(),
    ));
  }

  void _openRanking() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AiRankingScreen(characters: _characters),
    ));
  }

  // 互动样板：进 manifest 驱动的互动剧 demo（树状播放器 + 收费埋点 + 结局图鉴）。
  // 喂的是包内 demo manifest《最后一通电话》；上线换 /interactive/import 写库的真 manifest。
  void _openInteractive() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const InteractivePlayerScreen(),
    ));
  }

  // 真实剧集：进剧场同款详情页（选集/解锁/播放），真能看片。
  void _openDramaReal(ShortDrama d) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetailScreen(
        shortId: d.id,
        title: d.name,
        cover: d.image,
        intro: d.introduce,
        price: d.price,
        labels: d.labels,
        plays: d.playCount + d.likeCount,
        videoUrl: d.videoUrl,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(),
                _sparkEntry(), // AI 客串入口（用户反馈角色页找不到 Spark，补在这）
                // 角色星云舞台：占满中间所有剩余空间，绝不留黑缝
                Expanded(
                  // 监听 supportStore：送礼后真实应援值/进度即时刷新到头顶。
                  child: ListenableBuilder(
                    listenable: supportStore,
                    builder: (_, _) => _Constellation(
                      characters: _characters,
                      speakingId: _speakingId,
                      onOpen: _openCharacter,
                      onSpeak: _speak,
                    ),
                  ),
                ),
                SectionHeader(AppLocalizations.of(context).cast_sectionPlaying,
                    action: AppLocalizations.of(context).cast_oppRanking,
                    onAction: _openRanking),
                _dramaRail(),
                const SizedBox(height: 96), // 给底部导航留位
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSpark() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const SparkScreen()));

  // AI 客串入口卡（用户反馈角色页没 Spark 入口，补在 header 下）。
  Widget _sparkEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
      child: Bounce(
        onTap: _openSpark,
        child: Glass(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    gradient: FF.goldGradient, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF3A2700), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Cameo',
                        style: TextStyle(
                            color: FF.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                    SizedBox(height: 2),
                    Text('Upload a selfie — star in your own poster',
                        style: TextStyle(color: FF.dim, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: FF.dim, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── 顶部「角色元宇宙」入口（点进单独介绍页，不在这儿占地方）─────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Bounce(
        onTap: _openIntro,
        child: Glass(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: FF.brandGradient,
                  boxShadow: [
                    BoxShadow(
                        color: FF.purple.withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 1),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    gradientText(AppLocalizations.of(context).cast_universeTitle,
                        size: 19, gradient: FF.brandGradient),
                    const SizedBox(height: 3),
                    Text(AppLocalizations.of(context).cast_universeSub,
                        style: const TextStyle(
                            color: FF.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: FF.dim, size: 24),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, curve: Curves.easeOut),
    );
  }

  // ───────── 真实剧集横滑（互动样板 + 真能看的在播剧）─────────
  Widget _dramaRail() {
    // 第一张永远是互动样板（招牌玩法），后面跟真实剧；真实剧没回来时垫骨架占位。
    final cards = <Widget>[
      _ShowcaseCard(onTap: _openInteractive),
      for (final d in _dramas)
        _RealDramaCard(drama: d, onTap: () => _openDramaReal(d)),
      if (_dramasLoading && _dramas.isEmpty) ...[
        const _SkeletonCard(),
        const _SkeletonCard(),
      ],
    ];
    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => cards[i]
            .animate(delay: (70 * i + 100).ms)
            .fadeIn(duration: 440.ms)
            .slideX(begin: 0.14, curve: Curves.easeOut),
      ),
    );
  }
}

// ───────────────────────── 角色星云（固定网格 + 蛇形顺序聚光 + 邻居成比例缩小让位）─────────────────────────
class _Orb {
  final Offset anchor; // 固定网格位（不动，保持队形）
  final int row;
  final int col;
  double scale = 1; // 当前视觉缩放（聚光放大 / 被聚光邻居缩小）
  Offset pos = Offset.zero; // 渲染位（=anchor，聚光时夹边防出屏）
  _Orb({required this.anchor, required this.row, required this.col});
}

class _Constellation extends StatefulWidget {
  final List<AiCharacter> characters;
  final String? speakingId;
  final void Function(AiCharacter) onOpen;
  final void Function(String id) onSpeak;
  const _Constellation({
    required this.characters,
    required this.speakingId,
    required this.onOpen,
    required this.onSpeak,
  });

  @override
  State<_Constellation> createState() => _ConstellationState();
}

class _ConstellationState extends State<_Constellation>
    with SingleTickerProviderStateMixin {
  static const double _r = 48; // 头像球基础半径（直径 96）
  static const int _cols = 3;
  static const double _focusScale = 1.85; // 聚光放大≈2倍，明显
  static const double _minNeighbor = 0.55; // 邻居被聚光时缩到的最小倍数（让位，不硬挤）
  static const double _growDur = 1.5; // 初次慢放大
  static const double _holdDur = 2.0; // 停留
  static const double _handoffDur = 1.8; // 交接：当前慢缩 + 下一个同步慢放（重叠）
  static const int _pGrow = 0, _pHold = 1, _pHandoff = 2;
  final _rng = Random();

  late final Ticker _ticker;
  Size _arena = Size.zero;
  List<_Orb> _orbs = [];
  bool _seeded = false;

  // 随机聚光：当前球放大→停→交接给下一个随机球（下一个一定 ≠ 当前，不会原地不动）
  int _curr = 0;
  int _next = -1;
  int _phase = _pGrow;
  double _phaseT = 0;

  int? _held; // 手指按住的球（按住时暂停聚光巡游 + 弹台词）
  Offset _downPos = Offset.zero;
  int _downMs = 0;

  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Constellation old) {
    super.didUpdateWidget(old);
    // 服务端清单替换后角色数量变了（如后台新增角色）才重新布阵；
    // 数量不变（9→9，常态）则保持队形不动，避免视觉跳变。
    if (widget.characters.length != _orbs.length && _arena != Size.zero) {
      _seed();
    }
  }

  // 固定网格阵：3 列；角色随机落格（位置随机、但队形固定不动，靠缩放突出聚光）。
  void _seed() {
    final w = _arena.width, h = _arena.height;
    final n = widget.characters.length;
    final rows = (n + _cols - 1) ~/ _cols;

    final cellAnchor = <Offset>[];
    final cellRow = <int>[];
    final cellCol = <int>[];
    for (int r = 0; r < rows; r++) {
      final inRow = (r == rows - 1) ? n - r * _cols : _cols;
      final lead = (_cols - inRow) / 2.0; // 不满的行居中
      for (int j = 0; j < inRow; j++) {
        final xFrac =
            (_cols == 1) ? 0.5 : 0.16 + (0.68 / (_cols - 1)) * (lead + j);
        final yFrac = (rows == 1) ? 0.5 : 0.17 + (0.66 / (rows - 1)) * r;
        cellAnchor.add(Offset(
            (w * xFrac).clamp(_r, w - _r), (h * yFrac).clamp(_r, h - _r)));
        cellRow.add(r);
        cellCol.add(j);
      }
    }

    // 角色随机落格
    final perm = List.generate(n, (i) => i)..shuffle(_rng);
    _orbs = List.generate(n, (i) {
      final cell = perm[i];
      return _Orb(
          anchor: cellAnchor[cell], row: cellRow[cell], col: cellCol[cell]);
    });
    _curr = _rng.nextInt(n);
    _next = -1;
    _phase = _pGrow;
    _phaseT = 0;
  }

  void _tick(Duration now) {
    if (!_seeded || _arena == Size.zero) {
      _last = now;
      return;
    }
    double dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (dt <= 0 || dt > 0.05) dt = 0.016; // 离屏被 TickerMode 暂停回来的大跳跃，钳一下
    _recompute(dt);
    setState(() {});
  }

  double _ease(double t, double d) {
    final c = (t / d).clamp(0.0, 1.0);
    return c * c * (3 - 2 * c); // smoothstep
  }

  // 下一个聚光：随机，且一定 ≠ 当前（不会原地放大不动）
  int _pickNext(int curr) {
    final n = _orbs.length;
    if (n <= 1) return curr;
    int k = _rng.nextInt(n - 1);
    if (k >= curr) k += 1; // 跳过 curr，等概率落在其余 n-1 个
    return k;
  }

  // 网格相邻权重：正交相邻=1，斜对角=0.7，其余=0（决定被聚光时谁要让位缩小）
  double _adjWeight(_Orb a, _Orb b) {
    final dr = (a.row - b.row).abs();
    final dc = (a.col - b.col).abs();
    if (dr == 0 && dc == 0) return 0;
    if (dr <= 1 && dc <= 1) return (dr + dc == 1) ? 1.0 : 0.7;
    return 0;
  }

  void _recompute(double dt) {
    final n = _orbs.length;
    if (n == 0) return;
    final w = _arena.width, h = _arena.height;

    // 1) 推进状态机：放大 → 停 → 交接(当前慢缩 + 下一个随机球慢放)
    if (_held == null) {
      _phaseT += dt;
      switch (_phase) {
        case _pGrow:
          if (_phaseT >= _growDur) {
            _phase = _pHold;
            _phaseT = 0;
          }
          break;
        case _pHold:
          if (_phaseT >= _holdDur) {
            _next = _pickNext(_curr);
            _phase = _pHandoff;
            _phaseT = 0;
          }
          break;
        case _pHandoff:
          if (_phaseT >= _handoffDur) {
            _curr = _next;
            _next = -1;
            _phase = _pHold;
            _phaseT = 0;
          }
          break;
      }
    }

    // 2) 每个球的聚光强度
    final spot = List<double>.filled(n, 0);
    switch (_phase) {
      case _pGrow:
        spot[_curr] = _ease(_phaseT, _growDur);
        break;
      case _pHold:
        spot[_curr] = 1.0;
        break;
      case _pHandoff:
        final f = _ease(_phaseT, _handoffDur);
        spot[_curr] = 1.0 - f; // 当前慢缩
        if (_next >= 0) spot[_next] = f; // 下一个同步慢放
        break;
    }

    // 3) 缩放 = 自己放大 × 邻居让位缩小（队形固定不动，不硬挤）
    for (int i = 0; i < n; i++) {
      final grow = 1 + spot[i] * (_focusScale - 1);
      double pressure = 0;
      for (int j = 0; j < n; j++) {
        if (j == i) continue;
        final wgt = _adjWeight(_orbs[i], _orbs[j]);
        if (wgt <= 0) continue;
        final p = spot[j] * wgt;
        if (p > pressure) pressure = p;
      }
      final shrink = 1 + (_minNeighbor - 1) * pressure; // lerp(1, minNeighbor, pressure)
      _orbs[i].scale = grow * shrink;

      // 渲染位 = 锚点；只有被放大的球夹一下边界防出屏（其余锚点已内缩，不会动）
      final r = _r * _orbs[i].scale;
      final a = _orbs[i].anchor;
      _orbs[i].pos = Offset(a.dx.clamp(r, w - r), a.dy.clamp(r, h - r));
    }
  }

  int? _hit(Offset p) {
    int? best;
    double bestD = 1e9;
    for (int i = 0; i < _orbs.length; i++) {
      final d = (_orbs[i].pos - p).distance;
      final rr = _r * _orbs[i].scale + 6;
      if (d < rr && d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  void _onDown(PointerDownEvent e) {
    final i = _hit(e.localPosition);
    if (i == null) return;
    _held = i; // 按住期间暂停巡游
    _downPos = e.localPosition;
    _downMs = DateTime.now().millisecondsSinceEpoch;
    setState(() {});
  }

  void _onUp(PointerUpEvent e) {
    if (_held == null) return;
    final i = _held!;
    final dur = DateTime.now().millisecondsSinceEpoch - _downMs;
    final moved = (e.localPosition - _downPos).distance;
    final c = widget.characters[i];
    if (moved < 12 && dur < 320) {
      widget.onOpen(c); // 轻点 = 进详情
    } else if (moved < 12) {
      widget.onSpeak(c.id); // 摁住没动 = 说一句台词
    }
    _held = null;
    setState(() {});
  }

  void _onCancel(PointerCancelEvent e) {
    _held = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final size = Size(box.maxWidth, box.maxHeight);
      if (size.width > 0 && size.height > 0) {
        _arena = size;
        if (!_seeded) {
          _seed();
          _seeded = true;
        }
      }
      final speakingId = widget.speakingId;
      // 按缩放从小到大排序绘制 → 最大的（聚光球）最后画 = 永远在最上层，
      // 它的光环稳定盖住旁边缩小的邻居（不会有的邻居跑到光环上面）
      final zOrder = [for (int i = 0; i < _orbs.length; i++) i]
        ..sort((a, b) => _orbs[a].scale.compareTo(_orbs[b].scale));
      return Listener(
        onPointerDown: _onDown,
        onPointerUp: _onUp,
        onPointerCancel: _onCancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            for (final i in zOrder)
              Positioned(
                key: ValueKey(widget.characters[i].id),
                left: _orbs[i].pos.dx - _r,
                top: _orbs[i].pos.dy - _r,
                width: 2 * _r,
                height: 2 * _r,
                child: Transform.scale(
                  scale: _orbs[i].scale,
                  child: _orbVisual(widget.characters[i],
                      active: _orbs[i].scale > 1.05),
                ),
              ),
            // 说话气泡：贴在对应球上方
            for (int i = 0; i < _orbs.length; i++)
              if (speakingId == widget.characters[i].id)
                Positioned(
                  left: (_orbs[i].pos.dx - 92)
                      .clamp(2.0, max(2.0, _arena.width - 186)),
                  top: (_orbs[i].pos.dy - _r * _orbs[i].scale - 60)
                      .clamp(0.0, _arena.height),
                  width: 184,
                  child: _SpeechBubble(
                      text: widget.characters[i].greeting,
                      accent: widget.characters[i].aura.first),
                ),
          ],
        ),
      );
    });
  }

  // 单个头像球：柔光底 + 应援热度弧环 + 头像(底部压名字) + 顶部火苗热度
  Widget _orbVisual(AiCharacter c, {required bool active}) {
    const d = 2 * _r;
    const avatarD = 2 * _r - 16;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 背后柔光
          Container(
            width: d - 6,
            height: d - 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: c.aura.first.withValues(alpha: active ? 0.55 : 0.4),
                    blurRadius: active ? 34 : 26,
                    spreadRadius: 1),
              ],
            ),
          ),
          // 应援热度弧环（满圈=100%，剩下暗）
          CustomPaint(
            size: const Size(d, d),
            painter: _RingPainter(supportStore.progressFor(c), c.aura),
          ),
          // 头像 + 底部名字
          Container(
            width: avatarD,
            height: avatarD,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xCC0B0913),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.30), width: 1.4),
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  c.avatarHead == null
                      ? Center(child: _emojiFace(c, 36))
                      : Image.asset(c.avatarHead!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Center(child: _emojiFace(c, 36))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(6, 9, 6, 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.66),
                          ],
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(c.name,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black)
                                ])),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 顶部「火苗 + 热度数字」（点明这道弧 = 应援热度）
          Positioned(top: -3, child: _heatChip(c)),
        ],
      ),
    );
  }

  Widget _heatChip(AiCharacter c) {
    final cheer = supportStore.charTotalFor(c); // 真实应援值，送礼后实时涨
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xE60B0913),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: c.aura.first.withValues(alpha: 0.55), width: 1),
        boxShadow: [
          BoxShadow(color: c.aura.first.withValues(alpha: 0.35), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              size: 11, color: c.aura.last),
          const SizedBox(width: 2),
          Text(fmtCoins(cheer),
              style: TextStyle(
                  color: c.aura.first,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  height: 1.0)),
        ],
      ),
    );
  }

  // 真立绘未到位 / 加载失败时的占位脸（英文首字母 + 角色光晕渐变）。
  Widget _emojiFace(AiCharacter c, double size) {
    return ShaderMask(
      shaderCallback: (r) => LinearGradient(colors: c.aura).createShader(r),
      child: Text(c.emoji,
          style: TextStyle(
              color: Colors.white,
              fontSize: size,
              fontWeight: FontWeight.w900,
              height: 1.0)),
    );
  }
}

// 应援热度弧环：12 点钟起顺时针填，满圈闭合；剩余部分暗轨；末端有彗星头亮点
class _RingPainter extends CustomPainter {
  final double value;
  final List<Color> aura;
  _RingPainter(this.value, this.aura);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const stroke = 5.0;
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final v = value.clamp(0.0, 1.0);

    // 暗轨（剩下的部分）
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawArc(rect, 0, 2 * pi, false, track);

    final sweep = 2 * pi * v;
    final colors = aura.length >= 2 ? aura : [aura.first, aura.first];
    final shader = SweepGradient(
      colors: colors,
      transform: const GradientRotation(-pi / 2),
    ).createShader(rect);

    // 柔光
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 3
      ..strokeCap = StrokeCap.round
      ..shader = shader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawArc(rect, -pi / 2, sweep, false, glow);

    // 实弧
    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    canvas.drawArc(rect, -pi / 2, sweep, false, prog);

    // 末端亮点（未满时）
    if (v > 0 && v < 1) {
      final ang = -pi / 2 + sweep;
      final tip = center + Offset(cos(ang), sin(ang)) * radius;
      canvas.drawCircle(
          tip,
          stroke * 1.7,
          Paint()
            ..color = aura.last.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(tip, stroke * 0.85, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.aura != aura;
}

// 摁住角色弹出的台词气泡（毛玻璃）
class _SpeechBubble extends StatelessWidget {
  final String text;
  final Color accent;
  const _SpeechBubble({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 16,
      blur: 18,
      color: const Color(0xE60B0913),
      border: accent.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w700)),
    )
        .animate()
        .fadeIn(duration: 240.ms)
        .scaleXY(begin: 0.85, alignment: Alignment.bottomCenter, curve: Curves.easeOutBack);
  }
}

// ───────────────────────── 剧集卡 ─────────────────────────
const double _kCardW = 124;
const double _kPosterH = 150;

String _heatText(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

// 互动样板剧：招牌玩法入口（永远排第一张），渐变封面 + 大播放钮 + 「可玩」徽。
class _ShowcaseCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ShowcaseCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: SizedBox(
        width: _kCardW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _kPosterH,
              width: _kCardW,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FF.hot, FF.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: FF.purple.withValues(alpha: 0.42),
                      blurRadius: 24,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 8,
                    child: _badge(AppLocalizations.of(context).cast_demoBadge, const Color(0xCC000000)),
                  ),
                  Center(
                    child: const Icon(Icons.play_circle_fill_rounded,
                            color: Colors.white, size: 46)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                            begin: 1,
                            end: 1.12,
                            duration: 1400.ms,
                            curve: Curves.easeInOut),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).cast_demoTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: FF.text, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(AppLocalizations.of(context).cast_demoSub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: FF.dim, fontSize: 11, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// 真实在播剧：真海报 + 暗角 + 「在播」徽 + 角标播放钮；点开走真正的详情/播放。
class _RealDramaCard extends StatelessWidget {
  final ShortDrama drama;
  final VoidCallback onTap;
  const _RealDramaCard({required this.drama, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = drama;
    final l = AppLocalizations.of(context);
    final heat = _heatText(d.playCount + d.likeCount);
    final tag = d.labels.isNotEmpty ? d.labels.first : '';
    final sub = tag.isEmpty ? l.cast_heatOnlyFmt(heat) : l.cast_heatTagFmt(heat, tag);
    return Bounce(
      onTap: onTap,
      child: SizedBox(
        width: _kCardW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _kPosterH,
              width: _kCardW,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: FF.purple.withValues(alpha: 0.26),
                      blurRadius: 22,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (d.image.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: d.image,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: const Color(0xFF201A15)),
                        errorWidget: (_, _, _) =>
                            Container(color: const Color(0xFF201A15)),
                      )
                    else
                      Container(color: const Color(0xFF201A15)),
                    // 底部暗角，压住封面让标题/角标看得清
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x99000000)],
                          stops: [0.55, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _badge(l.cast_inPlay, FF.hot.withValues(alpha: 0.92)),
                    ),
                    const Positioned(
                      right: 7,
                      bottom: 7,
                      child: Icon(Icons.play_circle_fill_rounded,
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(d.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: FF.text, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: FF.dim, fontSize: 11, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// 真实剧还没拉回来时的占位骨架（淡淡呼吸），不空屏。
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
          ),
        );
    return SizedBox(
      width: _kCardW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: _kPosterH,
            width: _kCardW,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 8),
          bar(_kCardW, 14),
          const SizedBox(height: 4),
          bar(_kCardW * 0.7, 11),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
        begin: 0.45, duration: 900.ms, curve: Curves.easeInOut);
  }
}

Widget _badge(String text, Color bg) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(text,
        style: const TextStyle(
            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
  );
}

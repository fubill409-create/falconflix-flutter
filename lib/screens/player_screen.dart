import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/commerce_cue.dart';
import '../models/product.dart';
import '../theme.dart';
import '../ui/video_fit.dart';
import 'commerce.dart';
import 'login_screen.dart';
import 'sheets.dart';

/// 播放页：竖视频受控裁切（两侧各裁 8%，顶对齐，底部留窄暗边）；下方信息+操作叠在视频上。
/// 视频区任意点暂停/播放；左侧带货 Ghost Rail（幽灵柔光、≥5s 后慢慢淡出）；
/// 点幽灵条→左侧从上到下出一溜商品（可滑动），点商品→详情→结算。
class PlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String poster;
  final String episodeLabel;
  final String episodeId; // 取真实带货时间轴用（空=只用本地 mock）
  final String shortId; // 点赞/收藏归属的剧目 id（空=本地片源，不支持）
  final bool initiallyLiked;
  final bool initiallyCollected;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    this.poster = '',
    this.episodeLabel = '',
    this.episodeId = '',
    this.shortId = '',
    this.initiallyLiked = false,
    this.initiallyCollected = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _video;
  bool _ready = false;
  bool _paused = false;

  // 点赞/收藏：乐观本地状态，与服务端 toggle 同进退。
  bool _liked = false;
  bool _collected = false;
  int _burst = 0; // 点赞触发中央大爱心爆裂

  // 先用本地 mock 兜底（保证幽灵条永远能演示），有真实后端 cue 再替换。
  List<CommerceCue> _cues = const [];

  // Ghost Rail 状态机：侧边幽灵条=入口；点击→左侧竖排商品列（一溜，可滑动）
  String? _activeGroupKey;
  bool _railShown = false; // 幽灵条入口可见
  bool _railExpanded = false; // 左侧商品列展开
  final Set<String> _dismissed = {};
  Timer? _fadeTimer;

  // 控件层（返回/标题/信息/进度）自动隐藏：播放约 3 秒后淡出，碰屏幕再现
  bool _chromeVisible = true;
  Timer? _chromeTimer;
  void _restartChromeTimer() {
    _chromeTimer?.cancel();
    if (_video?.value.isPlaying ?? false) {
      _chromeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _chromeVisible = false);
      });
    }
  }

  Widget _chrome(Widget child) => IgnorePointer(
        ignoring: !_chromeVisible,
        child: AnimatedOpacity(
          opacity: _chromeVisible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: child,
        ),
      );

  @override
  void initState() {
    super.initState();
    _liked = widget.initiallyLiked;
    _collected = widget.initiallyCollected;
    // 兜底 mock：即使后端接不通或本集没标商品，幽灵条也照常可演示。
    _cues = CommerceCueAdapter.forEpisode(
      episodeId: widget.episodeId.isEmpty ? '${widget.title}#1' : widget.episodeId,
      fallbackImage: widget.poster,
    );
    _loadRealCues();
    _initVideo();
  }

  // 拉真实带货时间轴；拿到非空就替换 mock，失败/空则保持 mock（零回归）。
  Future<void> _loadRealCues() async {
    if (widget.episodeId.isEmpty) return;
    try {
      final real = await Api.fetchCommerceTimeline(widget.episodeId);
      if (!mounted || real.isEmpty) return;
      setState(() => _cues = real);
    } catch (_) {/* 接不通就用 mock，绝不打断观影 */}
  }

  Future<void> _initVideo() async {
    final url = widget.videoUrl;
    if (url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _video = c;
    c.addListener(_onTick);
    try {
      await c.initialize();
      if (!mounted || _video != c) return;
      c.setLooping(true);
      c.play();
      setState(() {
        _ready = true;
        _paused = false;
      });
      _restartChromeTimer();
    } catch (_) {/* 不可达：保留封面 */}
  }

  void _onTick() {
    final c = _video;
    if (c == null || !c.value.isInitialized) return;
    final t = c.value.position;
    String? key;
    for (final cue in _cues) {
      if (cue.activeAt(t) && !_dismissed.contains(cue.groupKey)) {
        key = cue.groupKey;
        break;
      }
    }
    if (key != _activeGroupKey) {
      _fadeTimer?.cancel();
      setState(() {
        _activeGroupKey = key;
        _railShown = key != null;
        _railExpanded = false; // 切场景收起已展开的商品列
      });
      if (key != null && c.value.isPlaying) _startFade();
    }
  }

  void _startFade() {
    _fadeTimer?.cancel();
    if (_railExpanded) return; // 已展开商品列时不自动淡出
    // 幽灵态至少显示 5 秒，再慢慢淡出（本轮不再弹）
    _fadeTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _railExpanded) return;
      final k = _activeGroupKey;
      setState(() {
        _railShown = false;
        if (k != null) _dismissed.add(k);
      });
    });
  }

  List<CommerceCue> get _activeShelf =>
      _cues.where((c) => c.groupKey == _activeGroupKey).toList();

  List<Product> get _activeProducts =>
      _activeShelf.map((c) => Product.fromCue(c, dramaId: widget.title)).toList();

  // 点幽灵条 → 左侧从上到下出一溜商品（可滑动），不挡底部、不影响观影
  void _expandRail() {
    _fadeTimer?.cancel();
    if (_activeProducts.isEmpty) return;
    setState(() {
      _railExpanded = true;
      _railShown = false; // 幽灵入口收起，让位给商品列
    });
  }

  void _collapseRail() {
    final k = _activeGroupKey;
    setState(() {
      _railExpanded = false;
      _railShown = false;
      if (k != null) _dismissed.add(k); // 本轮该场景已处理，不再重复打扰
    });
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _togglePlay() {
    final c = _video;
    if (c == null || !_ready) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _paused = true;
        _fadeTimer?.cancel();
        _chromeTimer?.cancel();
        _chromeVisible = true; // 暂停时控件常显
      } else {
        c.play();
        _paused = false;
        if (_railShown) _startFade();
        _chromeVisible = true;
        _restartChromeTimer();
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _chromeTimer?.cancel();
    final c = _video;
    _video = null;
    c?.removeListener(_onTick);
    c?.pause();
    c?.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<bool> _ensureLogin() async {
    if (auth.loggedIn) return true;
    final ok = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (ok == true) await auth.refresh();
    return auth.loggedIn;
  }

  // 点赞：乐观点亮 + 中央爆心仪式；失败回滚。
  Future<void> _like() async {
    if (widget.shortId.isEmpty) {
      _toast(AppLocalizations.of(context).home_localOnlyLike);
      return;
    }
    if (!await _ensureLogin()) return;
    final next = !_liked;
    setState(() {
      _liked = next;
      if (next) _burst++;
    });
    try {
      await Api.toggleThumb(widget.shortId);
      Api.noteLiked(widget.shortId, next); // 同步缓存：回到首页流状态一致。
    } catch (e) {
      if (!mounted) return;
      setState(() => _liked = !next);
      _toast('$e');
    }
  }

  Future<void> _toggleCollect() async {
    if (widget.shortId.isEmpty) {
      _toast(AppLocalizations.of(context).home_localOnlyCollect);
      return;
    }
    if (!await _ensureLogin()) return;
    final next = !_collected;
    setState(() => _collected = next);
    try {
      await Api.toggleCollect(widget.shortId);
      Api.noteCollected(widget.shortId, next); // 同步缓存：回到首页流状态一致。
      if (mounted && next) _toast(AppLocalizations.of(context).home_addedToMy);
    } catch (e) {
      if (!mounted) return;
      setState(() => _collected = !next);
      _toast('$e');
    }
  }

  void _onAction(String label) {
    final l = AppLocalizations.of(context);
    // 内部 switch 用稳定中文 key（actionKey 始终传中文），显示标签走 l10n。
    switch (label) {
      case '点赞':
        _like();
      case '收藏':
        _toggleCollect();
      case '分享':
        showShareSheet(context,
            sceneLabel: widget.title,
            shortId: widget.shortId,
            title: widget.title,
            posterUrl: widget.poster);
      case '选集':
        showEpisodeDrawer(
          context,
          title: widget.title.isEmpty ? l.player_btnEpisodes : widget.title,
          episodes: List.generate(
              12, (i) => (n: i + 1, name: l.player_episodeNumFmt(i + 1), unlocked: i < 1)),
          onPlay: (i) => _toast(l.player_switchEpFmt(i + 1)),
          onUnlockAll: () => _toast(l.player_unlockHint),
        );
      default:
        _toast(l.player_comingSoonFmt(label));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final topInset = mq.padding.top;
    final videoTop = topInset; // 返回键/带货列的定位基准（视频本身 cover 铺满整屏）

    return Scaffold(
      backgroundColor: const Color(0xFF07060A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0E0B12), Color(0xFF050407)],
              ),
            ),
          ),

          // 视频区：受控裁切（两侧各裁 kVideoSideCrop，顶对齐，底部留窄暗边），控件叠在上面
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlay,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedVideo(controller: _video, poster: widget.poster),
                  if (!_ready)
                    const Center(
                        child: CircularProgressIndicator(color: FF.hot)),
                  // 暂停指示（仅图标，整屏可点）
                  if (_paused)
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.34),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            size: 42, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 点赞：中央大爱心爆裂仪式（啪一下弹出→停留+抖一下→缓缓淡出，~1.7s）
          if (_burst > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: const Icon(Icons.favorite_rounded,
                          size: 150,
                          color: FF.hot,
                          shadows: [
                            Shadow(color: Color(0xB3FF4F9B), blurRadius: 64),
                            Shadow(color: Color(0x66FF4F9B), blurRadius: 120),
                          ])
                      // ① 进场：啪一下弹出 + 白光一闪
                      .animate(key: ValueKey(_burst))
                      .scaleXY(
                          begin: 0.2,
                          end: 1.0,
                          duration: 340.ms,
                          curve: Curves.easeOutBack)
                      .fadeIn(duration: 150.ms)
                      .shimmer(duration: 480.ms, color: Colors.white)
                      // ② 停留后抖一下（先停顿，让用户看清，再俏皮地抖）
                      .then(delay: 180.ms)
                      .shake(duration: 380.ms, hz: 4, rotation: 0.08)
                      // ③ 慢退场：缓缓放大淡出，给足回味
                      .then(delay: 160.ms)
                      .scaleXY(end: 1.45, duration: 520.ms, curve: Curves.easeIn)
                      .fadeOut(duration: 520.ms),
                ),
              ),
            ),

          // 左侧带货：默认幽灵条入口；点开后变一个大圆角玻璃框（商品在框里，可滑动）。
          // 范围限制在视频区内，从返回键下方到信息栏上方，避免遮住观影主体。
          if (_railExpanded)
            Positioned(
              left: 12,
              top: videoTop + 52,
              child: ConstrainedBox(
                // 框高随商品数自适应，最高不超过视频可用带，超出则内部滚动
                constraints: BoxConstraints(maxHeight: screenH - videoTop - 220),
                child: _ProductColumn(
                  products: _activeProducts,
                  onClose: _collapseRail,
                  onOpen: _openProduct,
                ),
              ),
            )
          else
            Positioned(
              left: 10,
              top: videoTop + 52,
              bottom: 160,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _GhostRail(
                  shown: _railShown,
                  count: _activeShelf.length,
                  imageUrl: _activeProducts.isEmpty
                      ? ''
                      : _activeProducts.first.imageUrl,
                  onTap: _expandRail,
                ),
              ),
            ),

          // 底部信息栏：叠在视频上、底部压暗保证可读（控件层，自动隐藏）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _chrome(DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00050407), Color(0xE6050407)],
                ),
              ),
              child: _InfoPanel(
                title: widget.title,
                episodeLabel: widget.episodeLabel,
                video: _ready ? _video : null,
                liked: _liked,
                collected: _collected,
                onAction: _onAction,
              ),
            )),
          ),

          // 返回键（控件层，自动隐藏）
          Positioned(
            top: topInset + 6,
            left: 12,
            child: _chrome(GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.42),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

/// 视频下方信息栏：片名 + 集 + 进度 + 操作行
class _InfoPanel extends StatelessWidget {
  final String title;
  final String episodeLabel;
  final VideoPlayerController? video;
  final bool liked;
  final bool collected;
  final ValueChanged<String> onAction;
  const _InfoPanel({
    required this.title,
    required this.episodeLabel,
    required this.video,
    required this.liked,
    required this.collected,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          18, 12, 18, 10 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (video != null) _GradientProgress(video!),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'FalconFlix' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: FF.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
              ),
              if (episodeLabel.isNotEmpty) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: FF.line)),
                  child: Text(episodeLabel,
                      style: const TextStyle(
                          color: FF.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (ctx) {
                final l = AppLocalizations.of(ctx);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _action(
                      liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      liked ? l.player_btnLiked : l.home_actionLike,
                      tint: liked ? FF.hot : Colors.white,
                      actionKey: '点赞',
                    ),
                    _action(
                      collected
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      collected ? l.home_actionCollected : l.home_actionCollect,
                      tint: collected ? FF.gold : Colors.white,
                      actionKey: '收藏',
                    ),
                    _action(Icons.reply_rounded, l.home_actionShare, actionKey: '分享'),
                    _action(Icons.view_list_rounded, l.player_btnEpisodes, actionKey: '选集'),
                    _action(Icons.auto_awesome_rounded, l.player_btnAiCast,
                        actionKey: 'AI入戏', tint: FF.teal),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label,
      {Color tint = Colors.white, String? actionKey}) {
    return GestureDetector(
      onTap: () => onAction(actionKey ?? label),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: tint, size: 26),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: FF.muted, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 粉→蓝渐变进度条（统一主题）
class _GradientProgress extends StatelessWidget {
  final VideoPlayerController video;
  const _GradientProgress(this.video);
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: video,
      builder: (context, _) {
        final v = video.value;
        final total = v.duration.inMilliseconds;
        final pos = v.position.inMilliseconds;
        final frac = (total > 0) ? (pos / total).clamp(0.0, 1.0) : 0.0;
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 6,
            color: Colors.white.withValues(alpha: 0.18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: frac == 0 ? 0.001 : frac,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: FF.progressGradient),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 左侧带货幽灵条：商品入口。真实商品缩略图 + 绿色 AI 角标（圆角方块），
/// 半透明（不糊住画面）、≥5s 后慢慢淡出；点击→左侧商品列。
class _GhostRail extends StatelessWidget {
  final bool shown;
  final int count;
  final String imageUrl;
  final VoidCallback onTap;

  const _GhostRail({
    required this.shown,
    required this.count,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !shown,
      child: AnimatedOpacity(
        opacity: shown ? 0.92 : 0.0,
        // 出现快、消失慢（慢慢下去）
        duration: Duration(milliseconds: shown ? 320 : 1100),
        curve: shown ? Curves.easeOut : Curves.easeInOut,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 真实商品缩略图（圆角方块、淡描边、柔光）
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.5),
                    child: imageUrl.isEmpty
                        ? const ColoredBox(color: Colors.black26)
                        : productImage(imageUrl),
                  ),
                ),
                // 右上绿色 AI 角标
                Positioned(
                  top: -5,
                  right: -1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.5),
                            blurRadius: 8),
                      ],
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
                // 多件时右下角件数
                if (count > 1)
                  Positioned(
                    bottom: -4,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: FF.brandGradient,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white, width: 1.1),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            height: 1.1,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 展开后的左侧竖排商品列（一溜，从上到下，可滑动）。
/// 半透明玻璃卡，不大面积遮住视频；点商品→详情→结算。
class _ProductColumn extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onClose;
  final ValueChanged<Product> onOpen;
  const _ProductColumn({
    required this.products,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    // 一个大圆角玻璃框：商品都在框里，框四周柔光美化
    return Container(
      width: 138,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 28,
              offset: const Offset(0, 14)),
          BoxShadow(
              color: const Color(0xFFFF4F9B).withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.40),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            padding: const EdgeInsets.fromLTRB(10, 11, 10, 11),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 绿色 AI 圆点 + 标题「场景同款」（对齐设计稿 Scene Product 区头）
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF22C55E),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.6),
                              blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).player_sceneSame,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (_, i) => _ProductMiniCard(
                      product: products[i],
                      onTap: () => onOpen(products[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 商品列里的迷你卡：方图 + 名称 + 渐变价。玻璃质感。
class _ProductMiniCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductMiniCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图（四角全圆）+ 右上角绿色 AI 匹配度角标
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: productImage(product.imageUrl),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.45),
                            blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text('${product.matchScore}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                height: 1.1,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (r) =>
                            FF.brandGradient.createShader(r),
                        child: Text(product.priceLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900)),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white54, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

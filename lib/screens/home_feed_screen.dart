import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../boot_warm.dart';
import '../l10n/generated/app_localizations.dart';
import '../nav.dart';
import '../models/feed_item.dart';
import '../theme.dart';
import '../ui/kit.dart';
import '../ui/video_fit.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'player_screen.dart';
import 'sheets.dart';

/// 首页 · 竖滑短剧流。严格按 Codex 设计稿 home-feed.html/css 1:1 实现。
class HomeFeedScreen extends StatefulWidget {
  final bool active; // 是否当前 Tab（离开首页时暂停视频）
  const HomeFeedScreen({super.key, this.active = true});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final PageController _page = PageController();
  List<FeedItem> _items = [];
  bool _loading = true;
  String? _error;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 复用 splash 期间预热的首页流：动画跑完时多半已就绪，进首页不再空转。
      final items = await Api.feed();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
      // 预热第二条：从第一条往下滑时即播，不再现场缓冲。
      if (items.length > 1) BootWarm.prewarmNext(items[1].videoUrl);
    } catch (e) {
      Api.resetFeed(); // 失败丢缓存，下次重试重新拉。
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) return const _BrandedLoader();
    if (_error != null) {
      return Stack(children: [
        const AmbientBackground(),
        _ErrorView(message: _error!, onRetry: _load),
      ]);
    }
    if (_items.isEmpty) {
      return Stack(children: [
        const AmbientBackground(),
        _ErrorView(message: l.home_noDramaData, onRetry: _load),
      ]);
    }
    return PageView.builder(
      controller: _page,
      scrollDirection: Axis.vertical,
      itemCount: _items.length,
      onPageChanged: (i) {
        setState(() => _current = i);
        // 滑到第 i 条时，提前预热第 i+1 条，让下一次下滑也是“滑到即播”。
        if (i + 1 < _items.length) {
          BootWarm.prewarmNext(_items[i + 1].videoUrl);
        }
      },
      itemBuilder: (context, i) => _FeedPage(
        item: _items[i],
        feedIndex: i,
        isActive: i == _current,
        tabActive: widget.active,
      ),
    );
  }
}

class _FeedPage extends StatefulWidget {
  final FeedItem item;
  final int feedIndex;
  final bool isActive;
  final bool tabActive;
  const _FeedPage(
      {required this.item,
      required this.feedIndex,
      required this.isActive,
      required this.tabActive});

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> with RouteAware {
  VideoPlayerController? _video;
  bool _ready = false;
  bool _paused = false;

  // 点赞/收藏：乐观本地状态，与服务端 toggle 同进退。
  bool _liked = false;
  bool _collected = false;
  int _likeBump = 0; // 点赞后本地 +1 叠到热度
  int _likePulse = 0; // 变化触发侧栏心跳
  int _collectPulse = 0;
  int _burst = 0; // 变化触发中央大爱心爆裂

  @override
  void initState() {
    super.initState();
    // 监听底部 Tab 切换：离开首页立刻暂停（绕开 IndexedStack/PageView 离屏重建时序）。
    homeTabActive.addListener(_onTabActive);
    if (widget.isActive && widget.tabActive) _initVideo();
    _loadInteractions();
  }

  /// 从服务端读回「我是否已点赞/已收藏本剧」，让侧栏按钮初始就显示正确状态，
  /// 而不是永远从灰开始（之前点了滑走再回来又变灰，像没生效）。
  Future<void> _loadInteractions() async {
    final id = widget.item.shortId;
    if (id.isEmpty || !auth.loggedIn) return;
    final liked = await Api.dramaLiked(id);
    final collected = await Api.dramaCollected(id);
    if (!mounted) return;
    if (id != widget.item.shortId) return; // 期间已换剧，丢弃
    if (liked == _liked && collected == _collected) return;
    setState(() {
      _liked = liked;
      _collected = collected;
    });
  }

  // 是否该处于播放态：当前页、首页 Tab 可见、用户没手动暂停。供异步初始化收尾时复核，
  // 避免「初始化途中切走了，结果回来还自动出声」。
  bool get _shouldPlay =>
      mounted && widget.isActive && homeTabActive.value && !_paused;

  void _onTabActive() {
    if (!mounted) return;
    if (!homeTabActive.value) {
      _video?.pause();
    } else if (widget.isActive && !_paused) {
      if (_video == null) {
        _initVideo();
      } else {
        _video!.play();
      }
    }
  }

  Future<bool> _ensureLogin() async {
    if (auth.loggedIn) return true;
    final ok = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (ok == true) await auth.refresh();
    return auth.loggedIn;
  }

  /// 点赞。toggle=true 普通点按（可取消）；toggle=false 双击（只点亮，不取消）。
  Future<void> _like({required bool toggle}) async {
    final id = widget.item.shortId;
    if (id.isEmpty) {
      _toast(context, AppLocalizations.of(context).home_localOnlyLike);
      return;
    }
    // 双击且已点赞：只放爱心特效，不动服务端（避免误取消）。
    if (!toggle && _liked) {
      setState(() => _burst++);
      return;
    }
    if (!await _ensureLogin()) return;
    final next = toggle ? !_liked : true;
    setState(() {
      _liked = next;
      _likeBump = next ? 1 : 0;
      _likePulse++;
      if (next) _burst++;
    });
    try {
      await Api.toggleThumb(id);
      Api.noteLiked(id, next); // 同步内存缓存：本次会话内滑走再回来状态不丢。
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _liked = !next;
        _likeBump = _liked ? 1 : 0;
      });
      _toast(context, '$e');
    }
  }

  Future<void> _toggleCollect() async {
    final id = widget.item.shortId;
    if (id.isEmpty) {
      _toast(context, AppLocalizations.of(context).home_localOnlyCollect);
      return;
    }
    if (!await _ensureLogin()) return;
    final next = !_collected;
    setState(() {
      _collected = next;
      _collectPulse++;
    });
    try {
      await Api.toggleCollect(id);
      Api.noteCollected(id, next); // 同步内存缓存：本次会话内滑走再回来状态不丢。
      if (mounted && next) _toast(context, AppLocalizations.of(context).home_addedToMy);
    } catch (e) {
      if (!mounted) return;
      setState(() => _collected = !next);
      _toast(context, '$e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  // 别的页面 push 盖在首页上（AI 玩法 / 播放页 / 详情）：暂停，避免后台还出声
  @override
  void didPushNext() => _video?.pause();

  // 上层页面弹出、重新回到首页：若仍是当前页、Tab 可见、用户没手动暂停 → 恢复
  @override
  void didPopNext() {
    if (widget.isActive && widget.tabActive && !_paused) _video?.play();
  }

  @override
  void didUpdateWidget(covariant _FeedPage old) {
    super.didUpdateWidget(old);
    // 复用本 State 但换了剧目：重置点赞/收藏镜像，避免串到别的剧；再按新剧读回真状态。
    if (old.item.shortId != widget.item.shortId) {
      _liked = false;
      _collected = false;
      _likeBump = 0;
      _loadInteractions();
    }
    // 当前页（哪条视频）切换：初始化 / 释放
    if (widget.isActive && !old.isActive) {
      if (widget.tabActive) _initVideo();
    } else if (!widget.isActive && old.isActive) {
      _disposeVideo();
    }
    // Tab 可见性切换：离开首页暂停，回到首页恢复（避免后台还出声）
    if (widget.tabActive != old.tabActive) {
      if (!widget.tabActive) {
        _video?.pause();
      } else if (widget.isActive && !_paused) {
        if (_video == null) {
          _initVideo();
        } else {
          _video!.play();
        }
      }
    }
  }

  Future<void> _initVideo() async {
    final url = widget.item.videoUrl;
    if (url.isEmpty) return;
    _paused = false; // 新片源：重置「用户手动暂停」镜像，避免沿用上一条的暂停态。
    // 优先用预热好的 controller：第一条来自 splash 预热，其余来自“滑到上一条时
    // 提前预热的下一条”。命中即播，省去现场缓冲那几秒（滑到→鹰头→等→影片 的根因）。
    if (_video == null) {
      final warm = BootWarm.take(url);
      if (warm != null) {
        final c = warm.$1;
        _video = c;
        try {
          await warm.$2; // 多半已缓冲完
          if (!mounted || _video != c) {
            c.dispose();
            return;
          }
          c.setLooping(true);
          // 初始化途中可能已切走 Tab/翻页：只有仍该播才播，否则保持暂停不出声。
          if (_shouldPlay) {
            c.play();
          } else {
            c.pause();
          }
          setState(() {
            _ready = true;
          });
        } catch (_) {/* 回退到封面 */}
        return;
      }
    }
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _video = c;
    try {
      await c.initialize();
      if (!mounted || _video != c) return;
      c.setLooping(true);
      // 初始化途中可能已切走 Tab/翻页：只有仍该播才播，否则保持暂停不出声。
      if (_shouldPlay) {
        c.play();
      } else {
        c.pause();
      }
      setState(() {
        _ready = true;
      });
    } catch (_) {/* 不可达回退到封面 */}
  }

  void _disposeVideo() {
    final c = _video;
    _video = null;
    _ready = false;
    c?.pause();
    c?.dispose();
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    final c = _video;
    if (c == null || !_ready) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _paused = true;
      } else {
        c.play();
        _paused = false;
      }
    });
  }

  @override
  void dispose() {
    homeTabActive.removeListener(_onTabActive);
    routeObserver.unsubscribe(this);
    _disposeVideo();
    super.dispose();
  }

  // —— 跳转 ——
  void _openPlayer() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          title: widget.item.shortName.isEmpty
              ? 'FalconFlix'
              : widget.item.shortName,
          videoUrl: widget.item.videoUrl,
          poster: widget.item.poster,
          episodeLabel: widget.item.episodeName,
          episodeId: widget.item.episodeId,
          shortId: widget.item.shortId,
          initiallyLiked: _liked,
          initiallyCollected: _collected,
        ),
      ));

  void _openDetail() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          shortId: widget.item.shortId,
          title: widget.item.shortName,
          cover: widget.item.poster,
          intro: widget.item.introduce,
          price: widget.item.price,
          plays: widget.item.likeCount + widget.item.thumbsUpCount,
          videoUrl: widget.item.videoUrl,
        ),
      ));

  bool get _hasCommerce =>
      widget.item.goodsPreId != null ||
      widget.item.goodsMidId != null ||
      widget.item.goodsAfterId != null;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final item = widget.item;
    final navClear = 72.0; // 浮动导航占位(下边距8+高64)，文案紧贴其上
    final pop = item.likeCount + item.thumbsUpCount;

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: () => _like(toggle: false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景：纯净暗底占位。视频未就绪时先看它——不再把账号头像（金鹰角标）
          // 拉满屏当背景（那是“为什么会有个金色鹰头大底”的根因）。配合下一条预热，
          // 滑到即播，这块暗底基本一闪而过。
          const _BrandedBackdrop(),
          // 视频：受控裁切（两侧各裁 kVideoSideCrop，顶对齐，底部窄暗边）
          if (_ready && _video != null) FittedVideo(controller: _video),
          // 压暗 scrim
          const DecoratedBox(decoration: BoxDecoration(gradient: FF.videoScrim)),
          // 暂停图标
          if (_paused)
            const Center(
                child: Icon(Icons.play_arrow_rounded,
                    size: 88, color: Colors.white60)),

          // 双击点赞：中央大爱心爆裂（不拦截手势）
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
                      // ② 停留后抖一下
                      .then(delay: 180.ms)
                      .shake(duration: 380.ms, hz: 4, rotation: 0.08)
                      // ③ 慢退场：缓缓放大淡出
                      .then(delay: 160.ms)
                      .scaleXY(end: 1.45, duration: 520.ms, curve: Curves.easeIn)
                      .fadeOut(duration: 520.ms),
                ),
              ),
            ),

          // 顶部不放任何品牌/logo —— video-first，画面完全让给视频

          // 右侧社交操作（统一玻璃微光）
          Positioned(
            right: 14,
            bottom: navClear + 70,
            child: Column(
              children: [
                _SideAction(
                    icon: Icons.favorite_rounded,
                    iconColor: _liked ? FF.hot : Colors.white,
                    glow: _liked ? FF.hot : Colors.white,
                    label: (pop + _likeBump) > 0
                        ? _fmt(pop + _likeBump)
                        : l.home_actionLike,
                    pulse: _likePulse,
                    onTap: () => _like(toggle: true)),
                const SizedBox(height: 18),
                _SideAction(
                    icon: _collected
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    iconColor: _collected ? FF.gold : Colors.white,
                    glow: _collected ? FF.gold : Colors.white,
                    label: _collected ? l.home_actionCollected : l.home_actionCollect,
                    pulse: _collectPulse,
                    onTap: _toggleCollect),
                const SizedBox(height: 18),
                _SideAction(
                    icon: Icons.reply_rounded,
                    label: l.home_actionShare,
                    onTap: () => showShareSheet(context,
                        sceneLabel: item.shortName,
                        shortId: item.shortId,
                        title: item.shortName,
                        posterUrl: item.poster)),
              ],
            ),
          ),

          // 底部文案区（压到左下角，紧贴导航上方）
          Positioned(
            left: 16,
            right: 78,
            bottom: navClear + 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 带货 cue（左）+ chips（右）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_hasCommerce) ...[
                      _CommerceCue(
                          onTap: () =>
                              _toast(context, l.home_shopComingSoon)),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _Chip(l.home_chipAiTheater, gold: true),
                          if (pop >= 1000) _Chip(_fmt(pop)), // 太小的数不显示孤立 chip
                          _Chip(item.price > 0
                              ? '¥${item.price.toStringAsFixed(0)}'
                              : l.common_free),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.shortName.isEmpty ? 'FalconFlix' : item.shortName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FF.text,
                    fontSize: 21,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Color(0x8F000000), blurRadius: 16, offset: Offset(0, 3)),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 180.ms)
                    .slideY(begin: 0.18, curve: Curves.easeOutExpo),
                if (item.introduce.isNotEmpty) ...[
                  const SizedBox(height: 11),
                  Text(
                    item.introduce,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FF.muted,
                      fontSize: 12.5,
                      height: 1.4,
                      shadows: [
                        Shadow(color: Color(0x73000000), blurRadius: 12),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _PrimaryActions(
                        onWatch: _openPlayer,
                        onDetail: _openDetail)
                    .animate()
                    .fadeIn(duration: 460.ms, delay: 260.ms)
                    .slideY(begin: 0.5, curve: Curves.easeOutExpo), // 文案上浮
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 缺图/缺视频/缓冲时的占位：干净暗底，不放 FF（别在视频出来前糊一块 FF）。
class _BrandedBackdrop extends StatelessWidget {
  const _BrandedBackdrop();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14100E), Color(0xFF0B0B0F)],
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color glow; // 彩色微光
  final Color iconColor;
  final int pulse; // 变化即触发一次弹跳（0 时不动）
  const _SideAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.glow = Colors.white,
      this.iconColor = Colors.white,
      this.pulse = 0});
  @override
  Widget build(BuildContext context) {
    Widget circle = ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x3D000000),
            border: Border.all(color: glow.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(color: glow.withValues(alpha: 0.38), blurRadius: 16),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
    if (pulse > 0) {
      circle = circle
          .animate(key: ValueKey(pulse))
          .scaleXY(
              begin: 1.32,
              end: 1.0,
              duration: 460.ms,
              curve: Curves.elasticOut);
    }
    return Bounce(
      onTap: onTap,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Color(0x85000000), blurRadius: 10)])),
        ],
      ),
    );
  }
}

class _CommerceCue extends StatelessWidget {
  final VoidCallback onTap;
  const _CommerceCue({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 22,
        blur: 18,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 78,
              height: 78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 无真实商品图时的金色 AI 商品占位（购物袋），不要用场景帧
                  ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2A2118), Color(0xFF15110C)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.shopping_bag_rounded,
                            color: FF.gold, size: 28),
                      ),
                    ),
                  ),
                  // 扫描环
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: FF.teal.withValues(alpha: 0.72)),
                        boxShadow: [
                          BoxShadow(
                              color: FF.teal.withValues(alpha: 0.36),
                              blurRadius: 18),
                        ],
                      ),
                    ),
                  ),
                  // AI 点
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, gradient: FF.aiGradient),
                      child: const Text('AI',
                          style: TextStyle(
                              color: Color(0xFF10231F),
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                  gradient: FF.goldGradient,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(AppLocalizations.of(context).home_bannerPremiere,
                  style: const TextStyle(
                      color: FF.textDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool gold;
  const _Chip(this.text, {this.gold = false});
  @override
  Widget build(BuildContext context) {
    // 不设 alignment / 固定宽高：让 chip 按内容自适应，避免在 Wrap 的有界约束下被撑满整行。
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: gold ? FF.goldGradient : null,
        color: gold ? null : const Color(0xC7FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: const TextStyle(
              color: FF.textDark, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  final VoidCallback onWatch;
  final VoidCallback onDetail;
  const _PrimaryActions(
      {required this.onWatch, required this.onDetail});
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
      children: [
        // Watch：红粉珊瑚渐变
        Bounce(
          onTap: onWatch,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: FF.watchGradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                    color: FF.hot2.withValues(alpha: 0.42),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 17),
                const SizedBox(width: 4),
                Text(AppLocalizations.of(context).home_btnWatch,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Details：玻璃
        Bounce(
          onTap: onDetail,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x33000000),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x3DFFFFFF)),
            ),
            child: Text(AppLocalizations.of(context).home_btnDetails,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
        ),
      ],
      ),
    );
  }
}

/// 首页流加载占位：干净暗底（接金鹰 splash 同色），只留一个细金圈，不放 FF。
/// 正常情况下 splash 已预热好首页流，这个几乎一闪而过。
class _BrandedLoader extends StatelessWidget {
  const _BrandedLoader();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFF0B0B0F)),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: FF.gold, strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: FF.dim, size: 48),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).home_loadFailedFmt(message),
                textAlign: TextAlign.center,
                style: const TextStyle(color: FF.muted, fontSize: 13)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(AppLocalizations.of(context).common_retry),
            ),
          ],
        ),
      ),
    );
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
  );
}

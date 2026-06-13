import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/ai_character.dart';
import '../models/support_store.dart';
import '../nav.dart';
import '../theme.dart';
import '../ui/kit.dart';
import '../ui/support_sheet.dart';
import '../api/api.dart';
import 'ai_chat_screen.dart';
import 'login_screen.dart';

/// 角色详情（二级）。进来第一眼 = **全屏可滑的时尚大片画廊**（看颜值、看身材、翻几套造型），
/// 往下滑才是：人设、出道应援进度、TA 的视频、可解锁的深入时刻、参演的剧、**实名应援榜**。
/// v0 = mock，「应援/解锁/欣赏/聊天」只走占位交互，不接计费。
class CharacterDetailScreen extends StatefulWidget {
  final AiCharacter character;
  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen>
    with RouteAware {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // 自我介绍视频（画廊首页自动播放的 15s 演员级 reel）。
  VideoPlayerController? _intro;
  bool _introReady = false;
  bool _introFailed = false;
  bool _muted = false; // 默认开声——TA 是在对你说话
  bool _introPausedByUser = false;
  // 上面盖了别的页（聊天/通话）。自我介绍视频是异步加载的，用户在它加载完之前就点进
  // 通话页时，didPushNext 暂停的是个还没起播的空控制器（等于没暂停），等 initialize() 完成
  // 那句延迟的 play() 仍会执行 → 视频在后台播起来抢音频焦点 → 把通话麦克风饿死（首次进通话
  // 必坏、退回再进才好的根因）。用这个标志保证：只要详情页被盖住，无论现在还是稍后都不起播。
  bool _coveredByRoute = false;

  bool get _hasIntro => (widget.character.introVideoUrl ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initIntro();
    _syncFav();
    // 拉真·应援榜 / 进度填进 supportStore 缓存；它 notify 后下方 ListenableBuilder 自动重建。
    supportStore.refreshChar(widget.character.id);
  }

  // 角色收藏（取代右上角空点的爱心）：登录用户拉收藏列表判断本角色是否已收藏。
  bool _faved = false;
  Future<void> _syncFav() async {
    if (!Api.hasToken) return;
    try {
      final s = await Api.myFavoriteChars();
      if (mounted) setState(() => _faved = s.contains(widget.character.id));
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    if (!Api.hasToken) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final was = _faved;
    setState(() => _faved = !was); // 乐观
    try {
      was
          ? await Api.unfavoriteChar(widget.character.id)
          : await Api.favoriteChar(widget.character.id);
    } catch (_) {
      if (mounted) setState(() => _faved = was); // 失败回滚
    }
  }

  Future<void> _initIntro() async {
    final url = widget.character.introVideoUrl;
    if (url == null || url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _intro = c;
    try {
      await c.initialize().timeout(const Duration(seconds: 15)); // 加超时:视频挂死不再一直转圈
      if (!mounted || _intro != c) {
        c.dispose();
        return;
      }
      c.setLooping(true);
      await c.setVolume(_muted ? 0 : 1);
      // 被通话/聊天页盖住时绝不起播（否则在后台抢音频焦点饿死通话麦克风）。
      if (_page == 0 && !_coveredByRoute) c.play();
      setState(() => _introReady = true);
    } catch (_) {
      if (mounted) setState(() => _introFailed = true);
    }
  }

  void _toggleIntroPlay() {
    final v = _intro;
    if (v == null || !_introReady) return;
    setState(() {
      if (v.value.isPlaying) {
        v.pause();
        _introPausedByUser = true;
      } else {
        v.play();
        _introPausedByUser = false;
      }
    });
  }

  void _toggleMute() {
    final v = _intro;
    setState(() => _muted = !_muted);
    v?.setVolume(_muted ? 0 : 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  // 聊天等页 push 盖上来：暂停，别让自我介绍在后台还出声。
  @override
  void didPushNext() {
    _coveredByRoute = true;
    _intro?.pause();
  }

  // 上层页弹回详情：若仍停在视频页且用户没手动暂停 → 恢复。
  @override
  void didPopNext() {
    _coveredByRoute = false;
    if (_page == 0 && _introReady && !_introPausedByUser) _intro?.play();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _pageCtrl.dispose();
    _intro?.pause();
    _intro?.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: FF.panel,
      content: Text(msg, style: const TextStyle(color: FF.text)),
    ));
  }

  void _support() => openSupportSheet(context, widget.character);

  void _chat() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AiChatScreen(character: widget.character),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: FF.bg,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          // 全屏画廊在最上、文字内容在下，整体可纵向滚动；画廊内可横滑翻图。
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _gallery(c)),
              SliverToBoxAdapter(child: _identity(c)),
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: supportStore,
                  builder: (_, _) => _progress(c),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                  child: SectionHeader(
                      AppLocalizations.of(context).cd_secVideos)),
              SliverToBoxAdapter(child: _clips(c)),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                  child: SectionHeader(
                      AppLocalizations.of(context).cd_secMoments,
                      action: AppLocalizations.of(context).cd_actUnlock)),
              SliverToBoxAdapter(child: _moments(c)),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                  child: SectionHeader(
                      AppLocalizations.of(context).cd_secCredits)),
              SliverToBoxAdapter(child: _credits(c)),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: supportStore,
                  builder: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(
                          AppLocalizations.of(context).cd_secBoardFmt(
                              supportStore.boardFor(c).length.toString()),
                          action: AppLocalizations.of(context).cd_actImInToo,
                          onAction: _support),
                      _board(c),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
          // 浮在画廊上的返回 / 收藏
          Positioned(
            top: topInset + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _circleBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                const Spacer(),
                _circleBtn(
                    _faved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    _toggleFav),
              ],
            ),
          ),
          // 底部渐隐：滚动内容触到按钮前先融进背景，按钮不再透出叠字
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 128,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      FF.bg.withValues(alpha: 0.92),
                      FF.bg,
                    ],
                    stops: const [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ───────── 满屏时尚大片画廊（手机宽、占满整屏，横滑翻几套造型）─────────
  Widget _gallery(AiCharacter c) {
    // 首页铺满整屏——进来第一眼就是 TA 对你说话的 15s 自我介绍视频，往后滑才是造型照 + 文字。
    final h = MediaQuery.of(context).size.height;
    final introOffset = _hasIntro ? 1 : 0;
    final pageCount = introOffset + c.gallery.length;
    if (pageCount == 0) {
      return SizedBox(height: h, child: Center(child: _haloFace(c)));
    }
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) {
              setState(() => _page = i);
              final v = _intro;
              if (v == null || !_introReady) return;
              if (_hasIntro && i == 0) {
                if (!_introPausedByUser) v.play();
              } else {
                v.pause();
              }
            },
            itemCount: pageCount,
            itemBuilder: (_, i) {
              if (_hasIntro && i == 0) return _introPage(c, h);
              return Image.asset(
                c.gallery[i - introOffset],
                fit: BoxFit.cover,
                width: double.infinity,
                height: h,
                errorBuilder: (_, _, _) => Center(child: _haloFace(c)),
              );
            },
          ),
          // 底部渐隐，照片自然融进深色页面 + 压暗让文字可读
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * 0.46,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      FF.bg.withValues(alpha: 0.62),
                      FF.bg,
                    ],
                    stops: const [0.0, 0.62, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // 名字 / 标签 / 翻页点 / 下滑提示（避开底部浮动按钮）
          Positioned(
            left: 22,
            right: 22,
            bottom: 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < pageCount; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _page ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? c.aura.first
                              : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: i == _page
                              ? [
                                  BoxShadow(
                                      color: c.aura.first.withValues(alpha: 0.6),
                                      blurRadius: 10)
                                ]
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  c.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                GlowChip(c.role, color: c.aura.first),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 20),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context).cd_swipeHint,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700)),
                  ],
                )
                    .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                    .moveY(begin: 0, end: 6, duration: 900.ms, curve: Curves.easeInOut),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 650.ms)
        .scaleXY(
            begin: 1.06,
            end: 1.0,
            duration: 1200.ms,
            curve: Curves.easeOutCubic);
  }

  // ───────── 画廊第一页：TA 的 15s 自我介绍视频（自动播放 / 循环 / 可静音）─────────
  Widget _introPage(AiCharacter c, double h) {
    final v = _intro;
    final topInset = MediaQuery.of(context).padding.top;
    final poster = c.gallery.isNotEmpty ? c.gallery.first : c.avatarHead;
    final playing = v != null && v.value.isPlaying;
    return GestureDetector(
      onTap: _toggleIntroPlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 加载中 / 失败时露出的占位海报
          if (poster != null)
            Image.asset(poster,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(color: FF.bg))
          else
            const ColoredBox(color: FF.bg),
          // 视频铺满（cover）
          if (_introReady && v != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: v.value.size.width,
                height: v.value.size.height,
                child: VideoPlayer(v),
              ),
            ),
          // 加载中转圈
          if (!_introReady && !_introFailed)
            Center(
              child: SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: c.aura.first),
              ),
            ),
          // 暂停时的大播放键
          if (_introReady && !playing)
            Center(
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.42),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
          // 顶部：「TA 的自我介绍」标 + 静音切换（下移避开返回行）
          Positioned(
            top: topInset + 54,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: c.aura.first.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 5),
                      Text(AppLocalizations.of(context).cd_introBadge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const Spacer(),
                if (_introReady)
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.34),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Icon(
                          _muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── 人设小传 + 完整性格（画廊下方）─────────
  Widget _identity(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.persona,
              style: const TextStyle(
                  color: FF.text,
                  fontSize: 14.5,
                  height: 1.55,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(c.personality,
              style: TextStyle(
                  color: FF.muted.withValues(alpha: 0.82),
                  fontSize: 12,
                  height: 1.65)),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }

  // 画廊图缺失时的占位：旋转光环 + 英文首字母脸。
  Widget _haloFace(AiCharacter c) {
    return SizedBox(
      width: 124,
      height: 124,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [c.aura.first, c.aura.last, c.aura.first],
              ),
              boxShadow: [
                BoxShadow(
                    color: c.aura.first.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 3),
              ],
            ),
          )
              .animate(onPlay: (ctrl) => ctrl.repeat())
              .rotate(begin: 0, end: 1, duration: 6500.ms),
          Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xCC0B0913),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22), width: 1.4),
            ),
            child: ShaderMask(
              shaderCallback: (r) =>
                  LinearGradient(colors: c.aura).createShader(r),
              child: Text(c.emoji,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(AiCharacter c) {
    final progress = supportStore.progressFor(c);
    final pct = (progress * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 18, 6, 0),
      child: Glass(
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(AppLocalizations.of(context).cd_debutProgress,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
                const Spacer(),
                Text('$pct%',
                    style: TextStyle(
                        color: c.aura.first,
                        fontSize: 15,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (ctx, box) {
              return Stack(
                children: [
                  Container(
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Container(
                    height: 9,
                    width: (box.maxWidth * progress)
                        .clamp(9.0, box.maxWidth),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: c.aura),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                            color: c.aura.first.withValues(alpha: 0.55),
                            blurRadius: 14),
                      ],
                    ),
                  )
                      .animate()
                      .scaleX(
                          begin: 0,
                          alignment: Alignment.centerLeft,
                          duration: 800.ms,
                          curve: Curves.easeOut),
                ],
              );
            }),
            const SizedBox(height: 9),
            Text(AppLocalizations.of(context).cd_debutHint,
                style: const TextStyle(
                    color: FF.dim, fontSize: 11, height: 1.4)),
          ],
        ),
      ),
    );
  }

  // ───────── TA 的视频（横滑片段）─────────
  Widget _clips(AiCharacter c) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
        itemCount: c.clips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => Bounce(
          onTap: () => _toast(
              AppLocalizations.of(context).cd_clipToastFmt(c.clips[i])),
          child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 84,
                  width: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: c.aura,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: c.aura.first.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.32),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 7),
                Text(c.clips[i],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: FF.text, fontSize: 11.5, height: 1.3)),
              ],
            ),
          ),
        )
            .animate(delay: (70 * i + 100).ms)
            .fadeIn(duration: 440.ms)
            .slideX(begin: 0.14, curve: Curves.easeOut),
      ),
    );
  }

  // ───────── 深入沟通的时刻（鹰币解锁）─────────
  Widget _moments(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
      child: Column(
        children: [
          for (int i = 0; i < c.moments.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Bounce(
                // 「深入沟通的时刻」→ 进真·AI 陪聊，把该时刻主题预填为开场话题（不再是假鹰币占位按钮）。
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AiChatScreen(
                        character: c, openingTopic: c.moments[i].title))),
                child: Glass(
                  radius: 16,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: c.aura),
                          boxShadow: [
                            BoxShadow(
                                color: c.aura.first.withValues(alpha: 0.45),
                                blurRadius: 14),
                          ],
                        ),
                        child: const Icon(Icons.forum_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.moments[i].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: FF.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(c.moments[i].hint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: FF.dim, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: FF.dim, size: 22),
                    ],
                  ),
                ),
              )
                  .animate(delay: (80 * i + 120).ms)
                  .fadeIn(duration: 460.ms)
                  .slideX(begin: 0.1, curve: Curves.easeOut),
            ),
        ],
      ),
    );
  }

  // ───────── TA 参演的剧（可点欣赏）─────────
  Widget _credits(AiCharacter c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (int i = 0; i < c.credits.length; i++)
            Bounce(
              onTap: () => _toast(
                  AppLocalizations.of(context).cd_creditToastFmt(c.credits[i])),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: c.aura.first.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_outline_rounded,
                        color: c.aura.first, size: 17),
                    const SizedBox(width: 7),
                    Text(c.credits[i],
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            )
                .animate(delay: (70 * i + 100).ms)
                .fadeIn(duration: 440.ms)
                .scaleXY(begin: 0.9, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  // ───────── 应援榜：应援王高亮 + 其余两列紧凑 ─────────
  Widget _board(AiCharacter c) {
    final board = supportStore.boardFor(c);
    if (board.isEmpty) return const SizedBox.shrink();
    final king = board.first;
    final rest = board.skip(1).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
      child: Column(
        children: [
          _kingRow(king)
              .animate()
              .fadeIn(duration: 480.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
          if (rest.isNotEmpty) const SizedBox(height: 10),
          for (int r = 0; r < (rest.length + 1) ~/ 2; r++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _boardCell(r * 2 + 2, rest[r * 2])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: r * 2 + 1 < rest.length
                        ? _boardCell(r * 2 + 3, rest[r * 2 + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 榜一大哥：一条 slim 金色高亮
  Widget _kingRow(Supporter s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: FF.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FF.gold.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: FF.gold.withValues(alpha: 0.16), blurRadius: 22)],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: FF.gold, size: 22),
          const SizedBox(width: 10),
          LevelBadge(level: s.level),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: FF.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: FF.goldGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(AppLocalizations.of(context).cd_kingBadge,
                      style: const TextStyle(
                          color: Color(0xFF3A2700),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
              AppLocalizations.of(context)
                  .sheets_coinsFmt(_fmtCoins(s.coins)),
              style: const TextStyle(
                  color: FF.gold,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // 紧凑小格（两列）
  Widget _boardCell(int rank, Supporter s) {
    final tier = levelTier(s.level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text('$rank',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: FF.dim, fontSize: 13, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 6),
          LevelBadge(level: s.level, scale: 0.82),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 1),
                Text(
                    AppLocalizations.of(context)
                        .sheets_coinsFmt(_fmtCoins(s.coins)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: tier.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final c = widget.character;
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Row(
        children: [
          // 应援：紧凑实心小药丸（不再半透叠字）
          GestureDetector(
            onTap: _support,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xF21A1622),
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: c.aura.first.withValues(alpha: 0.55)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: FF.gold, size: 16),
                  const SizedBox(width: 5),
                  Text(AppLocalizations.of(context).cd_btnSupport,
                      style: const TextStyle(
                          color: FF.text,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GradientButton(
              label: AppLocalizations.of(context).cd_btnChat,
              icon: Icons.chat_bubble_rounded,
              height: 44,
              gradient: LinearGradient(colors: c.aura),
              glow: c.aura.first,
              onTap: _chat,
            ),
          ),
        ],
      ),
    );
  }
}

/// 鹰币紧凑显示：>=1M → "1.2M"；>=1K → "5.8K"；其它原样。ASCII K/M 跨语言通用。
String _fmtCoins(int n) {
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

// ───────────────────────── V 级别角标（面子系统）─────────────────────────
/// 全 App 通用身份角标：V + 级别数字，颜色/渐变随段位升。
class LevelBadge extends StatelessWidget {
  final int level;
  final double scale;
  const LevelBadge({super.key, required this.level, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final tier = levelTier(level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        gradient: tier.gradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: tier.color.withValues(alpha: 0.4), blurRadius: 10),
        ],
      ),
      child: Text('V$level',
          style: TextStyle(
              color: Colors.white,
              fontSize: 12 * scale,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3)),
    );
  }
}

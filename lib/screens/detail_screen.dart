import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/episode.dart';
import '../state/app_settings.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'login_screen.dart';
import 'me_subpages.dart';
import 'player_screen.dart';
import 'sheets.dart';

/// 短剧详情页（电影级深色）。封面英雄 + 渐变标题 + 真实剧集选集。
/// 剧集来自后端 GET /short/info/{id}；点已解锁集播放真实视频。
class DetailScreen extends StatefulWidget {
  final String shortId;
  final String title;
  final String cover;
  final String intro;
  final double price;
  final List<String> labels;
  final int plays;
  final String videoUrl; // 兜底：剧集接不通时仍可播这个

  const DetailScreen({
    super.key,
    this.shortId = '',
    required this.title,
    required this.cover,
    required this.intro,
    required this.price,
    this.labels = const [],
    this.plays = 0,
    this.videoUrl = '',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Episode> _episodes = [];
  bool _loadingEps = true;
  bool _celebrating = false;
  bool _collected = false; // 是否已收藏(收藏按钮接真)

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
    _syncCollected();
  }

  // 同步收藏状态:登录用户拉一次收藏列表,判断本剧是否已收藏。
  Future<void> _syncCollected() async {
    if (widget.shortId.isEmpty || !auth.loggedIn) return;
    try {
      final ids = await Api.collectedIds();
      if (mounted && ids.contains(widget.shortId)) {
        setState(() => _collected = true);
      }
    } catch (_) {/* 拉不到就保持未收藏,用户仍可点收藏 */}
  }

  Future<void> _loadEpisodes() async {
    if (widget.shortId.isEmpty) {
      setState(() => _loadingEps = false);
      return;
    }
    try {
      final eps = await Api.getEpisodes(widget.shortId);
      if (!mounted) return;
      setState(() {
        _episodes = eps;
        _loadingEps = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingEps = false); // 接不通则回退占位
    }
  }

  void _playEpisode(Episode e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          title: widget.title.isEmpty ? 'FalconFlix' : widget.title,
          videoUrl: e.videoUrl.isEmpty ? widget.videoUrl : e.videoUrl,
          poster: widget.cover,
          episodeLabel: e.name,
          episodeId: e.id,
          shortId: widget.shortId,
        ),
      ),
    );
  }

  void _playFallback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          title: widget.title.isEmpty ? 'FalconFlix' : widget.title,
          videoUrl: widget.videoUrl,
          poster: widget.cover,
          episodeLabel: AppLocalizations.of(context).player_episodeNumFmt(1),
          shortId: widget.shortId,
        ),
      ),
    );
  }

  void _playFirst() {
    if (_episodes.isNotEmpty) {
      final first = _episodes.firstWhere((e) => e.unlocked,
          orElse: () => _episodes.first);
      _playEpisode(first);
    } else {
      _playFallback();
    }
  }

  int get _lockedCount => _episodes.where((e) => !e.unlocked).length;

  /// 点锁定集 → 四档解锁（本集 / 后续5集 / 后续10集 / 全集，按剩余锁定集动态显示）。
  /// 若开了「自动解锁」且余额够单集 → 静默直扣这一集（binge 体验），不弹窗。
  Future<void> _showUnlockTiers(Episode e) async {
    if (widget.shortId.isEmpty) return; // 本地兜底片源无真实商品
    if (!auth.loggedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true || !mounted) return;
    }
    await auth.refresh();
    if (!mounted) return;

    final single =
        e.price > 0 ? e.price : (widget.price > 0 ? widget.price : 1);
    // 自动解锁：开关开 + 余额够单集 → 静默直扣这一集。
    if (await AppSettings.autoUnlock() &&
        (auth.profile?.balance ?? 0) >= single) {
      if (!mounted) return;
      final ok = await Api.buyEpisode(e.id);
      if (ok && mounted) {
        await auth.refresh();
        await _loadEpisodes();
        if (mounted) _celebrate();
      }
      return;
    }

    final tiers = _buildTiers(e);
    if (!mounted) return;
    final purchased = await showTieredUnlockSheet(
      context,
      title: widget.title.isEmpty ? e.name : widget.title,
      tiers: tiers,
      onRecharge: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletScreen()),
      ),
    );
    if (purchased == true && mounted) {
      await auth.refresh();
      await _loadEpisodes();
      if (mounted) _celebrate();
    }
  }

  /// 从点击的锁定集 e 起，算四档解锁选项。
  /// 5/10 集 = 多行下单（各集价求和）；全集 = 后端全集商品（type=3，价=剧目价）。
  List<UnlockTierOption> _buildTiers(Episode e) {
    double sumOf(Iterable<Episode> es) =>
        es.fold(0.0, (s, x) => s + (x.price > 0 ? x.price : 0));
    final idx = _episodes.indexOf(e);
    final start = idx < 0 ? 0 : idx;
    final lockedFrom = [
      for (var i = start; i < _episodes.length; i++)
        if (!_episodes[i].unlocked) _episodes[i]
    ];
    final allLocked = _episodes.where((x) => !x.unlocked).toList();
    final tiers = <UnlockTierOption>[];

    final l = AppLocalizations.of(context);
    // 本集
    final one = lockedFrom.isNotEmpty ? lockedFrom.first : e;
    tiers.add((
      label: l.detail_unlockThis,
      count: 1,
      coins: one.price > 0 ? one.price : (widget.price > 0 ? widget.price : 1),
      purchase: () => Api.buyEpisodes([one.id]),
    ));
    // 后续 5 集
    if (lockedFrom.length >= 5) {
      final five = lockedFrom.take(5).toList();
      tiers.add((
        label: l.detail_unlockNext5,
        count: 5,
        coins: sumOf(five),
        purchase: () => Api.buyEpisodes([for (final x in five) x.id]),
      ));
    }
    // 后续 10 集
    if (lockedFrom.length >= 10) {
      final ten = lockedFrom.take(10).toList();
      tiers.add((
        label: l.detail_unlockNext10,
        count: 10,
        coins: sumOf(ten),
        purchase: () => Api.buyEpisodes([for (final x in ten) x.id]),
      ));
    }
    // 全集（剩余所有锁定集）。缺剧目价则按各集求和兜底。
    if (allLocked.length > 1) {
      final dramaPrice = widget.price > 0 ? widget.price : sumOf(allLocked);
      tiers.add((
        label: l.detail_unlockAll,
        count: allLocked.length,
        coins: dramaPrice,
        purchase: () => Api.buyDrama(widget.shortId),
      ));
    }
    return tiers;
  }

  /// 解锁全集（真扣鹰币）。
  void _unlockAll() => _openUnlock(
        label: widget.title.isEmpty ? AppLocalizations.of(context).detail_unlockAll : widget.title,
        count: _lockedCount > 0 ? _lockedCount : (_episodes.isEmpty ? 1 : _episodes.length),
        price: widget.price > 0 ? widget.price : 1,
        purchase: () => Api.buyDrama(widget.shortId),
      );

  /// 登录门槛 → 解锁弹窗 → 成功后刷新剧集/余额 + 庆祝动画。
  /// [autoEligible]=true（仅单集）时，若用户开了「自动解锁」且余额足够，跳过确认弹窗静默直扣。
  Future<void> _openUnlock({
    required String label,
    required int count,
    required double price,
    required Future<bool> Function() purchase,
    bool autoEligible = false,
  }) async {
    if (widget.shortId.isEmpty) return; // 本地兜底片源无真实商品，不走购买
    if (!auth.loggedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true || !mounted) return;
    }
    // 拉最新余额再开弹窗——门槛要准（后端余额不足会抛 500，不能让脏余额放行）。
    await auth.refresh();
    if (!mounted) return;
    // 自动解锁：开了开关 + 单集 + 余额够 → 静默直扣，免每次确认。
    if (autoEligible &&
        await AppSettings.autoUnlock() &&
        (auth.profile?.balance ?? 0) >= price) {
      if (!mounted) return;
      final ok = await purchase();
      if (ok && mounted) {
        await auth.refresh();
        await _loadEpisodes();
        if (mounted) _celebrate();
      }
      return;
    }
    if (!mounted) return;
    final purchased = await showUnlockSheet(
      context,
      title: label,
      count: count,
      price: price,
      onPurchase: purchase,
      onRecharge: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletScreen()),
      ),
    );
    if (purchased == true && mounted) {
      await auth.refresh();
      await _loadEpisodes();
      if (mounted) _celebrate();
    }
  }

  void _celebrate() {
    setState(() => _celebrating = true);
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) setState(() => _celebrating = false);
    });
  }

  void _openDrawer() {
    if (_episodes.isEmpty) return;
    final l = AppLocalizations.of(context);
    showEpisodeDrawer(
      context,
      title: widget.title.isEmpty ? l.player_btnEpisodes : widget.title,
      episodes: [
        for (var i = 0; i < _episodes.length; i++)
          (
            n: i + 1,
            name: _episodes[i].name.isEmpty ? l.player_episodeNumFmt(i + 1) : _episodes[i].name,
            unlocked: _episodes[i].unlocked
          )
      ],
      onPlay: (i) => _playEpisode(_episodes[i]),
      onUnlockAll: _unlockAll,
    );
  }

  String _fmt(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        children: [
          const AmbientBackground(),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _hero(),
              Transform.translate(
                offset: const Offset(0, -42),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gradientText(widget.title, size: 26),
                      const SizedBox(height: 12),
                      _meta(),
                      const SizedBox(height: 16),
                      Text(widget.intro,
                          style: const TextStyle(
                              color: FF.muted, fontSize: 13, height: 1.65)),
                      const SizedBox(height: 20),
                      _actions(),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context).player_btnEpisodes,
                              style: const TextStyle(
                                  color: FF.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          if (!_loadingEps && _episodes.isNotEmpty)
                            Text(AppLocalizations.of(context).detail_episodeCountFmt(_episodes.length),
                                style: const TextStyle(
                                    color: FF.dim, fontSize: 12)),
                          const Spacer(),
                          if (!_loadingEps && _episodes.isNotEmpty)
                            GestureDetector(
                              onTap: _openDrawer,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    gradient: FF.brandGradient,
                                    borderRadius: BorderRadius.circular(999)),
                                child: Text(AppLocalizations.of(context).detail_drawerEpisodes,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _episodesView(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: top + 6,
            left: 12,
            child: _circleBtn(
                Icons.arrow_back_rounded, () => Navigator.pop(context)),
          ),
          if (_celebrating) _celebrationOverlay(),
        ],
      ),
    );
  }

  Widget _celebrationOverlay() {
    final bal = auth.profile?.balance ?? 0;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.62),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: FF.brandGradient,
                boxShadow: [
                  BoxShadow(
                      color: FF.hot.withValues(alpha: 0.6), blurRadius: 44),
                  BoxShadow(
                      color: FF.purple.withValues(alpha: 0.5), blurRadius: 44),
                ],
              ),
              child: const Icon(Icons.lock_open_rounded,
                  color: Colors.white, size: 52),
            )
                .animate()
                .scaleXY(begin: 0.3, duration: 560.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 280.ms),
            const SizedBox(height: 20),
            gradientText(AppLocalizations.of(context).detail_unlockSuccess,
                    size: 24, gradient: FF.brandGradient)
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).detail_coinBalanceFmt(coinStr(bal)),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))
                .animate(delay: 320.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return SizedBox(
      height: 430,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.cover.isNotEmpty)
            CachedNetworkImage(imageUrl: widget.cover, fit: BoxFit.cover)
          else
            Container(color: FF.panel),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0x00000000), FF.bg],
                stops: [0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta() {
    return Row(
      children: [
        for (final l in widget.labels.take(2)) ...[
          GlowChip(l),
          const SizedBox(width: 8),
        ],
        const Icon(Icons.play_arrow_rounded, color: FF.muted, size: 16),
        Text(' ${AppLocalizations.of(context).detail_playsCountFmt(_fmt(widget.plays))}',
            style: const TextStyle(color: FF.muted, fontSize: 12)),
        const Spacer(),
        Text(
            widget.price > 0
                ? AppLocalizations.of(context).detail_priceUnlockFmt(coinStr(widget.price))
                : AppLocalizations.of(context).common_free,
            style: TextStyle(
                color: widget.price > 0 ? FF.gold : FF.teal,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _actions() {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: AppLocalizations.of(context).detail_playNow,
            icon: Icons.play_arrow_rounded,
            height: 48,
            onTap: _playFirst,
          ),
        ),
        const SizedBox(width: 12),
        // 收藏(接真:Api.toggleCollect)——之前是死按钮
        _softBtn(
          _collected ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          onTap: _toggleCollect,
          highlight: _collected,
        ),
        const SizedBox(width: 10),
        // 分享(接真:复用 showShareSheet)——之前是死按钮
        _softBtn(Icons.share_outlined, onTap: () {
          if (widget.shortId.isEmpty) return;
          showShareSheet(context,
              sceneLabel: widget.title,
              shortId: widget.shortId,
              title: widget.title,
              posterUrl: widget.cover);
        }),
      ],
    );
  }

  Future<void> _toggleCollect() async {
    if (widget.shortId.isEmpty) return;
    if (!auth.loggedIn) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final next = !_collected;
    setState(() => _collected = next); // 乐观更新
    try {
      await Api.toggleCollect(widget.shortId);
    } catch (_) {
      if (mounted) setState(() => _collected = !next); // 失败回滚
    }
  }

  Widget _episodesView() {
    if (_loadingEps) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: FF.hot)),
      );
    }
    if (_episodes.isEmpty) {
      // 接不通真实剧集：给一个可播放的兜底入口（首页流带过来的 videoUrl）
      return GestureDetector(
        onTap: widget.videoUrl.isNotEmpty ? _playFallback : null,
        child: Glass(
          radius: 14,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.play_circle_outline_rounded,
                  color: FF.gold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    widget.videoUrl.isNotEmpty
                        ? AppLocalizations.of(context).detail_playThis
                        : AppLocalizations.of(context).detail_noEpisodes,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _episodes.length,
      itemBuilder: (_, i) {
        final e = _episodes[i];
        final locked = !e.unlocked;
        return GestureDetector(
          onTap: locked ? () => _showUnlockTiers(e) : () => _playEpisode(e),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: locked ? FF.line : FF.hot.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${i + 1}',
                    style: TextStyle(
                        color: locked ? FF.dim : FF.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                if (locked)
                  const Icon(Icons.lock_outline, color: FF.dim, size: 11),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(color: Colors.white24)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _softBtn(IconData icon, {VoidCallback? onTap, bool highlight = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: highlight
                  ? FF.gold.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: highlight ? FF.gold : FF.line)),
          child: Icon(icon, color: highlight ? FF.gold : FF.text, size: 20),
        ),
      );
}

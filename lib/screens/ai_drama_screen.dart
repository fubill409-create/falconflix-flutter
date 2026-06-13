import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ix_manifest.dart';
import '../services/ix_progress.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'ix_player_screen.dart'; // Nova 真互动剧播放器
import 'login_screen.dart'; // 投票/解锁前的登录门
import 'spark_screen.dart'; // 客串自己 / AI 入戏（原「AI 玩法」折进来当小玩具）

/// C 位招牌 ·「AI 互动剧」落地页（v0 框架壳，2026-06-05）。
/// 三段式：①王牌片单（星光片场·制作管线，海报未到位前用渐变占位铺满）
///        ②理念宣言（互动剧 = 决策元宇宙的初级形态，Claude 亲笔）
///        ③愿景阶梯流程图（看剧→互动选择→客串自己→应援出道→决策元宇宙，会动）
/// 底部留一个「客串自己」口子，接原 AI 入戏（spark）。
/// 暗色电影感专用（星光片场基调），不走日夜——这是王牌秀场，要炫不要白。
class AiDramaScreen extends StatefulWidget {
  const AiDramaScreen({super.key});

  @override
  State<AiDramaScreen> createState() => _AiDramaScreenState();
}

class _AiDramaScreenState extends State<AiDramaScreen> {
  List<PipelineItem> _pipeline = const [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadPipeline();
  }

  Future<void> _loadPipeline() async {
    if (mounted) setState(() { _loading = true; _error = false; });
    try {
      final rows = await Api.ixPipeline();
      final items = [for (final r in rows) PipelineItem.fromJson(r)];
      if (mounted) setState(() { _pipeline = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  void _openCameo(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const SparkScreen(),
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 110),
              children: [
                _brand(context),
                const SizedBox(height: 14),
                const _NovaDramaSection(), // ① 已上线真互动剧（从 /ix/list 拉，置顶王牌）
                const SizedBox(height: 22),
                _pipelineHeading(context),
                const SizedBox(height: 12),
                _pipelineBody(context),
                const SizedBox(height: 26),
                const _Manifesto(),
                const SizedBox(height: 24),
                const _VisionLadder(),
                const SizedBox(height: 20),
                _cameoCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 制作管线主体：加载中转圈 / 拉取失败可重试 / 空态隐藏 / 有数据走网格。
  Widget _pipelineBody(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: FF.hot, strokeWidth: 2.4),
        ),
      );
    }
    if (_error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: FF.dim, size: 34),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context).common_loadFailed,
                  style: const TextStyle(color: FF.muted, fontSize: 13)),
              const SizedBox(height: 12),
              Bounce(
                onTap: _loadPipeline,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: FF.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(AppLocalizations.of(context).common_retry,
                      style: const TextStyle(
                          color: FF.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_pipeline.isEmpty) return const SizedBox.shrink();
    return _PipelineGrid(items: _pipeline);
  }

  // ───────── 顶部品牌行 ─────────
  Widget _brand(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              gradientText(l.aid_titleHeader, size: 30, gradient: FF.brandGradient),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [FF.orange, FF.gold]),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                        color: FF.gold.withValues(alpha: 0.4), blurRadius: 12),
                  ],
                ),
                child: Text(l.aid_aceBadge,
                    style: const TextStyle(
                        color: Color(0xFF231100),
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.06),
          const SizedBox(height: 6),
          Text(l.aid_tagline,
                  style: const TextStyle(
                      color: FF.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))
              .animate(delay: 120.ms)
              .fadeIn(duration: 600.ms),
        ],
      ),
    );
  }

  Widget _pipelineHeading(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          gradientText(l.aid_pipelineTitle, size: 21, gradient: FF.brandGradient),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(l.aid_pipelineSub,
                style: const TextStyle(
                    color: FF.dim, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ───────── 客串自己（折进来的 AI 入戏）─────────
  Widget _cameoCard(BuildContext context) {
    return Bounce(
      onTap: () => _openCameo(context),
      child: Glass(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [FF.blue, FF.teal]),
                boxShadow: [
                  BoxShadow(
                      color: FF.blue.withValues(alpha: 0.45), blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.face_retouching_natural_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).aid_cameoTitle,
                      style: const TextStyle(
                          color: FF.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(AppLocalizations.of(context).aid_cameoSub,
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
    );
  }
}

// 状态角标（渐变药丸 + 柔光）
Widget _statusBadge(String text, List<Color> colors) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(color: colors.last.withValues(alpha: 0.4), blurRadius: 10),
      ],
    ),
    child: Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1.1)),
  );
}

// ───────────────────────── 片单数据 ─────────────────────────
// 后端 /ix/pipeline 返回 4 状态：制作中 / 选角中 / 已排期 / 已上线。
enum IxStatus { producing, casting, scheduled, released }

IxStatus _statusFrom(String s) {
  switch (s) {
    case 'casting':
      return IxStatus.casting;
    case 'scheduled':
      return IxStatus.scheduled;
    case 'released':
      return IxStatus.released;
    default:
      return IxStatus.producing;
  }
}

/// 制作管线条目（GET /ingest/app/ix/pipeline 的真数据）。
/// casting 走真投票（votes/target/progress/myVoted）；released 带 dramaId 可直接进播放器。
class PipelineItem {
  final String slug;
  final String title;
  final String tagline;
  final IxStatus status;
  final String? posterUrl;
  final String? dramaId;
  int votes;
  int target;
  double progress; // 0..1
  bool myVoted;

  PipelineItem({
    required this.slug,
    required this.title,
    required this.tagline,
    required this.status,
    this.posterUrl,
    this.dramaId,
    this.votes = 0,
    this.target = 0,
    this.progress = 0,
    this.myVoted = false,
  });

  factory PipelineItem.fromJson(Map<String, dynamic> j) {
    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return PipelineItem(
      slug: '${j['slug'] ?? ''}',
      title: '${j['title'] ?? ''}',
      tagline: '${j['tagline'] ?? ''}',
      status: _statusFrom('${j['status'] ?? ''}'),
      posterUrl: str(j['posterUrl']),
      dramaId: str(j['dramaId']),
      votes: (j['votes'] is num) ? (j['votes'] as num).toInt() : 0,
      target: (j['target'] is num) ? (j['target'] as num).toInt() : 0,
      progress: (j['progress'] is num) ? (j['progress'] as num).toDouble() : 0,
      myVoted: j['myVoted'] == true,
    );
  }
}

// 海报基址（dramaId/title → 海报映射等仍可用）。
const _kPosterBase = 'https://falconflix.app/media/posters';

// ───────────────────────── 片单网格 ─────────────────────────
class _PipelineGrid extends StatelessWidget {
  final List<PipelineItem> items;
  const _PipelineGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _PipelineCard(item: items[i])
          .animate(delay: (60 * i + 120).ms)
          .fadeIn(duration: 460.ms)
          .slideY(begin: 0.1, curve: Curves.easeOut),
    );
  }
}

class _PipelineCard extends StatefulWidget {
  final PipelineItem item;
  const _PipelineCard({required this.item});

  @override
  State<_PipelineCard> createState() => _PipelineCardState();
}

class _PipelineCardState extends State<_PipelineCard> {
  bool _voting = false;

  PipelineItem get item => widget.item;

  // 渐变占位用色（无海报时铺满 + 兜底排版）。按 slug 派生稳定的双色，避免全一样。
  List<Color> get _accent {
    const palettes = <List<Color>>[
      [Color(0xFFFF6FB5), Color(0xFFB46BFF)],
      [Color(0xFF3E7BFA), Color(0xFF7A5CFF)],
      [Color(0xFFFFA24B), Color(0xFFFF5E8A)],
      [Color(0xFFB46BFF), Color(0xFFFF6FB5)],
      [Color(0xFFE0A23B), Color(0xFFFF7A59)],
      [Color(0xFF5A6CFF), Color(0xFF9B5CFF)],
    ];
    final key = item.slug.isNotEmpty ? item.slug : item.title;
    final h = key.isEmpty ? 0 : key.codeUnits.fold<int>(0, (a, b) => a + b);
    return palettes[h % palettes.length];
  }

  // 登录门 → 真投票 → 乐观更新 votes/progress/myVoted。失败静默回退。
  Future<void> _vote() async {
    if (item.myVoted || _voting) return;
    if (!auth.loggedIn) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    setState(() => _voting = true);
    // 乐观：先 +1、点亮已投，进度按 target 推。
    final prevVotes = item.votes;
    final prevProgress = item.progress;
    final prevVoted = item.myVoted;
    setState(() {
      item.votes = prevVotes + 1;
      item.myVoted = true;
      if (item.target > 0) {
        item.progress = (item.votes / item.target).clamp(0.0, 1.0);
      }
    });
    try {
      final r = await Api.ixVote(item.slug);
      if (!mounted) return;
      setState(() {
        item.votes = (r['votes'] is num) ? (r['votes'] as num).toInt() : item.votes;
        item.target = (r['target'] is num) ? (r['target'] as num).toInt() : item.target;
        item.progress =
            (r['progress'] is num) ? (r['progress'] as num).toDouble() : item.progress;
        item.myVoted = r['myVoted'] == true || item.myVoted;
        _voting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        item.votes = prevVotes;
        item.progress = prevProgress;
        item.myVoted = prevVoted;
        _voting = false;
      });
    }
  }

  // released：点开真互动剧播放器（带 dramaId）。
  void _openReleased() {
    final id = item.dramaId;
    if (id == null || id.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => IxPlayerScreen(
          dramaId: id, title: item.title.isEmpty ? null : item.title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final casting = item.status == IxStatus.casting;
    final released =
        item.status == IxStatus.released && (item.dramaId?.isNotEmpty ?? false);
    final accent = _accent;
    // 英文海报自带片名/调性字（烧在图里），有海报时不再叠任何文字,
    // 免得 App 文字压住海报排版（用户 2026-06-13 拍板）；暗角也只留给投票条用。
    final hasPoster = item.posterUrl != null && item.posterUrl!.isNotEmpty;
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: accent,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 有海报用图（cover 铺满）；没海报走渐变占位 + 首字水印
            if (hasPoster)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.posterUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              )
            else if (item.title.isNotEmpty)
              Positioned(
                right: -10,
                bottom: 14,
                child: Text(
                  item.title.substring(0, 1),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.16),
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      height: 0.8),
                ),
              ),
            // 暗角：有海报时只给底部投票条留一道浅渐变，别盖海报
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: hasPoster
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x77000000)],
                          stops: [0.78, 1],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x22000000), Color(0xDD000000)],
                          stops: [0.35, 1],
                        ),
                ),
              ),
            ),
            // 状态角标
            Positioned(
              left: 8,
              top: 8,
              child: _PipelineStatusBadge(status: item.status),
            ),
            // released：右上角播放钮提示「可播放」
            if (released)
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 30,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
              ),
            // 有海报：海报即卡面，只叠投票条；无海报：标题+钩子兜底
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hasPoster) ...[
                    Text(item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            shadows: [Shadow(blurRadius: 5, color: Colors.black)])),
                    const SizedBox(height: 3),
                    Text(item.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 10.5,
                            height: 1.3,
                            fontWeight: FontWeight.w500)),
                  ],
                  if (casting) ...[
                    const SizedBox(height: 8),
                    _CastVoteBar(
                      value: item.target > 0
                          ? (item.votes / item.target).clamp(0.0, 1.0)
                          : item.progress.clamp(0.0, 1.0),
                      voted: item.myVoted,
                      busy: _voting,
                      onTap: _vote,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // released 整卡可点进播放器；其余卡（含 casting）卡面本身不抢点击——
    // casting 的投票交互在卡内 _CastVoteBar 上。
    if (released) {
      return Bounce(onTap: _openReleased, child: card);
    }
    return card;
  }
}

// 制作管线状态角标：4 状态各自配色。
class _PipelineStatusBadge extends StatelessWidget {
  final IxStatus status;
  const _PipelineStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (status) {
      case IxStatus.casting:
        return _statusBadge(
            l.aid_castingBadge, const [Color(0xFF4BC0FF), Color(0xFF6B7BFF)]);
      case IxStatus.scheduled:
        // 「已排期」暂无 l10n key，硬编码中文（用户拍板：片名/状态走真后端文案为主）。
        return _statusBadge(
            '即将上线', const [Color(0xFF7A5CFF), Color(0xFFB46BFF)]);
      case IxStatus.released:
        return _statusBadge(
            l.aid_aceCardBadge, const [Color(0xFFFFC24B), Color(0xFFFF7A59)]);
      case IxStatus.producing:
        return _ProducingBadge();
    }
  }
}

// 制作中角标：带一个流光小点（在做的感觉）
class _ProducingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xE6121018),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FF.gold.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: FF.gold),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(begin: 0.3, duration: 800.ms),
          const SizedBox(width: 5),
          Text(AppLocalizations.of(context).aid_producingBadge,
              style: const TextStyle(
                  color: FF.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.1)),
        ],
      ),
    );
  }
}

// 选角投票条：真热度（votes/target）+ 可点的「想看/应援」按钮（真调 Api.ixVote）。
// 已投：高亮成「已想看」不可再点；投票中：禁用按钮。
class _CastVoteBar extends StatelessWidget {
  final double value; // 0..1
  final bool voted;
  final bool busy;
  final VoidCallback onTap;
  const _CastVoteBar({
    required this.value,
    required this.voted,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.how_to_vote_rounded,
                color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Expanded(
              child: Text(l.aid_castVoteFmt(pct.toString()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 5, color: Colors.white.withValues(alpha: 0.22)),
              FractionallySizedBox(
                widthFactor: value.clamp(0.05, 1),
                child: Container(
                  height: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, Color(0xFFFFE08A)]),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 想看/应援按钮：未投亮色可点；已投置灰显「已想看」。
        GestureDetector(
          onTap: (voted || busy) ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: voted
                  ? null
                  : const LinearGradient(colors: [Color(0xFFFF7A59), Color(0xFFFFC24B)]),
              color: voted ? const Color(0x33FFFFFF) : null,
              border: voted
                  ? Border.all(color: Colors.white.withValues(alpha: 0.4))
                  : null,
            ),
            child: busy
                ? const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          voted
                              ? Icons.check_rounded
                              : Icons.favorite_rounded,
                          color: voted ? Colors.white : const Color(0xFF231100),
                          size: 13),
                      const SizedBox(width: 4),
                      Text(voted ? '已想看' : '想看·应援',
                          style: TextStyle(
                              color: voted
                                  ? Colors.white
                                  : const Color(0xFF231100),
                              fontSize: 11,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── 理念宣言 ─────────────────────────
class _Manifesto extends StatelessWidget {
  const _Manifesto();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = <String>[
      l.aid_manifesto1,
      l.aid_manifesto2,
      l.aid_manifesto3,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Glass(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: FF.gold.withValues(alpha: 0.9), size: 18),
                const SizedBox(width: 8),
                Text(l.aid_manifestoHeader,
                    style: const TextStyle(
                        color: FF.dim,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < lines.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(lines[i],
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 16.5,
                            height: 1.5,
                            fontWeight: FontWeight.w700))
                    .animate(delay: (260 * i + 200).ms)
                    .fadeIn(duration: 700.ms)
                    .slideX(begin: 0.06, curve: Curves.easeOut),
              ),
            const SizedBox(height: 10),
            const Divider(color: Color(0x22FFFFFF), height: 1),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: FF.muted,
                    fontSize: 14,
                    height: 1.7,
                    fontWeight: FontWeight.w600),
                children: [
                  TextSpan(text: l.aid_metaversePre),
                  TextSpan(
                      text: l.aid_metaverseEmph,
                      style: const TextStyle(
                          color: FF.hot, fontWeight: FontWeight.w900)),
                  TextSpan(text: l.aid_metaversePost),
                ],
              ),
            ).animate(delay: 900.ms).fadeIn(duration: 800.ms),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── 愿景阶梯流程图 ─────────────────────────
class _LadderStep {
  final IconData icon;
  final String title;
  final String sub;
  final List<Color> accent;
  final bool destination;
  const _LadderStep(this.icon, this.title, this.sub, this.accent,
      {this.destination = false});
}

/// 愿景阶梯（i18n 化）：常量 icon/color 部分保留 const；title/sub 按 context 取本地化。
List<_LadderStep> _ladderFor(BuildContext context) {
  final l = AppLocalizations.of(context);
  return [
    _LadderStep(Icons.play_circle_fill_rounded, l.aid_step1Title,
        l.aid_step1Sub, const [FF.blue, FF.teal]),
    _LadderStep(Icons.alt_route_rounded, l.aid_step2Title,
        l.aid_step2Sub, const [FF.teal, FF.purple]),
    _LadderStep(Icons.face_retouching_natural_rounded, l.aid_step3Title,
        l.aid_step3Sub, const [FF.purple, FF.hot]),
    _LadderStep(Icons.local_fire_department_rounded, l.aid_step4Title,
        l.aid_step4Sub, const [FF.hot, FF.orange]),
    _LadderStep(Icons.auto_awesome_rounded, l.aid_step5Title,
        l.aid_step5Sub, const [FF.orange, FF.gold],
        destination: true),
  ];
}

class _VisionLadder extends StatelessWidget {
  const _VisionLadder();

  @override
  Widget build(BuildContext context) {
    final ladder = _ladderFor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 16),
            child: Row(
              children: [
                gradientText(AppLocalizations.of(context).aid_ladderHeader,
                    size: 19, gradient: FF.brandGradient),
              ],
            ),
          ),
          for (int i = 0; i < ladder.length; i++)
            _LadderNode(
              step: ladder[i],
              index: i + 1,
              isLast: i == ladder.length - 1,
            ),
        ],
      ),
    );
  }
}

class _LadderNode extends StatelessWidget {
  final _LadderStep step;
  final int index;
  final bool isLast;
  const _LadderNode(
      {required this.step, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final accent = step.accent.first;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧发光脊柱 + 节点
          SizedBox(
            width: 52,
            child: Column(
              children: [
                _GlowNode(icon: step.icon, accent: step.accent),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accent.withValues(alpha: 0.7),
                            accent.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右侧内容卡
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: step.destination
                      ? LinearGradient(colors: [
                          step.accent.first.withValues(alpha: 0.22),
                          step.accent.last.withValues(alpha: 0.12),
                        ])
                      : null,
                  color: step.destination ? null : const Color(0x14FFFFFF),
                  border: Border.all(
                      color: step.destination
                          ? step.accent.last.withValues(alpha: 0.55)
                          : const Color(0x1AFFFFFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(step.title,
                            style: TextStyle(
                                color: step.destination ? FF.gold : FF.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w900)),
                        if (step.destination) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.flag_rounded,
                              color: FF.gold.withValues(alpha: 0.9), size: 15),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(step.sub,
                        style: const TextStyle(
                            color: FF.muted,
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: (110 * index).ms).fadeIn(duration: 500.ms).slideX(
        begin: 0.08, curve: Curves.easeOut);
  }
}

class _GlowNode extends StatelessWidget {
  final IconData icon;
  final List<Color> accent;
  const _GlowNode({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: accent,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: accent.first.withValues(alpha: 0.5), blurRadius: 16),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1, end: 1.06, duration: 1600.ms, curve: Curves.easeInOut);
  }
}

// ───────────────────────── 已上线真互动剧（从 /ix/list 拉，Nova 推过来的）─────────────────────────
class _NovaDramaSection extends StatefulWidget {
  const _NovaDramaSection();
  @override
  State<_NovaDramaSection> createState() => _NovaDramaSectionState();
}

class _NovaDramaSectionState extends State<_NovaDramaSection> {
  List<IxDramaCard> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await http
          .get(Uri.parse('${Api.baseUrl}/ix/list'))
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        final j = jsonDecode(utf8.decode(r.bodyBytes));
        final data = (j is Map && j['data'] is List) ? (j['data'] as List) : const [];
        final items = [
          for (final x in data)
            if (x is Map) IxDramaCard.fromJson(x.cast<String, dynamic>())
        ];
        if (mounted) setState(() { _items = items; _loading = false; });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _items.isEmpty) return const SizedBox.shrink(); // 没真剧就不占地方
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                gradientText(AppLocalizations.of(context).aid_liveTitle,
                    size: 21, gradient: FF.brandGradient),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(AppLocalizations.of(context).aid_liveSub,
                      style: const TextStyle(
                          color: FF.dim, fontSize: 11.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          for (int i = 0; i < _items.length; i++) ...[
            _NovaCard(item: _items[i]),
            if (i != _items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _NovaCard extends StatefulWidget {
  final IxDramaCard item;
  const _NovaCard({required this.item});

  @override
  State<_NovaCard> createState() => _NovaCardState();
}

class _NovaCardState extends State<_NovaCard> {
  int _unlocked = 0; // 已解锁结局数

  @override
  void initState() {
    super.initState();
    IxProgress.tick.addListener(_loadDex);
    _loadDex();
  }

  @override
  void didUpdateWidget(covariant _NovaCard old) {
    super.didUpdateWidget(old);
    if (old.item.dramaId != widget.item.dramaId) _loadDex();
  }

  @override
  void dispose() {
    IxProgress.tick.removeListener(_loadDex);
    super.dispose();
  }

  Future<void> _loadDex() async {
    final s = await IxProgress.dex(widget.item.dramaId);
    if (mounted) setState(() => _unlocked = s.length);
  }

  @override
  Widget build(BuildContext context) => _build(context, _unlocked);

  IxDramaCard get item => widget.item;

  // 剧名只显示英文：清单 title 形如「七个爱我的方式 / Seven Ways to Be Loved」，
  // 取斜杠后段（英文）；没有斜杠就原样。它们是英文剧，不跟随系统语言（用户拍板）。
  String _mainTitle() {
    final t = item.title;
    final i = t.indexOf('/');
    final base = i > 0 ? t.substring(i + 1) : t;
    return base.replaceAll(RegExp(r'（[^）]*）'), '').trim();
  }

  // dramaId/title → 海报。Nova 推过来的剧，已知映射这里加；未知 fallback 渐变。
  String? _posterUrl() {
    if (item.title.contains('七个爱我')) return '$_kPosterBase/sevenways.png';
    return null;
  }

  Widget _gradientFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A1545), Color(0xFF7A1E4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );

  Widget _build(BuildContext context, int unlocked) {
    final posterUrl = _posterUrl();
    return Bounce(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => IxPlayerScreen(dramaId: item.dramaId, title: _mainTitle()),
      )),
      child: Container(
        height: 200, // 王牌大一号
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: FF.purple.withValues(alpha: 0.45),
                blurRadius: 26,
                offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 海报背景图
              if (posterUrl != null)
                CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _gradientFallback(),
                  errorWidget: (_, __, ___) => _gradientFallback(),
                )
              else
                _gradientFallback(),
              // 暗角
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Colors.transparent, Color(0xEE000000)],
                    stops: [0, 0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 14,
                child: _statusBadge(AppLocalizations.of(context).aid_aceCardBadge,
                    const [Color(0xFFFFC24B), Color(0xFFFF7A59)]),
              ),
              // 结局图鉴角标（看过 X / 总 Y）—— 没看过任何结局也显示，告诉你"有 Y 种结局"
              if (item.endingCount > 0)
                Positioned(
                  right: 14,
                  top: 14,
                  child: _DexBadge(unlocked: unlocked, total: item.endingCount),
                ),
              const Positioned(
                right: 16,
                top: 56,
                child: Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 56),
              ),
              Positioned(
                left: 16,
                right: 80,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_mainTitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 结局图鉴角标：📖 X / Y。X=已看过的结局数，Y=该剧总结局数。
/// 满了变金色高亮（"全收集"）。
class _DexBadge extends StatelessWidget {
  final int unlocked;
  final int total;
  const _DexBadge({required this.unlocked, required this.total});
  @override
  Widget build(BuildContext context) {
    final all = unlocked >= total && total > 0;
    final colors = all
        ? const [Color(0xFFFFD75A), Color(0xFFFFA630)] // 金
        : const [Color(0xCC000000), Color(0xAA000000)]; // 暗
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: all ? 0.9 : 0.35), width: 1),
        boxShadow: all
            ? [BoxShadow(color: const Color(0xFFFFA630).withValues(alpha: 0.5), blurRadius: 10)]
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.menu_book_rounded,
            color: all ? const Color(0xFF231100) : Colors.white, size: 12),
        const SizedBox(width: 4),
        Text('$unlocked / $total',
            style: TextStyle(
                color: all ? const Color(0xFF231100) : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                height: 1.1)),
      ]),
    );
  }
}

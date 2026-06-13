import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/community_post.dart';
import '../models/privilege.dart';
import '../models/time_label.dart';
import '../state/community_store.dart';
import '../widgets/content_filter.dart';
import '../widgets/ugc_actions.dart';
import '../theme.dart';
import '../ui/kit.dart';
import '../ui/level_gate.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

/// 社区动态流页面（阶段3）。
///
/// 电影级深色 + 环境光 + 毛玻璃卡，和「我的 / AI 互动」一脉相承。
/// 用户发的剧评/安利在这里汇成一条流；可点赞、可点进附带的剧去追。
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    community.ensureSeeded();
    // 拉黑名单:登录用户进社区时拉一次,据此隐藏被拉黑者的帖子(苹果 G1.2)。
    if (Api.hasToken) {
      Api.myBlockedIds()
          .then((ids) => community.setBlocked(ids))
          .catchError((_) => <String>{});
    }
  }

  Future<void> _openComposer({
    String? dramaId,
    String? dramaTitle,
    String? dramaPoster,
  }) async {
    // V 级别门槛：发动态 = V10（防白嫖刷屏；浏览/点赞 V1 免费）。门槛在 privilege.dart 一处可调。
    if (!await requireLevel(context, Feature.postCommunity)) return;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostComposerScreen(
          dramaId: dramaId,
          dramaTitle: dramaTitle,
          dramaPoster: dramaPoster,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: ListenableBuilder(
                    listenable: community,
                    builder: (context, _) {
                      final posts = community.posts;
                      if (posts.isEmpty) return _empty();
                      return RefreshIndicator(
                        color: FF.hot,
                        backgroundColor: FF.panel,
                        onRefresh: () async {
                          await Future<void>.delayed(
                              const Duration(milliseconds: 600));
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 120),
                          itemCount: posts.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, i) => _PostCard(
                            post: posts[i],
                            onLike: () => community.toggleLike(posts[i]),
                            onOpenDrama: () => _openDrama(posts[i]),
                            onBlocked: () => setState(() =>
                                community.hideByAuthor(posts[i].authorId)),
                          )
                              .animate()
                              .fadeIn(duration: 320.ms, delay: (i * 50).ms)
                              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 发动态：底部居中正经按钮（修掉之前错位/出屏的 Scaffold FAB）。
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: _ComposeFab(onTap: () => _openComposer()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDrama(CommunityPost p) {
    if (p.dramaId == null || p.dramaId!.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          shortId: p.dramaId!,
          title: p.dramaTitle ?? '',
          cover: p.dramaPoster ?? '',
          intro: '',
          price: 0,
        ),
      ),
    );
  }

  Widget _header() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: FF.text, size: 20),
          ),
          Expanded(child: gradientText(l.com2_title, size: 24)),
          GlowChip(l.com2_chipPlaza, color: FF.purple),
        ],
      ),
    );
  }

  Widget _empty() {
    final l = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.forum_outlined,
            color: FF.dim.withValues(alpha: 0.6), size: 56),
        const SizedBox(height: 16),
        Center(
          child: Text(l.com2_emptyHint,
              style: const TextStyle(color: FF.dim, fontSize: 14)),
        ),
      ],
    );
  }
}

/// 发动态悬浮按钮（渐变药丸 + 柔光）。
class _ComposeFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ComposeFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Bounce(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: FF.brandGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                  color: FF.hot.withValues(alpha: 0.4),
                  blurRadius: 26,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).com2_btnPost,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
  }
}

/// 单条动态卡。
class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onOpenDrama;
  final VoidCallback onBlocked;
  const _PostCard(
      {required this.post, required this.onLike, required this.onOpenDrama, required this.onBlocked});

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _authorRow(context),
          const SizedBox(height: 12),
          Text(post.text,
              style: const TextStyle(
                  color: FF.text, fontSize: 15, height: 1.5)),
          if (post.hasDrama) ...[
            const SizedBox(height: 12),
            _dramaCard(context),
          ],
          const SizedBox(height: 6),
          _actionRow(),
        ],
      ),
    );
  }

  Widget _authorRow(BuildContext context) {
    final hasAvatar = post.authorAvatar.startsWith('http');
    final initial =
        post.authorName.isNotEmpty ? post.authorName.characters.first : 'F';
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, gradient: FF.brandGradient),
          child: hasAvatar
              ? Image.network(post.authorAvatar,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initialText(initial))
              : _initialText(initial),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(post.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: FF.text,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700)),
                  ),
                  if (post.authorVip) ...[
                    const SizedBox(width: 6),
                    const GlowChip('VIP'),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(relativeTimeLabel(post.createdAt, AppLocalizations.of(context)),
                  style: const TextStyle(color: FF.dim, fontSize: 11.5)),
            ],
          ),
        ),
        // 举报 / 拉黑 入口(苹果 G1.2 UGC 合规)
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 20,
          icon: const Icon(Icons.more_horiz, color: FF.dim),
          onPressed: () => showUgcSheet(
            context,
            contentType: 'post',
            contentId: post.id,
            targetUserId: post.authorId,
            targetName: post.authorName,
            onBlocked: onBlocked,
          ),
        ),
      ],
    );
  }

  Widget _initialText(String s) => Text(s.toUpperCase(),
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));

  Widget _dramaCard(BuildContext context) {
    final hasPoster =
        (post.dramaPoster ?? '').startsWith('http');
    return Bounce(
      onTap: onOpenDrama,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FF.line),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 46,
                height: 62,
                decoration: const BoxDecoration(gradient: FF.brandGradient),
                child: hasPoster
                    ? Image.network(post.dramaPoster!,
                        width: 46,
                        height: 62,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _posterFallback())
                    : _posterFallback(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).com2_watching,
                      style: const TextStyle(color: FF.dim, fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(
                      post.dramaTitle ??
                          AppLocalizations.of(context).com2_fallbackDrama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: FF.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded,
                color: FF.hot, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _posterFallback() => const Center(
      child: Icon(Icons.movie_rounded, color: Colors.white, size: 20));

  Widget _actionRow() {
    return Row(
      children: [
        Bounce(
          onTap: onLike,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Icon(
                    post.liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: post.liked ? FF.hot : FF.dim,
                    size: 19),
                const SizedBox(width: 5),
                Text('${post.likeCount}',
                    style: TextStyle(
                        color: post.liked ? FF.hot : FF.dim,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.mode_comment_outlined, color: FF.dim, size: 18),
              const SizedBox(width: 5),
              Text('${post.commentCount}',
                  style: const TextStyle(
                      color: FF.dim, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 发动态页：正文 + 可选附带剧 + 发布。未登录先引导登录。
class PostComposerScreen extends StatefulWidget {
  final String? dramaId;
  final String? dramaTitle;
  final String? dramaPoster;
  const PostComposerScreen(
      {super.key, this.dramaId, this.dramaTitle, this.dramaPoster});

  @override
  State<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends State<PostComposerScreen> {
  final _controller = TextEditingController();
  bool _attachDrama = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasDrama =>
      (widget.dramaTitle != null && widget.dramaTitle!.trim().isNotEmpty);

  bool get _canPublish => _controller.text.trim().isNotEmpty;

  Future<void> _publish() async {
    if (!auth.loggedIn) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (ok == true) auth.refresh();
      return; // 登录回来后让用户再点一次发布，避免误发
    }
    if (!_canPublish) return;
    // 内容过滤(苹果 G1.2):违规词即时拦截,发不出去
    if (!ContentFilter.guard(context, _controller.text)) return;
    community.publish(
      text: _controller.text,
      dramaId: _attachDrama ? widget.dramaId : null,
      dramaTitle: _attachDrama ? widget.dramaTitle : null,
      dramaPoster: _attachDrama ? widget.dramaPoster : null,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(AppLocalizations.of(context).com2_publishedToast,
          style: const TextStyle(color: Colors.white)),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(6, 8, 6, 24),
                    children: [
                      Glass(
                        radius: 18,
                        child: TextField(
                          controller: _controller,
                          maxLines: 6,
                          minLines: 6,
                          maxLength: 500,
                          autofocus: true,
                          cursorColor: FF.hot,
                          style: const TextStyle(
                              color: FF.text, fontSize: 15, height: 1.5),
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).com2_postHint,
                            hintStyle: const TextStyle(
                                color: FF.dim, fontSize: 15),
                            border: InputBorder.none,
                            counterStyle: const TextStyle(color: FF.dim),
                          ),
                        ),
                      ),
                      if (_hasDrama) ...[
                        const SizedBox(height: 14),
                        _attachRow(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: FF.text, size: 20),
          ),
          Expanded(
            child: Text(AppLocalizations.of(context).com2_btnPost,
                style: const TextStyle(
                    color: FF.text, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          Bounce(
            onTap: _publish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: FF.brandGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                      color: FF.hot.withValues(
                          alpha: _canPublish ? 0.4 : 0.0),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Opacity(
                opacity: _canPublish ? 1 : 0.5,
                child: Text(AppLocalizations.of(context).com2_publish,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachRow() {
    final hasPoster = (widget.dramaPoster ?? '').startsWith('http');
    return Glass(
      radius: 16,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 42,
              height: 58,
              decoration: const BoxDecoration(gradient: FF.brandGradient),
              child: hasPoster
                  ? Image.network(widget.dramaPoster!,
                      width: 42,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.movie_rounded,
                              color: Colors.white, size: 18)))
                  : const Center(
                      child: Icon(Icons.movie_rounded,
                          color: Colors.white, size: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).com2_attachDrama,
                    style: const TextStyle(color: FF.dim, fontSize: 11)),
                const SizedBox(height: 3),
                Text(widget.dramaTitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: FF.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Switch(
            value: _attachDrama,
            activeThumbColor: Colors.white,
            activeTrackColor: FF.hot,
            inactiveTrackColor: FF.line,
            onChanged: (v) => setState(() => _attachDrama = v),
          ),
        ],
      ),
    );
  }
}

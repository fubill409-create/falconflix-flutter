import 'package:flutter/foundation.dart';

import '../auth.dart';
import '../models/community_post.dart';

/// 社区动态流的内存 store（框架先行）。
///
/// 现阶段帖子放在内存里：开局塞几条演示帖把动态流的样子撑起来，用户能发帖、
/// 能点赞，立刻看到自己发的内容冒到顶部——整条交互链路真跑通。
/// 后端 d_community_post 端点补好、随生产 jar 一起部署后，把 load()/publish()/
/// toggleLike() 三处换成真接口即可，UI 不动。
class CommunityStore extends ChangeNotifier {
  final List<CommunityPost> _posts = [];
  bool _seeded = false;

  List<CommunityPost> get posts => List.unmodifiable(_posts);
  bool get isEmpty => _posts.isEmpty;

  /// 进页面时调用：首次注入演示帖（只注入一次，避免重进重复）。
  void ensureSeeded() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    _posts.addAll([
      CommunityPost(
        id: 'seed-1',
        authorName: '追剧的橙子',
        authorVip: true,
        createdAt: now.subtract(const Duration(minutes: 12)),
        text: '《中东食神》第3集那段沙漠厨房太顶了，看饿了😋 谁还没追快冲！',
        dramaId: '9001',
        dramaTitle: '中东食神',
        likeCount: 38,
        commentCount: 6,
      ),
      CommunityPost(
        id: 'seed-2',
        authorName: 'Luna 的小迷妹',
        createdAt: now.subtract(const Duration(hours: 2)),
        text: '机器人女友的结局我哭了，AI 也能有这么细腻的感情线，编剧封神。',
        dramaId: '9002',
        dramaTitle: '机器人女友',
        likeCount: 21,
        commentCount: 3,
      ),
      CommunityPost(
        id: 'seed-3',
        authorName: '夜猫子观影团',
        createdAt: now.subtract(const Duration(hours: 7)),
        text: '今晚开个追剧夜，鹰眼精选短片刷了一整个合集，质量真的稳。有一起的吗～',
        likeCount: 14,
        commentCount: 9,
      ),
    ]);
  }

  /// 发布一条新帖：作者取当前登录资料，置顶插入，立刻通知刷新。
  CommunityPost publish({
    required String text,
    String? dramaId,
    String? dramaTitle,
    String? dramaPoster,
  }) {
    final p = auth.profile;
    final post = CommunityPost(
      id: 'me-${DateTime.now().millisecondsSinceEpoch}',
      authorName: p?.displayName ?? '我',
      authorAvatar: (p?.avatar ?? '').startsWith('http') ? p!.avatar : '',
      authorVip: p?.isVip ?? false,
      createdAt: DateTime.now(),
      text: text.trim(),
      dramaId: dramaId,
      dramaTitle: dramaTitle,
      dramaPoster: dramaPoster,
    );
    _posts.insert(0, post);
    notifyListeners();
    return post;
  }

  /// 点赞切换（本地乐观）。
  void toggleLike(CommunityPost post) {
    post.liked = !post.liked;
    post.likeCount += post.liked ? 1 : -1;
    if (post.likeCount < 0) post.likeCount = 0;
    notifyListeners();
  }
}

/// 全局单例：动态流页面/发帖页/分享面板共用。
final community = CommunityStore();

/// 社区动态帖子模型。
///
/// 阶段3「App 自有社区动态流」：用户发文 + 可选附带正在追的剧（海报卡）。
/// 框架先行：先用本地种子/内存 store 跑通 UI，后端 d_community_post 端点随后补上、
/// 一起部署。后端就绪后 fromJson 直接对接（字段名按后端 R.ok 返回的 data 调整）。
class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar; // 头像 url（空则用首字母圆球）
  final bool authorVip;
  final DateTime createdAt;
  final String text;

  // 可选：附带的剧（从分享面板「动态」带进来）。
  final String? dramaId;
  final String? dramaTitle;
  final String? dramaPoster;

  int likeCount;
  int commentCount;
  bool liked;

  CommunityPost({
    required this.id,
    required this.authorName,
    this.authorAvatar = '',
    this.authorVip = false,
    required this.createdAt,
    required this.text,
    this.dramaId,
    this.dramaTitle,
    this.dramaPoster,
    this.likeCount = 0,
    this.commentCount = 0,
    this.liked = false,
  });

  bool get hasDrama =>
      (dramaTitle != null && dramaTitle!.trim().isNotEmpty) ||
      (dramaPoster != null && dramaPoster!.trim().isNotEmpty);

  /// 友好相对时间：刚刚 / x分钟前 / x小时前 / x天前 / 月-日。
  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${createdAt.month}-${createdAt.day.toString().padLeft(2, '0')}';
  }

  factory CommunityPost.fromJson(Map<String, dynamic> j) {
    DateTime parseTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    return CommunityPost(
      id: '${j['id'] ?? ''}',
      authorName: '${j['userName'] ?? j['nickName'] ?? '鹰眼用户'}',
      authorAvatar: '${j['avatar'] ?? ''}',
      authorVip: '${j['vipStatus'] ?? ''}' == '1',
      createdAt: parseTime(j['createTime'] ?? j['createdAt']),
      text: '${j['content'] ?? j['text'] ?? ''}',
      dramaId: j['shortId'] == null ? null : '${j['shortId']}',
      dramaTitle: j['shortName']?.toString(),
      dramaPoster: j['shortImage']?.toString(),
      likeCount: parseInt(j['likeCount']),
      commentCount: parseInt(j['commentCount']),
      liked: '${j['liked'] ?? ''}' == 'true' || j['liked'] == true,
    );
  }
}

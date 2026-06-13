// UGC 合规交互(苹果 G1.2):举报 + 拉黑。可复用于社区动态、AI 聊天、用户资料、评论。
//
// 用法:
//   showUgcSheet(context, contentType: 'post', contentId: p.id, targetUserId: p.authorId,
//                targetName: p.authorName, onBlocked: () => reload());
//
// 文案中英双语自包含(按当前 locale 切),不依赖 l10n 重新生成,保证可编译。
import 'package:flutter/material.dart';
import '../api/api.dart';

bool _zh(BuildContext c) => Localizations.localeOf(c).languageCode == 'zh';

// 举报原因:code 必须与后端 REPORT_REASONS 一致
const _reasons = <String, List<String>>{
  // code: [中文, English]
  'porn': ['色情低俗', 'Pornography / Nudity'],
  'violence': ['暴力血腥', 'Violence / Gore'],
  'hate': ['仇恨言论', 'Hate speech'],
  'harassment': ['骚扰辱骂', 'Harassment / Bullying'],
  'spam_ad': ['垃圾广告', 'Spam / Ads'],
  'scam_fraud': ['诈骗信息', 'Scam / Fraud'],
  'illegal': ['违法内容', 'Illegal content'],
  'privacy': ['侵犯隐私', 'Privacy violation'],
  'minor': ['危害未成年人', 'Child safety'],
  'copyright': ['侵权盗版', 'Copyright infringement'],
  'other': ['其他', 'Other'],
};

/// 弹出"举报 / 拉黑"操作表。targetUserId 为空时只显示举报。
Future<void> showUgcSheet(
  BuildContext context, {
  required String contentType, // post/comment/chat/profile/avatar/drama
  String? contentId,
  String? targetUserId,
  String? targetName,
  VoidCallback? onBlocked,
}) async {
  final zh = _zh(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF161020),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Container(width: 36, height: 4, decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Color(0xFFFF6B81)),
            title: Text(zh ? '举报' : 'Report',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            subtitle: Text(zh ? '举报违规内容,我们 24 小时内处理' : 'Report objectionable content (handled in 24h)',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () async {
              Navigator.pop(sheetCtx);
              await _showReportReasons(context,
                  contentType: contentType, contentId: contentId, targetUserId: targetUserId);
            },
          ),
          if (targetUserId != null && targetUserId.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.block, color: Color(0xFFFFB020)),
              title: Text(zh ? '拉黑此用户' : 'Block this user',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              subtitle: Text(zh ? '不再看到 TA 的任何内容' : "Hide all of this user's content",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _confirmBlock(context, targetUserId, targetName, onBlocked);
              },
            ),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.white38),
            title: Text(zh ? '取消' : 'Cancel', style: const TextStyle(color: Colors.white54)),
            onTap: () => Navigator.pop(sheetCtx),
          ),
          const SizedBox(height: 4),
        ],
      ),
    ),
  );
}

Future<void> _showReportReasons(
  BuildContext context, {
  required String contentType,
  String? contentId,
  String? targetUserId,
}) async {
  final zh = _zh(context);
  String? picked;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF161020),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetCtx) => StatefulBuilder(
      builder: (sheetCtx, setSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(zh ? '选择举报原因' : 'Why are you reporting this?',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _reasons.entries.map((e) {
                  final on = picked == e.key;
                  return GestureDetector(
                    onTap: () => setSheet(() => picked = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: on ? const Color(0x33A05CFF) : Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: on ? const Color(0xFFA05CFF) : Colors.transparent),
                      ),
                      child: Text(zh ? e.value[0] : e.value[1],
                          style: TextStyle(color: on ? Colors.white : Colors.white70, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D7F),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: picked == null ? null : () async {
                    Navigator.pop(sheetCtx);
                    try {
                      await Api.reportContent(
                        contentType: contentType, contentId: contentId,
                        targetUserId: targetUserId, reasonCode: picked!,
                      );
                      _toast(context, zh ? '举报已提交,感谢反馈' : 'Reported. Thank you.');
                    } catch (_) {
                      _toast(context, zh ? '提交失败,请稍后再试' : 'Failed, please try again');
                    }
                  },
                  child: Text(zh ? '提交举报' : 'Submit report',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _confirmBlock(
  BuildContext context, String targetUserId, String? targetName, VoidCallback? onBlocked) async {
  final zh = _zh(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (dCtx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1326),
      title: Text(zh ? '拉黑用户' : 'Block user', style: const TextStyle(color: Colors.white)),
      content: Text(
        zh ? '拉黑后,你将不再看到 ${targetName ?? "该用户"} 的任何内容。可在 设置 中取消拉黑。'
           : "You won't see any content from ${targetName ?? 'this user'}. You can unblock in Settings.",
        style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dCtx, false),
            child: Text(zh ? '取消' : 'Cancel', style: const TextStyle(color: Colors.white54))),
        TextButton(onPressed: () => Navigator.pop(dCtx, true),
            child: Text(zh ? '拉黑' : 'Block', style: const TextStyle(color: Color(0xFFFF6B81)))),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await Api.blockUser(targetUserId);
    _toast(context, zh ? '已拉黑' : 'Blocked');
    onBlocked?.call();
  } catch (_) {
    _toast(context, zh ? '操作失败,请稍后再试' : 'Failed, please try again');
  }
}

void _toast(BuildContext context, String msg) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );
}

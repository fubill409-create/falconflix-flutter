import 'package:flutter/material.dart';

import '../api/api.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';

/// 我的拉黑名单（苹果 G1.2 UGC 合规：举报 + 拉黑必须可演示，且取消拉黑要有入口）。
/// 拉黑后端只回 userId 集合（[Api.myBlockedIds]），没有昵称，故只展示「用户 …后6位」。
/// 每条可「取消拉黑」（[Api.unblockUser]），乐观从列表移除，失败回滚。
class BlocklistScreen extends StatefulWidget {
  const BlocklistScreen({super.key});

  @override
  State<BlocklistScreen> createState() => _BlocklistScreenState();
}

class _BlocklistScreenState extends State<BlocklistScreen> {
  List<String>? _ids; // null = 未加载
  bool _loading = true;
  Object? _err;
  final Set<String> _busy = {}; // 正在取消拉黑的 id（防重复点击）

  bool _zh(BuildContext c) =>
      Localizations.localeOf(c).languageCode == 'zh';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final ids = await Api.myBlockedIds();
      if (!mounted) return;
      setState(() {
        _ids = ids.toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e;
        _loading = false;
      });
    }
  }

  Future<void> _unblock(String id) async {
    if (_busy.contains(id)) return;
    final zh = _zh(context);
    setState(() => _busy.add(id));
    // 乐观移除
    final prev = List<String>.from(_ids ?? const []);
    setState(() => _ids = (_ids ?? const []).where((e) => e != id).toList());
    try {
      await Api.unblockUser(id);
      if (!mounted) return;
      setState(() => _busy.remove(id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(zh ? '已取消拉黑' : 'Unblocked',
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (_) {
      if (!mounted) return;
      // 失败回滚
      setState(() {
        _ids = prev;
        _busy.remove(id);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(zh ? '操作失败，请稍后再试' : 'Failed, please try again',
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  // 没有昵称，只展示尾号方便用户区分（隐私安全）。
  String _label(String id, bool zh) {
    final tail = id.length <= 6 ? id : id.substring(id.length - 6);
    return zh ? '用户 $tail' : 'User $tail';
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    final zh = _zh(context);
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
                  child: _topbar(p, zh ? '拉黑名单' : 'Blocked users'),
                ),
                Expanded(child: _content(p, zh)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Pal p, bool zh) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: FF.hot));
    }
    if (_err != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(zh ? '加载失败' : 'Failed to load',
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(zh ? '重试' : 'Retry'),
            ),
          ],
        ),
      );
    }
    final ids = _ids ?? const <String>[];
    if (ids.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: p.textMuted, size: 48),
              const SizedBox(height: 14),
              Text(zh ? '你还没有拉黑任何人' : "You haven't blocked anyone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                  zh
                      ? '拉黑后将不再看到对方的任何内容。可在用户资料或榜单上拉黑。'
                      : "Blocked users' content is hidden from you. Block from a profile or leaderboard.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.textMuted, fontSize: 12, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Text(
              zh ? '已拉黑 ${ids.length} 位用户' : '${ids.length} blocked',
              style: TextStyle(
                  color: p.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6)),
        ),
        Glass(
          radius: 16,
          color: p.day ? p.card : FF.glassFill,
          border: p.line,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < ids.length; i++) ...[
                _row(p, zh, ids[i]),
                if (i != ids.length - 1)
                  Divider(height: 1, color: p.line, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(Pal p, bool zh, String id) {
    final busy = _busy.contains(id);
    return ListTile(
      dense: true,
      leading: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.day
              ? Colors.black.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: p.line),
        ),
        child: Icon(Icons.person_outline_rounded, color: p.textMuted, size: 18),
      ),
      title: Text(_label(id, zh),
          style: TextStyle(
              color: p.text, fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: TextButton(
        onPressed: busy ? null : () => _unblock(id),
        style: TextButton.styleFrom(
          foregroundColor: FF.hot,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: FF.hot))
            : Text(zh ? '取消拉黑' : 'Unblock',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _topbar(Pal p, String title) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.day
                  ? Colors.black.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: p.line),
            ),
            child: Icon(Icons.arrow_back_rounded, color: p.text, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(
                color: p.text, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

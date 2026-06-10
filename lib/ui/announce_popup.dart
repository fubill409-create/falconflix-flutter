import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';
import '../theme.dart';
import '../screens/detail_screen.dart';

/// 运营「上新公告」炫弹窗。
/// App 进场拉 `/ingest/announce/latest`，发现未看过的新公告就弹一次（电影级毛玻璃 + 发光 + 进场动效）。
/// 一切失败静默（拉不到/没网/没公告都不打扰用户）。
class AnnouncePopup {
  static const _seenKey = 'announce_seen_id';

  /// 进场调用：有未看过的新公告就弹。
  static Future<void> maybeShow(BuildContext context) async {
    try {
      final data = await _fetchLatest();
      if (data == null) return;
      final id = '${data['id'] ?? ''}';
      if (id.isEmpty) return;
      final sp = await SharedPreferences.getInstance();
      if (sp.getString(_seenKey) == id) return; // 已看过这条
      await sp.setString(_seenKey, id); // 先标记再弹，避免重复弹
      if (!context.mounted) return;
      await _show(context, data);
    } catch (_) {
      /* 静默：公告不是核心链路，绝不打断用户 */
    }
  }

  static Future<Map<String, dynamic>?> _fetchLatest() async {
    final r = await http
        .get(Uri.parse('${Api.baseUrl}/ingest/announce/latest'))
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is Map && j['data'] is Map) return Map<String, dynamic>.from(j['data']);
    return null;
  }

  static Future<void> _show(BuildContext context, Map<String, dynamic> a) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withOpacity(0.72),
      transitionDuration: const Duration(milliseconds: 460),
      pageBuilder: (ctx, _, __) => Center(child: _AnnounceCard(data: a)),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.86 + 0.14 * curved.value, child: child),
        );
      },
    );
  }
}

class _AnnounceCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _AnnounceCard({required this.data});
  @override
  State<_AnnounceCard> createState() => _AnnounceCardState();
}

class _AnnounceCardState extends State<_AnnounceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  void _go() {
    final a = widget.data;
    Navigator.of(context).pop();
    final link = '${a['link'] ?? ''}';
    var id = '${a['shortId'] ?? ''}';
    if (id.isEmpty && link.startsWith('/short/')) {
      id = link.substring('/short/'.length).split('/').first;
    }
    if (id.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DetailScreen(
          shortId: id,
          title: '${a['title'] ?? ''}',
          cover: '${a['image'] ?? ''}',
          intro: '${a['body'] ?? ''}',
          price: 0,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.data;
    final image = '${a['image'] ?? ''}';
    final title = '${a['title'] ?? ''}';
    final body = '${a['body'] ?? ''}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, child) {
            final t = _glow.value;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: FF.hot.withOpacity(0.28 + 0.22 * t),
                      blurRadius: 38 + 26 * t,
                      spreadRadius: 1),
                  BoxShadow(
                      color: FF.purple.withOpacity(0.20 + 0.16 * t),
                      blurRadius: 56 + 30 * t,
                      spreadRadius: 1),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              decoration: BoxDecoration(
                color: FF.panel,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: FF.hot.withOpacity(0.45), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (image.isNotEmpty)
                        Image.network(image,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _posterFallback(),
                            // 海报加载中先铺炫彩渐变占位，绝不露黑底
                            loadingBuilder: (ctx, child, progress) =>
                                progress == null ? child : _posterFallback())
                      else
                        _posterFallback(),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.transparent,
                                FF.panel,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(top: 14, left: 14, child: _newBadge()),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: FF.text,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                height: 1.2)),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(body,
                              style: const TextStyle(
                                  color: FF.muted, fontSize: 14, height: 1.45)),
                        ],
                        const SizedBox(height: 18),
                        _goButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _posterFallback() => Container(
        height: 200,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FF.hot, FF.purple, FF.blue],
          ),
        ),
        child: const Center(
            child: Icon(Icons.movie_creation_rounded,
                color: Colors.white, size: 56)),
      );

  Widget _newBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: FF.hotGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: FF.hot.withOpacity(0.5), blurRadius: 14)],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          SizedBox(width: 5),
          Text('上新 · NEW',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _goButton() => SizedBox(
        width: double.infinity,
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: FF.hotGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: FF.hot.withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: _go,
              child: const Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('立即去看',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ]),
              ),
            ),
          ),
        ),
      );
}

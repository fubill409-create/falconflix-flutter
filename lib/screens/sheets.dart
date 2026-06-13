import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/privilege.dart';
import '../theme.dart';
import '../ui/level_gate.dart';
import 'community_screen.dart';

/// FalconFlix 二级浮层（按 Codex app-subflows）：浅色圆角底部 sheet，
/// 粉/紫/珊瑚渐变。仅 UI 壳，业务后续接。

const _sheetBg = Color(0xF2FFFFFF); // white ~0.95
const _ink = Color(0xFF130F1B);
const _inkSoft = Color(0x99130F1B);
const _rowBg = Color(0xFFF4F2F8);
const _pinkCoral = LinearGradient(colors: [Color(0xFFFF4F9B), Color(0xFFFF7F62)]);
const _pinkPurple = LinearGradient(colors: [Color(0xFFFF4F9B), Color(0xFF7F6BFF)]);

Future<T?> _present<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => child,
  );
}

Widget _shell(BuildContext context, {required List<Widget> children}) {
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: _sheetBg,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    padding: EdgeInsets.fromLTRB(
        18, 10, 18, 20 + MediaQuery.of(context).padding.bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 46,
            height: 5,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                color: const Color(0x2E130F1B),
                borderRadius: BorderRadius.circular(999)),
          ),
        ),
        ...children,
      ],
    ),
  );
}

Widget _sheetTitle(String kicker, String title, {Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(kicker,
                  style: const TextStyle(
                      color: _inkSoft, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(
                      color: _ink, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

Widget _miniPill(String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: _pinkPurple, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
    ),
  );
}

Widget _primaryButton(String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: FF.brandGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: FF.hot.withValues(alpha: 0.28), blurRadius: 24),
        ],
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
    ),
  );
}

void _toast(BuildContext c, String m) => ScaffoldMessenger.of(c)
    .showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 2)));

/// 选集抽屉
void showEpisodeDrawer(
  BuildContext context, {
  required String title,
  required List<({int n, String name, bool unlocked})> episodes,
  required void Function(int index) onPlay,
  required VoidCallback onUnlockAll,
}) {
  final l = AppLocalizations.of(context);
  _present(context, _shell(context, children: [
    _sheetTitle(l.sheets_episodeTitle, title,
        trailing: _miniPill(l.sheets_unlockAllBtn, () {
          Navigator.pop(context);
          onUnlockAll();
        })),
    ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: episodes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 7),
        itemBuilder: (_, i) {
          final e = episodes[i];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onPlay(i);
            },
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: e.unlocked ? _pinkCoral : null,
                color: e.unlocked ? null : _rowBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(e.n.toString().padLeft(2, '0'),
                        style: TextStyle(
                            color: e.unlocked ? Colors.white : _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: e.unlocked ? Colors.white : _ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ),
                  Icon(e.unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                      color: e.unlocked ? Colors.white : _inkSoft, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ]));
}

/// 鹰币数字显示：整数不带小数，0.01 这类保留有效小数。
String coinStr(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// 一档解锁选项（详情页算好集数/总价/购买闭包传进来，sheet 只管选与扣）。
typedef UnlockTierOption = ({
  String label, // 「本集」「后续 5 集」「全集」
  int count, // 解锁集数
  double coins, // 该档总价（鹰币）
  Future<bool> Function() purchase, // 选定后真扣鹰币
});

/// 四档解锁弹窗（本集 / 后续5集 / 后续10集 / 全集）。选一档→立即解锁。
/// 成功 pop(true)，详情页接住放庆祝+刷新。调用前请确保已登录。
Future<bool?> showTieredUnlockSheet(
  BuildContext context, {
  required String title,
  required List<UnlockTierOption> tiers,
  required VoidCallback onRecharge,
}) {
  return _present<bool>(
    context,
    _TieredUnlockSheet(title: title, tiers: tiers, onRecharge: onRecharge),
  );
}

class _TieredUnlockSheet extends StatefulWidget {
  final String title;
  final List<UnlockTierOption> tiers;
  final VoidCallback onRecharge;
  const _TieredUnlockSheet({
    required this.title,
    required this.tiers,
    required this.onRecharge,
  });
  @override
  State<_TieredUnlockSheet> createState() => _TieredUnlockSheetState();
}

class _TieredUnlockSheetState extends State<_TieredUnlockSheet> {
  int _sel = 0;
  bool _busy = false;
  String? _error;

  double get _balance => auth.profile?.balance ?? 0;
  UnlockTierOption get _tier => widget.tiers[_sel];
  bool get _enough => _balance >= _tier.coins;

  Future<void> _buy() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await _tier.purchase();
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _busy = false;
          _error = l.sheets_unlockFailed;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l.sheets_networkErr;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _shell(context, children: [
      _sheetTitle(l.sheets_unlockTitle, l.sheets_unlockChooseCount),
      if (widget.title.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: _ink, fontSize: 15, fontWeight: FontWeight.w900)),
        ),
      for (var i = 0; i < widget.tiers.length; i++) _tierRow(i),
      const SizedBox(height: 4),
      // 余额行
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration:
            BoxDecoration(color: _rowBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.monetization_on_rounded,
                color: Color(0xFFE8A91C), size: 18),
            const SizedBox(width: 8),
            Text(l.sheets_walletBalance,
                style: const TextStyle(
                    color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(l.sheets_coinsFmt(coinStr(_balance)),
                style: TextStyle(
                    color: _enough ? _ink : FF.hot,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      if (!_enough) ...[
        const SizedBox(height: 8),
        Text(l.sheets_unlockShortFmt(coinStr(_tier.coins - _balance)),
            style: const TextStyle(
                color: _inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
      if (_error != null) ...[
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.error_outline_rounded, color: FF.hot, size: 15),
          const SizedBox(width: 6),
          Expanded(
              child: Text(_error!,
                  style: const TextStyle(color: FF.hot, fontSize: 12))),
        ]),
      ],
      const SizedBox(height: 16),
      if (_enough)
        _busy
            ? Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: FF.brandGradient,
                    borderRadius: BorderRadius.circular(999)),
                child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white)),
              )
            : _primaryButton(
                l.sheets_unlockNowFmt(coinStr(_tier.coins)), _buy)
      else
        _primaryButton(l.sheets_coinsNotEnough, () {
          Navigator.pop(context);
          widget.onRecharge();
        }),
    ]).animate().fadeIn(duration: 180.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _tierRow(int i) {
    final l = AppLocalizations.of(context);
    final t = widget.tiers[i];
    final sel = i == _sel;
    return GestureDetector(
      onTap: () => setState(() {
        _sel = i;
        _error = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: sel ? _pinkPurple : null,
          color: sel ? null : _rowBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? Colors.transparent : const Color(0x14130F1B)),
        ),
        child: Row(
          children: [
            Icon(sel ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: sel ? Colors.white : _inkSoft, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.label,
                      style: TextStyle(
                          color: sel ? Colors.white : _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900)),
                  Text(l.sheets_tierForeverFmt(t.count.toString()),
                      style: TextStyle(
                          color: sel ? const Color(0xCCFFFFFF) : _inkSoft,
                          fontSize: 11)),
                ],
              ),
            ),
            Text(l.sheets_coinsFmt(coinStr(t.coins)),
                style: TextStyle(
                    color: sel ? Colors.white : _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

/// 解锁购买弹窗（真扣鹰币）。
/// 余额够 → 「立即解锁」走 onPurchase；不够 → 「鹰币不足·去充值」走 onRecharge。
/// 成功后 pop(true)，由详情页接住放庆祝动画并刷新剧集/余额。
/// 调用前请确保已登录（未登录请先在外层引导登录）。
Future<bool?> showUnlockSheet(
  BuildContext context, {
  required String title,
  required int count,
  required double price,
  required Future<bool> Function() onPurchase,
  required VoidCallback onRecharge,
}) {
  return _present<bool>(
    context,
    _UnlockSheet(
      title: title,
      count: count,
      price: price,
      onPurchase: onPurchase,
      onRecharge: onRecharge,
    ),
  );
}

class _UnlockSheet extends StatefulWidget {
  final String title;
  final int count;
  final double price;
  final Future<bool> Function() onPurchase;
  final VoidCallback onRecharge;

  const _UnlockSheet({
    required this.title,
    required this.count,
    required this.price,
    required this.onPurchase,
    required this.onRecharge,
  });

  @override
  State<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends State<_UnlockSheet> {
  bool _busy = false;
  String? _error;

  double get _balance => auth.profile?.balance ?? 0;
  bool get _enough => _balance >= widget.price;
  bool get _isVip => auth.profile?.isVip ?? false;

  Future<void> _buy() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await widget.onPurchase();
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _busy = false;
          _error = l.sheets_unlockFailed;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l.sheets_networkErr;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final multi = widget.count > 1;
    return _shell(context, children: [
      _sheetTitle(l.sheets_unlockTitle,
          multi ? l.sheets_unlockAllSub : l.sheets_unlockThisSub),
      // 商品 hero：剧名 + 集数 + 鹰币价
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1430), Color(0xFF7F6BFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: FF.purple.withValues(alpha: 0.28), blurRadius: 24),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title.isEmpty ? 'FalconFlix' : widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              multi
                  ? l.sheets_unlockAllForeverFmt(widget.count.toString())
                  : l.sheets_unlockThisForever,
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(coinStr(widget.price),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(l.sheets_coinsShort,
                      style: const TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
                if (_isVip) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        gradient: FF.goldGradient,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(l.sheets_vipDiscount,
                        style: const TextStyle(
                            color: Color(0xFF1B1404),
                            fontSize: 11,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      // 余额行
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: _rowBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.monetization_on_rounded,
                color: Color(0xFFE8A91C), size: 18),
            const SizedBox(width: 8),
            Text(l.sheets_walletBalance,
                style: const TextStyle(
                    color: _ink, fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(l.sheets_coinsFmt(coinStr(_balance)),
                style: TextStyle(
                    color: _enough ? _ink : FF.hot,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      if (!_enough) ...[
        const SizedBox(height: 8),
        Text(l.sheets_unlockShortFmt(coinStr(widget.price - _balance)),
            style: const TextStyle(
                color: _inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
      if (_error != null) ...[
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: FF.hot, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_error!,
                  style: const TextStyle(color: FF.hot, fontSize: 12)),
            ),
          ],
        ),
      ],
      const SizedBox(height: 16),
      if (_enough)
        _busy
            ? Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: FF.brandGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white),
                ),
              )
            : _primaryButton(
                l.sheets_unlockNowFmt(coinStr(widget.price)), _buy)
        else
        _primaryButton(l.sheets_coinsNotEnough, () {
          Navigator.pop(context);
          widget.onRecharge();
        }),
    ])
        .animate()
        .fadeIn(duration: 260.ms)
        .slideY(begin: 0.06, duration: 320.ms, curve: Curves.easeOutCubic);
  }
}

// —— 分享：统一文案 / 链接 ——
// 落地页（带二维码 + 下载按钮）是当前真实可达的页面，作为分享落点。
const String _shareLandingUrl = 'https://falconflix.app/media/download/';

String _shareTitleOf(AppLocalizations l, String? title) =>
    (title == null || title.trim().isEmpty)
        ? l.sheets_fallbackTitle
        : title.trim();

String _shareTextOf(AppLocalizations l, String? title) =>
    l.sheets_shareTextFmt(_shareTitleOf(l, title), _shareLandingUrl);

/// 分享面板（真分享）：
///  · 复制链接 = 真 Clipboard
///  · 消息 = 系统分享面板（微信/LINE/WhatsApp… 由系统选）
///  · 海报 = 生成带二维码的精美海报 → 分享图片
///  · 动态 = 发到 App 社区动态流（带上这部剧）
///  · 混剪 = 智能混剪（下一阶段，明确标注）
void showShareSheet(
  BuildContext context, {
  required String sceneLabel,
  String? shortId,
  String? title,
  String? posterUrl,
}) {
  final l = AppLocalizations.of(context);
  final shareTitle = (title == null || title.trim().isEmpty) ? sceneLabel : title;
  final targets = <_ShareTarget>[
    _ShareTarget(l.sheets_shareTargetMessage, Icons.ios_share_rounded,
        ready: true, onTap: () async {
      await Share.share(_shareTextOf(l, shareTitle), subject: 'FalconFlix');
    }),
    _ShareTarget(l.sheets_shareTargetPoster, Icons.qr_code_2_rounded,
        ready: true, onTap: () async {
      _showPosterSheet(context,
          title: shareTitle,
          posterUrl: posterUrl,
          shortId: shortId,
          link: _shareLandingUrl);
    }),
    // v1:动态(社区mock)、混剪(没做)都去掉,只留消息、海报、复制链接三个真能用的。
  ];

  _present(context, _shell(context, children: [
    _sheetTitle(l.sheets_shareTitle, l.sheets_shareSub,
        trailing: _miniPill(l.sheets_copyLink, () async {
          await Clipboard.setData(
              ClipboardData(text: _shareTextOf(l, shareTitle)));
          if (context.mounted) {
            Navigator.pop(context);
            _toast(context, l.sheets_linkCopiedLong);
          }
        })),
    Row(
      children: [
        for (final t in targets) ...[
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (t.ready) Navigator.pop(context);
                await t.onTap();
              },
              child: Container(
                height: 78,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F2F8),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: t.ready ? _pinkPurple : null,
                        color: t.ready ? null : const Color(0xFFE7E3F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(t.icon,
                          color: t.ready ? Colors.white : _inkSoft, size: 20),
                    ),
                    const SizedBox(height: 7),
                    Text(t.label,
                        style: TextStyle(
                            color: t.ready ? _ink : _inkSoft,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
    // v1:不再展示"混剪即将上线"提示——这功能没做,也不预告没影的东西。
  ]));
}

class _ShareTarget {
  final String label;
  final IconData icon;
  final bool ready;
  final Future<void> Function() onTap;
  _ShareTarget(this.label, this.icon,
      {required this.ready, required this.onTap});
}

/// 海报分享面板：剧封面 + 标题 + 二维码 + 品牌，截图成 PNG 分享。
void _showPosterSheet(
  BuildContext context, {
  required String title,
  String? posterUrl,
  String? shortId,
  required String link,
}) {
  _present(context,
      _SharePosterSheet(title: title, posterUrl: posterUrl, shortId: shortId, link: link));
}

class _SharePosterSheet extends StatefulWidget {
  final String title;
  final String? posterUrl;
  final String? shortId;
  final String link;
  const _SharePosterSheet(
      {required this.title,
      required this.posterUrl,
      required this.shortId,
      required this.link});

  @override
  State<_SharePosterSheet> createState() => _SharePosterSheetState();
}

class _SharePosterSheetState extends State<_SharePosterSheet> {
  final GlobalKey _posterKey = GlobalKey();
  bool _busy = false;
  bool _imgReady = false;
  // 实际用作海报背景的封面：优先剧目真封面(/short/list)，回退首页头像，再回退渐变。
  String? _cover;

  @override
  void initState() {
    super.initState();
    _resolveCover();
  }

  /// 解析真封面：首页流只给品牌头像，这里按 shortId 取剧目真竖版封面。
  Future<void> _resolveCover() async {
    String? eff = widget.posterUrl;
    try {
      final real = await Api.dramaCover(widget.shortId);
      if (real != null && real.trim().isNotEmpty) eff = real;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _cover = (eff != null && eff.trim().isNotEmpty) ? eff : null;
      // 无图就走品牌渐变兜底，可立即分享；有图等图绘制完再放行。
      if (_cover == null) _imgReady = true;
    });
  }

  Future<void> _sharePoster() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      // 等一帧确保海报已绘制完
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _posterKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw l.sheets_posterGenFail;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw l.sheets_posterExportFail;
      final Uint8List bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/falconflix_poster_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: _shareTextOf(l, widget.title),
        subject: 'FalconFlix',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _toast(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _shell(context, children: [
      _sheetTitle(l.sheets_posterTitle, l.sheets_posterMakeSub,
          trailing: _miniPill(l.sheets_copyLink, () async {
            await Clipboard.setData(
                ClipboardData(text: _shareTextOf(l, widget.title)));
            if (context.mounted) _toast(context, l.sheets_linkCopiedShort);
          })),
      Center(
        child: RepaintBoundary(
          key: _posterKey,
          child: _PosterCard(
            title: widget.title,
            posterUrl: _cover,
            link: widget.link,
            onImgReady: () {
              if (mounted && !_imgReady) setState(() => _imgReady = true);
            },
          ),
        ),
      ),
      const SizedBox(height: 16),
      _busy
          ? Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: FF.brandGradient,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              ),
            )
          : Opacity(
              opacity: _imgReady ? 1 : 0.5,
              child: _primaryButton(
                  _imgReady
                      ? l.sheets_posterReady
                      : l.sheets_posterGenerating,
                  _imgReady ? _sharePoster : () {}),
            ),
    ])
        .animate()
        .fadeIn(duration: 240.ms)
        .slideY(begin: 0.06, duration: 320.ms, curve: Curves.easeOutCubic);
  }
}

/// 海报卡片本体（被截图）。竖版 9:14，封面 + 暗渐变 + 标题 + 二维码 + 品牌。
class _PosterCard extends StatelessWidget {
  final String title;
  final String? posterUrl;
  final String link;
  final VoidCallback onImgReady;
  const _PosterCard({
    required this.title,
    required this.posterUrl,
    required this.link,
    required this.onImgReady,
  });

  bool get _hasImg => posterUrl != null && posterUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18), blurRadius: 28),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 9 / 14,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 背景：封面 or 品牌渐变兜底
              if (_hasImg)
                CachedNetworkImage(
                  imageUrl: posterUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
                  imageBuilder: (ctx, provider) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => onImgReady());
                    return Image(image: provider, fit: BoxFit.cover);
                  },
                  placeholder: (_, _) =>
                      const ColoredBox(color: Color(0xFF1B1430)),
                  errorWidget: (_, _, _) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => onImgReady());
                    return const DecoratedBox(
                        decoration: BoxDecoration(gradient: _pinkPurple));
                  },
                )
              else
                const DecoratedBox(
                    decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B1430), Color(0xFF7F6BFF)],
                  ),
                )),
              // 底部暗渐变压字
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x33000000),
                      Color(0xE6000000),
                    ],
                    stops: [0.42, 0.66, 1.0],
                  ),
                ),
              ),
              // 顶部品牌
              Positioned(
                left: 14,
                top: 14,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/brand/logo_eagle.png',
                          width: 26, height: 26, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 7),
                    const Text('FalconFlix',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 6)
                            ])),
                  ],
                ),
              ),
              // 底部：标题 + 标语 + 二维码
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.isEmpty ? l.sheets_fallbackTitle : title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 8)
                                ]),
                          ),
                          const SizedBox(height: 6),
                          Text(l.sheets_posterTagline,
                              style: const TextStyle(
                                  color: Color(0xE6FFFFFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(color: Colors.black54, blurRadius: 6)
                                  ])),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: QrImageView(
                        data: link,
                        version: QrVersions.auto,
                        size: 64,
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                      ),
                    ),
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

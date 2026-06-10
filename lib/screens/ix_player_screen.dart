import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../api/api.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/ix_manifest.dart';
import '../services/ix_cache.dart';
import '../services/ix_progress.dart';
import '../theme.dart';
import '../ui/kit.dart';

/// Nova 互动剧 · 视频树播放器（真 mp4，沉浸式播放）。
///
/// 流程：拉 manifest → 进剧前并行 init 起点 + 起点.next 两段视频（B 预缓冲，
/// "准备中 X/2"）→ 进入播放。每段播到 60% 时后台预热确定的下一段（A 预热），
/// 段间切换零等待（除非用户选了不同分支）。
///
/// 沉浸 UI：默认全部控件淡出，视频铺满纯净播；点屏幕 → 顶部标题/返回 + 中心
/// 暂停 + 右下跳过浮现，3 秒无操作自动隐藏；暂停时控件保持显示直到再点屏幕。
///
/// flag 引擎：选项 setFlags 改状态，requires 结构化求值决定显隐/置灰。
/// 付费分支（price>0）Phase 1 放行体验，真扣鹰币 = Phase 2。
class IxPlayerScreen extends StatefulWidget {
  final String dramaId;
  final String? title;
  const IxPlayerScreen({super.key, required this.dramaId, this.title});

  @override
  State<IxPlayerScreen> createState() => _IxPlayerScreenState();
}

class _IxPlayerScreenState extends State<IxPlayerScreen> {
  // ── 数据 ──
  IxDrama? _drama;
  String? _error;
  bool _loading = true;
  bool _prepping = false; // B: 进剧前缓冲前两段
  int _prepDone = 0, _prepTotal = 0;
  final Map<String, dynamic> _flags = {};
  String? _nodeId;
  bool _videoEnded = false;
  int _clipIdx = 0; // 当前节点正在播第几个 clip（0-based）

  // ── 当前段 + 预热下一段（A）──
  VideoPlayerController? _vc;
  String? _prefetchKey; // 预热的目标 key = "${nodeId}#${clipIdx}"（节点+片段）
  VideoPlayerController? _prefetchVc;
  bool _prefetchKicked = false; // 当前段是否已触发预热

  // ── 控件显隐（沉浸式）──
  bool _controlsVisible = false;
  Timer? _hideTimer;

  IxNode? get _node => _drama?.node(_nodeId);
  bool get _isPlaying => _vc?.value.isPlaying ?? false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _vc?.removeListener(_onTick);
    _vc?.dispose();
    _prefetchVc?.dispose();
    super.dispose();
  }

  /// 创建已 init 好的 VideoPlayerController：本地缓存命中→读文件（秒开 0 下载），
  /// 否则→网络 + 后台静默拉到磁盘。失败抛错由调用方接住。
  Future<VideoPlayerController> _initVc(String url) async {
    final local = IxCache.fileFor(url);
    final VideoPlayerController c;
    if (local != null) {
      c = VideoPlayerController.file(local);
    } else {
      c = VideoPlayerController.networkUrl(Uri.parse(url));
      unawaited(IxCache.ensure(url).catchError((_) => File('')));
    }
    await c.initialize();
    return c;
  }

  /// 弹「继续上次 / 从头看」对话框。
  Future<bool?> _askResumeDialog(String savedNodeId) {
    final l = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1422),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l.ixp_resumeTitle,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900)),
        content: Text(l.ixp_resumeBody,
            style: const TextStyle(
                color: Color(0xCCFFFFFF), fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.ixp_resumeFromStart,
                style: const TextStyle(
                    color: Color(0xAAFFFFFF), fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.ixp_resumeContinue,
                style: const TextStyle(
                    color: FF.hot, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // ───────── 拉 manifest + B 预缓冲前两段 ─────────
  Future<void> _load() async {
    final l = AppLocalizations.of(context);
    try {
      final r = await http
          .get(Uri.parse('${Api.baseUrl}/ix/${widget.dramaId}'))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) {
        setState(() {
          _error = l.ixp_fetchFailedFmt(r.statusCode.toString());
          _loading = false;
        });
        return;
      }
      final d = IxDrama.fromString(utf8.decode(r.bodyBytes));
      final root = d.root;
      if (root == null) {
        setState(() {
          _error = l.ixp_dataAnomaly;
          _loading = false;
        });
        return;
      }
      await IxCache.ensureReady();
      // 后台静默 prefetch 这部剧的所有视频段（不阻塞起播；重看就是 0 等待）
      final allUrls = <String>{};
      for (final n in d.nodes.values) { allUrls.addAll(n.playUrls); }
      unawaited(IxCache.prefetchAll(allUrls));
      setState(() { _drama = d; _loading = false; });

      // 查存档：有 → 弹「继续上次 / 从头看」
      final save = await IxProgress.load(widget.dramaId);
      String startNodeId = root.id;
      int startClipIdx = 0;
      Map<String, dynamic> initFlags = Map<String, dynamic>.from(d.vars);
      if (save != null && d.node(save.nodeId) != null && mounted) {
        final cont = await _askResumeDialog(save.nodeId);
        if (cont == true) {
          startNodeId = save.nodeId;
          final n = d.node(save.nodeId);
          final maxClip = (n?.playUrls.length ?? 1) - 1;
          startClipIdx = save.clipIdx.clamp(0, maxClip < 0 ? 0 : maxClip);
          initFlags = Map<String, dynamic>.from(save.flags);
        } else {
          await IxProgress.clear(widget.dramaId);
        }
      }
      _flags..clear()..addAll(initFlags);

      // 起点的两段一起预备（X/N 准备中），下一段命中预热
      final startNode = d.node(startNodeId)!;
      final startUrls = startNode.playUrls;
      String? url1 = startClipIdx < startUrls.length ? startUrls[startClipIdx] : null;
      String? url2;
      String? key2;
      if (startClipIdx + 1 < startUrls.length) {
        url2 = startUrls[startClipIdx + 1]; key2 = '$startNodeId#${startClipIdx + 1}';
      } else if (startNode.choices.isEmpty && startNode.next != null && startNode.next!.isNotEmpty) {
        final next = d.node(startNode.next);
        if (next != null && next.playUrls.isNotEmpty) {
          url2 = next.playUrls[0]; key2 = '${next.id}#0';
        }
      }
      final total = (url1 != null ? 1 : 0) + (url2 != null ? 1 : 0);
      setState(() { _prepping = true; _prepTotal = total; _prepDone = 0; });
      VideoPlayerController? c1;
      if (url1 != null) {
        c1 = await _initVc(url1);
        if (mounted) setState(() => _prepDone++);
      }
      VideoPlayerController? c2;
      if (url2 != null && mounted) {
        c2 = await _initVc(url2);
        if (mounted) setState(() => _prepDone++);
      }
      if (!mounted) { c1?.dispose(); c2?.dispose(); return; }
      if (c2 != null && key2 != null) { _prefetchVc = c2; _prefetchKey = key2; }
      setState(() { _prepping = false; _nodeId = startNodeId; _clipIdx = startClipIdx; _videoEnded = c1 == null; });
      if (c1 != null) {
        _vc = c1;
        _vc!.addListener(_onTick);
        await _vc!.play();
        _scheduleHide();
        if (mounted) setState(() {});
      }
      // 记录起点存档
      unawaited(IxProgress.save(
        dramaId: widget.dramaId, nodeId: startNodeId, clipIdx: startClipIdx, flags: _flags));
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = l.ixp_loadErrorFmt(e.toString());
          _loading = false;
          _prepping = false;
        });
      }
    }
  }

  // ───────── 进节点（从 clip 0 开始）─────────
  Future<void> _enter(String id) async => _playUrl(id, 0);

  /// 播放 node[id] 的第 clipIdx 段（命中预热则秒切，否则现 init）。
  /// 关键：旧 controller 保持播放直到新 controller 就绪，避免段间黑屏；
  /// 旧 controller 的 dispose 推到后台异步，不阻塞 UI。
  Future<void> _playUrl(String nodeId, int clipIdx) async {
    final n = _drama?.node(nodeId);
    if (n == null) {
      setState(() =>
          _error = AppLocalizations.of(context).ixp_nodeNotFoundFmt(nodeId));
      return;
    }
    final urls = n.playUrls;
    if (urls.isEmpty || clipIdx >= urls.length) {
      final oldVc = _vc;
      _vc?.removeListener(_onTick);
      _vc = null;
      unawaited(oldVc?.dispose());
      if (mounted) setState(() { _nodeId = nodeId; _clipIdx = clipIdx; _videoEnded = true; });
      return;
    }

    final key = '$nodeId#$clipIdx';
    VideoPlayerController? newVc;

    // 命中预热？秒切。
    if (_prefetchKey == key && _prefetchVc != null && _prefetchVc!.value.isInitialized) {
      newVc = _prefetchVc!;
      _prefetchVc = null;
      _prefetchKey = null;
    } else {
      // 预热没命中（用户选了别的分支）→ 后台清掉
      final pf = _prefetchVc;
      _prefetchVc = null;
      _prefetchKey = null;
      unawaited(pf?.dispose());
      // 现 init —— 这段时间旧 _vc 仍持续播放，避免黑屏
      VideoPlayerController? c;
      try {
        c = await _initVc(urls[clipIdx]);
        if (!mounted) { unawaited(c.dispose()); return; }
        newVc = c;
      } catch (_) {
        unawaited(c?.dispose());
        if (mounted) {
          final oldVc = _vc;
          _vc?.removeListener(_onTick);
          _vc = null;
          unawaited(oldVc?.dispose());
          setState(() { _nodeId = nodeId; _clipIdx = clipIdx; _videoEnded = true; });
        }
        return;
      }
    }

    // 此时 newVc 已 initialized。原子替换 + 后台 dispose 旧。
    final oldVc = _vc;
    oldVc?.removeListener(_onTick);
    _vc = newVc;
    _vc!.addListener(_onTick);
    _videoEnded = false;
    _prefetchKicked = false;
    if (mounted) setState(() { _nodeId = nodeId; _clipIdx = clipIdx; });
    unawaited(_vc!.play());
    _scheduleHide();
    if (oldVc != null) unawaited(oldVc.dispose()); // 后台清旧
    // 存档（每次进新段都写）
    unawaited(IxProgress.save(
        dramaId: widget.dramaId, nodeId: nodeId, clipIdx: clipIdx, flags: _flags));
  }

  // ───────── 播放进度 tick：检结尾 + 触发预热 ─────────
  void _onTick() {
    final c = _vc;
    if (c == null || !c.value.isInitialized) return;
    final pos = c.value.position;
    final dur = c.value.duration;
    // A: 播到 15% 时预热下一段（提前触发，让"按跳过"也能命中预热）
    if (!_prefetchKicked && dur > Duration.zero) {
      final ratio = pos.inMilliseconds / dur.inMilliseconds;
      if (ratio >= 0.15) {
        _prefetchKicked = true;
        _kickPrefetch();
      }
    }
    // 段尾
    if (!_videoEnded && dur > Duration.zero && pos >= dur - const Duration(milliseconds: 280)) {
      _videoEnded = true;
      _onClipEnd();
    }
    if (mounted) setState(() {});
  }

  void _onClipEnd() {
    final n = _node;
    if (n == null) return;
    final urls = n.playUrls;
    if (_clipIdx + 1 < urls.length) {
      // 同节点下一片段连播
      _playUrl(_nodeId!, _clipIdx + 1);
      return;
    }
    // 节点末段：是结局→解锁图鉴+清存档（这部通关）；否则进抉择/续节点
    if (n.isEnding) {
      unawaited(IxProgress.unlockEnding(dramaId: widget.dramaId, endingId: n.id));
      unawaited(IxProgress.clear(widget.dramaId));
    }
    _afterVideo();
  }

  Future<void> _kickPrefetch() async {
    final n = _node;
    if (n == null) return;
    final urls = n.playUrls;
    String? targetUrl, targetKey;
    if (_clipIdx + 1 < urls.length) {
      // 1) 同节点下一段
      targetUrl = urls[_clipIdx + 1];
      targetKey = '${n.id}#${_clipIdx + 1}';
    } else if (n.choices.isEmpty && n.next != null && n.next!.isNotEmpty) {
      // 2) 节点末段 + 确定的 next（非抉择）→ 预热 next 节点 clip 0
      final next = _drama?.node(n.next);
      if (next != null && next.playUrls.isNotEmpty) {
        targetUrl = next.playUrls[0];
        targetKey = '${next.id}#0';
      }
    }
    if (targetUrl == null || targetKey == null) return;
    if (_prefetchKey == targetKey) return;
    final old = _prefetchVc; _prefetchVc = null; _prefetchKey = null;
    unawaited(old?.dispose());
    try {
      final c = await _initVc(targetUrl); // cache 优先
      if (!mounted) { unawaited(c.dispose()); return; }
      _prefetchVc = c;
      _prefetchKey = targetKey;
    } catch (_) {}
  }

  void _afterVideo() {
    final n = _node;
    if (n == null) return;
    _hideTimer?.cancel(); // 抉择/结局时控件显示由 UI 自己决定
    if (n.isEnding || n.isDecision) { setState(() => _controlsVisible = false); return; }
    if (n.next != null && n.next!.isNotEmpty) { _enter(n.next!); return; }
  }

  void _skip() {
    if (_videoEnded) return;
    unawaited(_vc?.pause());
    _videoEnded = true;
    _onClipEnd(); // 与播完段尾同款：先尝试下一 clip，是末段才进 next/choices/ending
  }

  /// owner 隐藏入口：长按标题打开节点跳转列表（测试用，让你不必每次从头跳过到目标段）。
  void _openNodeJumpSheet() {
    final d = _drama;
    if (d == null) return;
    final order = d.nodes.values.toList()
      ..sort((a, b) {
        // ending 排末尾，scene 按 id 排
        if (a.isEnding != b.isEnding) return a.isEnding ? 1 : -1;
        return a.id.compareTo(b.id);
      });
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15101F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4, margin: const EdgeInsets.only(top: 10, bottom: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(children: [
                  const Icon(Icons.alt_route_rounded, color: FF.hot, size: 18),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).ixp_nodeJumpTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(AppLocalizations.of(context).ixp_nodeJumpBody,
                    style: const TextStyle(
                        color: Color(0xAAFFFFFF),
                        fontSize: 11.5,
                        height: 1.4)),
              ),
              const Divider(height: 1, color: Color(0x22FFFFFF)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: order.length,
                  itemBuilder: (_, i) {
                    final n = order[i];
                    final isHere = n.id == _nodeId;
                    final segs = n.playUrls.length;
                    final label = n.isEnding
                        ? '🏁 ${n.id}  ·  ${n.title.isEmpty ? n.endingType : n.title}'
                        : (n.choices.isNotEmpty
                            ? '🎯 ${n.id}  ·  ${AppLocalizations.of(context).ixp_optionsCountFmt(n.choices.length.toString())}'
                            : '🎬 ${n.id}');
                    return ListTile(
                      dense: true,
                      title: Row(children: [
                        Expanded(
                          child: Text(label,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isHere ? FF.hot : Colors.white,
                                  fontSize: 14,
                                  fontWeight: isHere ? FontWeight.w900 : FontWeight.w600)),
                        ),
                        if (segs > 1)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0x33FFFFFF),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                AppLocalizations.of(context)
                                    .ixp_segCountFmt(segs.toString()),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                          ),
                      ]),
                      trailing: isHere
                          ? const Icon(Icons.play_arrow_rounded, color: FF.hot, size: 18)
                          : const Icon(Icons.chevron_right_rounded, color: Color(0x66FFFFFF), size: 18),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        if (!isHere) _enter(n.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _choose(IxChoice c) {
    if (!ixEval(c.requires, _flags)) return;
    c.setFlags.forEach((k, v) => _flags[k] = v);
    if (c.locked) {
      _toast(AppLocalizations.of(context)
          .ixp_lockedToastFmt(c.price.toString()));
    }
    _enter(c.target);
  }

  void _replay() {
    final d = _drama;
    if (d == null) return;
    _flags..clear()..addAll(d.vars);
    _enter(d.rootNodeId);
  }

  List<IxChoice> get _shownChoices {
    final n = _node;
    if (n == null) return const [];
    return [
      for (final c in n.choices)
        if (ixEval(c.requires, _flags) || !c.hidden) c,
    ];
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
    ));
  }

  // ───────── 控件显隐（沉浸式：点屏切显隐 + 自动淡出 + 暂停时不淡出）─────────
  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      setState(() => _controlsVisible = true);
      _scheduleHide();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  void _togglePlay() {
    final c = _vc;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
      _hideTimer?.cancel(); // 暂停时控件保持显示
    } else {
      c.play();
      _scheduleHide();
    }
    setState(() {});
  }

  bool get _isVideoPhase {
    // 是否处于"看视频"阶段（即非抉择/结局/加载/错误覆盖）
    final n = _node;
    if (n == null) return false;
    if (_videoEnded && (n.isEnding || n.isDecision)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isVideoPhase ? _toggleControls : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _videoLayer(),
            // 沉浸控件（淡入淡出）：顶栏 + 中心暂停/播放 + 右下跳过
            if (_isVideoPhase) ...[
              _topBar(),
              _centerPlayPause(),
              _skipBtn(),
            ],
            // 抉择 / 结局 / 加载 / 错误（独立层，不受控件淡出影响）
            _overlayLayer(),
          ],
        ),
      ),
    );
  }

  // ───────── 视频层 ─────────
  Widget _videoLayer() {
    final c = _vc;
    if (c != null && c.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        ),
      );
    }
    return Container(color: const Color(0xFF0B0910));
  }

  // ───────── 顶栏：标题 + 返回钮（淡入淡出）─────────
  Widget _topBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: IgnorePointer(
        ignoring: !_controlsVisible,
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Colors.transparent],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 12, 16),
                child: Row(
                  children: [
                    _circle(Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        // 长按标题 = owner 测试用「节点跳转」（普通用户不会发现）
                        onLongPress: _openNodeJumpSheet,
                        child: Text(
                          widget.title ??
                              _drama?.title ??
                              AppLocalizations.of(context).ixp_fallbackTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              shadows: [Shadow(blurRadius: 6, color: Colors.black)]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── 中心暂停 / 播放（淡入淡出 + 暂停时常亮）─────────
  Widget _centerPlayPause() {
    final c = _vc;
    if (c == null || !c.value.isInitialized) return const SizedBox.shrink();
    final showing = _controlsVisible || !c.value.isPlaying;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !showing,
        child: AnimatedOpacity(
          opacity: showing ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlay,
              child: Container(
                width: 72, height: 72, alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x55000000),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.4),
                ),
                child: Icon(
                  c.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 38,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── 右下跳过（淡入淡出）─────────
  Widget _skipBtn() {
    return Positioned(
      right: 14, bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: _outline(AppLocalizations.of(context).ixp_btnSkip,
                  Icons.fast_forward_rounded, _skip),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── 抉择 / 结局 / 加载 / 错误（独立层）─────────
  Widget _overlayLayer() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: FF.hot, strokeWidth: 2.4));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: FF.dim, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: FF.muted, fontSize: 14)),
              const SizedBox(height: 16),
              _outline(AppLocalizations.of(context).ixp_btnBack,
                  Icons.arrow_back_rounded,
                  () => Navigator.of(context).maybePop()),
            ],
          ),
        ),
      );
    }
    if (_prepping) return _preppingView();
    final n = _node;
    if (n == null) return const SizedBox.shrink();
    if (_videoEnded && n.isEnding) return _endingCard(n);
    if (_videoEnded && n.isDecision) return _choicesPanel(n);
    // 没出片占位（manifest 视频 URL 为空）
    if (n.playUrls.isEmpty) {
      final l = AppLocalizations.of(context);
      return Container(
        color: const Color(0xFF0B0910),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_creation_outlined, color: FF.dim, size: 44),
            const SizedBox(height: 12),
            Text(l.ixp_segGenerating,
                style: const TextStyle(color: FF.muted, fontSize: 14)),
            const SizedBox(height: 14),
            _outline(l.ixp_btnContinue, Icons.fast_forward_rounded, _skip),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _preppingView() {
    return Container(
      color: const Color(0xCC000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 38, height: 38,
            child: CircularProgressIndicator(color: FF.hot, strokeWidth: 2.4),
          ),
          const SizedBox(height: 14),
          Text(
            _prepTotal > 0
                ? AppLocalizations.of(context).ixp_prepFmt(
                    _prepDone.toString(), _prepTotal.toString())
                : AppLocalizations.of(context).ixp_prep,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _choicesPanel(IxNode n) {
    final choices = _shownChoices;
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xCC000000), Color(0xF2000000)],
            stops: [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(AppLocalizations.of(context).ixp_yourChoice,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black)
                          ])),
                ),
                for (int i = 0; i < choices.length; i++) ...[
                  _choiceCard(choices[i], i),
                  if (i != choices.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceCard(IxChoice c, int i) {
    final enabled = ixEval(c.requires, _flags);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Bounce(
        onTap: () => _choose(c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [
              FF.hot.withValues(alpha: 0.22),
              FF.purple.withValues(alpha: 0.22),
            ]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(c.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800)),
              ),
              if (c.locked) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [FF.orange, FF.gold]),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.lock_rounded, color: Color(0xFF231100), size: 12),
                    const SizedBox(width: 3),
                    Text('${c.price}',
                        style: const TextStyle(
                            color: Color(0xFF231100),
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: (60 * i).ms).fadeIn(duration: 320.ms).slideY(begin: 0.12, curve: Curves.easeOut);
  }

  Widget _endingCard(IxNode n) {
    final c = _endingColor(n.endingType);
    return Positioned.fill(
      child: Container(
        color: const Color(0xCC000000),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: c),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_endingLabel(n.endingType),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 18),
              Text(
                  n.title.isEmpty
                      ? AppLocalizations.of(context).ixp_endingFallback
                      : n.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _outline(AppLocalizations.of(context).ixp_btnReplay,
                      Icons.replay_rounded, _replay),
                  const SizedBox(width: 14),
                  _outline(AppLocalizations.of(context).ixp_btnBack,
                      Icons.check_rounded,
                      () => Navigator.of(context).maybePop()),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  List<Color> _endingColor(String t) {
    if (t.contains('good')) return const [FF.teal, FF.gold];
    if (t.contains('bad')) return const [Color(0xFF8A8A8A), Color(0xFF555555)];
    if (t.contains('hidden')) return const [FF.purple, FF.hot];
    return const [FF.blue, FF.purple]; // open / 其他
  }

  String _endingLabel(String t) {
    final l = AppLocalizations.of(context);
    switch (t) {
      case 'good': return l.ixp_endingGood;
      case 'bad': return l.ixp_endingBad;
      case 'hidden': return l.ixp_endingHidden;
      case 'open': return l.ixp_endingOpen;
      default: return t.isEmpty ? l.ixp_endingFallback : t;
    }
  }

  Widget _circle(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x55000000),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _outline(String label, IconData icon, VoidCallback onTap) =>
      _PressBtn(label: label, icon: icon, onTap: onTap);
}

/// 强按压反馈按钮：按下立即变白色背景 + 图标变深色 + 缩小 + 触觉震动。
/// 暗色场景上一眼看出"按上了"。
class _PressBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PressBtn({required this.label, required this.icon, required this.onTap});
  @override
  State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn> {
  bool _down = false;
  void _set(bool v) { if (mounted && _down != v) setState(() => _down = v); }
  @override
  Widget build(BuildContext context) {
    final fg = _down ? const Color(0xFF1A1A1A) : Colors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) { _set(true); HapticFeedback.lightImpact(); },
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: _down ? Colors.white : const Color(0x55000000),
            border: Border.all(
                color: Colors.white.withValues(alpha: _down ? 1 : 0.30),
                width: _down ? 1.5 : 1),
            boxShadow: _down
                ? [const BoxShadow(color: Color(0x55FFFFFF), blurRadius: 14, spreadRadius: 1)]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: fg, size: 17),
            const SizedBox(width: 7),
            Text(widget.label,
                style: TextStyle(
                    color: fg, fontSize: 14, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );
  }
}

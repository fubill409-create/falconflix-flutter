import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/interactive_manifest.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import '../ui/thinking_backdrop.dart';

/// 互动剧 · manifest 驱动的树状播放器（FalconFlix ↔ Nova 对接的播放端）。
/// 读 manifest（节点树/选项边/收费标记）→ 标题屏 → 场景(旁白) → 抉择(发光选择卡+投票%+锁+
/// 预览诱饵) → 幕间转场(呼吸星·章节卡) → 结局(稀有度+图鉴)。
/// ⚠️转场分两类：①预制内容(已生成好的视频)=短促章节卡，**不写「生成中」**；
/// ②末端 2888 自定义结局=真烧 API 几分钟的异步活，走「需要时间·完成通知你」（占位 /generateEnding）。
/// 当前喂的是包内 demo manifest；上线换成 `/interactive/import` 写库的真 manifest。
const String kDemoManifestAsset = 'assets/interactive/demo_manifest.json';

class InteractivePlayerScreen extends StatefulWidget {
  final String manifestAsset;
  const InteractivePlayerScreen(
      {super.key, this.manifestAsset = kDemoManifestAsset});

  @override
  State<InteractivePlayerScreen> createState() =>
      _InteractivePlayerScreenState();
}

enum _Phase { loading, error, title, scene, decision, ending }

class _InteractivePlayerScreenState extends State<InteractivePlayerScreen> {
  InteractiveManifest? _m;
  String? _err;
  _Phase _phase = _Phase.loading;
  String _nodeId = '';
  // 转场/生成中：原地浮起星片 + 文案叠在上方空白区，正文留着、不整屏切白。
  bool _busy = false;
  String _busyLabel = '';
  String? _busySub;
  final Set<String> _visitedEndings = {};
  final Set<String> _unlocked = {}; // "nodeId>target"

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await rootBundle.loadString(widget.manifestAsset);
      final m = InteractiveManifest.fromJsonString(s);
      final errs = m.validate();
      if (!mounted) return;
      if (errs.isNotEmpty) {
        setState(() {
          _err = errs.join('\n');
          _phase = _Phase.error;
        });
        return;
      }
      setState(() {
        _m = m;
        _phase = _Phase.title;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = AppLocalizations.of(context).ixp_loadErrorFmt(e.toString());
        _phase = _Phase.error;
      });
    }
  }

  IxNode? get _node => _m?.node(_nodeId);

  void _start() {
    setState(() {
      _nodeId = _m!.rootNodeId;
      _phaseForNode();
    });
  }

  void _phaseForNode() {
    final n = _node;
    if (n == null) return;
    if (n.isEnding) {
      _visitedEndings.add(n.id);
      _phase = _Phase.ending;
    } else if (n.type == IxNodeType.decision) {
      _phase = _Phase.decision;
    } else {
      _phase = _Phase.scene;
    }
  }

  /// 幕间转场（预制内容 = Nova 早生成好的视频，切下一段已缓存视频）。
  /// 短促一瞬的「呼吸星」章节卡，label = 即将进入的章节名，**绝不写「生成中」**——
  /// 因为没有任何东西在生成，就是加载下一段现成视频。真实版这里就是切下一个 videoUrl。
  Future<void> _advance(String targetId) async {
    // 预制转场只留上方那颗呼吸星，**不显文案**——章节名在新场景自己的 chip 上有，
    // 重复显会和正文「字压字」重叠（用户真机点破）。
    setState(() {
      _busy = true;
      _busyLabel = '';
      _busySub = null;
    });
    // 久一点足一点·要有"思考"的停顿感：进场→星呼吸几下→退场（动画时长铁律）。
    await Future.delayed(const Duration(milliseconds: 3400));
    if (!mounted) return;
    setState(() {
      _nodeId = targetId;
      _phaseForNode();
      _busy = false;
    });
  }

  /// 现场定制专属结局（2888 = 真·现场烧 API 给你一个人生成视频，几分钟的异步活）。
  /// 讲清「需要时间 · 完成通知你 · 你可以先去逛逛」——不是拿个动画在那等几秒那么简单。
  /// demo 没接后端 → 这里模拟「已提交→制作中→完成」几段；真实版 = POST /interactive/generateEnding
  /// → 轮询 Nova 生成 → 完成推送通知 → 用户回来播放专属视频（[[project-monetization-redesign]]）。
  Future<void> _customEnding(String targetId) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _busyLabel = l.ip_busyAiCreatingTitle;
      _busySub = l.ip_busyAiCreatingSub;
    });
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    setState(() {
      _busyLabel = l.ip_busyDirectorTitle;
      _busySub = l.ip_busyDirectorSub;
    });
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    setState(() {
      _busyLabel = l.ip_busyDoneTitle;
      _busySub = l.ip_busyDoneSub;
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _nodeId = targetId;
      _phaseForNode();
      _busy = false;
    });
  }

  void _continueScene() {
    final n = _node;
    if (n?.next != null) _advance(n!.next!);
  }

  void _choose(IxChoice c) {
    final key = '$_nodeId>${c.target}';
    if (c.price > 0 && !_unlocked.contains(key)) {
      _openUnlock(c, key);
    } else {
      _advance(c.target);
    }
  }

  // ─── 收费埋点：预制分支(60) 解锁 / 末端开放式结局(2888) 定制仪式 ───
  void _openUnlock(IxChoice c, String key) {
    final target = _m?.node(c.target);
    final isAiSlot = target?.type == IxNodeType.endingAiSlot || c.price >= 2888;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _UnlockSheet(
        choice: c,
        isAiSlot: isAiSlot,
        onConfirm: () {
          Navigator.pop(ctx);
          setState(() => _unlocked.add(key));
          if (isAiSlot) {
            _customEnding(c.target); // 真异步生成：需要时间·完成通知你
          } else {
            _advance(c.target); // 预制分支：切已生成好的视频
          }
        },
      ),
    );
  }

  void _replay() {
    setState(_start);
  }

  @override
  Widget build(BuildContext context) {
    // 互动剧播放器 = 通用功能（什么剧都能放），跟随日夜：白天亮、夜里暗。
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      body: Stack(
        children: [
          if (!p.day) const AmbientBackground(),
          // 正文：换节点时原地「交叉淡入」，不闪白、不丢内容。
          // 转场/思考中整体变暗→退成背景（世界静下来、AI 在想），让上方那颗星成为焦点，
          // 也根治了章节文案和正文「对撞重叠」的错位感。
          SafeArea(
            child: AnimatedOpacity(
              opacity: _busy ? 0.3 : 1.0,
              duration: const Duration(milliseconds: 320),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 480),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey('${_phase.name}_$_nodeId'),
                  child: _body(),
                ),
              ),
            ),
          ),
          // 转场/生成中：浮起星片 + 文案叠在上方空白区——正文留着、不整屏切白。
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              child: _busy
                  ? _busyOverlay()
                  : const SizedBox.shrink(key: ValueKey('idle')),
            ),
          ),
          // 顶部返回 + 图鉴进度（始终在，不被盖走）
          if (_phase != _Phase.loading)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 14, 0),
                child: Row(
                  children: [
                    _circleBtn(Icons.arrow_back_rounded,
                        () => Navigator.of(context).maybePop()),
                    const Spacer(),
                    if (_m != null) _dexChip(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 转场/生成中的浮起星片层：上方空白区一颗呼吸星 + 文案，正文留在下面照常可见。
  Widget _busyOverlay() {
    final p = Pal.now();
    return Align(
      key: const ValueKey('busy'),
      alignment: const Alignment(0, -0.46),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FloatingAiStar(size: 152),
            // 预制转场无文案时只显星；2888 定制等有文案才显（且那时正文已淡出，不会压字）。
            if (_busyLabel.isNotEmpty) ...[
              const SizedBox(height: 26),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                child: Column(
                  key: ValueKey('$_busyLabel|$_busySub'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_busyLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    if (_busySub != null) ...[
                      const SizedBox(height: 10),
                      Text(_busySub!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: p.textMuted,
                              fontSize: 12.5,
                              height: 1.7)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _Phase.loading:
        return const Center(
            child: CircularProgressIndicator(color: FF.hot, strokeWidth: 2.6));
      case _Phase.error:
        return _errorView();
      case _Phase.title:
        return _titleView();
      case _Phase.scene:
        return _sceneView();
      case _Phase.decision:
        return _decisionView();
      case _Phase.ending:
        return _endingView();
    }
  }

  // ───────────────────────── 标题屏 ─────────────────────────
  Widget _titleView() {
    final m = _m!;
    final p = Pal.now();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          GlowChip(l.ip_titleChipFmt(m.endingCount.toString())),
          const SizedBox(height: 20),
          gradientText(m.title,
                  size: 40, gradient: FF.brandGradient)
              .animate()
              .fadeIn(duration: 600.ms)
              .scaleXY(begin: 0.92, curve: Curves.easeOut),
          const SizedBox(height: 18),
          Text(m.synopsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 15,
                      height: 1.7))
              .animate()
              .fadeIn(delay: 350.ms, duration: 700.ms),
          const Spacer(),
          Text(l.ip_titleSub,
              style: TextStyle(color: p.textMuted, fontSize: 12.5)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
                label: l.ip_titleStart, height: 54, onTap: _start),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  // ───────────────────────── 场景（旁白） ─────────────────────────
  Widget _sceneView() {
    final n = _node!;
    final p = Pal.now();
    return Padding(
      key: ValueKey('scene_${n.id}'),
      padding: const EdgeInsets.fromLTRB(26, 64, 26, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 大留白在上：把旁白压到下半屏，上方那块空地留给转场的呼吸星，不再字压字。
          const Spacer(flex: 3),
          if (n.chip.isNotEmpty)
            GlowChip(n.chip).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
          const SizedBox(height: 18),
          Text(n.beat,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 19,
                      height: 1.85,
                      fontWeight: FontWeight.w600))
              .animate()
              .fadeIn(delay: 200.ms, duration: 800.ms)
              .slideY(begin: 0.04, curve: Curves.easeOut),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _continueScene,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  gradient: FF.brandGradient,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                        color: FF.hot.withValues(alpha: 0.32), blurRadius: 20),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context).ip_btnContinue,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 抉择点 ─────────────────────────
  Widget _decisionView() {
    final n = _node!;
    final p = Pal.now();
    return Padding(
      key: ValueKey('decision_${n.id}'),
      padding: const EdgeInsets.fromLTRB(22, 64, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          if (n.chip.isNotEmpty) GlowChip(n.chip),
          const SizedBox(height: 14),
          Text(n.question,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 22,
                      height: 1.5,
                      fontWeight: FontWeight.w900))
              .animate()
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 22),
          for (var i = 0; i < n.choices.length; i++)
            _choiceCard(n.choices[i], i),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _choiceCard(IxChoice c, int i) {
    final unlocked = _unlocked.contains('$_nodeId>${c.target}');
    final locked = c.price > 0 && !unlocked;
    final isAi = c.price >= 2888; // 2888 卡始终暗金（premium），不跟日夜
    final p = Pal.now();
    final onCard = isAi ? Colors.white : p.text;
    final onCardMuted = isAi ? Colors.white60 : p.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _choose(c),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isAi
                ? const LinearGradient(
                    colors: [Color(0xFF3A2A12), Color(0xFF2A1840)])
                : null,
            color: isAi
                ? null
                : (p.day ? Colors.white : Colors.white.withValues(alpha: 0.05)),
            border: Border.all(
                color: isAi
                    ? FF.gold.withValues(alpha: 0.6)
                    : (locked
                        ? FF.gold.withValues(alpha: 0.32)
                        : (p.day
                            ? Colors.black.withValues(alpha: 0.10)
                            : Colors.white.withValues(alpha: 0.14)))),
            boxShadow: isAi
                ? [BoxShadow(color: FF.gold.withValues(alpha: 0.22), blurRadius: 18)]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (locked)
                    Icon(isAi ? Icons.auto_awesome : Icons.lock_rounded,
                        color: FF.gold, size: 18),
                  if (locked) const SizedBox(width: 8),
                  Expanded(
                    child: Text(c.label,
                        style: TextStyle(
                            color: onCard,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            height: 1.3)),
                  ),
                  if (locked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: FF.goldGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                          AppLocalizations.of(context)
                              .sheets_coinsFmt(c.price.toString()),
                          style: const TextStyle(
                              color: Color(0xFF2A1B00),
                              fontSize: 11,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ],
              ),
              // 预览诱饵（锁前钩子台词）
              if (locked && (c.teaserLine?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility_outlined,
                        color: FF.gold.withValues(alpha: 0.8), size: 13),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(c.teaserLine!,
                          style: TextStyle(
                              color: FF.gold.withValues(alpha: 0.85),
                              fontSize: 12.5,
                              height: 1.45,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ],
              // 投票条（社会认同）
              if (c.vote > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: c.vote / 100.0,
                          minHeight: 4,
                          backgroundColor: (isAi || !p.day)
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(
                              locked ? FF.gold : FF.teal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        AppLocalizations.of(context)
                            .ip_voteFmt(c.vote.toString()),
                        style: TextStyle(color: onCardMuted, fontSize: 11)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn(delay: (120 * i).ms, duration: 420.ms).slideY(
          begin: 0.12, curve: Curves.easeOut),
    );
  }

  // ───────────────────────── 结局 ─────────────────────────
  Widget _endingView() {
    final n = _node!;
    final isAi = n.type == IxNodeType.endingAiSlot;
    final colors = _rarityColors(n.rarity);
    final p = Pal.now();
    return Padding(
      key: ValueKey('ending_${n.id}'),
      padding: const EdgeInsets.fromLTRB(28, 64, 28, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          // 稀有度徽章
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(colors: colors),
              boxShadow: [
                BoxShadow(color: colors.last.withValues(alpha: 0.5), blurRadius: 20),
              ],
            ),
            child: Text(isAi ? '✦ ${n.rarity}' : n.rarity,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900)),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scaleXY(begin: 0.6, curve: Curves.easeOutBack),
          const SizedBox(height: 18),
          gradientText(n.endingTitle,
                  size: 34,
                  gradient: LinearGradient(colors: colors))
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 18),
          Text(n.endingText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 15,
                      height: 1.85))
              .animate()
              .fadeIn(delay: 450.ms, duration: 800.ms),
          const SizedBox(height: 14),
          // 图鉴进度
          Text(
              AppLocalizations.of(context).ip_endingProgressFmt(
                  _visitedEndings.length.toString(),
                  _m!.endingCount.toString()),
              style: const TextStyle(
                  color: FF.gold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _outlineBtn(
                    AppLocalizations.of(context).ip_btnDex,
                    Icons.auto_stories_rounded,
                    _openDex),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                    label: AppLocalizations.of(context).ip_btnReplay,
                    height: 52,
                    onTap: _replay),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  // ───────────────────────── 结局图鉴 ─────────────────────────
  void _openDex() {
    final m = _m!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xF2141019),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, 20 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                gradientText(AppLocalizations.of(context).ip_dexTitle,
                    size: 22, gradient: FF.brandGradient),
                const Spacer(),
                Text('${_visitedEndings.length}/${m.endingCount}',
                    style: const TextStyle(
                        color: FF.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            for (final e in m.endings) _dexRow(e),
          ],
        ),
      ),
    );
  }

  Widget _dexRow(IxNode e) {
    final got = _visitedEndings.contains(e.id);
    final colors = _rarityColors(e.rarity);
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: got ? 0.06 : 0.025),
        border: Border.all(
            color: got
                ? colors.last.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(got ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: got ? colors.last : FF.dim, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(got ? e.endingTitle : l.ip_dexLocked,
                    style: TextStyle(
                        color: got ? Colors.white : FF.dim,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(e.rarity,
                    style: TextStyle(
                        color: got ? colors.last : FF.dim, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 小件 ─────────────────────────
  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.report_gmailerrorred_rounded,
                  color: FF.hot, size: 40),
              const SizedBox(height: 14),
              Builder(
                builder: (context) => Text(
                    AppLocalizations.of(context)
                        .ip_errorTitleFmt(_err ?? ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Pal.now().text, fontSize: 13, height: 1.6)),
              ),
            ],
          ),
        ),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    final p = Pal.now();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.topbarBg,
          border: Border.all(color: p.line),
        ),
        child: Icon(icon, color: p.text, size: 20),
      ),
    );
  }

  Widget _dexChip() {
    final p = Pal.now();
    return GestureDetector(
      onTap: _phase == _Phase.title ? null : _openDex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: p.topbarBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_rounded, color: FF.gold, size: 15),
            const SizedBox(width: 5),
            Text('${_visitedEndings.length}/${_m!.endingCount}',
                style: TextStyle(
                    color: p.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _outlineBtn(String label, IconData icon, VoidCallback onTap) {
    final p = Pal.now();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.day ? p.text.withValues(alpha: 0.3) : Colors.white30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: p.text, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  List<Color> _rarityColors(String rarity) {
    if (rarity.contains('定制')) return [FF.gold, FF.brightGold];
    if (rarity.contains('隐藏') || rarity.contains('真') || rarity.contains('反转')) {
      return [FF.purple, FF.hot];
    }
    if (rarity.contains('稀有')) return [FF.blue, FF.teal];
    if (rarity.contains('好')) return [FF.teal, FF.gold];
    return [FF.dim, FF.weak]; // 坏/普通
  }
}

/// 解锁弹层：预制分支(60) / 末端开放式定制结局(2888)。
/// demo = 样板剧，不真扣鹰币（标注「样板剧免费体验」）；上线接 Nova 内容时走真扣费/真生成。
class _UnlockSheet extends StatelessWidget {
  final IxChoice choice;
  final bool isAiSlot;
  final VoidCallback onConfirm;
  const _UnlockSheet(
      {required this.choice, required this.isAiSlot, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xF2141019),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 22 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(999)),
          ),
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: FF.goldGradient,
              boxShadow: [
                BoxShadow(color: FF.gold.withValues(alpha: 0.5), blurRadius: 22),
              ],
            ),
            child: Icon(isAiSlot ? Icons.auto_awesome : Icons.lock_open_rounded,
                color: const Color(0xFF2A1B00), size: 32),
          ),
          const SizedBox(height: 16),
          Text(isAiSlot ? l.ip_unlockTitleAi : l.ip_unlockTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (choice.teaserLine?.isNotEmpty ?? false)
            Text(choice.teaserLine!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: FF.gold.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.6,
                    fontStyle: FontStyle.italic)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: FF.gold, size: 18),
                const SizedBox(width: 8),
                Text(l.sheets_coinsFmt(choice.price.toString()),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(l.ip_demoFree,
                    style: const TextStyle(color: FF.dim, fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: isAiSlot ? l.ip_unlockBtnAi : l.ip_unlockBtn,
              height: 52,
              onTap: onConfirm,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.ip_unlockCancel,
                style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

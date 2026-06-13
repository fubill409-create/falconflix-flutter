import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/interactive_manifest.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import '../ui/thinking_backdrop.dart';

/// 互动剧 · 包内「免费样板剧」播放器（manifest 驱动的树状播放）。
/// 读包内 demo manifest（节点树/选项边）→ 标题屏 → 场景(旁白) → 抉择(发光选择卡+投票%+
/// 钩子台词) → 幕间转场(呼吸星·章节卡) → 结局(稀有度+图鉴)。
/// 这是一部**免费体验 demo**：所有分支直接进，全程不收费、不弹解锁层、无 AI 定制结局，
/// 转场只切现成节点、**绝不写「生成中」**（没有任何东西在生成）。
/// 真正的付费分支解锁 / AI 定制结局走真后端的剧（见 ix_player_screen + Api.ix*）。
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
  // 幕间转场：原地浮起一颗呼吸星，正文留着、不整屏切白。
  // 这是免费样板剧——只切换现成节点，没有任何付费 / AI 生成，所以转场不显「生成中」文案。
  bool _busy = false;
  final Set<String> _visitedEndings = {};

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

  /// 幕间转场：切到下一段现成节点（免费样板剧，没有任何东西在生成）。
  /// 短促一瞬的「呼吸星」章节卡——章节名在新场景自己的 chip 上有，**绝不写「生成中」**。
  Future<void> _advance(String targetId) async {
    setState(() => _busy = true);
    // 一点停顿感：进场→星呼吸几下→退场。
    await Future.delayed(const Duration(milliseconds: 3400));
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

  // 免费样板剧：所有选项直接进，不扣费、不弹解锁层、不假装在生成。
  // 真正的付费解锁 / AI 定制结局走真后端的剧（ix_player_screen / Api.ix*），不在这部 demo 上。
  void _choose(IxChoice c) {
    _advance(c.target);
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

  /// 幕间转场的浮起星片层：上方空白区一颗呼吸星，正文留在下面照常可见。
  /// 免费样板剧只切现成节点，转场不显任何「生成中」文案（章节名在新场景 chip 上）。
  Widget _busyOverlay() {
    return const Align(
      key: ValueKey('busy'),
      alignment: Alignment(0, -0.46),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: FloatingAiStar(size: 152),
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
          const SizedBox(height: 14),
          // 明确标注：这是免费样板剧，全程不收费、无 AI 定制（真付费体验在真后端的剧上）。
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: FF.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: FF.gold.withValues(alpha: 0.4)),
            ),
            child: Text(l.aid_demoBadge,
                style: const TextStyle(
                    color: FF.gold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800)),
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
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

  // 免费样板剧：选项卡统一样式——无锁、无价（不展示任何不会真扣的价格）。
  // 钩子台词 + 人群投票% 是诚实的「社会认同」元素，保留。
  Widget _choiceCard(IxChoice c, int i) {
    final p = Pal.now();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _choose(c),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: p.day ? Colors.white : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
                color: p.day
                    ? Colors.black.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(c.label,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            height: 1.3)),
                  ),
                ],
              ),
              // 钩子台词（悬念峰值，免费可见）
              if (c.teaserLine?.isNotEmpty ?? false) ...[
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
                          backgroundColor: p.day
                              ? Colors.black.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation(FF.teal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        AppLocalizations.of(context)
                            .ip_voteFmt(c.vote.toString()),
                        style: TextStyle(color: p.textMuted, fontSize: 11)),
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

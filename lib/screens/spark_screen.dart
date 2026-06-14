import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'login_screen.dart';
import 'spark_flow_screen.dart';

/// AI 玩法（Spark）页 — 和短剧观看连接的轻量 AI 玩法。已接真实后端：
/// 玩法卡从 Api.sparkModes() 拉取，明码标价；商城卡改为「我的创作」入口。
/// 从首页/播放页「AI 入戏」进入时带 [contextTitle]（当前短剧），顶部显示创作横幅。
class SparkScreen extends StatefulWidget {
  final String? contextTitle;
  const SparkScreen({super.key, this.contextTitle});

  @override
  State<SparkScreen> createState() => _SparkScreenState();
}

class _SparkScreenState extends State<SparkScreen> {
  List<Map<String, dynamic>> _modes = [];

  @override
  void initState() {
    super.initState();
    _loadModes();
  }

  Future<void> _loadModes() async {
    try {
      final m = await Api.sparkModes();
      if (mounted && m.isNotEmpty) setState(() => _modes = m);
    } catch (_) {
      // 失败保持空：网格隐藏，hero 仍可点（用兜底 poster）。
    }
  }

  // 每个玩法的图标与简介（按 mode key 映射；文案取已有 l10n）。
  IconData _iconFor(String mode) {
    switch (mode) {
      case 'avatar':
        return Icons.face_retouching_natural_outlined;
      case 'makeover':
        return Icons.auto_fix_high_outlined;
      case 'poster':
      default:
        return Icons.image_outlined;
    }
  }

  String _descFor(AppLocalizations l, String mode) {
    switch (mode) {
      case 'avatar':
        return l.sp_toolAvatarDesc;
      case 'makeover':
        return l.sp_toolMakeoverDesc;
      case 'poster':
      default:
        return l.sp_toolPosterDesc;
    }
  }

  // 玩法名取本地化文案（按 mode 映射），不用服务端 label——否则切英语仍显示中文。
  String _nameFor(AppLocalizations l, String mode) {
    switch (mode) {
      case 'avatar':
        return l.sp_toolAvatarName;
      case 'makeover':
        return l.sp_toolMakeoverName;
      case 'poster':
      default:
        return l.sp_toolPosterName;
    }
  }

  void _launch(Map<String, dynamic> m) {
    final mode = m['mode']?.toString() ?? 'poster';
    final label = _nameFor(AppLocalizations.of(context), mode);
    final coins = (m['coins'] as num?)?.toInt() ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SparkFlowScreen(
          mode: mode,
          label: label,
          coins: coins,
          contextTitle: widget.contextTitle,
        ),
      ),
    );
  }

  void _launchFirst() {
    if (_modes.isNotEmpty) {
      _launch(_modes.first);
    } else {
      // modes 未拉到：用 poster 兜底（flow 内会再拉一次拿到权威价）。
      _launch({'mode': 'poster', 'label': 'Drama poster', 'coins': 25});
    }
  }

  void _openHistory() {
    if (!auth.loggedIn) {
      Navigator.push<bool>(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()))
          .then((ok) {
        if (ok == true) auth.refresh();
      });
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FF.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _MyCreationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final contextTitle = widget.contextTitle;
    return Scaffold(
      backgroundColor: FF.bg,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 110),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 从首页/播放页「AI Remix」push 进来时显示返回（作为底栏 Tab 时不显示）
                    if (Navigator.canPop(context)) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x18FFFFFF),
                            border: Border.all(color: FF.line),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: FF.text, size: 20),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          gradientText(l.sp_sectionHeader,
                              size: 26, gradient: FF.aiGradient),
                          const SizedBox(height: 4),
                          Text(l.sp_subtitle,
                              style: const TextStyle(
                                  color: FF.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (contextTitle != null && contextTitle.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Glass(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: FF.teal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(l.sp_creatingFmt(contextTitle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: FF.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _hero(context).animate().fadeIn(duration: 450.ms).slideY(
                    begin: 0.1, curve: Curves.easeOut),
                const SizedBox(height: 14),
                _historyEntry(l)
                    .animate(delay: 120.ms)
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOut),
                const SizedBox(height: 14),
                _featureGrid(context)
                    .animate(delay: 240.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1A16), Color(0xFF16201E)],
        ),
        border: Border.all(color: FF.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniChip(l.sp_chipLinked),
          const SizedBox(height: 12),
          Text(l.sp_putInDramaTitle,
              style: const TextStyle(
                  color: FF.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(l.sp_putInDramaBody,
              style: const TextStyle(
                  color: FF.muted, fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _launchFirst,
            child: Container(
              height: 44,
              width: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: FF.hotGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(l.sp_btnTryRoleplay,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 1800.ms, color: Colors.white24),
        ],
      ),
    );
  }

  /// 「我的创作」入口（原场景商城死卡复用为真实历史入口）。
  Widget _historyEntry(AppLocalizations l) {
    return GestureDetector(
      onTap: _openHistory,
      child: Glass(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.collections_outlined, color: FF.gold, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Creations',
                      style: TextStyle(
                          color: FF.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text("See everything you've made with AI.",
                      style: TextStyle(color: FF.muted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: FF.dim, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureGrid(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_modes.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: _modes.length,
      itemBuilder: (_, i) {
        final m = _modes[i];
        final mode = m['mode']?.toString() ?? '';
        final label = _nameFor(l, mode);
        final coins = (m['coins'] as num?)?.toInt() ?? 0;
        return GestureDetector(
          onTap: () => _launch(m),
          child: Glass(
            radius: 16,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        FF.gold.withValues(alpha: 0.18),
                        FF.teal.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                  child: Center(
                      child: Icon(_iconFor(mode),
                          color: FF.brightGold, size: 30)),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniChip(l.sp_chipLinked),
                      const SizedBox(height: 8),
                      Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(_descFor(l, mode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: FF.muted, fontSize: 11, height: 1.35)),
                      const SizedBox(height: 8),
                      Text('$coins coins',
                          style: const TextStyle(
                              color: FF.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniChip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: FF.bg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FF.line)),
        child: Text(t,
            style: const TextStyle(
                color: FF.text, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

/// 「我的创作」底部弹窗：真接 Api.sparkHistory()，网格展示历史成片。
class _MyCreationsSheet extends StatefulWidget {
  const _MyCreationsSheet();

  @override
  State<_MyCreationsSheet> createState() => _MyCreationsSheetState();
}

class _MyCreationsSheetState extends State<_MyCreationsSheet> {
  List<Map<String, dynamic>>? _items; // null = 加载中
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final h = await Api.sparkHistory();
      if (mounted) setState(() => _items = h);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: FF.dim, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('My Creations',
                style: TextStyle(
                    color: FF.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _body(),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: FF.dim)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_error) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('Couldn\'t load, please try again.',
              style: TextStyle(color: FF.muted, fontSize: 13)),
        ),
      );
    }
    final items = _items;
    if (items == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.4, color: FF.hot),
        ),
      );
    }
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('Nothing here yet — go make your first one.',
              style: TextStyle(color: FF.muted, fontSize: 13)),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.7,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final url = items[i]['resultUrl']?.toString() ?? '';
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.black26,
              child: url.isEmpty
                  ? const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: FF.dim, size: 22))
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: FF.dim, size: 22)),
                    ),
            ),
          );
        },
      ),
    );
  }
}

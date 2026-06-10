import 'package:flutter/material.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../state/locale_notifier.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';
import '../version.dart';
import 'me_subpages.dart' show AboutScreen;

/// 帮助与关于子页 —— 任务 #15 / me_screen「帮助与关于」组。
///
/// 4 个分项：FAQ / 联系客服(工单) / 意见反馈 / 关于。
class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
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
                  child: _topbar(p, AppLocalizations.of(context).helpAbout_title),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    final l = AppLocalizations.of(context);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(6, 4, 6, 110),
                      children: [
                        _group(p, l.helpAbout_sectionHelp, [
                          _row(p, Icons.help_outline_rounded, l.helpAbout_rowFaq,
                              subtitle: l.helpAbout_rowFaqDesc,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const FaqListScreen()))),
                          _row(p, Icons.support_agent_outlined, l.helpAbout_rowSupport,
                              subtitle: l.helpAbout_rowSupportDesc,
                              onTap: () {
                                if (!auth.loggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF15101F),
                                    content: Text(l.common_pleaseLogin,
                                        style: const TextStyle(color: Colors.white)),
                                  ));
                                  return;
                                }
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SupportTicketsScreen()));
                              }),
                          _row(p, Icons.feedback_outlined, l.helpAbout_rowFeedback,
                              subtitle: l.helpAbout_rowFeedbackDesc,
                              onTap: () {
                                if (!auth.loggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF15101F),
                                    content: Text(l.common_pleaseLogin,
                                        style: const TextStyle(color: Colors.white)),
                                  ));
                                  return;
                                }
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const FeedbackSubmitScreen()));
                              }),
                        ]),
                        _group(p, l.helpAbout_sectionAbout, [
                          _row(p, Icons.info_outline_rounded, l.me_rowAbout,
                              value: kAppVersion,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const AboutScreen()))),
                        ]),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(Pal p, String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text(title,
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
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(height: 1, color: p.line, indent: 52),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Pal p, IconData icon, String title,
      {String? subtitle, String? value, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: p.textMuted, size: 20),
      title: Text(title,
          style: TextStyle(
              color: p.text, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle,
              style: TextStyle(color: p.textMuted, fontSize: 11)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: TextStyle(color: p.textMuted, fontSize: 12)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: p.textMuted, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}

// =============================================================
// FAQ 列表
// =============================================================
class FaqListScreen extends StatefulWidget {
  const FaqListScreen({super.key});

  @override
  State<FaqListScreen> createState() => _FaqListScreenState();
}

class _FaqListScreenState extends State<FaqListScreen> {
  List<Map<String, dynamic>>? _items;
  bool _loading = true;
  String? _error;
  String _category = '';

  /// 分类 key → AppLocalizations getter 名（运行时翻译）
  static const _cats = [
    ('', 'faq_catAll'),
    ('account', 'faq_catAccount'),
    ('recharge', 'faq_catRecharge'),
    ('playback', 'faq_catPlayback'),
    ('interactive', 'faq_catInteractive'),
    ('other', 'faq_catOther'),
  ];

  String _catLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'faq_catAll': return l.faq_catAll;
      case 'faq_catAccount': return l.faq_catAccount;
      case 'faq_catRecharge': return l.faq_catRecharge;
      case 'faq_catPlayback': return l.faq_catPlayback;
      case 'faq_catInteractive': return l.faq_catInteractive;
      case 'faq_catOther': return l.faq_catOther;
      default: return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lang = localeNotifier.value.languageCode;
      final list = await Api.helpFaqList(
          category: _category.isEmpty ? null : _category, lang: lang);
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : AppLocalizations.of(context).common_loadFailed;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
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
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 6),
                  child: _topbar(p, AppLocalizations.of(context).faq_title),
                ),
                _catBar(p),
                Expanded(child: _content(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _catBar(Pal p) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          for (final c in _cats)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(_catLabel(AppLocalizations.of(context), c.$2),
                    style: TextStyle(
                        color: _category == c.$1
                            ? Colors.white
                            : p.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                selected: _category == c.$1,
                selectedColor: FF.hot,
                backgroundColor: p.day
                    ? Colors.black.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.05),
                side: BorderSide(color: p.line),
                onSelected: (_) {
                  setState(() => _category = c.$1);
                  _load();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(Pal p) {
    final l = AppLocalizations.of(context);
    if (_loading) return Center(child: CircularProgressIndicator(color: FF.hot));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }
    final items = _items ?? const [];
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline_rounded, color: p.textMuted, size: 52),
              const SizedBox(height: 14),
              Text(l.faq_emptyTitle,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l.faq_emptyBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.textMuted, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 110),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _FaqExpandable(p: p, item: items[i]),
    );
  }
}

class _FaqExpandable extends StatefulWidget {
  final Pal p;
  final Map<String, dynamic> item;
  const _FaqExpandable({required this.p, required this.item});

  @override
  State<_FaqExpandable> createState() => _FaqExpandableState();
}

class _FaqExpandableState extends State<_FaqExpandable> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final q = widget.item['question']?.toString() ?? '';
    final a = widget.item['answer']?.toString() ?? '';
    return Glass(
      radius: 12,
      color: p.day ? p.card : FF.glassFill,
      border: p.line,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(q,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4)),
                  ),
                  Icon(
                      _open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: p.textMuted,
                      size: 22),
                ],
              ),
            ),
          ),
          if (_open) ...[
            Divider(height: 1, color: p.line, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SelectableText(a,
                    style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13,
                        height: 1.6)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// 工单列表 + 新建工单 + 对话详情
// =============================================================
class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  List<Map<String, dynamic>>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await Api.feedbackMyList(pageNum: 1, pageSize: 50);
      if (!mounted) return;
      setState(() {
        _items = r.list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : AppLocalizations.of(context).common_loadFailed;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
    return Scaffold(
      backgroundColor: p.pageBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: FF.hot,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context).tickets_newBtn,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () async {
          final created = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FeedbackSubmitScreen(asTicket: true)));
          if (created == true) _load();
        },
      ),
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
                  child: _topbar(p, AppLocalizations.of(context).tickets_title),
                ),
                Expanded(child: _content(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Pal p) {
    if (_loading) return Center(child: CircularProgressIndicator(color: FF.hot));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(AppLocalizations.of(context).common_retry),
            ),
          ],
        ),
      );
    }
    final items = _items ?? const [];
    if (items.isEmpty) {
      final l = AppLocalizations.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent_outlined,
                  color: p.textMuted, size: 52),
              const SizedBox(height: 14),
              Text(l.tickets_emptyTitle,
                  style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l.tickets_emptyBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.textMuted, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: FF.hot,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 110),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _TicketCard(
          p: p,
          item: items[i],
          onTap: () async {
            final fid = items[i]['id'];
            if (fid is! int) return;
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TicketThreadScreen(feedbackId: fid)));
            _load();
          },
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Pal p;
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _TicketCard(
      {required this.p, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = item['status'] is int
        ? item['status'] as int
        : int.tryParse('${item['status']}') ?? 0;
    String statusLabel;
    Color statusColor;
    switch (status) {
      case 0:
        statusLabel = l.tickets_statusPending;
        statusColor = const Color(0xFFFFC107);
        break;
      case 1:
        statusLabel = l.tickets_statusReplied;
        statusColor = const Color(0xFF22C55E);
        break;
      case 2:
        statusLabel = l.tickets_statusResolved;
        statusColor = const Color(0xFF6F94FF);
        break;
      default:
        statusLabel = l.tickets_statusClosed;
        statusColor = p.textMuted;
    }
    final type = item['type']?.toString() ?? 'other';
    final content = item['content']?.toString() ?? '';
    final updateTime = item['updateTime']?.toString() ??
        item['createTime']?.toString() ??
        '';
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 14,
        color: p.day ? p.card : FF.glassFill,
        border: p.line,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Text(_typeLabel(context, type),
                    style: TextStyle(
                        color: p.textMuted, fontSize: 11)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: p.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: p.text,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(updateTime,
                style: TextStyle(color: p.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String _typeLabel(BuildContext context, String type) {
    final l = AppLocalizations.of(context);
    switch (type) {
      case 'bug':
        return l.feedback_typeBug;
      case 'suggestion':
        return l.feedback_typeSuggestion;
      case 'complaint':
        return l.feedback_typeComplaint;
      case 'recharge_issue':
        return l.feedback_typeRecharge;
      case 'other':
      default:
        return l.feedback_typeOther;
    }
  }
}

class TicketThreadScreen extends StatefulWidget {
  final int feedbackId;
  const TicketThreadScreen({super.key, required this.feedbackId});

  @override
  State<TicketThreadScreen> createState() => _TicketThreadScreenState();
}

class _TicketThreadScreenState extends State<TicketThreadScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await Api.feedbackThread(widget.feedbackId);
      if (!mounted) return;
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : AppLocalizations.of(context).common_loadFailed;
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await Api.feedbackReply(widget.feedbackId, text);
      _replyCtrl.clear();
      await _load();
      if (!mounted) return;
      setState(() => _sending = false);
    } catch (e) {
      setState(() => _sending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(l.tickets_sendFailed(e is ApiException ? e.message : '$e'),
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
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
                  child: _topbar(p, AppLocalizations.of(context).tickets_threadTitle),
                ),
                Expanded(child: _body(p)),
                _composer(p),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(Pal p) {
    if (_loading) return Center(child: CircularProgressIndicator(color: FF.hot));
    if (_error != null) {
      return Center(
          child: Text(_error!,
              style: TextStyle(color: p.textMuted, fontSize: 13)));
    }
    final feedback = _data?['feedback'] as Map<String, dynamic>? ?? const {};
    final replies = _data?['replies'] as List? ?? const [];
    return ListView(
      reverse: false,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      children: [
        _bubble(p, feedback, isStaff: false, isInitial: true),
        for (final r in replies.whereType<Map<String, dynamic>>())
          _bubble(p, r, isStaff: r['isStaff'] == 1, isInitial: false),
      ],
    );
  }

  Widget _bubble(Pal p, Map<String, dynamic> m,
      {required bool isStaff, required bool isInitial}) {
    final l = AppLocalizations.of(context);
    final content = m['content']?.toString() ?? '';
    final time =
        m['createTime']?.toString() ?? m['updateTime']?.toString() ?? '';
    return Align(
      // 客服气泡：阅读方向起点；我的气泡：阅读方向终点。
      // 在 LTR(中英日韩法) = 客服左/我右；RTL(阿语) 自动镜像为 客服右/我左。
      alignment: isStaff
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isStaff
              ? (p.day ? p.card : FF.glassFill)
              : FF.hot.withValues(alpha: 0.18),
          // RTL 自动镜像：客服气泡 bottom-start=4(贴对话方向起点)，我侧 bottom-end=4
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(14),
            topEnd: const Radius.circular(14),
            bottomStart: Radius.circular(isStaff ? 4 : 14),
            bottomEnd: Radius.circular(isStaff ? 14 : 4),
          ),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment:
              isStaff ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isInitial) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(l.tickets_initial,
                        style: TextStyle(
                            color: p.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(content,
                style: TextStyle(
                    color: p.text, fontSize: 14, height: 1.6)),
            const SizedBox(height: 4),
            Text('${isStaff ? l.tickets_speakerStaff : l.tickets_speakerSelf} · $time',
                style: TextStyle(color: p.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _composer(Pal p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: p.day ? p.card : FF.glassFill,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyCtrl,
                maxLines: 4,
                minLines: 1,
                style: TextStyle(color: p.text, fontSize: 14),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: AppLocalizations.of(context).tickets_replyHint,
                  hintStyle: TextStyle(color: p.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: p.day
                      ? Colors.black.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: p.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: p.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: FF.hot, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: FF.hot))
                  : const Icon(Icons.send_rounded, color: FF.hot),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// 意见反馈：提交表单
// =============================================================
class FeedbackSubmitScreen extends StatefulWidget {
  /// asTicket=true 表示从「联系客服」页过来，提交即生成一条工单；
  /// asTicket=false 表示从「意见反馈」入口过来（语义一致，仅文案微差异）。
  final bool asTicket;
  const FeedbackSubmitScreen({super.key, this.asTicket = false});

  @override
  State<FeedbackSubmitScreen> createState() => _FeedbackSubmitScreenState();
}

class _FeedbackSubmitScreenState extends State<FeedbackSubmitScreen> {
  String _type = 'suggestion';
  final _contentCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  bool _submitting = false;

  /// type → AppLocalizations getter key
  static const _types = [
    ('bug', 'feedback_typeBug'),
    ('suggestion', 'feedback_typeSuggestion'),
    ('complaint', 'feedback_typeComplaint'),
    ('recharge_issue', 'feedback_typeRecharge'),
    ('other', 'feedback_typeOther'),
  ];

  String _typeLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'feedback_typeBug': return l.feedback_typeBug;
      case 'feedback_typeSuggestion': return l.feedback_typeSuggestion;
      case 'feedback_typeComplaint': return l.feedback_typeComplaint;
      case 'feedback_typeRecharge': return l.feedback_typeRecharge;
      case 'feedback_typeOther': return l.feedback_typeOther;
      default: return key;
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final c = _contentCtrl.text.trim();
    if (c.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(l.feedback_minLength,
            style: const TextStyle(color: Colors.white)),
      ));
      return;
    }
    setState(() => _submitting = true);
    try {
      await Api.feedbackSubmit(
        type: _type,
        content: c,
        appVersion: kAppVersion,
        deviceInfo: _deviceInfo(),
        contact: _contactCtrl.text.trim().isEmpty
            ? null
            : _contactCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(l.feedback_submitted,
            style: const TextStyle(color: Colors.white)),
      ));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(e.message,
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (_) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15101F),
        content: Text(l.common_loadFailed,
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  String _deviceInfo() {
    // 简化：只带 platform 和 locale，正经的 device_info 包等 #16 一起接
    final loc = localeNotifier.value.languageCode;
    return 'lang=$loc';
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.now();
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
                  child: _topbar(p, widget.asTicket
                      ? AppLocalizations.of(context).feedback_titleTicket
                      : AppLocalizations.of(context).feedback_titleFeedback),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    final l = AppLocalizations.of(context);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
                      children: [
                        Text(l.feedback_typeLabel,
                            style: TextStyle(
                                color: p.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in _types)
                              ChoiceChip(
                                label: Text(_typeLabel(l, t.$2),
                                    style: TextStyle(
                                      color: _type == t.$1
                                          ? Colors.white
                                          : p.text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    )),
                                selected: _type == t.$1,
                                selectedColor: FF.hot,
                                backgroundColor: p.day
                                    ? Colors.black.withValues(alpha: 0.04)
                                    : Colors.white.withValues(alpha: 0.05),
                                side: BorderSide(color: p.line),
                                onSelected: (_) =>
                                    setState(() => _type = t.$1),
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(l.feedback_contentLabel,
                            style: TextStyle(
                                color: p.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: p.line)),
                          child: TextField(
                            controller: _contentCtrl,
                            maxLines: 6,
                            maxLength: 1000,
                            style:
                                TextStyle(color: p.text, fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12),
                              hintText: widget.asTicket
                                  ? l.feedback_contentHintTicket
                                  : l.feedback_contentHintFeedback,
                              hintStyle: TextStyle(
                                  color: p.textMuted, fontSize: 13),
                              border: InputBorder.none,
                              counterStyle: TextStyle(
                                  color: p.textMuted, fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(l.feedback_contactLabel,
                            style: TextStyle(
                                color: p.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: p.line)),
                          child: TextField(
                            controller: _contactCtrl,
                            style: TextStyle(color: p.text, fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              hintText: l.feedback_contactHint,
                              hintStyle: TextStyle(
                                  color: p.textMuted, fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          label: _submitting ? l.feedback_submitting : l.feedback_submit,
                          height: 50,
                          onTap: _submitting
                              ? () {}
                              : () {
                                  _submit();
                                },
                        ),
                        const SizedBox(height: 12),
                        Text(l.feedback_tip(kAppVersion),
                            style: TextStyle(
                                color: p.textMuted,
                                fontSize: 11,
                                height: 1.5)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 通用 topbar
Widget _topbar(Pal p, String title) {
  return Builder(
    builder: (context) => Row(
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
    ),
  );
}

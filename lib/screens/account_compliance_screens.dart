import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../ui/daynight.dart';
import '../ui/kit.dart';

/// 账号合规两件套：注销账号（7 天冷静期）+ 数据导出（GDPR/CCPA）。任务 #14。
///
/// 注销账号：Apple 5.1.1(v) 上架硬要求；Google Play 2024 起也要求。
/// 数据导出：GDPR Article 15 + CCPA 数据可移植权。

// =============================================================
// 注销账号
// =============================================================
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  /// 当前 pending 注销申请（如有）。null = 无 pending。
  Map<String, dynamic>? _pending;
  bool _loading = true;
  String? _error;

  final _typeConfirm = TextEditingController();
  String _reason = '';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _typeConfirm.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await Api.deletionStatus();
      if (!mounted) return;
      setState(() {
        _pending = s;
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

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final confirmPhrase = l.deleteAcc_confirmPhrase;
    if (_typeConfirm.text.trim() != confirmPhrase) {
      _toast(l.deleteAcc_typeMismatch(confirmPhrase));
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FF.panel,
        title: Text(l.deleteAcc_finalTitle,
            style: const TextStyle(
                color: FF.text, fontSize: 16, fontWeight: FontWeight.w800)),
        content: Text(l.deleteAcc_finalBody,
            style: const TextStyle(color: FF.dim, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel, style: const TextStyle(color: FF.dim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteAcc_finalSubmit,
                style: const TextStyle(
                    color: FF.hot, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      final result = await Api.requestAccountDeletion(
          reason: _reason.trim().isEmpty ? null : _reason.trim());
      if (!mounted) return;
      setState(() {
        _pending = result;
        _typeConfirm.clear();
      });
      _toast(l.deleteAcc_submitted);
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast(l.common_loadFailed);
    }
  }

  Future<void> _cancelPending() async {
    final l = AppLocalizations.of(context);
    try {
      await Api.cancelAccountDeletion();
      if (!mounted) return;
      setState(() => _pending = null);
      _toast(l.deleteAcc_cancelled);
    } catch (e) {
      _toast('${l.common_loadFailed}: ${e is ApiException ? e.message : e}');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
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
                  child: _topbar(p, AppLocalizations.of(context).deleteAcc_title),
                ),
                Expanded(child: _body(p)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: p.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadStatus,
              style: OutlinedButton.styleFrom(
                  foregroundColor: FF.gold,
                  side: const BorderSide(color: FF.gold)),
              child: Text(AppLocalizations.of(context).common_retry),
            ),
          ],
        ),
      );
    }
    if (_pending != null) return _pendingState(p);
    return _form(p);
  }

  Widget _pendingState(Pal p) {
    final l = AppLocalizations.of(context);
    final scheduled = _pending?['scheduledAt']?.toString() ?? '';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FF.hot.withValues(alpha: 0.16),
                border: Border.all(color: FF.hot, width: 2)),
            child: Icon(Icons.hourglass_top_rounded, color: FF.hot, size: 34),
          ),
        ),
        const SizedBox(height: 18),
        Text(l.deleteAcc_inProgress,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.text, fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(
          '${l.deleteAcc_scheduledAt(scheduled)}\n\n${l.deleteAcc_pendingHint}',
          textAlign: TextAlign.center,
          style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 26),
        GradientButton(
          label: l.deleteAcc_cancelBtn,
          height: 50,
          onTap: _cancelPending,
        ),
      ],
    );
  }

  Widget _form(Pal p) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        const SizedBox(height: 16),
        Icon(Icons.warning_amber_rounded, color: FF.hot, size: 44),
        const SizedBox(height: 16),
        Text(l.deleteAcc_willDelete,
            style: TextStyle(
                color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _bullet(p, l.deleteAcc_bullet1),
        _bullet(p, l.deleteAcc_bullet2),
        _bullet(p, l.deleteAcc_bullet3),
        _bullet(p, l.deleteAcc_bullet4),
        _bullet(p, l.deleteAcc_bullet5),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FF.hot.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FF.hot.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: FF.hot, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.deleteAcc_coolingHint,
                  style: TextStyle(color: p.text, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(l.deleteAcc_reasonLabel,
            style: TextStyle(
                color: p.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FF.line)),
          child: TextField(
            maxLines: 3,
            maxLength: 200,
            onChanged: (v) => _reason = v,
            style: const TextStyle(color: FF.text, fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              hintText: l.deleteAcc_reasonHint,
              hintStyle: const TextStyle(color: FF.dim, fontSize: 13),
              border: InputBorder.none,
              counterStyle: const TextStyle(color: FF.dim, fontSize: 10),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.deleteAcc_typeToConfirm(l.deleteAcc_confirmPhrase),
            style: TextStyle(
                color: p.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FF.line)),
          child: TextField(
            controller: _typeConfirm,
            style: const TextStyle(color: FF.text, fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              hintText: l.deleteAcc_confirmPhrase,
              hintStyle: const TextStyle(color: FF.dim, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: FF.hot,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(l.deleteAcc_submit,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.deleteAcc_thinkAgain,
              style: TextStyle(color: p.textMuted)),
        ),
      ],
    );
  }

  Widget _bullet(Pal p, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fiber_manual_record, color: FF.hot, size: 6),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: p.textMuted, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// 数据导出（GDPR / CCPA）
// =============================================================
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  Map<String, dynamic>? _latest;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

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
      final s = await Api.dataExportStatus();
      if (!mounted) return;
      setState(() {
        _latest = s;
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

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      final result = await Api.requestDataExport();
      if (!mounted) return;
      setState(() {
        _latest = result;
        _submitting = false;
      });
      _toast(l.dataExport_submitted);
    } on ApiException catch (e) {
      setState(() => _submitting = false);
      _toast(e.message);
    } catch (_) {
      setState(() => _submitting = false);
      _toast(l.common_loadFailed);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
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
                  child: _topbar(p, AppLocalizations.of(context).dataExport_title),
                ),
                Expanded(child: _body(p)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: p.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: p.textMuted, fontSize: 12)),
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
    final l = AppLocalizations.of(context);
    final status = _latest?['status'];
    final fileUrl = _latest?['fileUrl']?.toString();
    final expiresAt = _latest?['expiresAt']?.toString();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        const SizedBox(height: 16),
        Icon(Icons.download_for_offline_rounded, color: FF.hot, size: 44),
        const SizedBox(height: 16),
        Text(auth.loggedIn ? l.dataExport_introTitle : l.common_pleaseLogin,
            style: TextStyle(
                color: p.text, fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(
          l.dataExport_introBody,
          style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 22),
        if (status != null) _statusCard(p, status, fileUrl, expiresAt),
        const SizedBox(height: 18),
        if (status == null || status == 2 || status == 3 || status == 4)
          GradientButton(
            label: _submitting ? l.dataExport_submitting : l.dataExport_submitBtn,
            height: 50,
            onTap: _submitting ? () {} : () { _submit(); },
          ),
      ],
    );
  }

  Widget _statusCard(
      Pal p, dynamic status, String? fileUrl, String? expiresAt) {
    final l = AppLocalizations.of(context);
    String label;
    Color color;
    Widget? trailing;
    final s = status is int ? status : int.tryParse('$status') ?? 0;
    switch (s) {
      case 0:
        label = l.dataExport_statusQueued;
        color = const Color(0xFFFFC107);
        break;
      case 1:
        label = l.dataExport_statusProcessing;
        color = const Color(0xFF6F94FF);
        break;
      case 2:
        label = l.dataExport_statusReady;
        color = const Color(0xFF22C55E);
        if (fileUrl != null && fileUrl.isNotEmpty) {
          final copiedMsg = '${l.common_loadFailed} · ${l.dataExport_downloadBtn}';
          trailing = ElevatedButton(
            onPressed: () async {
              final ok = await launchUrl(Uri.parse(fileUrl),
                  mode: LaunchMode.externalApplication);
              if (!ok) {
                await Clipboard.setData(ClipboardData(text: fileUrl));
                _toast(copiedMsg);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FF.hot,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l.dataExport_downloadBtn,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800)),
          );
        }
        break;
      case 3:
        label = l.dataExport_statusExpired;
        color = const Color(0xFFB0B0B0);
        break;
      case 4:
        label = l.dataExport_statusFailed;
        color = FF.hot;
        break;
      default:
        label = l.common_loadFailed;
        color = p.textMuted;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.day ? p.card : FF.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.line),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                if (expiresAt != null && expiresAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(l.dataExport_expiresAt(expiresAt),
                      style: TextStyle(color: p.textMuted, fontSize: 11)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// 通用 topbar（合规页共用）
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../api/api.dart';
import '../auth.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'login_screen.dart';

/// AI Spark 客串三步流程：设置 → 生成中 → 结果。
/// 已接真实后端：相册取图 → OBS 上传 → 扣鹰币建单 → 轮询 → 展示真图。
class SparkFlowScreen extends StatefulWidget {
  final String mode; // 真实玩法 key：poster / makeover / avatar
  final String label; // 玩法中文名（标题用）
  final int coins; // 该玩法收费（鹰币，服务端权威，按钮明码标价）
  final String? contextTitle; // 关联短剧
  const SparkFlowScreen({
    super.key,
    required this.mode,
    required this.label,
    required this.coins,
    this.contextTitle,
  });

  @override
  State<SparkFlowScreen> createState() => _SparkFlowScreenState();
}

enum _Phase { setup, generating, result }

class _SparkFlowScreenState extends State<SparkFlowScreen> {
  // 当前选中玩法（默认进入时传的那个，picker 里可切换）。
  late String _mode = widget.mode;
  late String _label = widget.label;
  late int _coins = widget.coins;

  // 全部真实玩法（用于 picker）；先用进入时已知的占位，拉到后替换。
  List<Map<String, dynamic>> _modes = [];

  File? _photo; // 已选本地照片（缩略图用）
  String? _photoUrl; // 上传后的公网地址（生成用）
  bool _uploading = false;

  _Phase _phase = _Phase.setup;

  // 生成态
  int? _jobId;
  double _progress = 0; // 0..1 仅用于进度观感
  String? _resultUrl;
  bool _failed = false;
  bool _sharing = false;
  bool _avatarSet = false;

  @override
  void initState() {
    super.initState();
    _modes = [
      {'mode': widget.mode, 'label': widget.label, 'coins': widget.coins}
    ];
    _loadModes();
  }

  Future<void> _loadModes() async {
    try {
      final m = await Api.sparkModes();
      if (!mounted || m.isEmpty) return;
      setState(() {
        _modes = m;
        // 同步当前选中玩法的权威价格（服务端为准）。
        final cur = m.firstWhere(
          (e) => e['mode']?.toString() == _mode,
          orElse: () => <String, dynamic>{},
        );
        if (cur.isNotEmpty) {
          _label = cur['label']?.toString() ?? _label;
          _coins = (cur['coins'] as num?)?.toInt() ?? _coins;
        }
      });
    } catch (_) {
      // 拉取失败不影响：用进入时传入的玩法/价格继续。
    }
  }

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

  void _selectMode(Map<String, dynamic> m) {
    setState(() {
      _mode = m['mode']?.toString() ?? _mode;
      _label = m['label']?.toString() ?? _label;
      _coins = (m['coins'] as num?)?.toInt() ?? _coins;
    });
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF15101F),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  // ── 选图 + 上传 ────────────────────────────────
  Future<void> _pickPhoto() async {
    if (_uploading) return;
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 90,
      );
      if (x == null) return;
      final file = File(x.path);
      setState(() {
        _photo = file;
        _photoUrl = null;
        _uploading = true;
      });
      final url = await Api.uploadImage(file);
      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _uploading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _toast('上传失败，请检查网络后重试');
    }
  }

  // ── 生成 + 轮询 ────────────────────────────────
  Future<void> _startGenerate() async {
    if (_photoUrl == null || _uploading) return;
    if (!auth.loggedIn) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (ok == true) await auth.refresh();
      if (!auth.loggedIn) return; // 仍未登录则不继续。
    }

    setState(() {
      _phase = _Phase.generating;
      _progress = 0.04;
      _failed = false;
      _resultUrl = null;
      _jobId = null;
    });

    final requestId =
        'spark_${DateTime.now().millisecondsSinceEpoch}_${_mode}';
    try {
      final res = await Api.sparkGenerate(
        mode: _mode,
        photoUrl: _photoUrl!,
        requestId: requestId,
      );
      // 扣费成功，刷新余额。
      await auth.refresh();
      final id = (res['jobId'] as num?)?.toInt();
      if (id == null) {
        if (!mounted) return;
        setState(() {
          _phase = _Phase.result;
          _failed = true;
        });
        return;
      }
      _jobId = id;
      await _poll(id);
    } on ApiException catch (e) {
      if (!mounted) return;
      // 鹰币不足 → 回到设置页提示去充值，不进结果页。
      setState(() => _phase = _Phase.setup);
      if (e.message.contains('鹰币不足')) {
        _toast('鹰币不足，去充值');
      } else {
        _toast(e.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.setup);
      _toast('生成失败，请稍后重试');
    }
  }

  Future<void> _poll(int id) async {
    // 生成约 30-45s，每 ~4.5s 轮询一次，最多 ~2 分钟。
    const interval = Duration(seconds: 5);
    const maxTries = 28;
    for (var i = 0; i < maxTries; i++) {
      await Future.delayed(interval);
      if (!mounted || _jobId != id) return; // 已离开 / 重新生成
      Map<String, dynamic> job;
      try {
        job = await Api.sparkJob(id);
      } catch (_) {
        continue; // 单次网络抖动，继续轮询。
      }
      if (!mounted || _jobId != id) return;
      final status = job['status']?.toString();
      // 进度观感：随轮询逐步推进，封顶 0.95，done 时拉满。
      setState(() => _progress = (0.1 + i / maxTries).clamp(0.04, 0.95));
      if (status == 'done') {
        final url = job['resultUrl']?.toString() ?? '';
        setState(() {
          _progress = 1;
          _resultUrl = url.isEmpty ? null : url;
          _failed = url.isEmpty;
          _phase = _Phase.result;
        });
        return;
      }
      if (status == 'failed') {
        // 失败已自动退币。
        await auth.refresh();
        if (!mounted) return;
        setState(() {
          _failed = true;
          _phase = _Phase.result;
        });
        return;
      }
    }
    // 超时：当作失败提示（后端若已退则余额已回）。
    if (!mounted) return;
    setState(() {
      _failed = true;
      _phase = _Phase.result;
    });
  }

  void _regenerate() {
    setState(() {
      _jobId = null;
      _phase = _Phase.setup;
      _resultUrl = null;
      _failed = false;
      _progress = 0;
    });
  }

  // ── 保存 / 分享 ────────────────────────────────
  Future<void> _shareResult() async {
    final url = _resultUrl;
    if (url == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw '下载失败';
      final dir = await getTemporaryDirectory();
      final ext = url.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final file = File(
          '${dir.path}/falconflix_spark_${DateTime.now().millisecondsSinceEpoch}.$ext');
      await file.writeAsBytes(res.bodyBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/$ext')],
        subject: 'FalconFlix',
      );
    } catch (_) {
      _toast('分享失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _setAsAvatar() async {
    final url = _resultUrl;
    if (url == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      await Api.updateAvatar(url);
      await auth.refresh();
      if (!mounted) return;
      setState(() => _avatarSet = true);
      _toast('已设为头像');
    } on ApiException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('设置失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FF.bg,
      body: SafeArea(
        bottom: false,
        child: switch (_phase) {
          _Phase.setup => _setup(context),
          _Phase.generating => _generating(context),
          _Phase.result => _result(context),
        },
      ),
    );
  }

  // ── 第 1 步：设置 ──────────────────────────────
  Widget _setup(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canGen = _photoUrl != null && !_uploading;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
      children: [
        _topbar('AI Spark'),
        const SizedBox(height: 14),
        Text(l.spf_settingsTitle,
            style: const TextStyle(
                color: FF.dim, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        gradientText(_label, size: 30),
        if (widget.contextTitle != null && widget.contextTitle!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.link_rounded, color: FF.blue, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l.spf_linkedToFmt(widget.contextTitle!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: FF.muted, fontSize: 12)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _uploadCard(l),
        const SizedBox(height: 18),
        Text(l.spf_chooseTool,
            style: const TextStyle(
                color: FF.text, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemCount: _modes.length,
          itemBuilder: (_, i) {
            final m = _modes[i];
            final mode = m['mode']?.toString() ?? '';
            final label = m['label']?.toString() ?? '';
            final coins = (m['coins'] as num?)?.toInt() ?? 0;
            final sel = mode == _mode;
            return GestureDetector(
              onTap: () => _selectMode(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: sel ? FF.aiRemixGradient : null,
                  color: sel ? null : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? Colors.transparent : FF.line),
                ),
                child: Row(
                  children: [
                    Icon(_iconFor(mode),
                        color: sel ? Colors.white : FF.muted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: sel ? Colors.white : FF.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                          Text('$coins 鹰币',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: sel ? Colors.white70 : FF.dim,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: canGen ? _startGenerate : null,
          child: Opacity(
            opacity: canGen ? 1 : 0.45,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: FF.brandGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                      color: FF.hot.withValues(alpha: 0.3), blurRadius: 22),
                ],
              ),
              child: Text(
                  _uploading
                      ? '照片上传中…'
                      : (_photoUrl == null
                          ? l.spf_noPhotoBtn
                          : l.spf_genBtnFmt('$_coins 鹰币')),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('生成将扣除 $_coins 鹰币；若生成失败将自动退还。',
            textAlign: TextAlign.center,
            style: const TextStyle(color: FF.dim, fontSize: 11)),
      ],
    );
  }

  Widget _uploadCard(AppLocalizations l) {
    final hasPhoto = _photo != null;
    return GestureDetector(
      onTap: _uploading ? null : _pickPhoto,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FF.line),
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasPhoto ? null : FF.brandGradient,
                  color: hasPhoto ? Colors.black26 : null),
              child: hasPhoto
                  ? Image.file(_photo!, width: 88, height: 88, fit: BoxFit.cover)
                  : const Icon(Icons.add_a_photo_outlined,
                      color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
                _uploading
                    ? '正在上传…'
                    : (hasPhoto ? l.spf_photoReady : l.spf_uploadPhoto),
                style: const TextStyle(
                    color: FF.text, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            if (_uploading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: FF.hot),
              )
            else
              Text(hasPhoto ? l.spf_photoTapToReplace : l.spf_photoHint,
                  style: const TextStyle(color: FF.dim, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── 第 2 步：生成中 ────────────────────────────
  Widget _generating(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _topbar('AI Spark', showBack: false),
        const Spacer(),
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, gradient: FF.brandGradient),
          child: const Text('AI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900)),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(end: 1.08, duration: 900.ms, curve: Curves.easeInOut),
        const SizedBox(height: 24),
        gradientText(l.spf_generating, size: 22),
        const SizedBox(height: 8),
        Text(l.spf_generatingSub,
            style: const TextStyle(color: FF.muted, fontSize: 12)),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _progressBar(_progress),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _progressBar(double v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 6, color: Colors.white.withValues(alpha: 0.08)),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                widthFactor: v.clamp(0.02, 1),
                child: Container(
                  height: 6,
                  decoration: const BoxDecoration(gradient: FF.brandGradient),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('${(v * 100).round()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: FF.dim, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── 第 3 步：结果 ──────────────────────────────
  Widget _result(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAvatar = _mode == 'avatar';
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(gradient: FF.splashGradient),
                alignment: Alignment.center,
                child: _failed
                    ? Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Colors.white, size: 56),
                            const SizedBox(height: 14),
                            const Text('生成失败，鹰币已退',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      )
                    : (_resultUrl != null
                        ? Image.network(
                            _resultUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, p) => p == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white)),
                            errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white,
                                size: 56),
                          )
                        : const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 72)),
              ),
            ),
            SizedBox(height: _failed ? 130 : 260),
          ],
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FF.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: FF.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, gradient: FF.brandGradient),
                  child: const Text('AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 12),
                if (_failed) ...[
                  Text('生成失败',
                      style: const TextStyle(color: FF.dim, fontSize: 12)),
                  const SizedBox(height: 4),
                  gradientText('鹰币已退还', size: 22),
                  const SizedBox(height: 6),
                  const Text('请重新生成，或稍后再试。',
                      style: TextStyle(color: FF.muted, fontSize: 12)),
                  const SizedBox(height: 16),
                  _btn('重新生成', FF.brandGradient, _regenerate),
                ] else ...[
                  Text(l.spf_genDoneTag,
                      style: const TextStyle(color: FF.dim, fontSize: 12)),
                  const SizedBox(height: 4),
                  gradientText(l.spf_genDoneTitleFmt(_label), size: 22),
                  const SizedBox(height: 6),
                  Text(l.spf_genDoneBody,
                      style: const TextStyle(color: FF.muted, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: isAvatar
                            ? _btn(
                                _avatarSet ? '已设为头像' : '设为头像',
                                FF.brandGradient,
                                _avatarSet ? () {} : _setAsAvatar,
                                busy: _sharing)
                            : _btn(l.spf_btnSave, FF.brandGradient,
                                _shareResult,
                                busy: _sharing),
                      ),
                      const SizedBox(width: 10),
                      _iconBtn(Icons.refresh_rounded, _regenerate),
                      const SizedBox(width: 10),
                      _iconBtn(Icons.ios_share_rounded,
                          _sharing ? () {} : _shareResult),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: _backBtn(onDark: true),
        ),
      ],
    );
  }

  Widget _btn(String label, Gradient g, VoidCallback onTap,
          {bool busy = false}) =>
      GestureDetector(
        onTap: busy ? () {} : onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: g, borderRadius: BorderRadius.circular(999)),
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: Colors.white))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900)),
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: FF.line)),
          child: Icon(icon, color: FF.text, size: 20),
        ),
      );

  Widget _topbar(String kicker, {bool showBack = true}) {
    return Row(
      children: [
        if (showBack) _backBtn() else const SizedBox(width: 40),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: FF.line)),
          child: Text(kicker,
              style: const TextStyle(
                  color: FF.muted, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _backBtn({bool onDark = false}) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: onDark ? Colors.white24 : FF.line),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      );
}

// 数字人实时通话引擎（原生）。
// 一句话：麦克风 16k PCM16 ──WS二进制──▶ 本机中继(/ws/native) ──▶ OpenAI Realtime(语音对语音)
//        OpenAI 出声 ──中继下采样16k──WS二进制──▶ 这里 ──▶ Simli sendAudioData（脸做口型，声音从脸里出）。
// Dart 端不碰重采样/base64/Realtime 协议——全在 Node 中继里干，这边只搬字节 + 转字幕。
//
// Simli 的 apiKey/faceId 通话时从中继 GET /api/vendor/simli/native 运行时拉，不硬编进 APK。
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:record/record.dart';
import 'package:simli_client/simli_client.dart';
import 'package:simli_client/models/simli_client_config.dart';
import 'package:simli_client/models/simli_error.dart';
import 'package:simli_client/models/simli_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/api.dart';
import '../app_config.dart';

enum DhPhase { connecting, live, ended, error }

/// 一通数字人电话。new → start() → （挂断/离开）stop()。状态用 ValueNotifier 暴露给 UI 响应式刷新。
class DigitalHumanCall {
  DigitalHumanCall(this.characterId);

  final String characterId;

  /// 通话阶段（接通中 / 通话中 / 已挂断 / 出错）。
  final ValueNotifier<DhPhase> phase = ValueNotifier(DhPhase.connecting);

  /// 状态文案（「正在接通…」「已接通」「出错：…」），UI 直接显示。
  final ValueNotifier<String> status = ValueNotifier('正在接通…');

  /// 数字人正在说的实时字幕（累积当前这轮的转写）。
  final ValueNotifier<String> caption = ValueNotifier('');

  /// 数字人画面首帧已渲染（用来淡出「演员在片场」过场）。
  final ValueNotifier<bool> videoReady = ValueNotifier(false);

  SimliClient? _simli;
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micSub;
  bool _disposed = false;

  /// 回声闸（设备外放时根除「数字人听见自己→自言自语」）：数字人脸真正在出声期间不上行麦克风，
  /// 出声停了再多关 _kEchoTailMs 毫秒等扬声器余响/混响散掉。关键是用 Simli 的 isSpeaking
  /// （SPEAK/SILENT，与真实播放对齐）当时钟——中继那条按「发送时刻」的时间闸对不上 Simli 的
  /// 缓冲播放延时，根治不了外放回声，这条才是对的。戴耳机时无回声，本闸只是不让你抢话而已。
  static const int _kEchoTailMs = 800;
  int _micMuteUntilMs = 0;

  /// 给 UI 渲染数字人画面用（RTCVideoView(renderer!)）。
  RTCVideoRenderer? get renderer => _simli?.videoRenderer;

  /// 数字人是否正在出声（驱动「说话中」指示灯）。
  ValueNotifier<bool>? get speaking => _simli?.isSpeakingNotifier;

  Future<void> start() async {
    try {
      // 1) 麦克风权限
      if (!await _recorder.hasPermission()) {
        _fail('需要麦克风权限才能通话');
        return;
      }

      // 1.5) 关键：把 flutter_webrtc 钉成「媒体外放、且不抢音频焦点」。
      // Simli 的连接是纯 RecvOnly（只放数字人的脸+声音，自己不往 WebRTC 送麦克风），
      // 默认配置有两处会打停我们 record 包正在采的麦克风（现象＝画面一渲染麦克风帧立刻断、
      // 用户说话没反应，且流既不 onDone 也不 onError，是被系统饿死）：
      //   ① 默认音频模式是 MODE_IN_COMMUNICATION，切换会重配输入 HAL；
      //   ② manageAudioFocus=true 会在播放起来那刻抢 AUDIOFOCUS_GAIN（独占焦点），
      //      把持有麦克风的 record 采集挤掉（logcat 实测 onAudioFocusChange(-1) 紧跟着帧停）。
      // 解法：MODE_NORMAL + music 流 + media 用途，并 manageAudioFocus=false，
      // 让数字人声音像后台播放器一样静静外放，绝不碰音频焦点，record 全程独占麦克风。
      // 回声仍由上面 isSpeaking 半双工闸根治，不靠通话模式的硬件 AEC。
      try {
        await Helper.setAndroidAudioConfiguration(AndroidAudioConfiguration(
          manageAudioFocus: false,
          androidAudioMode: AndroidAudioMode.normal,
          androidAudioStreamType: AndroidAudioStreamType.music,
          androidAudioAttributesUsageType: AndroidAudioAttributesUsageType.media,
          androidAudioAttributesContentType: AndroidAudioAttributesContentType.unknown,
        ));
      } catch (_) {}

      // 2) 运行时拉 Simli 凭证（不硬编进包）
      final cfg = await _fetchSimliConfig();
      if (cfg == null) return; // _fail 已置态
      if (_disposed) return;

      // 3) 起 Simli 脸（WebRTC 直连 Simli，渲染到 renderer，自带同步语音）
      final simli = SimliClient(
        clientConfig: SimliClientConfig(
          apiKey: cfg.$1,
          faceId: cfg.$2,
          handleSilence: true,
          maxSessionLength: 600,
          maxIdleTime: 180,
          syncAudio: true,
          // 手机网络下 STUN/TURN 候选收集常贴着 10s 边界超时（UDP 被限速时 libwebrtc
          // 要 ~9.5s 才放弃），给足余量，免得卡在 "ICE gathering timeout"。
          iceGatheringTimeout: const Duration(seconds: 30),
        ),
        log: Logger('simli'),
      );
      simli.onFailed = (SimliError e) {
        _fail('数字人连接失败：${e.message}');
      };
      simli.onDisconnected = () {
        if (!_disposed) _end();
      };
      // 首帧渲染 → 淡出「演员在片场」过场
      simli.stateNotifier.addListener(() {
        // ignore: avoid_print
        print('[dh] simli state=${simli.stateNotifier.value}');
        if (!_disposed && simli.stateNotifier.value == SimliState.rendering) {
          _markVideoReady('state');
        }
      });
      // 双保险：直接盯住渲染器本身。srcObject 一绑定 renderVideo 立即为 true、且渲染器尺寸
      // 一出来 value.width>0——这是「帧真的在上屏」最直接的信号，不依赖 Simli 状态机
      // （某些机型状态机没翻到 rendering，但帧已 25fps 在渲，封面就永远不淡出）。
      final vr = simli.videoRenderer;
      vr?.addListener(() {
        if (_disposed || vr.textureId == null) return;
        if (vr.renderVideo || vr.value.width > 0) _markVideoReady('renderer');
      });
      _simli = simli;
      unawaited(simli.start());

      // 4) 连中继 /ws/native
      _ws = WebSocketChannel.connect(
          Uri.parse(digitalHumanWsUrl(characterId, token: Api.token)));
      await _ws!.ready.timeout(const Duration(seconds: 8));
      if (_disposed) return;
      _wsSub = _ws!.stream.listen(_onWsData, onError: (_) => _fail('通话连接出错'), onDone: _end);

      // 5) 麦克风 16k PCM16 单声道流 → 二进制上行。
      // 用原始麦克风（不开 AEC/NS/AGC）：这三个开关在安卓 record 包里会把采集源切到
      // VOICE_COMMUNICATION + 挂 AudioEffect，和 Simli 的 flutter_webrtc 音频模式互抢，
      // 实测会把麦克风采到的样本压成近乎静音 → server_vad 永不触发 → 用户说话没反应。
      // 回声不在这儿治：中继的半双工时间闸（数字人出声时丢麦克风帧）已根除自言自语。
      final micStream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: false,
        noiseSuppress: false,
        autoGain: false,
      ));
      // ignore: avoid_print
      print('[dh] mic stream started');
      var _micN = 0;
      _micSub = micStream.listen((bytes) {
        final ws = _ws;
        final now = DateTime.now().millisecondsSinceEpoch;
        // 数字人正在出声 → 把闸门往后顶；出声停了再续 _kEchoTailMs 余响窗口。
        if (_simli?.isSpeakingNotifier.value ?? false) {
          _micMuteUntilMs = now + _kEchoTailMs;
        }
        final muted = now < _micMuteUntilMs;
        if (!muted && ws != null && !_disposed) ws.sink.add(bytes);
        _micN++;
        if (_micN % 25 == 0) {
          var peak = 0;
          for (var i = 0; i + 1 < bytes.length; i += 2) {
            var s = bytes[i] | (bytes[i + 1] << 8);
            if (s >= 32768) s -= 65536;
            final a = s < 0 ? -s : s;
            if (a > peak) peak = a;
          }
          // ignore: avoid_print
          print('[dh] mic frame=$_micN len=${bytes.length} peak=$peak muted=$muted');
        }
      }, onError: (e) {
        // ignore: avoid_print
        print('[dh] mic stream error: $e');
      }, onDone: () {
        // ignore: avoid_print
        print('[dh] mic stream done (closed)');
      });
    } on TimeoutException {
      _fail('接通超时，检查中继是否在跑（adb reverse tcp:5050）');
    } catch (e) {
      _fail('通话启动失败：$e');
    }
  }

  /// 首帧画面就绪（封面淡出）。两条来源都会调到这里，谁先到算谁，幂等。
  void _markVideoReady(String src) {
    if (_disposed || videoReady.value) return;
    // ignore: avoid_print
    print('[dh] videoReady=true via $src');
    videoReady.value = true;
    // 告诉中继：脸已出画、能收音频了 → 中继现在才发开场白（早发会被 Simli 当「未初始化」丢掉）。
    try { _ws?.sink.add(jsonEncode({'type': 'simli_ready'})); } catch (_) {}
    // 画面真的出来了，这才叫「已接通」。
    if (phase.value == DhPhase.live) status.value = '已接通';
  }

  /// 通话中也可打字插一句。
  void sendText(String text) {
    final t = text.trim();
    final ws = _ws;
    if (t.isEmpty || ws == null) return;
    ws.sink.add(jsonEncode({'type': 'text', 'text': t}));
  }

  Future<void> stop() => _teardown(DhPhase.ended, '已挂断');

  void _onWsData(dynamic event) {
    if (_disposed) return;
    if (event is String) {
      _onJson(event);
    } else {
      // 二进制 = 数字人语音 PCM16@16k → 直接喂 Simli 做口型 + 出声
      final bytes = event is Uint8List
          ? event
          : Uint8List.fromList((event as List).cast<int>());
      _simli?.sendAudioData(bytes);
    }
  }

  void _onJson(String raw) {
    Map<String, dynamic> m;
    try {
      m = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (m['type']) {
      case 'ready':
        // 线路通了，但画面还没出来——先说「接通中」，等首帧渲染(_markVideoReady)才改「已接通」，
        // 免得用户对着「演员正在就位」的封面却看到「已接通」而误会。
        phase.value = DhPhase.live;
        if (!videoReady.value) status.value = '接通中…';
        break;
      case 'speech_started':
        // 你开口了 → 清掉数字人嘴里的余音（打断）
        _simli?.clearBuffer();
        caption.value = '';
        break;
      case 'assistant_delta':
        caption.value = caption.value + (m['text'] as String? ?? '');
        break;
      case 'response_done':
        final t = (m['text'] as String? ?? '').trim();
        if (t.isNotEmpty) caption.value = t;
        break;
      case 'error':
        _fail('${m['error'] ?? '通话出错'}');
        break;
      case 'closed':
        _end();
        break;
    }
  }

  /// 返回 (apiKey, faceId)；失败置错并返回 null。
  Future<(String, String)?> _fetchSimliConfig() async {
    try {
      final r = await http
          .get(
            Uri.parse('$kDigitalHumanRelayBase/api/vendor/simli/native?characterId=${Uri.encodeComponent(characterId)}'),
            headers: {
              if (Api.token != null) 'Authorization': 'Bearer ${Api.token}',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) {
        _fail('拉数字人配置失败(${r.statusCode})，检查中继');
        return null;
      }
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final apiKey = j['apiKey'] as String?;
      final faceId = j['faceId'] as String?;
      if (apiKey == null || apiKey.isEmpty || faceId == null || faceId.isEmpty) {
        _fail('中继没返回 Simli 配置');
        return null;
      }
      return (apiKey, faceId);
    } on TimeoutException {
      _fail('连不上中继，确认 adb reverse tcp:5050 已开');
      return null;
    } catch (e) {
      _fail('拉数字人配置出错：$e');
      return null;
    }
  }

  void _fail(String msg) {
    if (_disposed) return;
    status.value = msg;
    phase.value = DhPhase.error;
    unawaited(_teardown(DhPhase.error, msg));
  }

  void _end() {
    if (_disposed || phase.value == DhPhase.ended) return;
    unawaited(_teardown(DhPhase.ended, '通话已结束'));
  }

  Future<void> _teardown(DhPhase end, String msg) async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    if (phase.value != DhPhase.error) phase.value = end;
    status.value = msg;
    try { await _micSub?.cancel(); } catch (_) {}
    try { await _recorder.stop(); } catch (_) {}
    try { await _recorder.dispose(); } catch (_) {}
    try { await _wsSub?.cancel(); } catch (_) {}
    try { await _ws?.sink.close(); } catch (_) {}
    try { await _simli?.close(); } catch (_) {}
  }

  void dispose() {
    unawaited(_teardown(phase.value, status.value));
    phase.dispose();
    status.dispose();
    caption.dispose();
    videoReady.dispose();
  }
}

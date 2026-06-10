import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:logging/logging.dart';
import 'package:simli_client/extension/websocket_extension.dart';
import 'package:simli_client/models/simli_client_config.dart';
import 'package:simli_client/models/simli_error.dart';
import 'package:simli_client/models/simli_exception.dart';
import 'package:simli_client/models/simli_state.dart';
import 'package:web_socket_client/web_socket_client.dart';

/// Represents a client for interacting with the Simli API and managing WebRTC
/// connections, including video rendering, peer connections, and data channels.
class SimliClient {
  /// Creates a new [SimliClient] instance.

  SimliClient({
    required this.clientConfig,
    required this.log,
  }) {
    videoRenderer = RTCVideoRenderer();
    videoRenderer!.initialize();
  }

  /// Logger for the login of the data
  Logger log;

  /// client config for the session
  SimliClientConfig clientConfig;

  /// The WebRTC peer connection.
  RTCPeerConnection? peerConnection;

  /// The video renderer used for displaying video streams.
  RTCVideoRenderer? videoRenderer;

  /// Timer for monitoring audio levels.
  Timer? audioLEvelTimer;

  /// Timer for monitoring audio levels.
  Timer? connectionTimeOutTimer;

  /// The number of ICE candidates found.
  int candidateCount = 0;

  /// Tracks the previous ICE candidate count.
  int prevCandidateCount = -1;

  /// FalconFlix 补丁：视频流是否已绑定到 renderer。onAddStream 与 onTrack 会就同一路视频
  /// 各回调一次、且两个回调给的 MediaStream.id 不同，若各 set 一次 srcObject 会让原生
  /// EglRenderer 经历 track→null→track 的释放/重建抖动，在部分安卓机上把 Flutter Texture
  /// 与渲染面解绑 → 帧在 25fps 渲染但画面全黑。用此标志确保 srcObject 只绑定一次。
  bool _videoAttached = false;

  /// Notifies listeners of changes to the client's state.
  ValueNotifier<SimliState> stateNotifier = ValueNotifier(SimliState.ideal);

  /// Notifies listeners of changes in whether the user is speaking.
  ValueNotifier<bool> isSpeakingNotifier = ValueNotifier(false);

  /// A callback for handling connection events.
  VoidCallback? onConnection;

  /// A callback for handling connection failed events.
  void Function(SimliError error)? onFailed;

  /// A callback for handling disconnection events.
  VoidCallback? onDisconnected;

  /// Gets whether the user is currently speaking.
  bool get isSpeaking => isSpeakingNotifier.value;

  /// Sets whether the user is currently speaking.
  set isSpeaking(bool value) {
    isSpeakingNotifier.value = value;
  }

  /// Gets current state of the client.
  SimliState get state => stateNotifier.value;

  /// Gets current state of the client.
  set state(SimliState state) {
    // ignore: avoid_print
    print('[simli] state -> $state');
    stateNotifier.value = state;
  }

  /// Utility method to check connection status
  bool get isConnected {
    return sessionInitialized &&
        webSocket != null &&
        webSocket!.isConnected &&
        peerConnection != null &&
        state == SimliState.connected;
  }

  /// Notifies listeners with audio level of the avatar.
  ValueNotifier<double> audioLevelNotifier = ValueNotifier(0);

  ///websocket connection for communication
  WebSocket? webSocket;

  ///it will be true if session is initialized
  bool sessionInitialized = false;

  // Map<String, int> pingSendTimes = {};
  ///store the time of last send time of data
  int lastSendTime = 0;

  ///it will hold the reason for the error
  String? errorReason;

  /// Gets the client configuration
  SimliClientConfig get config => clientConfig;

  MediaStreamTrack? _audioStreamTack;

  /// Returns a list of ICE servers.
  ///
  /// The function retrieves ICE servers using an API key with the
  ///  specified retry and timeout configurations.
  /// If fetching fails, a default STUN server is provided.
  Future<dynamic> getIceServers({
    required int maxRetry,
    required Duration retryDelay,
    required String apiKey,
    required Duration requestTimeout,
  }) async {
    final client = RetryClient(
      http.Client(),
      retries: maxRetry,
      delay: (retryCount) => retryDelay,
      onRetry: (p0, p1, retryCount) {
        logException('ICE servers fetch attempt $retryCount failed: $p1');
      },
    );
    try {
      final response = await client
          .post(
            Uri.parse('https://api.simli.ai/getIceServers'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'apiKey': apiKey}),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw SimliException(
          'http-status-code',
          'HTTP error! status: ${response.statusCode}',
        );
      }
      final iceServers = jsonDecode(response.body) as List<dynamic>;
      if (iceServers.isEmpty) {
        throw SimliException(
          SimliExceptionCode.noIceServes,
          'No ICE servers returned',
        );
      }
      return List<Map<String, dynamic>>.from(iceServers);
    } catch (error) {
      logInfo('Using fallback STUN server: $error');
      return [
        {'urls': 'stun:stun.l.google.com:19302'},
      ];
    } finally {
      client.close();
    }
  }

  /// Creates a WebRTC peer connection and sets up listeners.
  Future<void> createRTCPeerConnection() async {
    final configuration = <String, dynamic>{
      'sdpSemantics': 'unified-plan',
      'iceServers': await getIceServers(
        maxRetry: clientConfig.maxRetryAttempts,
        apiKey: clientConfig.apiKey,
        requestTimeout: clientConfig.requestTimeout,
        retryDelay: clientConfig.retryDelay,
      ),
      'iceTransportPolicy': 'all',
    };

    logInfo(configuration);
    try {
      peerConnection = await createPeerConnection(configuration);
      logSuccess('Peer connection created');
    } catch (e) {
      handleConnectionFailure('Failed to create peer connection: $e');
      return;
    }

    setupPeerConnectionListener();
  }

  /// Sets up listeners for WebRTC peer connection events.
  void setupPeerConnectionListener() {
    if (peerConnection == null) return;
    peerConnection?.onIceGatheringState = (RTCIceGatheringState value) {
      logInfo('ICE gathering state changed: $value');
    };
    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      logInfo('ICE connection state changed: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        logSuccess(
          'WebRTC connection established and ready for communication.',
        );
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        handleConnectionFailure('ICE connection failed');
      }
    };
    peerConnection?.onSignalingState = (RTCSignalingState value) {
      logInfo('Signal state changed: $value');
    };
    peerConnection?.onAddStream = _addVideoStream;
    peerConnection?.onTrack = (RTCTrackEvent value) {
      logInfo('Track Kind: ${value.track.kind}');
      if (value.track.kind == 'video') {
        if (value.streams.isNotEmpty) {
          _addVideoStream(value.streams.first);
        } else {
          logException('Track added, but no associated stream found');
          handleConnectionFailure(
            'Track added, but no associated stream found',
          );
        }
      } else {
        _audioStreamTack = value.track;
      }
    };
    peerConnection?.onIceCandidate = (RTCIceCandidate value) async {
      if (value.candidate == null) {
        // logInfo(await peerConnection?.getLocalDescription());
      } else {
        // logInfo(value.candidate);
        candidateCount += 1;
      }
    };
    logInfo('Registered all listener for the connection ');
  }

  void _setupConnectionStateHandler() {
    if (peerConnection == null) return;

    peerConnection!.onConnectionState = (connectionState) {
      switch (connectionState) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          clearTimeouts();
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          handleConnectionFailure('Connection failed or closed');
          cleanup();
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          handleDisconnection();

        case RTCPeerConnectionState.RTCPeerConnectionStateNew:
          logInfo('Connection state is New');
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          logInfo('Connection is in progress');
      }
    };
  }

  /// Starts the WebRTC session by creating the peer connection, adding data
  /// channels, and negotiating.

  Future<void> start({int retryAttempt = 1}) async {
    try {
      clearTimeouts();
      state = SimliState.connecting;
      connectionTimeOutTimer = Timer(
        clientConfig.connectionTimeoutTime,
        handleConnectionTimeout,
      );
      await createRTCPeerConnection();
      _setupConnectionStateHandler();
      unawaited(
        peerConnection?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
        ),
      );
      unawaited(
        peerConnection?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
        ),
      );
      await negotiate();
      clearTimeouts();
    } on Exception catch (e) {
      logException('Connection attempt $retryAttempt failed: $e');
      clearTimeouts();

      if (retryAttempt < clientConfig.maxRetryAttempts) {
        logInfo('Retrying connection... Attempt ${retryAttempt + 1}');
        await Future<void>.delayed(clientConfig.retryDelay);
        await cleanup();
        return start(retryAttempt: retryAttempt + 1);
      }
      handleConnectionFailure(
        'Failed to connect after ${clientConfig.maxRetryAttempts} attempts',
      );
    }
  }

  /// Initializes a session by sending metadata to a remote API.
  ///
  /// This method sends a POST request to the Simli API to start an
  /// audio-to-video session. Upon success, it sends the session token over
  /// the data channel.
  Future<void> initializeSession() async {
    const apiUrl = 'https://api.simli.ai/startAudioToVideoSession';

    // Combine metadata with client configuration.
    final metadata = <String, dynamic>{
      'video_reference_url': clientConfig.videoReferenceUrl,
      'isJPG': clientConfig.isJPG,
      ...clientConfig.toJson(),
    };

    try {
      // Make API request.
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metadata),
      );

      if (response.statusCode != 200) {
        _handleApiFailure(response);
        return;
      }

      // Extract and send the session token.
      final sessionToken =
          (jsonDecode(response.body) as Map)['session_token'].toString();

      if (webSocket?.isConnected ?? false) {
        webSocket?.send(sessionToken);
        logSuccess('Session token sent successfully.');
        logInfo('Session initialized successfully.');
      } else {
        handleConnectionFailure('Data channel not open to send session token.');
      }
    } catch (error) {
      handleConnectionFailure('Failed to initialize session: $error');
    }
  }

  /// Handles API request failures.
  void _handleApiFailure(http.Response response) {
    logException('Failed to start session: ${response.statusCode}');
    logException('Response body: ${response.body}');
    handleConnectionFailure('Failed to start session: ${response.statusCode}');
  }

  /// FalconFlix vendored 补丁：POST startAudioToVideoSession 换取 session_token，
  /// 供新版 /compose/webrtc/p2p WS 端点鉴权。失败返回 null。
  Future<String?> _createSimliSession() async {
    const apiUrl = 'https://api.simli.ai/startAudioToVideoSession';
    final metadata = <String, dynamic>{
      'video_reference_url': clientConfig.videoReferenceUrl,
      'isJPG': clientConfig.isJPG,
      ...clientConfig.toJson(),
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metadata),
      );
      if (response.statusCode != 200) {
        _handleApiFailure(response);
        return null;
      }
      final token = (jsonDecode(response.body) as Map)['session_token'];
      if (token == null) {
        handleConnectionFailure('No session_token in Simli response');
        return null;
      }
      logSuccess('Simli session token acquired');
      return token.toString();
    } catch (error) {
      handleConnectionFailure('Failed to create session: $error');
      return null;
    }
  }

  /// Negotiates a WebRTC connection by creating an offer, setting the local
  /// description, gathering ICE candidates, and exchanging session details
  /// with the server.
  ///
  /// Throws a [PlatformException] if the [peerConnection] is not initialized.
  Future<void> negotiate() async {
    logInfo('Negotiation started');
    if (peerConnection == null) {
      throw PlatformException(code: 'peer-connection-not-initialized');
    }

    try {
      // Create an offer for the peer connection.
      final description = await peerConnection?.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await peerConnection?.setLocalDescription(description!);

      // Wait for ICE gathering to complete before proceeding.
      await waitForIceGathering();

      // Retrieve the local description after ICE gathering.
      final localDescription = await peerConnection?.getLocalDescription();
      if (localDescription == null) {
        return;
      }

      // FalconFlix vendored 补丁：Simli 协议已升级。旧版裸连 wss://api.simli.ai/StartWebRTCSession
      // 现被服务端 403 拒（web_socket_client 会静默重连 → firstWhere 永不 Connected → 最后报
      // 假「Connection timed out / ICE gathering timeout」）。新流程：先 POST
      // startAudioToVideoSession 拿 session_token，再连 /compose/webrtc/p2p（token 走 query 鉴权）。
      // enableSFU=true：媒体走 Simli SFU（公网可达），手机无 TURN（getIceServers 已 404）也能建连。
      final sessionToken = await _createSimliSession();
      if (sessionToken == null) {
        handleConnectionFailure('Failed to create Simli session');
        return;
      }
      webSocket = WebSocket(
        Uri.parse(
          'wss://api.simli.ai/compose/webrtc/p2p'
          '?session_token=$sessionToken&enableSFU=true',
        ),
        timeout: clientConfig.webSocketTimeout,
      );
      RTCSessionDescription? answer;
      // Listen to messages
      webSocket?.messages.listen(
        (data) async {
          logInfo('Received message: $data');

          if (data == 'START') {
            // 新协议下 session 在 WS 连接时即就绪，这里软忽略即可。
            logInfo('Session START received');
          } else if (data == 'STOP') {
            await close();
          } else if (data.toString().startsWith('pong')) {
            // final pingKey = (data as String).replaceFirst('pong', 'ping');
            // final pT = pingSendTimes[pingKey];
            // final difference = DateTime.now().millisecondsSinceEpoch - pT;
            // if (pingTime != null) {
            //   logInfo(
            //'Simli Latency: $difference',
            //   );
            // }
          } else if (data == 'ACK') {
            logInfo('Received ACK');
          } else {
            try {
              logInfo('Received  answer');
              final message =
                  jsonDecode(data as String) as Map<String, dynamic>;
              if (message['type'] == 'answer') {
                answer = RTCSessionDescription(
                  message['sdp'].toString(),
                  message['type'].toString(),
                );
              } else if (message.containsKey('video_metadata')) {
                // FalconFlix 补丁（仅兜底，必须在绑定之后）：video_metadata 往往早于
                // onAddStream/onTrack 的 srcObject 绑定到达。绝不能在 _videoAttached 之前
                // 就 set rendering —— 那会让上层在 renderVideo(textureId&&srcObject) 还是
                // false 时就 build 出 RTCVideoView，而 flutter_webrtc 把 Texture/占位 的
                // 选择烤死在 build 那一刻的 child 里（value 变化不重建它），导致永久纯黑。
                // 真正推 rendering 的地方在 _addVideoStream 绑定 srcObject 之后。
                if (_videoAttached && state != SimliState.rendering) {
                  logSuccess('video_metadata (post-attach) — marking rendering');
                  state = SimliState.rendering;
                }
              }
            } catch (e) {
              logException('Error parsing message: $e');
            }
          }
        },
        onError: (dynamic error) {
          logException('Error: $error');

          handleConnectionFailure('WebSocket has error $error');
        },
        onDone: () {
          logInfo('WebSocket closed');

          handleConnectionFailure('WebSocket closed unexpectedly');
        },
      );
      // Wait until a connection has been established.
      await webSocket?.connection.firstWhere((state) => state is Connected);
      logSuccess('Websocket is connected');
      // WS 一连上即视为会话就绪（token 已在 URL 鉴权），放开音频上行，
      // 否则中继喂来的语音会被 sendAudioData 的 sessionInitialized 守卫丢掉。
      sessionInitialized = true;
      state = SimliState.connected;
      onConnection?.call();
      logInfo('Sending SDP Data');
      webSocket?.send(jsonEncode(localDescription.toMap()));
      logSuccess('local description send');

      // wsConnectCompleter.complete();

      // Wait for answer with timeout
      final answerCompleter = Completer<void>();
      Timer? timeoutTimer;

      void checkAnswer() {
        if (answer != null) {
          timeoutTimer?.cancel();
          peerConnection!.setRemoteDescription(
            RTCSessionDescription(answer!.sdp, answer!.type),
          );
          logSuccess('Setting remote description: ');
          _startAudioLevelChecking();
          answerCompleter.complete();
        } else {
          Future.delayed(const Duration(milliseconds: 100), checkAnswer);
        }
      }

      timeoutTimer = Timer(clientConfig.answerTimeoutTime, () {
        if (!answerCompleter.isCompleted) {
          answerCompleter
              .completeError(TimeoutException('SIMLI: Answer timeout'));
        }
      });

      checkAnswer();
      logInfo('Negotiation finished');
      await answerCompleter.future;
    } catch (e) {
      // Handle any additional errors in offer creation or session negotiation.
      logException('Error during negotiation: $e');

      handleConnectionFailure('Error during negotiation: $e');
    }
  }

  /// Waits for the ICE gathering process to complete.
  ///
  /// This method completes once the ICE candidates have been gathered.

  Future<void> waitForIceGathering() async {
    if (peerConnection?.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }
    final completer = Completer<void>();
    Timer? settleTimer;
    void finish() {
      if (!completer.isCompleted) completer.complete();
    }

    // 正常路径：收到收集完成事件就走。
    peerConnection?.onIceGatheringState = (state) {
      logInfo('ICE gathering state changed: $state');
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        finish();
      }
    };

    // 兜底（FalconFlix vendored 补丁）：部分安卓机永不触发 Complete，但会持续吐候选；
    // 收到候选后若 1.5s 内无新候选，就当收集完毕（host/srflx 已够建连），
    // 避免原版死等 Complete 卡满超时报「ICE gathering timeout」。
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) candidateCount += 1;
      if (completer.isCompleted) return;
      if (candidate.candidate == null) {
        finish(); // end-of-candidates 信号
        return;
      }
      settleTimer?.cancel();
      settleTimer = Timer(const Duration(milliseconds: 1500), finish);
    };

    try {
      await completer.future.timeout(
        clientConfig.iceGatheringTimeout,
        onTimeout: () {
          throw Exception('ICE gathering timeout');
        },
      );
    } finally {
      settleTimer?.cancel();
    }
  }

  /// it will handle connection failure
  void handleConnectionFailure(String reason) {
    errorReason = reason;
    logException('Connection failure: $reason');

    onFailed?.call(
      SimliError(
        message: reason,
      ),
    );
    cleanup();
  }

  ///it will handle connection timeout
  void handleConnectionTimeout() {
    handleConnectionFailure('Connection timed out');
  }

  ///handle disconnection of the webrtc connection
  void handleDisconnection() {
    if (sessionInitialized) {
      logException('Connection lost, attempting to reconnect...');
      cleanup().then((value) {
        start();
      }).onError(
        (error, stackTrace) {
          logException('Reconnection failed:  $error');
          handleConnectionFailure('Reconnection failed');
        },
      );
    }
  }

  ///it will cleanup the current resource
  Future<void> cleanup() async {
    await peerConnection?.close();
    peerConnection = null;
    webSocket?.close();
    webSocket = null;
    clearTimeouts();
    sessionInitialized = false;
    candidateCount = 0;
    prevCandidateCount = -1;
    _videoAttached = false;
    errorReason = null;
    logInfo('Resources cleaned up');
  }

  ///it will clear connection timeout
  void clearTimeouts() {
    connectionTimeOutTimer?.cancel();
    connectionTimeOutTimer = null;
  }

  /// Sends audio data over the data channel.
  ///
  /// This method ensures that the data channel is open before sending
  /// audio data. If the channel is not open, it logs an exception.
  ///
  /// [audioData] is the binary audio data to be sent.

  void sendAudioData(Uint8List audioData) {
    if (!sessionInitialized) {
      logException('Session not initialized. Ignoring audio data.');
      return;
    }

    if (webSocket != null) {
      try {
        if (sessionInitialized) {
          webSocket!.send(audioData);
          logSuccess('Data Sent: ${audioData.length}');
          if (lastSendTime != 0) {
            final diff = DateTime.now().millisecondsSinceEpoch - lastSendTime;
            logInfo(
              'Time between sends: $diff',
            );
          }
          lastSendTime = DateTime.now().millisecondsSinceEpoch;
        } else {
          logInfo(
            '''WebSocket open but session is being initialized.Ignoring audio data. ''',
          );
        }
      } catch (error) {
        logException('Failed to send audio data: $error');
      }
    } else {
      logException('WebSocket is not open. Error Reason: $errorReason');
    }
  }

  /// Adds a video stream to the video renderer and sets up audio settings.
  ///
  /// This method configures the [videoRenderer] to display the incoming video
  /// stream. It also manages audio settings, such as enabling the speakerphone
  ///  on mobile devices. [stream] is the incoming media stream containing video and/or audio tracks.
  Future<void> _addVideoStream(MediaStream stream) async {
    // ignore: avoid_print
    print('[simli] _addVideoStream ${stream.id} videoTracks=${stream.getVideoTracks().length} attached=$_videoAttached');
    // 只绑定一次，且只绑定真正带视频轨的那一路（onAddStream 早到时往往还没有视频轨）。
    // 这样 srcObject 只 set 一次，原生 EglRenderer 不再 track→null→track 抖动，Texture 不黑屏。
    if (_videoAttached) {
      logInfo('Video already attached — skip ${stream.id}');
      return;
    }
    if (stream.getVideoTracks().isEmpty) {
      logInfo('Stream ${stream.id} has no video track yet — wait for onTrack');
      return;
    }
    // 先 await initialize()（幂等）确保 textureId 已就绪，否则 srcObject setter 会因
    // textureId==null 抛 'Call initialize before setting the stream'（热启动第二通的竞态）。
    await videoRenderer?.initialize();
    if (_videoAttached) return; // await 期间另一回调可能已绑定，二次确认
    _videoAttached = true;
    // ignore: avoid_print
    print('[simli] _addVideoStream initialized, renderer=${videoRenderer != null} textureId=${videoRenderer?.textureId}');
    logSuccess(stream.getVideoTracks());
    // Set the source of the video renderer to the incoming media stream.
    videoRenderer?.srcObject = stream;
    // ignore: avoid_print
    print('[simli] _addVideoStream srcObject set, renderVideo=${videoRenderer?.renderVideo}');
    // 注意：绝不要在这里读 stream.active —— 该 getter 在原生端会抛异常，会让本 async
    // 方法在下一行 state=rendering 之前中断，导致状态机永远进不了 rendering（黑屏根因）。
    logSuccess('Video stream added');
    // FalconFlix 关键修复（黑屏根因）：srcObject 的 setter 同步把 _srcObject=stream，
    // 此刻 renderVideo(textureId!=null && srcObject!=null) 立即为 true。必须在「绑定之后」
    // 才把 state 推到 rendering，让上层 videoReady 翻转、RTCVideoView 在 renderVideo==true
    // 时才重建——否则它会把占位 Container（纯黑）烤死，帧虽 25fps 渲染却永不上屏。
    state = SimliState.rendering;
    // Log when the first video frame is rendered.
    videoRenderer?.onFirstFrameRendered = () {
      logSuccess('First video frame rendered');
      state = SimliState.rendering;
    };
    // FalconFlix 补丁：部分安卓机型 onFirstFrameRendered 不触发（帧已 25fps 解码渲染，
    // 但回调静默），导致 state 永不进入 rendering、上层「演员正在就位」封面永不淡出。
    // onResize 在渲染器拿到首帧尺寸时触发，是更可靠的「画面已出」信号，双保险。
    videoRenderer?.onResize = () {
      if (state != SimliState.rendering) {
        logSuccess('Video renderer resized — first frame is flowing');
        state = SimliState.rendering;
      }
    };

    // Handle audio track settings based on the platform.
    if (kIsWeb) {
      stream.getAudioTracks().first.enabled = true;
    } else {
      stream.getAudioTracks().first.enabled = true;
      if (!Platform.isMacOS) {
        stream.getAudioTracks().first.enableSpeakerphone(true);
      }
    }
  }

  void _startAudioLevelChecking() {
    if (_audioStreamTack == null) return;
    monitorAudioPlaying(peerConnection!, _audioStreamTack!);
    return;
  }

  void _stopAudioLevelChecking() {
    audioLEvelTimer?.cancel();
    audioLEvelTimer = null;
  }

  ///it will monitor audio playing on audio track
  Future<void> monitorAudioPlaying(
    RTCPeerConnection connection,
    MediaStreamTrack audioTrack,
  ) async {
    var silenceCounter = 0;
    audioLEvelTimer =
        Timer.periodic(clientConfig.audioCheckInterval, (timer) async {
      if (!audioTrack.enabled) {
        logException('The audio track is not playing (ended or disabled).');
        timer.cancel();
        return;
      }

      final stats = await connection.getStats(audioTrack);
      for (final report in stats) {
        if (report.type == 'inbound-rtp' &&
            report.values['mediaType'].toString() == 'audio') {
          final audioLevel = report.values['audioLevel'] as double? ?? 0.0;

          if (audioLevel > 0) {
            isSpeaking = true;
            silenceCounter = 0; // Reset silence counter
            // logInfo('SIMLI: Audio is playing.');
          } else {
            silenceCounter++;
            if (silenceCounter *
                    clientConfig.audioCheckInterval.inMilliseconds >=
                clientConfig.silenceThreshold.inMilliseconds) {
              isSpeaking = false;
              // logInfo('SIMLI: Audio is silent for a prolonged period.');
            }
          }
        }
      }
    });
  }

  ///it will clear the current audio buffer on server
  void clearBuffer() => webSocket?.send('SKIP');

  /// Closes the peer connection, data channels, video renderer, and timers.
  /// Ensures all resources are properly released.
  Future<void> close() async {
    if (state == SimliState.ideal) {
      logInfo('Client already closed.');
      return;
    }

    try {
      logInfo('Closing client resources...');
      _stopAudioLevelChecking();
      // Notify disconnection
      onDisconnected?.call();

      // Close WebSocket connection
      webSocket?.close();
      webSocket = null;

      // Close PeerConnection and its transceivers/senders
      if (peerConnection != null) {
        // Stop transceivers and senders
        (await peerConnection?.getTransceivers())?.forEach((transceiver) {
          transceiver.stop();
        });
        (await peerConnection?.senders)?.forEach((sender) {
          sender.track?.stop();
        });

        await peerConnection?.close();
        peerConnection = null;
      }

      // Stop audio monitoring and cleanup timers
      _stopAudioLevelChecking();
      clearTimeouts();

      // Dispose video renderer
      await videoRenderer?.dispose();
      videoRenderer = null;

      // Reset internal state
      sessionInitialized = false;
      isSpeaking = false;
      candidateCount = 0;
      prevCandidateCount = -1;
      errorReason = null;

      logInfo('Client closed successfully.');
      state = SimliState.ideal;
    } catch (e) {
      logException('Error while closing resources: $e');
    }
  }

  ///it will log using info method
  void logSuccess(dynamic data) {
    log.fine(data.toString());
  }

  ///it will log using info method
  void logInfo(dynamic data) {
    log.info(data.toString());
  }

  ///it will log using serve method
  void logException(dynamic data) {
    log.shout(data.toString());
  }
}

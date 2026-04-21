import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_client.dart';

/// Wraps the Agora RTC engine lifecycle for 1-to-1 / group voice & video
/// calls. Uses tokens minted by /api/calls/start.
class CallService extends ChangeNotifier {
  RtcEngine? _engine;
  String? _callId;
  String? _channel;
  String? _token;
  String _type = 'voice'; // voice | video
  String _state = 'idle'; // idle | ringing | ongoing | ended
  int _duration = 0;
  final Set<int> _remoteUids = {};

  String get state => _state;
  String get type => _type;
  Set<int> get remoteUids => _remoteUids;
  int get duration => _duration;

  Future<void> _ensurePermissions(bool video) async {
    await [Permission.microphone, if (video) Permission.camera].request();
  }

  Future<bool> _ensureEngine(String appId) async {
    if (_engine != null) return true;
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (_, __) { _state = 'ongoing'; notifyListeners(); },
      onUserJoined: (_, remoteUid, __) { _remoteUids.add(remoteUid); notifyListeners(); },
      onUserOffline: (_, remoteUid, __) { _remoteUids.remove(remoteUid); notifyListeners(); },
      onLeaveChannel: (_, __) { _state = 'ended'; notifyListeners(); },
    ));
    return true;
  }

  /// Place a new outgoing call.
  Future<bool> startCall({required String chatId, required String type}) async {
    _type = type;
    await _ensurePermissions(type == 'video');
    final r = await ApiClient.instance.callStart(chatId, type);
    if (r['success'] != true) return false;
    final d = r['data'] as Map<String, dynamic>;
    _callId = d['call_id']?.toString();
    _channel = d['channel']?.toString();
    _token = d['agora_token']?.toString() ?? d['token']?.toString();
    final appId = d['agora_app_id']?.toString() ?? d['app_id']?.toString() ?? '';
    final uid = int.tryParse('${d['uid'] ?? 0}') ?? 0;
    if (_channel == null || _token == null || appId.isEmpty) return false;
    await _ensureEngine(appId);
    if (type == 'video') await _engine!.enableVideo();
    _state = 'ringing';
    notifyListeners();
    await _engine!.joinChannel(
      token: _token!, channelId: _channel!, uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    return true;
  }

  /// Answer an incoming call with the given call_id.
  Future<bool> answer(String callId) async {
    _callId = callId;
    final r = await ApiClient.instance.callAnswer(callId, true);
    if (r['success'] != true) return false;
    final d = r['data'] as Map<String, dynamic>;
    _channel = d['channel']?.toString();
    _token = d['agora_token']?.toString() ?? d['token']?.toString();
    _type = d['type']?.toString() ?? 'voice';
    final appId = d['agora_app_id']?.toString() ?? d['app_id']?.toString() ?? '';
    final uid = int.tryParse('${d['uid'] ?? 0}') ?? 0;
    if (_channel == null || _token == null) return false;
    await _ensurePermissions(_type == 'video');
    await _ensureEngine(appId);
    if (_type == 'video') await _engine!.enableVideo();
    await _engine!.joinChannel(
      token: _token!, channelId: _channel!, uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    return true;
  }

  Future<void> decline(String callId) async {
    await ApiClient.instance.callAnswer(callId, false);
    _state = 'ended'; notifyListeners();
  }

  Future<void> end() async {
    try { await _engine?.leaveChannel(); } catch (_) {}
    if (_callId != null) {
      try { await ApiClient.instance.callEnd(_callId!, duration: _duration); } catch (_) {}
    }
    _state = 'ended';
    notifyListeners();
  }

  Future<void> toggleMute(bool mute) async {
    await _engine?.muteLocalAudioStream(mute);
  }

  Future<void> toggleCamera(bool on) async {
    if (on) { await _engine?.enableVideo(); } else { await _engine?.disableVideo(); }
  }

  Future<void> switchCamera() async { await _engine?.switchCamera(); }

  Future<void> dispose_() async {
    try { await _engine?.leaveChannel(); await _engine?.release(); } catch (_) {}
    _engine = null;
  }

  RtcEngine? get engine => _engine;
  String? get channel => _channel;
  String? get callId => _callId;
}

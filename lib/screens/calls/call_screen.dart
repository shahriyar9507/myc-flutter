import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String peerName;
  final String type; // voice | video
  final bool incoming;
  final String? callId;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.peerName,
    required this.type,
    this.incoming = false,
    this.callId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _muted = false;
  bool _camOn = true;
  bool _frontCam = true;

  CallService get _svc => context.read<CallService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _place());
  }

  Future<void> _place() async {
    if (widget.incoming && widget.callId != null) {
      await _svc.answer(widget.callId!);
    } else {
      await _svc.startCall(chatId: widget.chatId, type: widget.type);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _svc.end();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<CallService>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (widget.type == 'video' && s.engine != null && s.channel != null)
            s.remoteUids.isEmpty
                ? _localPreview(s.engine!)
                : AgoraVideoView(controller: VideoViewController.remote(
                    rtcEngine: s.engine!,
                    canvas: VideoCanvas(uid: s.remoteUids.first),
                    connection: RtcConnection(channelId: s.channel!),
                  )),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0, right: 0,
            child: Column(
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: MyCColors.accentGradient,
                  ),
                  child: Center(child: Text(
                    widget.peerName.isNotEmpty ? widget.peerName[0] : '?',
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
                const SizedBox(height: 12),
                Text(widget.peerName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  s.state == 'ringing' ? 'Ringing…'
                    : s.state == 'ongoing' ? _format(_seconds)
                    : s.state == 'ended' ? 'Call ended' : 'Connecting…',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ctl(Icons.mic_off, _muted, () { setState(() => _muted = !_muted); _svc.toggleMute(_muted); }),
                if (widget.type == 'video')
                  _ctl(Icons.videocam_off, !_camOn, () { setState(() => _camOn = !_camOn); _svc.toggleCamera(_camOn); }),
                if (widget.type == 'video')
                  _ctl(Icons.cameraswitch, false, () { setState(() => _frontCam = !_frontCam); _svc.switchCamera(); }),
                _ctl(Icons.call_end, true, () async { await _svc.end(); if (mounted) Navigator.pop(context); }, red: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _localPreview(RtcEngine engine) =>
      AgoraVideoView(controller: VideoViewController(rtcEngine: engine, canvas: const VideoCanvas(uid: 0)));

  Widget _ctl(IconData icon, bool active, VoidCallback onTap, {bool red = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: red ? Colors.red : (active ? Colors.white24 : Colors.white12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }
}

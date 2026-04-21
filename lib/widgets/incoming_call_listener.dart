import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/call_service.dart';
import '../services/realtime_service.dart';
import '../screens/calls/call_screen.dart';

/// Listens on users/{uid}/incoming_call and shows a full-screen ringer
/// when a call arrives. Mount once inside the MaterialApp builder.
class IncomingCallListener extends StatefulWidget {
  final Widget child;
  const IncomingCallListener({super.key, required this.child});

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  StreamSubscription<DatabaseEvent>? _sub;
  bool _showing = false;
  String? _lastCallId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  void _attach() {
    final auth = context.read<AuthService>();
    final uid = auth.userId;
    if (uid == null) return;
    _sub = RealtimeService.instance
        .incomingCallsStream(uid.toString())
        .listen(_onEvent);
  }

  void _onEvent(DatabaseEvent ev) {
    final v = ev.snapshot.value;
    if (v is! Map) return;
    final m = Map<String, dynamic>.from(v as Map);
    final callId = m['call_id']?.toString();
    if (callId == null || callId.isEmpty) return;
    if (_showing || callId == _lastCallId) return;
    _lastCallId = callId;
    _showRinger(
      callId: callId,
      chatId: m['chat_id']?.toString() ?? '',
      fromName: m['from_name']?.toString() ?? 'Incoming call',
      type: m['type']?.toString() ?? 'voice',
    );
  }

  Future<void> _showRinger({
    required String callId,
    required String chatId,
    required String fromName,
    required String type,
  }) async {
    _showing = true;
    final nav = Navigator.of(context, rootNavigator: true);
    final auth = context.read<AuthService>();
    final svc = context.read<CallService>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _Ringer(
        fromName: fromName,
        type: type,
        onAccept: () async {
          Navigator.of(ctx, rootNavigator: true).pop();
          if (auth.userId != null) {
            unawaited(RealtimeService.instance.clearIncomingCall(auth.userId!.toString()));
          }
          unawaited(svc.answer(callId));
          nav.push(MaterialPageRoute(
            builder: (_) => CallScreen(
              chatId: chatId,
              peerName: fromName,
              type: type,
              incoming: true,
              callId: callId,
            ),
          ));
        },
        onDecline: () async {
          Navigator.of(ctx, rootNavigator: true).pop();
          if (auth.userId != null) {
            unawaited(RealtimeService.instance.clearIncomingCall(auth.userId!.toString()));
          }
          await svc.decline(callId);
        },
      ),
    );
    _showing = false;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Ringer extends StatelessWidget {
  final String fromName;
  final String type;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _Ringer({
    required this.fromName,
    required this.type,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),
            Column(
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: MyCColors.accentGradient,
                  ),
                  child: Center(child: Text(
                    fromName.isNotEmpty ? fromName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
                const SizedBox(height: 20),
                Text(fromName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  type == 'video' ? 'Incoming video call…' : 'Incoming voice call…',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn(Icons.call_end, Colors.red, onDecline),
                  _btn(type == 'video' ? Icons.videocam : Icons.call, Colors.green, onAccept),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      );
}

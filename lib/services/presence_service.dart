import 'package:flutter/widgets.dart';
import 'realtime_service.dart';

/// Observes app lifecycle and mirrors online/offline presence into RTDB.
class PresenceService with WidgetsBindingObserver {
  PresenceService(this.userId);
  final String userId;
  bool _attached = false;

  void attach() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);
    RealtimeService.instance.setPresence(userId, true);
  }

  void detach() {
    if (!_attached) return;
    _attached = false;
    WidgetsBinding.instance.removeObserver(this);
    RealtimeService.instance.setPresence(userId, false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final online = state == AppLifecycleState.resumed;
    RealtimeService.instance.setPresence(userId, online);
  }
}

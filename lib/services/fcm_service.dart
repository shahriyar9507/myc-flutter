import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

/// Handles FCM permission, token registration with backend, and foreground
/// display of notifications via flutter_local_notifications. Background
/// messages are delivered by the system notification tray.
class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  String? _token;
  String? get token => _token;

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));

    if (Platform.isAndroid) {
      final android = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(const AndroidNotificationChannel(
        'myc_messages', 'Messages',
        description: 'Incoming MyC messages',
        importance: Importance.high,
      ));
      await android?.createNotificationChannel(const AndroidNotificationChannel(
        'myc_calls', 'Calls',
        description: 'Incoming MyC calls',
        importance: Importance.max,
      ));
    }

    FirebaseMessaging.onMessage.listen(_onForeground);
  }

  Future<void> registerWithBackend(String bearer) async {
    _token = await _fcm.getToken();
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse(ApiConfig.pushRegister),
        headers: {
          'Authorization': 'Bearer $bearer',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': _token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'device_name': 'MyC Flutter',
        }),
      );
    } catch (e) {
      debugPrint('FCM register failed: $e');
    }

    _fcm.onTokenRefresh.listen((t) async {
      _token = t;
      try {
        await http.post(
          Uri.parse(ApiConfig.pushRegister),
          headers: {
            'Authorization': 'Bearer $bearer',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'token': t,
            'platform': Platform.isIOS ? 'ios' : 'android',
            'device_name': 'MyC Flutter',
          }),
        );
      } catch (_) {}
    });
  }

  void _onForeground(RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;
    final channel = msg.data['type'] == 'call' ? 'myc_calls' : 'myc_messages';
    _local.show(
      msg.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel, channel == 'myc_calls' ? 'Calls' : 'Messages',
          importance: channel == 'myc_calls' ? Importance.max : Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(msg.data),
    );
  }
}

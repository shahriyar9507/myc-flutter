import 'package:flutter/material.dart';
import 'api_client.dart';

/// Holds the user's settings (visibility, notification prefs, theme mode,
/// font size, language, DND, quiet hours) and syncs with the backend.
class SettingsService extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  // Theme
  String themeMode = 'dark'; // system | light | dark
  double fontSize = 16;
  String language = 'en';

  ThemeMode get flutterThemeMode => switch (themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  // Privacy
  String lastSeenVisibility = 'everyone';
  String profilePhotoVisibility = 'everyone';
  String aboutVisibility = 'everyone';
  bool readReceipts = true;
  bool typingIndicator = true;

  // Notifications — global
  bool notifPush = true;
  bool notifSound = true;
  bool notifVibrate = true;
  bool notifInApp = true;
  bool notifPreview = true;
  bool showOnLockscreen = true;
  bool showSenderName = true;
  bool notifyMessages = true;
  bool notifyGroups = true;
  bool notifyCalls = true;
  bool notifyStories = true;
  bool notifyMentions = true;
  String vibration = 'short';
  String ledColor = '#7C3AED';
  String badgeMode = 'messages';
  String popupPriority = 'high';

  // Quiet hours
  bool quietEnabled = false;
  String quietStart = '22:00';
  String quietEnd = '07:00';
  String quietException = 'none';

  // DND
  bool dndEnabled = false;
  DateTime? dndUntil;

  Future<void> load() async {
    final r = await _api.settingsGet();
    if (r['success'] != true) return;
    _apply((r['data'] as Map?) ?? {});
    notifyListeners();
  }

  void _apply(Map d) {
    themeMode = d['theme_mode']?.toString() ?? themeMode;
    final fs = d['font_size'];
    if (fs is num) fontSize = fs.toDouble();
    else if (fs is String) { final p = double.tryParse(fs); if (p != null) fontSize = p; }
    language = d['language']?.toString() ?? language;

    lastSeenVisibility = d['last_seen_visibility']?.toString() ?? lastSeenVisibility;
    profilePhotoVisibility = d['profile_photo_visibility']?.toString() ?? d['photo_visibility']?.toString() ?? profilePhotoVisibility;
    aboutVisibility = d['about_visibility']?.toString() ?? d['status_visibility']?.toString() ?? aboutVisibility;
    readReceipts = _b(d['read_receipts'], readReceipts);
    typingIndicator = _b(d['typing_indicator'], typingIndicator);

    notifPush = _b(d['notif_push'] ?? d['notifications_enabled'], notifPush);
    notifSound = _b(d['notif_sound'], notifSound);
    notifVibrate = _b(d['notif_vibrate'], notifVibrate);
    notifInApp = _b(d['notif_in_app'] ?? d['in_app_sound'], notifInApp);
    notifPreview = _b(d['notif_preview'] ?? d['show_preview'], notifPreview);
    showOnLockscreen = _b(d['show_on_lockscreen'], showOnLockscreen);
    showSenderName = _b(d['show_sender_name'], showSenderName);
    notifyMessages = _b(d['notify_messages'], notifyMessages);
    notifyGroups = _b(d['notify_groups'], notifyGroups);
    notifyCalls = _b(d['notify_calls'], notifyCalls);
    notifyStories = _b(d['notify_stories'], notifyStories);
    notifyMentions = _b(d['notify_mentions'], notifyMentions);
    vibration = d['vibration']?.toString() ?? vibration;
    ledColor = d['led_color']?.toString() ?? ledColor;
    badgeMode = d['badge_mode']?.toString() ?? badgeMode;
    popupPriority = d['popup_priority']?.toString() ?? popupPriority;

    quietEnabled = _b(d['quiet_enabled'] ?? d['quiet_hours_enabled'], quietEnabled);
    quietStart = d['quiet_start']?.toString() ?? quietStart;
    quietEnd = d['quiet_end']?.toString() ?? quietEnd;
    quietException = d['quiet_exception']?.toString() ?? quietException;

    dndEnabled = _b(d['dnd_enabled'], dndEnabled);
    final u = d['dnd_until']?.toString();
    dndUntil = (u != null && u.isNotEmpty) ? DateTime.tryParse(u) : null;
  }

  static bool _b(dynamic v, bool d) => v == null ? d : (v == true || v == 1);

  Future<bool> save(Map<String, dynamic> patch) async {
    // Apply optimistically so UI reflects immediately.
    _apply({...patch});
    notifyListeners();
    final r = await _api.settingsUpdate(patch);
    return r['success'] == true;
  }
}

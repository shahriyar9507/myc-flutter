// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyC';

  @override
  String get chats => 'Chats';

  @override
  String get stories => 'Stories';

  @override
  String get calls => 'Calls';

  @override
  String get profile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get newChat => 'New chat';

  @override
  String get newGroup => 'New group';

  @override
  String get typing => 'typing…';

  @override
  String get online => 'Active now';

  @override
  String get offline => 'Offline';

  @override
  String get sendMessage => 'Message…';

  @override
  String get noMessages => 'No messages';

  @override
  String get noChats => 'No chats yet';

  @override
  String get copy => 'Copy';

  @override
  String get reply => 'Reply';

  @override
  String get forward => 'Forward';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteForEveryone => 'Delete for everyone';

  @override
  String get deleteForMe => 'Delete for me';

  @override
  String get star => 'Star';

  @override
  String get unstar => 'Unstar';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get blocked => 'Blocked';

  @override
  String get starred => 'Starred';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get language => 'Language';

  @override
  String get appLock => 'App lock';

  @override
  String get doNotDisturb => 'Do not disturb';

  @override
  String get logout => 'Log out';

  @override
  String get changePassword => 'Change password';

  @override
  String get sessions => 'Active sessions';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get about => 'About';

  @override
  String get readReceipts => 'Read receipts';

  @override
  String get typingIndicator => 'Typing indicator';

  @override
  String get everyone => 'Everyone';

  @override
  String get myContacts => 'My contacts';

  @override
  String get nobody => 'Nobody';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibrate => 'Vibrate';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get systemDefault => 'System default';

  @override
  String get messageTextSize => 'Message text size';

  @override
  String get aiPalettes => 'AI palettes';

  @override
  String get unlockMyC => 'Unlock MyC';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get useBiometric => 'Use biometric';

  @override
  String get recording => 'Recording…';

  @override
  String get voiceMessage => 'Voice message';

  @override
  String get edited => 'edited';

  @override
  String get messageDeleted => 'This message was deleted';

  @override
  String get shareMoment => 'Share a moment';

  @override
  String get visibleFor24h => 'Visible for 24h';

  @override
  String members(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }
}

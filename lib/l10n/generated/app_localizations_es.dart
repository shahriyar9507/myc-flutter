// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MyC';

  @override
  String get chats => 'Chats';

  @override
  String get stories => 'Historias';

  @override
  String get calls => 'Llamadas';

  @override
  String get profile => 'Perfil';

  @override
  String get search => 'Buscar';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get typing => 'escribiendo…';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Desconectado';

  @override
  String get sendMessage => 'Mensaje…';

  @override
  String get noMessages => 'Sin mensajes';

  @override
  String get noChats => 'Aún no hay chats';

  @override
  String get copy => 'Copiar';

  @override
  String get reply => 'Responder';

  @override
  String get forward => 'Reenviar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteForEveryone => 'Eliminar para todos';

  @override
  String get deleteForMe => 'Eliminar para mí';

  @override
  String get star => 'Destacar';

  @override
  String get unstar => 'Quitar destacado';

  @override
  String get pin => 'Fijar';

  @override
  String get unpin => 'Desfijar';

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Reactivar';

  @override
  String get blocked => 'Blocked';

  @override
  String get starred => 'Starred';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get privacy => 'Privacidad';

  @override
  String get language => 'Idioma';

  @override
  String get appLock => 'Bloqueo';

  @override
  String get doNotDisturb => 'No molestar';

  @override
  String get logout => 'Cerrar sesión';

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

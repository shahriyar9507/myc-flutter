import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/fcm_service.dart';
import 'services/realtime_service.dart';
import 'services/settings_service.dart';
import 'services/call_service.dart';
import 'services/app_lock_service.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/auth/password_change_screen.dart';
import 'screens/auth/sessions_screen.dart';
import 'screens/profile/public_profile_screen.dart';
import 'screens/user_search/user_search_screen.dart';
import 'screens/chat_list/group_create_screen.dart';
import 'screens/contacts/contacts_screen.dart';
import 'screens/settings/blocked_users_screen.dart';
import 'screens/chat_thread/starred_messages_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/settings/notifications_screen.dart';
import 'screens/settings/appearance_screen.dart';
import 'screens/settings/language_screen.dart';
import 'screens/settings/app_lock_screen.dart';
import 'screens/settings/dnd_screen.dart';
import 'screens/settings/palette_screen.dart';
import 'screens/settings/chat_notify_screen.dart';
import 'screens/chat_list/group_info_screen.dart';
import 'screens/stories/stories_create_screen.dart';
import 'screens/lock/lock_screen.dart';
import 'widgets/incoming_call_listener.dart';

// Must be top-level / static for the FCM background isolate.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: MyCColors.darkBg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  await FcmService.instance.init();

  final auth = AuthService();
  await auth.loadStoredAuth();

  final settings = SettingsService();
  final appLock = AppLockService();
  await appLock.load();

  if (auth.isLoggedIn && auth.token != null) {
    unawaited(RealtimeService.instance.signIn(auth.token!));
    unawaited(FcmService.instance.registerWithBackend(auth.token!));
    unawaited(settings.load());
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyCApp(
    auth: auth,
    settings: settings,
    appLock: appLock,
    onboardingDone: onboardingDone,
  ));
}

class MyCApp extends StatefulWidget {
  final AuthService auth;
  final SettingsService settings;
  final AppLockService appLock;
  final bool onboardingDone;
  const MyCApp({
    super.key,
    required this.auth,
    required this.settings,
    required this.appLock,
    required this.onboardingDone,
  });

  @override
  State<MyCApp> createState() => _MyCAppState();
}

class _MyCAppState extends State<MyCApp> with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>();
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locked = widget.appLock.enabled;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.appLock.markBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.appLock.shouldLockOnResume() && mounted) {
        setState(() => _locked = true);
      }
    }
  }

  void _unlock() => setState(() => _locked = false);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.auth),
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.appLock),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => CallService()),
      ],
      child: Consumer<SettingsService>(builder: (context, s, _) => MaterialApp(
        navigatorKey: _navKey,
        title: 'MyC',
        debugShowCheckedModeBanner: false,
        theme: MyCTheme.dark,
        darkTheme: MyCTheme.dark,
        themeMode: s.flutterThemeMode,
        locale: Locale(s.language),
        supportedLocales: const [
          Locale('en'), Locale('es'), Locale('fr'), Locale('de'),
          Locale('pt'), Locale('it'), Locale('ru'), Locale('hi'),
          Locale('bn'), Locale('ar'), Locale('zh'), Locale('ja'),
          Locale('ko'), Locale('tr'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          if (_locked && widget.auth.isLoggedIn) {
            return LockScreen(onUnlocked: _unlock);
          }
          final content = child ?? const SizedBox.shrink();
          if (widget.auth.isLoggedIn) {
            return IncomingCallListener(child: content);
          }
          return content;
        },
        home: _initialScreen(),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/profile/edit': (_) => const ProfileEditScreen(),
          '/profile/password': (_) => const PasswordChangeScreen(),
          '/profile/sessions': (_) => const SessionsScreen(),
          '/search': (_) => const UserSearchScreen(),
          '/group/new': (_) => const GroupCreateScreen(),
          '/contacts': (_) => const ContactsScreen(),
          '/blocked': (_) => const BlockedUsersScreen(),
          '/starred': (_) => const StarredMessagesScreen(),
          '/settings/privacy': (_) => const PrivacyScreen(),
          '/settings/notifications': (_) => const NotificationsScreen(),
          '/settings/appearance': (_) => const AppearanceScreen(),
          '/settings/language': (_) => const LanguageScreen(),
          '/settings/app-lock': (_) => const AppLockScreen(),
          '/dnd': (_) => const DndScreen(),
          '/palettes': (_) => const PaletteScreen(),
          '/stories/new': (_) => const StoriesCreateScreen(),
        },
        onGenerateRoute: (s) {
          if (s.name == '/profile/public') {
            final id = s.arguments?.toString() ?? '';
            return MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: id));
          }
          if (s.name == '/chat-notify') {
            final id = s.arguments?.toString() ?? '';
            return MaterialPageRoute(builder: (_) => ChatNotifyScreen(chatId: id));
          }
          if (s.name == '/group/info') {
            final id = s.arguments?.toString() ?? '';
            return MaterialPageRoute(builder: (_) => GroupInfoScreen(chatId: id));
          }
          return null;
        },
      )),
    );
  }

  Widget _initialScreen() {
    if (!widget.onboardingDone) return const OnboardingScreen();
    if (!widget.auth.isLoggedIn) return const LoginScreen();
    return const HomeScreen();
  }
}

// MyC Firebase configuration (hand-written from myc-api1/config/firebase.php).
// Regenerate with `flutterfire configure` if project config changes.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError('Firebase not configured for this platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUdBWJmw82rCvtdPrVDjr9XRZNQ6x19rM',
    appId: '1:863529519686:android:6203902c8a70749dbe5847',
    messagingSenderId: '863529519686',
    projectId: 'myc-chat-99ec8',
    databaseURL: 'https://myc-chat-99ec8-default-rtdb.firebaseio.com',
    storageBucket: 'myc-chat-99ec8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXPqkA-spWtJqV_xumPGmI8EWCW0s930I',
    appId: '1:863529519686:ios:2e16e59dfcc41016be5847',
    messagingSenderId: '863529519686',
    projectId: 'myc-chat-99ec8',
    databaseURL: 'https://myc-chat-99ec8-default-rtdb.firebaseio.com',
    storageBucket: 'myc-chat-99ec8.firebasestorage.app',
    iosBundleId: 'com.crispybroasted.myc',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAUdBWJmw82rCvtdPrVDjr9XRZNQ6x19rM',
    appId: '1:863529519686:android:6203902c8a70749dbe5847',
    messagingSenderId: '863529519686',
    projectId: 'myc-chat-99ec8',
    databaseURL: 'https://myc-chat-99ec8-default-rtdb.firebaseio.com',
    storageBucket: 'myc-chat-99ec8.firebasestorage.app',
  );
}

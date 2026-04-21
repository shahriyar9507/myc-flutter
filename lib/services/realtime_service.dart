import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'secure_storage.dart';

/// Signs into Firebase with a custom token minted by /api/auth/firebase-token,
/// then exposes RTDB streams for messages, typing, reads, presence, and calls.
class RealtimeService {
  RealtimeService._();
  static final instance = RealtimeService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _signedIn = false;

  /// Exchange the MyC bearer token for a Firebase custom token and sign in.
  /// Safe to call multiple times — becomes a no-op once signed in.
  Future<bool> signIn(String bearerToken) async {
    if (_signedIn && _auth.currentUser != null) return true;
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.firebaseToken),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );
      if (res.statusCode != 200) return false;
      final body = jsonDecode(res.body);
      final fbToken = body['data']?['firebase_token'];
      if (fbToken == null) return false;
      await SecureStorage.writeFirebaseToken(fbToken);
      await _auth.signInWithCustomToken(fbToken);
      _signedIn = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    _signedIn = false;
    try { await _auth.signOut(); } catch (_) {}
  }

  // ── Messages ──────────────────────────────────────────────
  Stream<DatabaseEvent> messageStream(String chatId) =>
      _db.ref('chats/$chatId/messages').orderByChild('ts').onValue;

  Stream<DatabaseEvent> chatLastUpdate(String chatId) =>
      _db.ref('chats/$chatId/last_update').onValue;

  // ── Typing ────────────────────────────────────────────────
  Future<void> setTyping(String chatId, String userId, bool typing) =>
      _db.ref('chats/$chatId/typing/$userId').set(typing ? ServerValue.timestamp : null);

  Stream<DatabaseEvent> typingStream(String chatId) =>
      _db.ref('chats/$chatId/typing').onValue;

  // ── Read receipts ─────────────────────────────────────────
  Future<void> markRead(String chatId, String userId, String messageId) =>
      _db.ref('chats/$chatId/reads/$userId').set({
        'message_id': messageId,
        'ts': ServerValue.timestamp,
      });

  Stream<DatabaseEvent> readsStream(String chatId) =>
      _db.ref('chats/$chatId/reads').onValue;

  // ── Presence ──────────────────────────────────────────────
  Future<void> setPresence(String userId, bool online) async {
    final ref = _db.ref('users/$userId/presence');
    await ref.onDisconnect().set({'online': false, 'last_seen': ServerValue.timestamp});
    await ref.set({'online': online, 'last_seen': ServerValue.timestamp});
  }

  Stream<DatabaseEvent> presenceStream(String userId) =>
      _db.ref('users/$userId/presence').onValue;

  // ── Calls ─────────────────────────────────────────────────
  Stream<DatabaseEvent> incomingCallsStream(String userId) =>
      _db.ref('users/$userId/incoming_call').onValue;

  Future<void> clearIncomingCall(String userId) =>
      _db.ref('users/$userId/incoming_call').remove();

  Stream<DatabaseEvent> callStream(String callId) =>
      _db.ref('calls/$callId').onValue;

  Future<void> setCallParticipantState(String callId, String userId, String state) =>
      _db.ref('calls/$callId/participants/$userId').set({
        'state': state,
        'ts': ServerValue.timestamp,
      });
}

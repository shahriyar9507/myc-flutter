import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'secure_storage.dart';

/// One HTTP client for the entire app. Every endpoint in ApiConfig has a
/// corresponding typed method here so screens don't juggle http.Client /
/// headers / JSON decoding themselves.
class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await SecureStorage.readToken();
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<Map<String, dynamic>> _get(String url) async {
    try {
      final r = await http.get(Uri.parse(url), headers: await _headers(json: false));
      return _decode(r);
    } catch (e) { return {'success': false, 'error': '$e'}; }
  }

  Future<Map<String, dynamic>> _post(String url, [Map<String, dynamic>? body]) async {
    try {
      final r = await http.post(Uri.parse(url),
          headers: await _headers(), body: jsonEncode(body ?? {}));
      return _decode(r);
    } catch (e) { return {'success': false, 'error': '$e'}; }
  }

  Map<String, dynamic> _decode(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
      return {'success': false, 'error': 'Bad response'};
    } catch (_) { return {'success': false, 'error': 'HTTP ${r.statusCode}'}; }
  }

  // ── Profile ──────────────────────────────────────────────
  Future<Map<String, dynamic>> profileGet([int? id]) =>
      _get(id == null ? ApiConfig.profileGet : '${ApiConfig.profileGet}?user_id=$id');
  Future<Map<String, dynamic>> profileUpdate(Map<String, dynamic> data) =>
      _post(ApiConfig.profileUpdate, data);
  Future<Map<String, dynamic>> profileSearch(String query) =>
      _get('${ApiConfig.profileSearch}?q=${Uri.encodeComponent(query)}');

  // ── Chats ────────────────────────────────────────────────
  Future<Map<String, dynamic>> chatList() => _get(ApiConfig.chatList);
  Future<Map<String, dynamic>> chatGet(String id) => _get('${ApiConfig.chatGet}?chat_id=$id');
  Future<Map<String, dynamic>> chatCreate({required String type, int? userId, List<int>? members, String? name}) =>
      _post(ApiConfig.chatCreate, {
        'type': type,
        if (userId != null) 'user_id': userId,
        if (members != null) 'members': members,
        if (name != null) 'name': name,
      });
  Future<Map<String, dynamic>> chatPin(String chatId, bool pinned) =>
      _post(ApiConfig.chatPin, {'chat_id': chatId, 'pinned': pinned});
  Future<Map<String, dynamic>> chatMute(String chatId, {int? hours, bool indefinite = false}) =>
      _post(ApiConfig.chatMute, {
        'chat_id': chatId,
        if (hours != null) 'hours': hours,
        'indefinite': indefinite,
      });

  // ── Groups ───────────────────────────────────────────────
  Future<Map<String, dynamic>> groupUpdate(String chatId, Map<String, dynamic> patch) =>
      _post(ApiConfig.groupUpdate, {'chat_id': chatId, ...patch});
  Future<Map<String, dynamic>> groupAddMember(String chatId, String userId) =>
      _post(ApiConfig.groupAddMember, {'chat_id': chatId, 'user_id': userId});
  Future<Map<String, dynamic>> groupRemoveMember(String chatId, String userId) =>
      _post(ApiConfig.groupRemoveMember, {'chat_id': chatId, 'user_id': userId});
  Future<Map<String, dynamic>> groupSetAdmin(String chatId, String userId, bool admin) =>
      _post(ApiConfig.groupSetAdmin, {'chat_id': chatId, 'user_id': userId, 'is_admin': admin});
  Future<Map<String, dynamic>> groupSetNickname(String chatId, String userId, String nickname) =>
      _post(ApiConfig.groupSetNickname, {'chat_id': chatId, 'user_id': userId, 'nickname': nickname});

  // ── Sessions ─────────────────────────────────────────────
  Future<Map<String, dynamic>> sessionsList() => _get(ApiConfig.sessionsList);
  Future<Map<String, dynamic>> sessionRevoke(String id) =>
      _post(ApiConfig.sessionRevoke, {'session_id': id});
  Future<Map<String, dynamic>> sessionRevokeAll() =>
      _post(ApiConfig.logoutAll);

  // ── Messages ─────────────────────────────────────────────
  Future<Map<String, dynamic>> messageList(String chatId, {int? before}) =>
      _get('${ApiConfig.messageList}?chat_id=$chatId${before != null ? "&before=$before" : ""}');
  Future<Map<String, dynamic>> messageSend(Map<String, dynamic> data) =>
      _post(ApiConfig.messageSend, data);
  Future<Map<String, dynamic>> messageEdit(String id, String content) =>
      _post(ApiConfig.messageEdit, {'message_id': id, 'content': content});
  Future<Map<String, dynamic>> messageDelete(String id, {bool forEveryone = false}) =>
      _post(ApiConfig.messageDelete, {'message_id': id, 'for_everyone': forEveryone});
  Future<Map<String, dynamic>> messageReact(String id, String? emoji) =>
      _post(ApiConfig.messageReact, {'message_id': id, 'emoji': emoji});
  Future<Map<String, dynamic>> messageRead(String chatId, String messageId) =>
      _post(ApiConfig.messageRead, {'chat_id': chatId, 'message_id': messageId});
  Future<Map<String, dynamic>> messageStar(String id, bool star) =>
      _post(ApiConfig.messageStar, {'message_id': id, 'star': star});
  Future<Map<String, dynamic>> messagePin(String id, bool pin) =>
      _post(ApiConfig.messagePin, {'message_id': id, 'pin': pin});
  Future<Map<String, dynamic>> messageForward(String id, List<String> chatIds) =>
      _post(ApiConfig.messageForward, {'message_id': id, 'chat_ids': chatIds});
  Future<Map<String, dynamic>> starredList() => _get(ApiConfig.messagesStarred);

  // ── Calls ────────────────────────────────────────────────
  Future<Map<String, dynamic>> callStart(String chatId, String type) =>
      _post(ApiConfig.callStart, {'chat_id': chatId, 'type': type});
  Future<Map<String, dynamic>> callAnswer(String callId, bool accept) =>
      _post(ApiConfig.callAnswer, {'call_id': callId, 'accept': accept});
  Future<Map<String, dynamic>> callEnd(String callId, {int duration = 0}) =>
      _post(ApiConfig.callEnd, {'call_id': callId, 'duration': duration});
  Future<Map<String, dynamic>> callHistory() => _get(ApiConfig.callHistory);

  // ── Contacts ─────────────────────────────────────────────
  Future<Map<String, dynamic>> contactAdd(int userId, {String? nickname}) =>
      _post(ApiConfig.contactAdd, {'user_id': userId, if (nickname != null) 'nickname': nickname});
  Future<Map<String, dynamic>> contactRemove(int userId) =>
      _post(ApiConfig.contactRemove, {'user_id': userId});
  Future<Map<String, dynamic>> contactList() => _get(ApiConfig.contactList);
  Future<Map<String, dynamic>> contactFavorite(int userId, bool favorite) =>
      _post(ApiConfig.contactFavorite, {'user_id': userId, 'favorite': favorite});

  // ── Blocks ───────────────────────────────────────────────
  Future<Map<String, dynamic>> blockUser(int userId, {String? reason}) =>
      _post(ApiConfig.blockUser, {'user_id': userId, if (reason != null) 'reason': reason});
  Future<Map<String, dynamic>> unblockUser(int userId) =>
      _post(ApiConfig.unblockUser, {'user_id': userId});
  Future<Map<String, dynamic>> blockList() => _get(ApiConfig.blockList);

  // ── Stories ──────────────────────────────────────────────
  Future<Map<String, dynamic>> storyCreate(Map<String, dynamic> data) =>
      _post(ApiConfig.storyCreate, data);
  Future<Map<String, dynamic>> storyList() => _get(ApiConfig.storyList);
  Future<Map<String, dynamic>> storyView(String id) =>
      _post(ApiConfig.storyView, {'story_id': id});
  Future<Map<String, dynamic>> storyDelete(String id) =>
      _post(ApiConfig.storyDelete, {'story_id': id});

  // ── Settings ─────────────────────────────────────────────
  Future<Map<String, dynamic>> settingsGet() => _get(ApiConfig.settingsGet);
  Future<Map<String, dynamic>> settingsUpdate(Map<String, dynamic> data) =>
      _post(ApiConfig.settingsUpdate, data);
  Future<Map<String, dynamic>> settingsChatOverride(String chatId, Map<String, dynamic> data) =>
      _post(ApiConfig.settingsChatOverride, {'chat_id': chatId, ...data});

  // ── Palettes ─────────────────────────────────────────────
  Future<Map<String, dynamic>> paletteSave(Map<String, dynamic> data) =>
      _post(ApiConfig.paletteSave, data);
  Future<Map<String, dynamic>> paletteList() => _get(ApiConfig.paletteList);
  Future<Map<String, dynamic>> paletteApply(String id) =>
      _post(ApiConfig.paletteApply, {'palette_id': id});
  Future<Map<String, dynamic>> paletteDelete(String id) =>
      _post(ApiConfig.paletteDelete, {'palette_id': id});

  // ── Typing ───────────────────────────────────────────────
  Future<Map<String, dynamic>> typingSet(String chatId, bool typing) =>
      _post(ApiConfig.typingSet, {'chat_id': chatId, 'typing': typing});

  // ── Media ────────────────────────────────────────────────
  Future<Map<String, dynamic>?> uploadMedia(List<int> bytes, String filename, String type) async {
    try {
      final token = await SecureStorage.readToken();
      final req = http.MultipartRequest('POST', Uri.parse(ApiConfig.mediaUpload));
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.fields['type'] = type;
      req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      final resp = await http.Response.fromStream(await req.send());
      final d = _decode(resp);
      return d['success'] == true ? (d['data'] as Map<String, dynamic>?) : null;
    } catch (e) {
      debugPrint('uploadMedia: $e');
      return null;
    }
  }
}

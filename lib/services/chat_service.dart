import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'api_client.dart';
import 'secure_storage.dart';

/// Holds the user's chat list and message cache.
/// Real-time updates come from RealtimeService (Firebase RTDB); this service
/// only owns the initial fetch + local mutation helpers.
class ChatService extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;

  final Map<String, List<MessageModel>> _messages = {};
  List<MessageModel> messagesFor(String chatId) => _messages[chatId] ?? const [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  ChatService() { _initUserId(); }

  Future<void> _initUserId() async {
    final id = await SecureStorage.readUserId();
    _currentUserId = id?.toString();
  }

  Future<void> fetchChats({bool hideLoader = false}) async {
    if (!hideLoader) { _isLoading = true; notifyListeners(); }
    _error = null;
    final r = await _api.chatList();
    if (r['success'] == true) {
      final list = (r['data']?['chats'] as List?) ?? const [];
      _chats = list.map((c) => ChatModel.fromJson(c)).toList()
        ..sort((a, b) {
          if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    } else {
      _error = r['error']?.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<MessageModel>> fetchMessages(String chatId) async {
    await _initUserId();
    final r = await _api.messageList(chatId);
    if (r['success'] != true) return _messages[chatId] ?? const [];
    final list = (r['data']?['messages'] as List?) ?? const [];
    final msgs = list
        .map((m) => MessageModel.fromJson(m, _currentUserId ?? ''))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _messages[chatId] = msgs;
    notifyListeners();
    return msgs;
  }

  /// Injects a realtime RTDB message snapshot into the cache.
  void upsertMessage(String chatId, MessageModel msg) {
    final list = List<MessageModel>.from(_messages[chatId] ?? const []);
    final idx = list.indexWhere((m) => m.id == msg.id);
    if (idx >= 0) {
      list[idx] = msg;
    } else {
      list.insert(0, msg);
    }
    _messages[chatId] = list;
    notifyListeners();
  }

  Future<bool> sendMessage(
    String chatId,
    String content, {
    String type = 'text',
    String? mediaUrl,
    String? mediaThumb,
    int? duration,
    String? replyTo,
  }) async {
    final r = await _api.messageSend({
      'chat_id': chatId,
      'type': type,
      'content': content,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaThumb != null) 'media_thumbnail': mediaThumb,
      if (duration != null) 'duration': duration,
      if (replyTo != null) 'reply_to': replyTo,
    });
    if (r['success'] == true) fetchChats(hideLoader: true);
    return r['success'] == true;
  }

  Future<String?> createChat({required String type, int? userId, List<int>? members, String? name}) async {
    final r = await _api.chatCreate(type: type, userId: userId, members: members, name: name);
    if (r['success'] == true) {
      fetchChats(hideLoader: true);
      return r['data']?['chat_id']?.toString();
    }
    return null;
  }

  Future<Map<String, dynamic>?> uploadMedia(List<int> bytes, String filename, String type) =>
      _api.uploadMedia(bytes, filename, type);

  Future<bool> editMessage(String id, String content) async {
    final r = await _api.messageEdit(id, content);
    return r['success'] == true;
  }

  Future<bool> deleteMessage(String id, {bool forEveryone = false}) async {
    final r = await _api.messageDelete(id, forEveryone: forEveryone);
    return r['success'] == true;
  }

  Future<bool> reactMessage(String id, String? emoji) async {
    final r = await _api.messageReact(id, emoji);
    return r['success'] == true;
  }

  Future<bool> starMessage(String id, bool star) async {
    final r = await _api.messageStar(id, star);
    return r['success'] == true;
  }

  Future<bool> pinMessage(String id, bool pin) async {
    final r = await _api.messagePin(id, pin);
    return r['success'] == true;
  }

  Future<bool> forwardMessage(String id, List<String> chatIds) async {
    final r = await _api.messageForward(id, chatIds);
    return r['success'] == true;
  }

  Future<bool> markRead(String chatId, String messageId) async {
    final r = await _api.messageRead(chatId, messageId);
    return r['success'] == true;
  }
}

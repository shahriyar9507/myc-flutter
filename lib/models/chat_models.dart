/// Chat + message models. Mirrors the backend schema closely and carries
/// all fields needed by the UI: replies, reactions, stars, pins, receipts.
class ChatModel {
  final String id;
  final String type; // 'private' | 'group'
  final String name;
  final String? avatar;
  final String theme;
  final String? wallpaper;
  final String lastMessage;
  final String updatedAt;
  final int unreadCount;
  final bool isOnline;
  final bool pinned;
  final DateTime? mutedUntil;
  final int? peerId;
  final List<int> memberIds;

  ChatModel({
    required this.id,
    required this.type,
    required this.name,
    this.avatar,
    required this.theme,
    this.wallpaper,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
    this.isOnline = false,
    this.pinned = false,
    this.mutedUntil,
    this.peerId,
    this.memberIds = const [],
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final peer = json['peer'] as Map<String, dynamic>?;
    return ChatModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'private',
      name: json['name']?.toString() ?? peer?['name']?.toString() ?? 'Unknown',
      avatar: json['avatar']?.toString() ?? peer?['avatar']?.toString(),
      theme: json['theme']?.toString() ?? 'aurora',
      wallpaper: json['wallpaper']?.toString(),
      lastMessage: json['last_message_preview']?.toString() ?? '',
      updatedAt: json['last_message_at']?.toString() ?? '',
      unreadCount: _int(json['unread_count']),
      isOnline: peer?['is_online'] == true,
      pinned: json['pinned'] == true || json['pinned'] == 1,
      mutedUntil: _parseDate(json['muted_until']),
      peerId: _int(peer?['id']),
      memberIds: ((json['members'] as List?) ?? const [])
          .map((m) => _int(m is Map ? m['id'] : m))
          .toList(),
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // text|image|video|audio|voice|file|sticker|location|contact|system
  final String? mediaUrl;
  final String? mediaThumb;
  final int? duration;
  final String? replyToId;
  final String? replyPreview;
  final String? forwardedFrom;
  final bool edited;
  final bool deletedForAll;
  final bool starred;
  final bool pinned;
  final Map<String, String> reactions; // emoji -> userId
  final List<String> readBy;
  final bool delivered;
  final DateTime createdAt;
  final bool isMine;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    this.mediaUrl,
    this.mediaThumb,
    this.duration,
    this.replyToId,
    this.replyPreview,
    this.forwardedFrom,
    this.edited = false,
    this.deletedForAll = false,
    this.starred = false,
    this.pinned = false,
    this.reactions = const {},
    this.readBy = const [],
    this.delivered = false,
    required this.createdAt,
    required this.isMine,
  });

  /// 48h edit window flag.
  bool get editable =>
      isMine && type == 'text' &&
      DateTime.now().difference(createdAt) < const Duration(hours: 48);

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['sender_id']?.toString() ?? '';
    final rawReactions = json['reactions'];
    final Map<String, String> reactions = {};
    if (rawReactions is Map) {
      rawReactions.forEach((k, v) => reactions[k.toString()] = v.toString());
    } else if (rawReactions is List) {
      for (final r in rawReactions) {
        if (r is Map && r['emoji'] != null && r['user_id'] != null) {
          reactions[r['user_id'].toString()] = r['emoji'].toString();
        }
      }
    }
    final readByRaw = json['read_by'];
    final List<String> readBy = readByRaw is List
        ? readByRaw.map((e) => e.toString()).toList()
        : const [];
    return MessageModel(
      id: json['id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      senderId: senderId,
      senderName: json['sender_name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      mediaUrl: json['media_url']?.toString(),
      mediaThumb: json['media_thumbnail']?.toString(),
      duration: _intOrNull(json['duration']),
      replyToId: json['reply_to']?.toString(),
      replyPreview: json['reply_preview']?.toString(),
      forwardedFrom: json['forwarded_from']?.toString(),
      edited: json['edited'] == 1 || json['edited'] == true,
      deletedForAll: json['deleted_for_all'] == 1 || json['deleted_for_all'] == true,
      starred: json['starred'] == 1 || json['starred'] == true,
      pinned: json['pinned'] == 1 || json['pinned'] == true,
      reactions: reactions,
      readBy: readBy,
      delivered: json['delivered'] == 1 || json['delivered'] == true,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      isMine: senderId == currentUserId,
    );
  }

  MessageModel copyWith({
    String? content,
    bool? edited,
    bool? starred,
    bool? pinned,
    Map<String, String>? reactions,
    List<String>? readBy,
  }) =>
      MessageModel(
        id: id,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content ?? this.content,
        type: type,
        mediaUrl: mediaUrl,
        mediaThumb: mediaThumb,
        duration: duration,
        replyToId: replyToId,
        replyPreview: replyPreview,
        forwardedFrom: forwardedFrom,
        edited: edited ?? this.edited,
        deletedForAll: deletedForAll,
        starred: starred ?? this.starred,
        pinned: pinned ?? this.pinned,
        reactions: reactions ?? this.reactions,
        readBy: readBy ?? this.readBy,
        delivered: delivered,
        createdAt: createdAt,
        isMine: isMine,
      );
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

int? _intOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse('$v');
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  return null;
}

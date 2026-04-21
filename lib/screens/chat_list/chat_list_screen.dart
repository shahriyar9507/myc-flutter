import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/myc_logo.dart';
import '../../services/chat_service.dart';
import '../../services/api_client.dart';
import '../../services/realtime_service.dart';
import '../../services/secure_storage.dart';
import '../../models/chat_models.dart';
import '../chat_thread/chat_thread_screen.dart';
import 'search_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final Map<String, StreamSubscription> _chatSubs = {};
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _userId = await SecureStorage.readUserId();
      if (!mounted) return;
      await context.read<ChatService>().fetchChats();
      _wireRtdb();
    });
  }

  void _wireRtdb() {
    final svc = context.read<ChatService>();
    for (final c in svc.chats) {
      if (_chatSubs.containsKey(c.id)) continue;
      _chatSubs[c.id] = RealtimeService.instance.chatLastUpdate(c.id).listen((_) {
        if (mounted) svc.fetchChats(hideLoader: true);
      });
    }
    if (_userId != null) RealtimeService.instance.setPresence(_userId!, true);
  }

  @override
  void dispose() {
    for (final s in _chatSubs.values) { s.cancel(); }
    _chatSubs.clear();
    if (_userId != null) RealtimeService.instance.setPresence(_userId!, false);
    super.dispose();
  }

  Future<void> _longPressActions(ChatModel chat) async {
    final action = await showModalBottomSheet<String>(
      context: context, backgroundColor: MyCColors.darkCard,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: Icon(chat.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.white),
          title: Text(chat.pinned ? 'Unpin chat' : 'Pin chat', style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, 'pin'),
        ),
        ListTile(
          leading: const Icon(Icons.volume_off, color: Colors.white),
          title: Text(chat.mutedUntil != null ? 'Unmute' : 'Mute', style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, 'mute'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: Colors.white),
          title: const Text('Custom notifications', style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, 'notify'),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
          title: const Text('Delete chat', style: TextStyle(color: Colors.redAccent)),
          onTap: () => Navigator.pop(context, 'delete'),
        ),
      ]),
    );
    if (action == null || !mounted) return;
    final api = ApiClient.instance;
    switch (action) {
      case 'pin':
        await api.chatPin(chat.id, !chat.pinned);
        break;
      case 'mute':
        if (chat.mutedUntil != null) {
          await api.chatMute(chat.id, hours: 0);
        } else {
          final hours = await _pickMuteHours();
          if (hours != null) await api.chatMute(chat.id, hours: hours, indefinite: hours < 0);
        }
        break;
      case 'notify':
        if (mounted) Navigator.pushNamed(context, '/chat-notify', arguments: chat.id);
        break;
      case 'delete':
        // Delete chat endpoint not wired here; stub
        break;
    }
    if (mounted) context.read<ChatService>().fetchChats(hideLoader: true);
  }

  Future<int?> _pickMuteHours() => showModalBottomSheet<int>(
    context: context, backgroundColor: MyCColors.darkCard,
    builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
      for (final opt in const [[1, '1 hour'], [8, '8 hours'], [168, '1 week'], [-1, 'Always']])
        ListTile(title: Text(opt[1] as String, style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, opt[0] as int)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final chatService = context.watch<ChatService>();

    // Make sure new chats get their RTDB subscription.
    for (final c in chatService.chats) {
      if (!_chatSubs.containsKey(c.id)) {
        _chatSubs[c.id] = RealtimeService.instance.chatLastUpdate(c.id).listen((_) {
          if (mounted) context.read<ChatService>().fetchChats(hideLoader: true);
        });
      }
    }

    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const MyCWordmark(size: 20, color: Colors.white, markColor: MyCColors.accent),
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: _glassButton(Icons.search),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewChatScreen())).then((_) {
                    if (context.mounted) context.read<ChatService>().fetchChats();
                  }),
                  child: _glassButton(Icons.edit_square),
                ),
              ])
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Chats',
              style: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1)),
          ),
          // Stories rail
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _addStoryBtn(),
                _storyAvatar('Maya', 'M', true),
                _storyAvatar('Kai', 'K', false),
                _storyAvatar('Jordan', 'J', true),
                _storyAvatar('Alex', 'A', false),
              ],
            ),
          ),
          Expanded(
            child: chatService.isLoading
              ? const Center(child: CircularProgressIndicator(color: MyCColors.accent))
              : chatService.chats.isEmpty
                ? Center(child: Text('No chats yet', style: GoogleFonts.inter(color: Colors.white54)))
                : RefreshIndicator(
                    onRefresh: () => chatService.fetchChats(),
                    color: MyCColors.accent,
                    backgroundColor: MyCColors.darkCard,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: chatService.chats.length,
                      itemBuilder: (context, index) {
                        final chat = chatService.chats[index];
                        return _chatRow(chat);
                      },
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _chatRow(ChatModel chat) {
    final muted = chat.mutedUntil != null;
    final msg = chat.lastMessage.isEmpty ? 'No messages' : chat.lastMessage;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatThreadScreen(
          chatId: chat.id, name: chat.name, themeId: chat.theme,
          online: chat.isOnline, peerId: chat.peerId,
        ),
      )).then((_) {
        if (mounted) context.read<ChatService>().fetchChats(hideLoader: true);
      }),
      onLongPress: () => _longPressActions(chat),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          Stack(children: [
            Container(width: 54, height: 54,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(colors: [MyCColors.accent.withValues(alpha: 0.5), MyCColors.pink.withValues(alpha: 0.5)])),
              child: Center(child: Text(chat.name.isNotEmpty ? chat.name[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            ),
            if (chat.isOnline) Positioned(bottom: 0, right: 0, child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(color: MyCColors.online, shape: BoxShape.circle,
                border: Border.all(color: MyCColors.darkBg, width: 2)))),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (chat.pinned) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.push_pin, size: 12, color: Colors.white54)),
              Expanded(child: Text(chat.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700))),
              if (muted) const Icon(Icons.volume_off, size: 14, color: Colors.white38),
            ]),
            const SizedBox(height: 4),
            Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: chat.unreadCount > 0 ? Colors.white : MyCColors.darkMuted,
                fontSize: 14,
                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
              )),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_formatTime(chat.updatedAt),
              style: GoogleFonts.inter(color: chat.unreadCount > 0 ? MyCColors.accent : MyCColors.darkMuted, fontSize: 12)),
            const SizedBox(height: 6),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(gradient: MyCColors.accentGradient, borderRadius: BorderRadius.circular(10)),
                child: Text('${chat.unreadCount}', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            else const SizedBox(height: 20),
          ]),
        ]),
      ),
    );
  }

  String _formatTime(String iso) {
    if (iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final now = DateTime.now();
    if (now.difference(d).inDays == 0) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    if (now.difference(d).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[d.weekday - 1];
    }
    return '${d.day}/${d.month}';
  }

  Widget _glassButton(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  Widget _addStoryBtn() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/stories/new'),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
          child: const Center(child: Icon(Icons.add, color: MyCColors.accent)),
        ),
        const SizedBox(height: 6),
        Text('Your story', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
      ]),
    ),
  );

  Widget _storyAvatar(String name, String initial, bool unseen) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: unseen ? MyCColors.pinkGradient : null, color: unseen ? null : Colors.white24),
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: MyCColors.darkBg),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20))),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 12,
        fontWeight: unseen ? FontWeight.bold : FontWeight.normal)),
    ]),
  );
}

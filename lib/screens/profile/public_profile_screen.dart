import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../chat_thread/chat_thread_screen.dart';

class PublicProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const PublicProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse('${user['id']}') ?? 0;
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) async {
              if (v == 'block') {
                await ApiClient.instance.blockUser(id);
                if (context.mounted) Navigator.pop(context);
              } else if (v == 'contact') {
                await ApiClient.instance.contactAdd(id);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact added')));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'contact', child: Text('Add to contacts')),
              PopupMenuItem(value: 'block', child: Text('Block user')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
            backgroundColor: MyCColors.accent.withValues(alpha: 0.3),
            child: user['avatar'] == null ? Text('${user['name']?[0] ?? '?'}', style: const TextStyle(fontSize: 40, color: Colors.white)) : null,
          ),
          const SizedBox(height: 16),
          Text(user['name']?.toString() ?? '', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          Text('@${user['username']}', style: GoogleFonts.inter(color: Colors.white54)),
          if (user['bio'] != null) ...[
            const SizedBox(height: 12),
            Text(user['bio'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text('Message'),
            style: ElevatedButton.styleFrom(backgroundColor: MyCColors.accent, minimumSize: const Size(220, 44)),
            onPressed: () async {
              final chatId = await context.read<ChatService>().createChat(type: 'private', userId: id);
              if (chatId == null || !context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => ChatThreadScreen(
                  chatId: chatId, name: user['name']?.toString() ?? '',
                  themeId: 'aurora', online: user['is_online'] == true,
                ),
              ));
            },
          ),
        ]),
      ),
    );
  }
}

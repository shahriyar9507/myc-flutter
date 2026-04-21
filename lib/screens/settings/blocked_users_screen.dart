import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});
  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.blockList();
    if (!mounted) return;
    setState(() {
      _users = ((r['data']?['users'] as List?) ?? const [])
          .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Blocked users', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(child: Text('No blocked users', style: GoogleFonts.inter(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (_, i) {
                    final u = _users[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: u['avatar'] != null ? NetworkImage(u['avatar']) : null,
                        child: u['avatar'] == null ? Text('${u['name']?[0] ?? '?'}') : null,
                      ),
                      title: Text(u['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('@${u['username']}', style: const TextStyle(color: Colors.white54)),
                      trailing: TextButton(
                        child: const Text('Unblock'),
                        onPressed: () async {
                          await ApiClient.instance.unblockUser(int.tryParse('${u['id']}') ?? 0);
                          _load();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

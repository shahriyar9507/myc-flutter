import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../profile/public_profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final bool forChat;
  const UserSearchScreen({super.key, this.forChat = false});
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _c = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) { setState(() => _results = []); return; }
    setState(() => _loading = true);
    final r = await ApiClient.instance.profileSearch(q.trim());
    if (!mounted) return;
    setState(() {
      _results = ((r['data']?['users'] as List?) ?? const [])
          .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
      _loading = false;
    });
  }

  @override
  void dispose() { _debounce?.cancel(); _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: TextField(
          controller: _c, autofocus: true, onChanged: _onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Search users…', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(child: Text('No results', style: GoogleFonts.inter(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final u = _results[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: u['avatar'] != null ? NetworkImage(u['avatar']) : null,
                        backgroundColor: MyCColors.accent.withValues(alpha: 0.3),
                        child: u['avatar'] == null ? Text('${u['name']?[0] ?? '?'}') : null,
                      ),
                      title: Text(u['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('@${u['username']}', style: const TextStyle(color: Colors.white54)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(user: u),
                      )),
                    );
                  },
                ),
    );
  }
}

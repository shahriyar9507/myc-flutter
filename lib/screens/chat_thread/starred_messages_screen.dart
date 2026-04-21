import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';

class StarredMessagesScreen extends StatefulWidget {
  const StarredMessagesScreen({super.key});
  @override
  State<StarredMessagesScreen> createState() => _StarredMessagesScreenState();
}

class _StarredMessagesScreenState extends State<StarredMessagesScreen> {
  List<Map<String, dynamic>> _msgs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.starredList();
    if (!mounted) return;
    setState(() {
      _msgs = ((r['data']?['messages'] as List?) ?? const [])
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
        title: Text('Starred', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _msgs.isEmpty ? Center(child: Text('No starred messages', style: GoogleFonts.inter(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) {
                    final m = _msgs[i];
                    return ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text(m['content']?.toString() ?? '[${m['type']}]',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${m['sender_name'] ?? ''} · ${m['chat_name'] ?? ''}',
                          style: const TextStyle(color: Colors.white54)),
                    );
                  },
                ),
    );
  }
}

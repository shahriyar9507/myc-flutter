import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../user_search/user_search_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.contactList();
    if (!mounted) return;
    final list = ((r['data']?['contacts'] as List?) ?? const [])
        .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
    list.sort((a, b) {
      final fa = (a['favorite'] == true || a['favorite'] == 1) ? 0 : 1;
      final fb = (b['favorite'] == true || b['favorite'] == 1) ? 0 : 1;
      if (fa != fb) return fa.compareTo(fb);
      return (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? '');
    });
    setState(() { _contacts = list; _loading = false; });
  }

  Future<void> _toggleFavorite(Map<String, dynamic> c) async {
    final fav = !(c['favorite'] == true || c['favorite'] == 1);
    await ApiClient.instance.contactFavorite(int.tryParse('${c['id']}') ?? 0, fav);
    _load();
  }

  Future<void> _remove(Map<String, dynamic> c) async {
    await ApiClient.instance.contactRemove(int.tryParse('${c['id']}') ?? 0);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Contacts', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen()));
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? Center(child: Text('No contacts', style: GoogleFonts.inter(color: Colors.white54)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (_, i) {
                      final c = _contacts[i];
                      final fav = c['favorite'] == true || c['favorite'] == 1;
                      return Dismissible(
                        key: Key('contact_${c['id']}'),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) => _remove(c),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: c['avatar'] != null ? NetworkImage(c['avatar']) : null,
                            child: c['avatar'] == null ? Text('${c['name']?[0] ?? '?'}') : null,
                          ),
                          title: Text(c['nickname']?.toString() ?? c['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                          subtitle: Text('@${c['username']}', style: const TextStyle(color: Colors.white54)),
                          trailing: IconButton(
                            icon: Icon(fav ? Icons.star : Icons.star_border, color: fav ? Colors.amber : Colors.white54),
                            onPressed: () => _toggleFavorite(c),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});
  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  List<Map<String, dynamic>> _contacts = [];
  final Set<int> _selected = {};
  bool _busy = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.contactList();
    setState(() => _contacts = ((r['data']?['contacts'] as List?) ?? const [])
        .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList());
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty || _selected.isEmpty) return;
    setState(() => _busy = true);
    final r = await ApiClient.instance.chatCreate(
      type: 'group', name: _name.text.trim(), members: _selected.toList(),
    );
    setState(() => _busy = false);
    if (r['success'] == true && mounted) Navigator.pop(context, r['data']?['chat_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('New group', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _busy ? null : _create,
            child: Text('Create', style: GoogleFonts.inter(color: MyCColors.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _name, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Group name', labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: _desc, style: const TextStyle(color: Colors.white), maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description (optional)', labelStyle: TextStyle(color: Colors.white54))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _contacts.length,
            itemBuilder: (_, i) {
              final c = _contacts[i];
              final id = int.tryParse('${c['id']}') ?? 0;
              final sel = _selected.contains(id);
              return CheckboxListTile(
                value: sel, activeColor: MyCColors.accent,
                onChanged: (v) => setState(() => v == true ? _selected.add(id) : _selected.remove(id)),
                title: Text(c['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text('@${c['username']}', style: const TextStyle(color: Colors.white54)),
                secondary: CircleAvatar(
                  backgroundImage: c['avatar'] != null ? NetworkImage(c['avatar']) : null,
                  child: c['avatar'] == null ? Text('${c['name']?[0] ?? '?'}') : null,
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

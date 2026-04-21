import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';

/// Group info: rename, description, member add/remove, admin toggle, nicknames.
class GroupInfoScreen extends StatefulWidget {
  final String chatId;
  const GroupInfoScreen({super.key, required this.chatId});
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  Map<String, dynamic> _chat = {};
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.chatGet(widget.chatId);
    if (!mounted) return;
    setState(() {
      _chat = (r['data']?['chat'] as Map?)?.cast<String, dynamic>() ?? {};
      _members = ((_chat['members'] as List?) ?? const [])
          .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
      _loading = false;
    });
  }

  Future<void> _rename() async {
    final ctl = TextEditingController(text: _chat['name']?.toString() ?? '');
    final v = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MyCColors.darkCard,
        title: const Text('Rename group', style: TextStyle(color: Colors.white)),
        content: TextField(controller: ctl, autofocus: true, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Save')),
        ],
      ),
    );
    if (v != null && v.trim().isNotEmpty) {
      await ApiClient.instance.groupUpdate(widget.chatId, {'name': v.trim()});
      _load();
    }
  }

  Future<void> _editDescription() async {
    final ctl = TextEditingController(text: _chat['description']?.toString() ?? '');
    final v = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MyCColors.darkCard,
        title: const Text('Description', style: TextStyle(color: Colors.white)),
        content: TextField(controller: ctl, maxLines: 4, autofocus: true, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Save')),
        ],
      ),
    );
    if (v != null) {
      await ApiClient.instance.groupUpdate(widget.chatId, {'description': v});
      _load();
    }
  }

  Future<void> _memberAction(Map<String, dynamic> m) async {
    final isAdmin = m['is_admin'] == true || m['is_admin'] == 1;
    final id = m['id']?.toString() ?? '';
    final action = await showModalBottomSheet<String>(
      context: context, backgroundColor: MyCColors.darkCard,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: Icon(isAdmin ? Icons.remove_moderator : Icons.admin_panel_settings, color: Colors.white),
          title: Text(isAdmin ? 'Revoke admin' : 'Make admin', style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, 'admin'),
        ),
        ListTile(
          leading: const Icon(Icons.badge, color: Colors.white),
          title: const Text('Set nickname', style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, 'nick'),
        ),
        ListTile(
          leading: const Icon(Icons.person_remove, color: Colors.redAccent),
          title: const Text('Remove from group', style: TextStyle(color: Colors.redAccent)),
          onTap: () => Navigator.pop(context, 'remove'),
        ),
      ]),
    );
    if (action == null || !mounted) return;
    if (action == 'admin') {
      await ApiClient.instance.groupSetAdmin(widget.chatId, id, !isAdmin);
    } else if (action == 'remove') {
      await ApiClient.instance.groupRemoveMember(widget.chatId, id);
    } else if (action == 'nick') {
      final ctl = TextEditingController(text: m['nickname']?.toString() ?? '');
      final v = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: MyCColors.darkCard,
          title: const Text('Nickname', style: TextStyle(color: Colors.white)),
          content: TextField(controller: ctl, autofocus: true, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Save')),
          ],
        ),
      );
      if (v != null) await ApiClient.instance.groupSetNickname(widget.chatId, id, v);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: MyCColors.darkBg, body: Center(child: CircularProgressIndicator()));
    final name = _chat['name']?.toString() ?? 'Group';
    final desc = _chat['description']?.toString() ?? '';
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Group info', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: ListView(children: [
        const SizedBox(height: 16),
        Center(child: CircleAvatar(radius: 48, backgroundColor: MyCColors.accent,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 40, color: Colors.white)))),
        const SizedBox(height: 12),
        ListTile(
          title: Text(name, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.edit, color: Colors.white54), onTap: _rename,
        ),
        ListTile(
          title: const Text('Description', style: TextStyle(color: Colors.white54)),
          subtitle: Text(desc.isEmpty ? 'Add a description…' : desc, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.edit, color: Colors.white54), onTap: _editDescription,
        ),
        const Divider(color: Colors.white12),
        ListTile(
          leading: const Icon(Icons.wallpaper, color: Colors.white),
          title: const Text('Chat wallpaper', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          onTap: () => Navigator.pushNamed(context, '/settings/appearance'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: Colors.white),
          title: const Text('Custom notifications', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          onTap: () => Navigator.pushNamed(context, '/chat-notify', arguments: widget.chatId),
        ),
        const Divider(color: Colors.white12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('${_members.length} members',
              style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
        ),
        for (final m in _members) ListTile(
          leading: CircleAvatar(child: Text('${m['name']?.toString().isNotEmpty == true ? m['name'][0].toString().toUpperCase() : '?'}')),
          title: Text(m['nickname']?.toString().isNotEmpty == true ? '${m['nickname']} (${m['name']})' : (m['name']?.toString() ?? ''),
              style: const TextStyle(color: Colors.white)),
          subtitle: Text('@${m['username'] ?? ''}', style: const TextStyle(color: Colors.white54)),
          trailing: (m['is_admin'] == true || m['is_admin'] == 1)
              ? const Chip(label: Text('Admin'), backgroundColor: MyCColors.accent) : null,
          onTap: () => _memberAction(m),
        ),
      ]),
    );
  }
}

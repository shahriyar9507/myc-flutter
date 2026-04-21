import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';

class ChatNotifyScreen extends StatefulWidget {
  final String chatId;
  const ChatNotifyScreen({super.key, required this.chatId});
  @override
  State<ChatNotifyScreen> createState() => _ChatNotifyScreenState();
}

class _ChatNotifyScreenState extends State<ChatNotifyScreen> {
  Map<String, dynamic> _s = {};
  bool _loaded = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.settingsGet();
    final overrides = (r['data']?['chat_overrides'] as Map?) ?? {};
    final o = overrides[widget.chatId] ?? {};
    if (!mounted) return;
    setState(() { _s = (o as Map).cast<String, dynamic>(); _loaded = true; });
  }

  Future<void> _save(Map<String, dynamic> patch) async {
    setState(() => _s.addAll(patch));
    await ApiClient.instance.settingsChatOverride(widget.chatId, _s);
  }

  bool _b(String key, [bool def = true]) => _s[key] == true || _s[key] == 1 || (_s[key] == null ? def : false);
  String _s_(String key, String def) => (_s[key] ?? def).toString();

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Chat notifications', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: ListView(children: [
        ListTile(
          title: const Text('Mute', style: TextStyle(color: Colors.white)),
          subtitle: Text(_s['muted_until'] ?? 'Off', style: const TextStyle(color: Colors.white54)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          onTap: () async {
            final v = await showModalBottomSheet<int>(
              context: context, backgroundColor: MyCColors.darkCard,
              builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(title: const Text('Unmute', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 0)),
                ListTile(title: const Text('1 hour', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 1)),
                ListTile(title: const Text('8 hours', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 8)),
                ListTile(title: const Text('1 week', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 168)),
                ListTile(title: const Text('Indefinite', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, -1)),
              ]),
            );
            if (v != null) {
              if (v == 0) _save({'muted_until': null});
              else if (v == -1) _save({'muted_until': 'indefinite'});
              else _save({'muted_until': DateTime.now().add(Duration(hours: v)).toIso8601String()});
            }
          },
        ),
        SwitchListTile(
          title: const Text('Show preview', style: TextStyle(color: Colors.white)),
          value: _b('show_preview'), onChanged: (v) => _save({'show_preview': v})),
        SwitchListTile(
          title: const Text('Show on lockscreen', style: TextStyle(color: Colors.white)),
          value: _b('show_on_lockscreen'), onChanged: (v) => _save({'show_on_lockscreen': v})),
        SwitchListTile(
          title: const Text('Mentions only', style: TextStyle(color: Colors.white)),
          value: _b('mentions_only', false), onChanged: (v) => _save({'mentions_only': v})),
        ListTile(
          title: const Text('Vibration', style: TextStyle(color: Colors.white)),
          subtitle: Text(_s_('vibration', 'default'), style: const TextStyle(color: Colors.white54)),
          onTap: () => _choose('vibration', ['default', 'off', 'short', 'long', 'pattern']),
        ),
        ListTile(
          title: const Text('Popup mode', style: TextStyle(color: Colors.white)),
          subtitle: Text(_s_('popup_mode', 'screen_on'), style: const TextStyle(color: Colors.white54)),
          onTap: () => _choose('popup_mode', ['always', 'screen_on', 'never']),
        ),
        ListTile(
          title: const Text('Priority', style: TextStyle(color: Colors.white)),
          subtitle: Text(_s_('priority', 'high'), style: const TextStyle(color: Colors.white54)),
          onTap: () => _choose('priority', ['high', 'normal', 'low']),
        ),
      ]),
    );
  }

  Future<void> _choose(String key, List<String> options) async {
    final v = await showModalBottomSheet<String>(
      context: context, backgroundColor: MyCColors.darkCard,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        for (final o in options) ListTile(
          title: Text(o, style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, o),
        ),
      ]),
    );
    if (v != null) _save({key: v});
  }
}

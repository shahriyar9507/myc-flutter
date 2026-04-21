import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import 'call_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});
  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<Map<String, dynamic>> _calls = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.callHistory();
    if (!mounted) return;
    setState(() {
      _calls = ((r['data']?['calls'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered =>
      _filter == 'missed' ? _calls.where((c) => c['status'] == 'missed').toList() : _calls;

  void _place(Map<String, dynamic> c) {
    final chatId = c['chat_id']?.toString() ?? '';
    final name = c['peer_name']?.toString() ?? c['name']?.toString() ?? 'Unknown';
    final type = c['type']?.toString() ?? 'voice';
    if (chatId.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CallScreen(chatId: chatId, peerName: name, type: type),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Calls',
                      style: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _load,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                _chip('All', 'all'),
                const SizedBox(width: 8),
                _chip('Missed', 'missed'),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: MyCColors.accent))
                  : _filtered.isEmpty
                      ? Center(child: Text('No calls yet',
                          style: GoogleFonts.inter(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _row(_filtered[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final sel = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.inter(color: sel ? Colors.black : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _row(Map<String, dynamic> c) {
    final name = c['peer_name']?.toString() ?? c['name']?.toString() ?? 'Unknown';
    final status = c['status']?.toString() ?? 'ended';
    final isMissed = status == 'missed' || status == 'declined';
    final isVideo = (c['type']?.toString() ?? 'voice') == 'video';
    final isOutgoing = c['outgoing'] == true || c['direction'] == 'outgoing';
    final time = c['started_at']?.toString() ?? '';
    final duration = c['duration'] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [MyCColors.accent.withValues(alpha: 0.4), MyCColors.pink.withValues(alpha: 0.4)]),
          ),
          child: Center(child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.spaceGrotesk(color: isMissed ? MyCColors.error : Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(isMissed ? Icons.call_missed : (isOutgoing ? Icons.call_made : Icons.call_received),
                  color: isMissed ? MyCColors.error : MyCColors.darkMuted, size: 14),
              const SizedBox(width: 4),
              Text('$time${duration > 0 ? " · ${duration}s" : ""}',
                  style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13)),
            ]),
          ]),
        ),
        IconButton(
          icon: Icon(isVideo ? Icons.videocam : Icons.phone, color: MyCColors.accent),
          onPressed: () => _place(c),
        ),
      ]),
    );
  }
}

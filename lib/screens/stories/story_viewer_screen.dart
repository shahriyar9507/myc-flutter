import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../../services/secure_storage.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  const StoryViewerScreen({super.key, required this.stories});
  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _index = 0;
  Timer? _timer;
  double _progress = 0;
  String? _meId;
  bool _showViewers = false;

  @override
  void initState() {
    super.initState();
    SecureStorage.readUserId().then((v) => setState(() => _meId = v));
    _advance();
  }

  void _advance() {
    _timer?.cancel();
    _progress = 0;
    final id = widget.stories[_index]['id']?.toString();
    if (id != null) ApiClient.instance.storyView(id);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() => _progress += 0.01);
      if (_progress >= 1) {
        if (_index < widget.stories.length - 1) { setState(() => _index++); _advance(); }
        else { _timer?.cancel(); Navigator.pop(context); }
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _delete() async {
    final id = widget.stories[_index]['id']?.toString();
    if (id == null) return;
    await ApiClient.instance.storyDelete(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stories[_index];
    final media = s['media_url']?.toString();
    final name = s['user_name']?.toString() ?? '';
    final userId = s['user_id']?.toString() ?? '';
    final isMine = _meId != null && _meId == userId;
    final viewers = (s['viewers'] as List?) ?? const [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (d) {
            final w = MediaQuery.of(context).size.width;
            if (d.localPosition.dx < w / 3) {
              if (_index > 0) { setState(() => _index--); _advance(); }
            } else {
              if (_index < widget.stories.length - 1) { setState(() => _index++); _advance(); }
              else { Navigator.pop(context); }
            }
          },
          child: Stack(children: [
            Positioned.fill(child: media != null
                ? Image.network(media, fit: BoxFit.contain)
                : Container(color: MyCColors.darkCard, child: Center(
                    child: Text(s['content']?.toString() ?? '', style: GoogleFonts.inter(color: Colors.white, fontSize: 22))))),
            Positioned(
              top: 12, left: 12, right: 12,
              child: Column(children: [
                Row(children: [
                  for (int i = 0; i < widget.stories.length; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Expanded(child: LinearProgressIndicator(
                      value: i < _index ? 1 : (i == _index ? _progress : 0),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    )),
                  ],
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
                  const SizedBox(width: 8),
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (isMine) IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: _delete),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ]),
              ]),
            ),
            if (isMine) Positioned(
              bottom: 20, left: 0, right: 0,
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showViewers = !_showViewers),
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  label: Text('${viewers.length} views', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            if (_showViewers && isMine) Positioned(
              bottom: 60, left: 16, right: 16,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(color: MyCColors.darkCard, borderRadius: BorderRadius.circular(16)),
                child: ListView(
                  shrinkWrap: true,
                  children: [for (final v in viewers) ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(v is Map ? (v['name']?.toString() ?? 'Unknown') : v.toString(),
                      style: const TextStyle(color: Colors.white)),
                    subtitle: v is Map && v['viewed_at'] != null
                      ? Text(v['viewed_at'].toString(), style: const TextStyle(color: Colors.white54))
                      : null,
                  )],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

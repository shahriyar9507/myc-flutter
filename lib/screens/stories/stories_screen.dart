import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../widgets/myc_logo.dart';
import '../../services/api_client.dart';
import 'story_viewer_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<Map<String, dynamic>> _stories = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.storyList();
    if (!mounted) return;
    setState(() {
      _stories = ((r['data']?['stories'] as List?) ?? const [])
          .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
      _loading = false;
    });
  }

  /// Group stories by author so each avatar represents one user's story set.
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final out = <String, List<Map<String, dynamic>>>{};
    for (final s in _stories) {
      final uid = s['user_id']?.toString() ?? 'unknown';
      out.putIfAbsent(uid, () => []).add(s);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Stories', style: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1)),
              const MyCWordmark(size: 16, color: Colors.white, showMark: false),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: MyCColors.accent))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: MyCColors.accent, backgroundColor: MyCColors.darkCard,
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.7,
                    children: [
                      _addStoryCard(),
                      for (final entry in grouped.entries)
                        _storyCard(entry.value),
                    ],
                  ),
                ),
          ),
        ]),
      ),
    );
  }

  Widget _addStoryCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/stories/new').then((_) => _load()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 56, height: 56,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: MyCColors.accentGradient),
            child: const Icon(Icons.add, color: Colors.white, size: 28)),
          const SizedBox(height: 16),
          Text('Share a\nmoment', textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Visible for 24h', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _storyCard(List<Map<String, dynamic>> items) {
    final first = items.first;
    final name = first['user_name']?.toString() ?? 'Unknown';
    final createdAt = DateTime.tryParse(first['created_at']?.toString() ?? '');
    final ago = createdAt != null ? _timeAgo(DateTime.now().difference(createdAt)) : '';
    final media = first['media_url']?.toString();
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => StoryViewerScreen(stories: items),
      )).then((_) => _load()),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: media != null
              ? DecorationImage(image: NetworkImage(media), fit: BoxFit.cover)
              : null,
          gradient: media == null
              ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [MyCColors.accent, MyCColors.pink])
              : null,
        ),
        child: Stack(children: [
          Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.2), Colors.transparent, Colors.black.withValues(alpha: 0.7)]),
          )),
          Positioned(
            top: 12, left: 12, right: 12,
            child: Row(children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(child: Container(height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(1.5)))),
              ],
            ]),
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Row(children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.3)),
                child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(ago, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
              ])),
            ]),
          ),
        ]),
      ),
    );
  }

  String _timeAgo(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

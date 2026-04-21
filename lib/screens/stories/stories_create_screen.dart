import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/media_helpers.dart';

class StoriesCreateScreen extends StatefulWidget {
  const StoriesCreateScreen({super.key});
  @override
  State<StoriesCreateScreen> createState() => _StoriesCreateScreenState();
}

class _StoriesCreateScreenState extends State<StoriesCreateScreen> {
  String _mode = 'text'; // text | image | video
  String? _mediaUrl;
  final _caption = TextEditingController();
  Color _bg = Colors.deepPurple;
  Color _fg = Colors.white;
  String _privacy = 'public'; // public | contacts | close_friends
  bool _saving = false;

  final _palette = [Colors.deepPurple, Colors.teal, Colors.pink, Colors.orange, Colors.black, Colors.indigo];

  Future<void> _pick(ImageSource src, String kind) async {
    final picker = ImagePicker();
    final x = kind == 'image'
        ? await picker.pickImage(source: src, imageQuality: 85)
        : await picker.pickVideo(source: src);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final typed = kind == 'image' ? await MediaHelpers.compressImage(bytes) : bytes;
    if (!MediaHelpers.withinLimit(typed.length, kind)) {
      _snack('File too large'); return;
    }
    final up = await ChatService().uploadMedia(typed, x.name, kind);
    if (up != null && up['url'] != null) {
      setState(() { _mediaUrl = up['url']; _mode = kind; });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final r = await ApiClient.instance.storyCreate({
      'type': _mode,
      if (_mediaUrl != null) 'media_url': _mediaUrl,
      'caption': _caption.text,
      'bg_color': '#${_bg.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'text_color': '#${_fg.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'privacy': _privacy,
    });
    setState(() => _saving = false);
    if (!mounted) return;
    if (r['success'] == true) { Navigator.pop(context, true); }
    else { _snack(r['error']?.toString() ?? 'Failed'); }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.lock_outline, color: Colors.white),
            onSelected: (v) => setState(() => _privacy = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'public', child: Text('Public')),
              PopupMenuItem(value: 'contacts', child: Text('Contacts')),
              PopupMenuItem(value: 'close_friends', child: Text('Close friends')),
            ],
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const CircularProgressIndicator(color: Colors.white)
                : Text('Share', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: _mediaUrl != null
                ? Image.network(_mediaUrl!, fit: BoxFit.contain)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      controller: _caption,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _fg, fontSize: 30, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'Type something…',
                        hintStyle: TextStyle(color: _fg.withValues(alpha: 0.6), fontSize: 24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
          ),
        ),
        if (_mediaUrl != null) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _caption, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Add a caption…', hintStyle: TextStyle(color: Colors.white54)),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              IconButton(icon: const Icon(Icons.image, color: Colors.white), onPressed: () => _pick(ImageSource.gallery, 'image')),
              IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: () => _pick(ImageSource.gallery, 'video')),
              IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: () => _pick(ImageSource.camera, 'image')),
              const SizedBox(width: 12),
              for (final c in _palette)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _bg = c),
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white24))),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

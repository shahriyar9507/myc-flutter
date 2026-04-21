import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';

/// AI palette generator — user types a prompt, backend returns 4 colors
/// (primary, accent, bubble, background). We save, apply, delete palettes.
class PaletteScreen extends StatefulWidget {
  const PaletteScreen({super.key});
  @override
  State<PaletteScreen> createState() => _PaletteScreenState();
}

class _PaletteScreenState extends State<PaletteScreen> {
  final _prompt = TextEditingController();
  List<Map<String, dynamic>> _palettes = [];
  bool _busy = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.paletteList();
    if (!mounted) return;
    setState(() {
      _palettes = ((r['data']?['palettes'] as List?) ?? const [])
          .whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
    });
  }

  Future<void> _generate() async {
    if (_prompt.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final r = await ApiClient.instance.paletteSave({'prompt': _prompt.text.trim()});
    setState(() => _busy = false);
    if (r['success'] == true) { _prompt.clear(); _load(); }
    else if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['error']?.toString() ?? 'Failed')));
  }

  Color _hex(String h) {
    final s = h.replaceFirst('#', '');
    return Color(int.parse('ff$s', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('AI palettes', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _prompt,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe a mood, e.g. "sunset on mars"',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            )),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MyCColors.accent),
              onPressed: _busy ? null : _generate,
              child: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Generate'),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _palettes.length,
            itemBuilder: (_, i) {
              final p = _palettes[i];
              final colors = [p['primary'], p['accent'], p['bubble'], p['background']]
                  .where((c) => c != null).map((c) => _hex('$c')).toList();
              return ListTile(
                title: Text(p['name']?.toString() ?? p['prompt']?.toString() ?? 'Palette',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Row(children: [
                  for (final c in colors) Container(
                    width: 24, height: 24, margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                  ),
                ]),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: MyCColors.accent),
                    onPressed: () async {
                      await ApiClient.instance.paletteApply('${p['id']}');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied')));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white54),
                    onPressed: () async {
                      await ApiClient.instance.paletteDelete('${p['id']}');
                      _load();
                    },
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

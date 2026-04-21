import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/settings_service.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = [
    ['en', 'English'],
    ['es', 'Español'],
    ['fr', 'Français'],
    ['de', 'Deutsch'],
    ['pt', 'Português'],
    ['it', 'Italiano'],
    ['ru', 'Русский'],
    ['hi', 'हिन्दी'],
    ['bn', 'বাংলা'],
    ['ar', 'العربية'],
    ['zh', '中文'],
    ['ja', '日本語'],
    ['ko', '한국어'],
    ['tr', 'Türkçe'],
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsService>();
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Language', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              for (int i = 0; i < _languages.length; i++) ...[
                if (i > 0) Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                ListTile(
                  title: Text(_languages[i][1], style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
                  subtitle: Text(_languages[i][0].toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: s.language == _languages[i][0] ? const Icon(Icons.check, color: MyCColors.accent) : null,
                  onTap: () => s.save({'language': _languages[i][0]}),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

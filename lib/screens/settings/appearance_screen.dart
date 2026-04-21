import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/settings_service.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsService>();
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Appearance', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('THEME', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 12),
        _card([
          for (final opt in const [['system', 'System default'], ['light', 'Light mode'], ['dark', 'Dark mode']])
            RadioListTile<String>(
              title: Text(opt[1], style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
              value: opt[0], groupValue: s.themeMode, activeColor: MyCColors.accent,
              onChanged: (v) { if (v != null) s.save({'theme_mode': v}); },
            ),
        ]),
        const SizedBox(height: 28),
        Text('TEXT', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 12),
        _card([
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Message text size', style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('${s.fontSize.round()}px', style: const TextStyle(color: MyCColors.accent, fontWeight: FontWeight.w600)),
              ]),
              Slider(
                value: s.fontSize.clamp(12, 22),
                min: 12, max: 22, divisions: 10,
                activeColor: MyCColors.accent,
                onChanged: (v) => s.save({'font_size': v}),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 28),
        _card([
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Colors.white),
            title: const Text('AI palettes', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Generate themes from a prompt', style: TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () => Navigator.pushNamed(context, '/palettes'),
          ),
        ]),
      ]),
    );
  }

  Widget _card(List<Widget> children) => Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(children: children));
}

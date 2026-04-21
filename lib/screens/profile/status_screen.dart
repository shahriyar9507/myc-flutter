import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Set Status', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save', style: GoogleFonts.inter(color: MyCColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🎧', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "What's happening?",
                      hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.close, color: Colors.white.withValues(alpha: 0.3), size: 20),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text('PRESETS', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _presetRow('🎧', 'Deep focus', 'Notifications paused'),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                _presetRow('🚗', 'Driving', 'Be there soon'),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                _presetRow('🏋️', 'Working out', 'At the gym'),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                _presetRow('💤', 'Sleeping', 'Do not disturb'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _presetRow(String emoji, String title, String subtitle) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13)),
    );
  }
}

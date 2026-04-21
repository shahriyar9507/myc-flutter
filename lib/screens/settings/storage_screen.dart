import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Storage & Data', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('2.4 GB Used', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text('of 64 GB available on your device', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 14)),
          const SizedBox(height: 24),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              height: 12,
              children: [
                Expanded(flex: 6, child: Container(color: MyCColors.accent)), // Photos
                Expanded(flex: 3, child: Container(color: MyCColors.pink)), // Videos
                Expanded(flex: 1, child: Container(color: MyCColors.gold)), // Documents
                Expanded(flex: 10, child: Container(color: Colors.white.withValues(alpha: 0.1))), // Free
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _legendRow(MyCColors.accent, 'Photos', '1.2 GB'),
          _legendRow(MyCColors.pink, 'Videos', '850 MB'),
          _legendRow(MyCColors.gold, 'Documents', '350 MB'),
          
          const SizedBox(height: 32),
          Text('NETWORK USAGE', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: Text('Use less data for calls', style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
              value: false,
              onChanged: (v) {},
              activeColor: Colors.white,
              activeTrackColor: MyCColors.accent,
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, String size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 16))),
          Text(size, style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 15)),
        ],
      ),
    );
  }
}

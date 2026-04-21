import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/settings_service.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _options = ['everyone', 'contacts', 'nobody'];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsService>();
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Privacy', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: MyCColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.lock, color: MyCColors.green, size: 28),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('End-to-End Encrypted', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Your messages and calls are secured.', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 28),
          Text('VISIBILITY', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 12),
          _card([
            _row(context, 'Last seen', s.lastSeenVisibility, (v) => s.save({'last_seen_visibility': v})),
            _div(),
            _row(context, 'Profile photo', s.profilePhotoVisibility, (v) => s.save({'profile_photo_visibility': v})),
            _div(),
            _row(context, 'About', s.aboutVisibility, (v) => s.save({'about_visibility': v})),
          ]),
          const SizedBox(height: 28),
          Text('MESSAGING', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 12),
          _card([
            SwitchListTile(
              title: const Text('Read receipts', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Show blue ticks when you read messages', style: TextStyle(color: Colors.white54)),
              value: s.readReceipts, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'read_receipts': v}),
            ),
            _div(),
            SwitchListTile(
              title: const Text('Typing indicator', style: TextStyle(color: Colors.white)),
              value: s.typingIndicator, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'typing_indicator': v}),
            ),
          ]),
          const SizedBox(height: 28),
          _card([
            ListTile(
              leading: const Icon(Icons.block, color: Colors.redAccent),
              title: const Text('Blocked users', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () => Navigator.pushNamed(context, '/blocked'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(children: children));

  Widget _div() => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1);

  Widget _row(BuildContext ctx, String title, String value, Future<void> Function(String) onChange) {
    return ListTile(
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 15)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
      onTap: () async {
        final v = await showModalBottomSheet<String>(
          context: ctx, backgroundColor: MyCColors.darkCard,
          builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
            for (final o in _options) ListTile(
              title: Text(o, style: const TextStyle(color: Colors.white)),
              trailing: o == value ? const Icon(Icons.check, color: MyCColors.accent) : null,
              onTap: () => Navigator.pop(ctx, o),
            ),
          ]),
        );
        if (v != null) await onChange(v);
      },
    );
  }
}

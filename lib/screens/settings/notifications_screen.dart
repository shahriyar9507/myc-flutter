import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/settings_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsService>();
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Notifications', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card([
            SwitchListTile(
              title: const Text('Push notifications', style: TextStyle(color: Colors.white)),
              value: s.notifPush, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'notif_push': v}),
            ),
            _div(),
            SwitchListTile(
              title: const Text('Sound', style: TextStyle(color: Colors.white)),
              value: s.notifSound, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'notif_sound': v}),
            ),
            _div(),
            SwitchListTile(
              title: const Text('Vibrate', style: TextStyle(color: Colors.white)),
              value: s.notifVibrate, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'notif_vibrate': v}),
            ),
            _div(),
            SwitchListTile(
              title: const Text('In-app notifications', style: TextStyle(color: Colors.white)),
              value: s.notifInApp, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'notif_in_app': v}),
            ),
            _div(),
            SwitchListTile(
              title: const Text('Show preview', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Show message content on lock screen', style: TextStyle(color: Colors.white54)),
              value: s.notifPreview, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'notif_preview': v}),
            ),
          ]),
          const SizedBox(height: 28),
          Text('SMART MODES', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 12),
          _card([
            SwitchListTile(
              title: const Text('Quiet hours', style: TextStyle(color: Colors.white)),
              subtitle: Text('${s.quietStart} – ${s.quietEnd}', style: const TextStyle(color: Colors.white54)),
              value: s.quietEnabled, activeColor: MyCColors.accent,
              onChanged: (v) => s.save({'quiet_enabled': v}),
            ),
            if (s.quietEnabled) ...[
              _div(),
              ListTile(
                title: const Text('Start', style: TextStyle(color: Colors.white)),
                trailing: Text(s.quietStart, style: const TextStyle(color: MyCColors.accent, fontWeight: FontWeight.w600)),
                onTap: () => _pickTime(context, s.quietStart, (t) => s.save({'quiet_start': t})),
              ),
              _div(),
              ListTile(
                title: const Text('End', style: TextStyle(color: Colors.white)),
                trailing: Text(s.quietEnd, style: const TextStyle(color: MyCColors.accent, fontWeight: FontWeight.w600)),
                onTap: () => _pickTime(context, s.quietEnd, (t) => s.save({'quiet_end': t})),
              ),
            ],
            _div(),
            ListTile(
              title: const Text('Do not disturb', style: TextStyle(color: Colors.white)),
              subtitle: Text(s.dndEnabled ? 'On' : 'Off', style: const TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () => Navigator.pushNamed(context, '/dnd'),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext ctx, String cur, Future<void> Function(String) save) async {
    final parts = cur.split(':');
    final t = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(hour: int.tryParse(parts.first) ?? 22, minute: int.tryParse(parts.last) ?? 0),
    );
    if (t != null) await save('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
  }

  Widget _card(List<Widget> children) => Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(children: children));

  Widget _div() => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1);
}

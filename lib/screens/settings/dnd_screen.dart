import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/settings_service.dart';

class DndScreen extends StatelessWidget {
  const DndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsService>();
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Do not disturb', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('Enable DND', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Silence every notification until expiry', style: TextStyle(color: Colors.white54)),
          value: s.dndEnabled,
          onChanged: (v) => s.save({'dnd_enabled': v, if (!v) 'dnd_until': null}),
        ),
        if (s.dndEnabled) ListTile(
          title: const Text('Until', style: TextStyle(color: Colors.white)),
          subtitle: Text(s.dndUntil?.toLocal().toString() ?? 'Not set',
              style: const TextStyle(color: Colors.white54)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          onTap: () async {
            final d = await showDatePicker(
              context: context, firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: s.dndUntil ?? DateTime.now().add(const Duration(hours: 1)),
            );
            if (d == null || !context.mounted) return;
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(s.dndUntil ?? DateTime.now().add(const Duration(hours: 1))),
            );
            if (t == null) return;
            final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
            await s.save({'dnd_until': dt.toIso8601String()});
          },
        ),
      ]),
    );
  }
}

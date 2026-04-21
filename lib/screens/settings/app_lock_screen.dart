import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/app_lock_service.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AppLockService>();
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('App lock', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('Enable app lock', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Require PIN / biometric on app open', style: TextStyle(color: Colors.white54)),
          value: svc.enabled,
          onChanged: (v) async {
            if (v) {
              final pin = await _askPin(context, 'Set a PIN');
              if (pin != null) await svc.enablePin(pin);
            } else {
              await svc.disable();
            }
          },
        ),
        if (svc.enabled) ...[
          SwitchListTile(
            title: const Text('Face / fingerprint unlock', style: TextStyle(color: Colors.white)),
            value: svc.biometric,
            onChanged: (v) => svc.setBiometric(v),
          ),
          ListTile(
            title: const Text('Auto-lock', style: TextStyle(color: Colors.white)),
            subtitle: Text('${svc.autolockSec}s', style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () async {
              final sec = await showModalBottomSheet<int>(
                context: context,
                backgroundColor: MyCColors.darkCard,
                builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
                  for (final s in [0, 30, 60, 300, 900])
                    ListTile(
                      title: Text(s == 0 ? 'Immediately' : '$s seconds', style: const TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(context, s),
                    ),
                ]),
              );
              if (sec != null) await svc.setAutolockSec(sec);
            },
          ),
          ListTile(
            title: const Text('Change PIN', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () async {
              final pin = await _askPin(context, 'New PIN');
              if (pin != null) await svc.enablePin(pin);
            },
          ),
        ],
      ]),
    );
  }

  Future<String?> _askPin(BuildContext context, String title) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c, obscureText: true, keyboardType: TextInputType.number,
          maxLength: 6, decoration: const InputDecoration(hintText: '4–6 digit PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            if (c.text.length >= 4) Navigator.pop(context, c.text);
          }, child: const Text('Set')),
        ],
      ),
    );
  }
}

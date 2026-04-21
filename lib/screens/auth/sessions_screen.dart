import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Active sessions', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text('Sign out of all devices', style: GoogleFonts.inter(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout from all devices'),
            style: ElevatedButton.styleFrom(backgroundColor: MyCColors.error, minimumSize: const Size.fromHeight(50)),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Log out everywhere?'),
                  content: const Text('This ends every session on every device.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<AuthService>().logout(allDevices: true);
                if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
          ),
        ]),
      ),
    );
  }
}

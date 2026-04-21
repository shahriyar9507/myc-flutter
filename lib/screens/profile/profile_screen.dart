import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/myc_logo.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;
    final name = user?['name']?.toString() ?? 'Me';
    final username = user?['username']?.toString() ?? '';
    final bio = user?['bio']?.toString() ?? '';
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Profile', style: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -1)),
                const MyCWordmark(size: 16, color: Colors.white, showMark: false),
              ]),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile/edit'),
                child: Column(children: [
                  Container(
                    width: 92, height: 92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [MyCColors.accent, MyCColors.pink]),
                    ),
                    child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  if (username.isNotEmpty) Text('@$username', style: GoogleFonts.inter(fontSize: 15, color: MyCColors.darkMuted)),
                  if (bio.isNotEmpty) Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(bio, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Account', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            _tile(context, Icons.person, 'Edit profile', 'Name, username, bio, avatar', const Color(0xFF1E1E2C), Colors.white, '/profile/edit'),
            _tile(context, Icons.lock_outline, 'Change password', 'Update your password', MyCColors.green.withValues(alpha: 0.2), MyCColors.green, '/profile/password'),
            _tile(context, Icons.devices, 'Active sessions', 'Manage devices', Colors.white.withValues(alpha: 0.1), Colors.white70, '/profile/sessions'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Preferences', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            _tile(context, Icons.dark_mode, 'Appearance', 'Theme & text size', const Color(0xFF1E1E2C), Colors.white, '/settings/appearance'),
            _tile(context, Icons.notifications, 'Notifications', 'Sounds, quiet hours, DND', MyCColors.gold.withValues(alpha: 0.2), MyCColors.gold, '/settings/notifications'),
            _tile(context, Icons.lock, 'Privacy', 'Visibility & receipts', MyCColors.green.withValues(alpha: 0.2), MyCColors.green, '/settings/privacy'),
            _tile(context, Icons.language, 'Language', 'App language', Colors.white.withValues(alpha: 0.1), Colors.white70, '/settings/language'),
            _tile(context, Icons.fingerprint, 'App lock', 'PIN & biometric', MyCColors.accent.withValues(alpha: 0.2), MyCColors.accentLight, '/settings/app-lock'),
            _tile(context, Icons.block, 'Blocked users', 'Manage blocks', Colors.redAccent.withValues(alpha: 0.2), Colors.redAccent, '/blocked'),
            _tile(context, Icons.star, 'Starred messages', 'Your favorites', MyCColors.gold.withValues(alpha: 0.2), MyCColors.gold, '/starred'),
            _tile(context, Icons.palette, 'AI palettes', 'Generate themes', const Color(0xFF2D1B4E), const Color(0xFFFF4FA3), '/palettes'),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                },
                child: Text('Log out', style: GoogleFonts.inter(color: MyCColors.error, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String title, String subtitle, Color bg, Color ic, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: ic, size: 22),
      ),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 13)),
      trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2)),
      onTap: () => Navigator.pushNamed(ctx, route),
    );
  }
}

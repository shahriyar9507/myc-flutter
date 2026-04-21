import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});
  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    if (_new.text != _confirm.text) return _snack('Passwords do not match');
    if (_new.text.length < 8 ||
        !_new.text.contains(RegExp(r'[A-Z]')) ||
        !_new.text.contains(RegExp(r'[0-9]'))) {
      return _snack('Min 8 chars, 1 uppercase, 1 number');
    }
    setState(() => _busy = true);
    final r = await context.read<AuthService>().changePassword(_old.text, _new.text);
    setState(() => _busy = false);
    if (!mounted) return;
    if (r['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
      Navigator.pop(context);
    } else {
      _snack(r['error']?.toString() ?? 'Failed');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Change password', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _pwd('Current password', _old),
        _pwd('New password', _new),
        _pwd('Confirm new password', _confirm),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: MyCColors.accent, minimumSize: const Size.fromHeight(50)),
          onPressed: _busy ? null : _submit,
          child: _busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Update password'),
        ),
      ]),
    );
  }

  Widget _pwd(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: c, obscureText: true, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.white54),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/app_lock_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const LockScreen({super.key, required this.onUnlock});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _c = TextEditingController();
  String? _err;

  @override
  void initState() { super.initState(); _bio(); }

  Future<void> _bio() async {
    final ok = await context.read<AppLockService>().tryBiometric();
    if (ok && mounted) widget.onUnlock();
  }

  Future<void> _submit() async {
    final ok = await context.read<AppLockService>().verifyPin(_c.text);
    if (ok) { widget.onUnlock(); } else { setState(() => _err = 'Wrong PIN'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text('MyC is locked', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              TextField(
                controller: _c, obscureText: true, keyboardType: TextInputType.number,
                maxLength: 6, autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 8),
                textAlign: TextAlign.center,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: '••••', hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              if (_err != null) Text(_err!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: MyCColors.accent),
                onPressed: _submit,
                child: const Text('Unlock'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use biometric'),
                onPressed: _bio,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

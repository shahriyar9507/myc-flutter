import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/myc_logo.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;
  bool? _usernameAvailable;
  Timer? _debounce;
  int _step = 0; // 0 = credentials, 1 = personal info
  late AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgAnim = AnimationController(
      vsync: this, duration: const Duration(seconds: 10),
    )..repeat();
    _usernameCtrl.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _bgAnim.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    _debounce?.cancel();
    final u = _usernameCtrl.text.trim();
    if (u.length < 3) {
      setState(() => _usernameAvailable = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await context.read<AuthService>().checkUsername(u);
      if (mounted) setState(() => _usernameAvailable = available);
    });
  }

  void _nextStep() {
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    final c = _confirmCtrl.text;

    if (u.length < 3) {
      setState(() => _error = 'Username must be 3+ characters');
      return;
    }
    if (_usernameAvailable == false) {
      setState(() => _error = 'Username is already taken');
      return;
    }
    if (p.length < 8) {
      setState(() => _error = 'Password must be 8+ characters');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(p)) {
      setState(() => _error = 'Password needs at least one uppercase letter');
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(p)) {
      setState(() => _error = 'Password needs at least one number');
      return;
    }
    if (p != c) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _error = null; _step = 1; });
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.length < 2) {
      setState(() => _error = 'Name must be 2+ characters');
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      setState(() => _error = 'Invalid email format');
      return;
    }

    setState(() => _error = null);
    final auth = context.read<AuthService>();
    final result = await auth.register(
      username: _usernameCtrl.text.trim(),
      name: name,
      password: _passwordCtrl.text,
      email: email.isEmpty ? null : email,
    );

    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() => _error = result['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: Stack(
        children: [
          // Animated bg
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, _) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _RegBgPainter(t: _bgAnim.value * 2 * pi),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Back button for step 1
                  if (_step == 1)
                    GestureDetector(
                      onTap: () => setState(() { _step = 0; _error = null; }),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),

                  if (_step == 0) ...[
                    Center(child: MyCMark(size: 56, color: MyCColors.accent, glow: true)),
                    const SizedBox(height: 28),
                  ],

                  Center(
                    child: Text(
                      _step == 0 ? 'Create your account' : 'Almost there',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 30, fontWeight: FontWeight.w700,
                        letterSpacing: -1, color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      _step == 0 ? 'Pick a username and password' : 'Tell us your name',
                      style: GoogleFonts.inter(fontSize: 15, color: MyCColors.darkMuted),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Step indicator
                  Row(
                    children: [
                      Expanded(child: Container(
                        height: 3, decoration: BoxDecoration(
                          color: MyCColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
                      const SizedBox(width: 6),
                      Expanded(child: Container(
                        height: 3, decoration: BoxDecoration(
                          color: _step >= 1 ? MyCColors.accent : Colors.white12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Error
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MyCColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MyCColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: MyCColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            _error!, style: GoogleFonts.inter(color: MyCColors.error, fontSize: 13),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_step == 0) ...[
                    // Username
                    _GlassField(
                      controller: _usernameCtrl,
                      label: 'Username',
                      icon: Icons.alternate_email_rounded,
                      suffix: _usernameAvailable == null
                          ? null
                          : Icon(
                              _usernameAvailable! ? Icons.check_circle : Icons.cancel,
                              color: _usernameAvailable! ? MyCColors.green : MyCColors.error,
                              size: 20,
                            ),
                    ),
                    if (_usernameAvailable != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 6),
                        child: Text(
                          _usernameAvailable! ? 'Username available ✓' : 'Username taken',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _usernameAvailable! ? MyCColors.green : MyCColors.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Password
                    _GlassField(
                      controller: _passwordCtrl,
                      label: 'Password (8+ chars, 1 uppercase, 1 number)',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure1,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure1 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: MyCColors.darkMuted, size: 20,
                        ),
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm password
                    _GlassField(
                      controller: _confirmCtrl,
                      label: 'Confirm password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure2,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: MyCColors.darkMuted, size: 20,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Next button
                    _AccentButton(label: 'Next', onTap: _nextStep),
                  ],

                  if (_step == 1) ...[
                    // Name
                    _GlassField(
                      controller: _nameCtrl,
                      label: 'Full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _GlassField(
                      controller: _emailCtrl,
                      label: 'Email (optional)',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 32),

                    // Register button
                    _AccentButton(
                      label: auth.loading ? '' : 'Create Account',
                      onTap: auth.loading ? () {} : _register,
                      loading: auth.loading,
                    ),
                  ],

                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 14, color: MyCColors.darkMuted),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: MyCColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass-morphism text field
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(icon, color: MyCColors.darkMuted, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

/// Accent gradient button
class _AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _AccentButton({required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: MyCColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyCColors.accent.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Background painter for register screen
class _RegBgPainter extends CustomPainter {
  final double t;
  _RegBgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final blobs = [
      (w * 0.8, h * 0.1, const Color(0xFFFF6A88)),
      (w * 0.2, h * 0.5, const Color(0xFF6A5EF7)),
      (w * 0.6, h * 0.9, const Color(0xFF43E97B)),
    ];
    for (int i = 0; i < blobs.length; i++) {
      final (bx, by, color) = blobs[i];
      final cx = bx + sin(t + i * 2.1) * w * 0.06;
      final cy = by + cos(t * 0.8 + i * 1.3) * h * 0.04;
      final r = w * 0.38;
      canvas.drawCircle(Offset(cx, cy), r, Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    }
  }

  @override
  bool shouldRepaint(_RegBgPainter old) => true;
}

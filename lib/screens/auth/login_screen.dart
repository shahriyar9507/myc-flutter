import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/myc_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;
  late AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _bgAnim.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = null);
    final auth = context.read<AuthService>();
    final result = await auth.login(
      identifier: _identifierCtrl.text.trim(),
      password: _passwordCtrl.text,
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
          // Animated background
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (context, _) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _AuthBgPainter(t: _bgAnim.value * 2 * pi),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: MyCMark(size: 56, color: MyCColors.accent, glow: true),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Welcome back',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Sign in to continue chatting',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: MyCColors.darkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

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
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.inter(color: MyCColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Username / email / phone
                  _GlassField(
                    controller: _identifierCtrl,
                    label: 'Username, email or phone',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _GlassField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: MyCColors.darkMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  GestureDetector(
                    onTap: auth.loading ? null : _login,
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
                        child: auth.loading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 14, color: MyCColors.darkMuted),
                          children: [
                            const TextSpan(text: 'New to MyC? '),
                            TextSpan(
                              text: 'Create account',
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
          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 15),
          prefixIcon: Icon(icon, color: MyCColors.darkMuted, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

/// Animated background for auth screens
class _AuthBgPainter extends CustomPainter {
  final double t;

  _AuthBgPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blobs = [
      (w * 0.15, h * 0.15, const Color(0xFF6A5EF7)),
      (w * 0.85, h * 0.35, const Color(0xFFFF6A88)),
      (w * 0.5, h * 0.85, const Color(0xFF43E97B)),
    ];

    for (int i = 0; i < blobs.length; i++) {
      final (bx, by, color) = blobs[i];
      final cx = bx + sin(t + i * 2) * w * 0.08;
      final cy = by + cos(t * 0.7 + i * 1.5) * h * 0.05;
      final r = w * 0.4;

      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_AuthBgPainter old) => true;
}

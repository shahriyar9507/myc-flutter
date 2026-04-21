import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../widgets/myc_logo.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;
  late AnimationController _bgAnimController;

  final _pages = const [
    _OnboardingPage(
      icon: '✨',
      kicker: 'WELCOME TO MYC',
      title: 'Chat, but with\na little weather.',
      subtitle:
          'A messenger that feels alive — with animated themes, deep customization, and your own style.',
      gradientColors: [Color(0xFF6A5EF7), Color(0xFF9B5EF7), Color(0xFFFF6A88)],
    ),
    _OnboardingPage(
      icon: '🌈',
      kicker: '11 LIVE THEMES',
      title: 'A weather report\nfor every chat.',
      subtitle:
          'Rain, Aurora, Lava, Matrix and more — each chat gets its own animated world. Not gradients. Real animations.',
      gradientColors: [Color(0xFF43E97B), Color(0xFF38F9D7), Color(0xFF6A5EF7)],
    ),
    _OnboardingPage(
      icon: '🎨',
      kicker: 'FULL CUSTOMIZATION',
      title: 'Make it\ncompletely yours.',
      subtitle:
          'Customize every color — bubbles, backgrounds, accents. Dark mode, light mode, or follow your system. AI-generated palettes.',
      gradientColors: [Color(0xFFFF6A88), Color(0xFFFFCF4A), Color(0xFFFF9A8B)],
    ),
    _OnboardingPage(
      icon: '🔔',
      kicker: 'SMART NOTIFICATIONS',
      title: 'Notifications\nyour way.',
      subtitle:
          'Per-chat notification control, quiet hours, DND modes, and focus filters. Never miss what matters.',
      gradientColors: [Color(0xFFFFCF4A), Color(0xFFFF6A88), Color(0xFF6A5EF7)],
    ),
    _OnboardingPage(
      icon: '🚀',
      kicker: 'EVERYTHING YOU NEED',
      title: 'Voice, video,\nstories, and more.',
      subtitle:
          'Calls, group chats, voice messages, file sharing, reactions, stories — all built in. No extras needed.',
      gradientColors: [Color(0xFF30CFD0), Color(0xFF6A5EF7), Color(0xFFFF6A88)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  void _goToRegister() async {
    await _completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _goToLogin() async {
    await _completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: Stack(
        children: [
          // Animated background gradient blobs
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, _) {
              final t = _bgAnimController.value * 2 * pi;
              final pageColors = _pages[_currentPage].gradientColors;
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BgPainter(t: t, colors: pageColors),
              );
            },
          ),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MyCWordmark(
                        size: 18,
                        color: Colors.white,
                        markColor: MyCColors.accent,
                      ),
                      if (!isLastPage)
                        TextButton(
                          onPressed: () {
                            _controller.animateToPage(
                              _pages.length - 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) => _buildPage(_pages[i]),
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    children: [
                      // Page indicator
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          activeDotColor: MyCColors.accent,
                          dotColor: Colors.white24,
                          expansionFactor: 4,
                          spacing: 6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (isLastPage) ...[
                        // Get Started button
                        _AccentButton(
                          label: 'Create Account',
                          onTap: _goToRegister,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _goToLogin,
                          child: Text(
                            'I already have an account',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Next button
                        _AccentButton(
                          label: 'Next',
                          onTap: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  page.gradientColors[0].withValues(alpha: 0.3),
                  page.gradientColors[1].withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: page.gradientColors[0].withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(page.icon, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 32),
          // Kicker
          Text(
            page.kicker,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: page.gradientColors[0],
            ),
          ),
          const SizedBox(height: 12),
          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, page.gradientColors[0].withValues(alpha: 0.8)],
            ).createShader(bounds),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.5,
                height: 1.05,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: MyCColors.darkMuted,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String icon;
  final String kicker;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.icon,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

/// Animated gradient background painter
class _BgPainter extends CustomPainter {
  final double t;
  final List<Color> colors;

  _BgPainter({required this.t, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Three floating gradient blobs
    for (int i = 0; i < 3; i++) {
      final cx = w * (0.2 + 0.3 * i) + sin(t + i * 2) * w * 0.1;
      final cy = h * (0.2 + 0.2 * i) + cos(t * 0.7 + i * 1.5) * h * 0.08;
      final r = w * (0.35 + 0.1 * i);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i % colors.length].withValues(alpha: 0.2),
            colors[i % colors.length].withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => true;
}

/// Purple gradient button matching the HTML prototype style
class _AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AccentButton({required this.label, required this.onTap});

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
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}

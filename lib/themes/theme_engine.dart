import 'dart:math';
import 'package:flutter/material.dart';

import 'theme_painters.dart';

/// Renders a live animated background for the chat thread
class AnimatedChatTheme extends StatefulWidget {
  final String themeId;

  const AnimatedChatTheme({super.key, required this.themeId});

  @override
  State<AnimatedChatTheme> createState() => _AnimatedChatThemeState();
}

class _AnimatedChatThemeState extends State<AnimatedChatTheme>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Use a long duration and repeat for infinite animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedChatTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeId != widget.themeId) {
      // Re-initialize state or specific particle engines if needed
      // when the theme changes live.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _getThemeConfig(widget.themeId);

    return Container(
      decoration: BoxDecoration(
        gradient: cfg.background,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: cfg.painterFactory(_controller.value),
          );
        },
      ),
    );
  }

  _ThemeConfig _getThemeConfig(String id) {
    switch (id) {
      case 'rain':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
          painterFactory: (t) => RainPainter(t: t),
        );
      case 'snow':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
          ),
          painterFactory: (t) => SnowPainter(t: t),
        );
      case 'confetti':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0F5), Color(0xFFE6E6FA)],
          ),
          painterFactory: (t) => ConfettiPainter(t: t),
        );
      case 'bubbles':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
          ),
          painterFactory: (t) => BubblesPainter(t: t),
        );
      case 'aurora':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0F19), Color(0xFF1A2A42)],
          ),
          painterFactory: (t) => AuroraPainter(t: t),
        );
      case 'fireflies':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1B15), Color(0xFF1A2F24)],
          ),
          painterFactory: (t) => FirefliesPainter(t: t),
        );
      case 'sakura':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
          ),
          painterFactory: (t) => SakuraPainter(t: t),
        );
      case 'starfield':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF05050A), Color(0xFF110B29)],
          ),
          painterFactory: (t) => StarfieldPainter(t: t),
        );
      case 'lava':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0B2E), Color(0xFF2D1B4E)],
          ),
          painterFactory: (t) => LavaPainter(t: t),
        );
      case 'matrix':
        return _ThemeConfig(
          background: const LinearGradient(colors: [Colors.black, Colors.black]),
          painterFactory: (t) => MatrixPainter(t: t),
        );
      case 'ocean':
        return _ThemeConfig(
          background: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF003B46), Color(0xFF07575B)],
          ),
          painterFactory: (t) => OceanPainter(t: t),
        );
      default: // Default to a static dark theme
        return _ThemeConfig(
          background: const LinearGradient(
            colors: [Color(0xFF0B0B12), Color(0xFF14141E)],
          ),
          painterFactory: (t) => EmptyPainter(),
        );
    }
  }
}

class _ThemeConfig {
  final Gradient background;
  final CustomPainter Function(double t) painterFactory;
  _ThemeConfig({required this.background, required this.painterFactory});
}



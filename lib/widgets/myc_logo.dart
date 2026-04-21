import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MyC diamond logo mark — two overlapping diamonds with inner cut and center dot
class MyCMark extends StatelessWidget {
  final double size;
  final Color color;
  final bool glow;

  const MyCMark({super.key, this.size = 32, this.color = Colors.white, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MyCMarkPainter(color: color, glow: glow),
    );
  }
}

class _MyCMarkPainter extends CustomPainter {
  final Color color;
  final bool glow;

  _MyCMarkPainter({required this.color, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);

    // Outer diamond
    final outerPath = Path()
      ..moveTo(s / 2, s * 0.075)
      ..lineTo(s * 0.925, s / 2)
      ..lineTo(s / 2, s * 0.925)
      ..lineTo(s * 0.075, s / 2)
      ..close();

    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 1), color.withValues(alpha: 0.7)],
      ).createShader(Rect.fromLTWH(0, 0, s, s));

    if (glow) {
      canvas.drawPath(outerPath, Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }

    canvas.drawPath(outerPath, outerPaint);

    // Inner diamond cut
    final innerPath = Path()
      ..moveTo(s / 2, s * 0.275)
      ..lineTo(s * 0.725, s / 2)
      ..lineTo(s / 2, s * 0.725)
      ..lineTo(s * 0.275, s / 2)
      ..close();

    final innerColor = color == Colors.white
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.white;
    canvas.drawPath(innerPath, Paint()..color = innerColor);

    // Center dot
    canvas.drawCircle(center, s * 0.06, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// MyC wordmark — logo mark + "MyC" text
class MyCWordmark extends StatelessWidget {
  final double size;
  final Color color;
  final Color? markColor;
  final bool showMark;

  const MyCWordmark({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF111111),
    this.markColor,
    this.showMark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMark) ...[
          MyCMark(size: size * 1.1, color: markColor ?? color),
          SizedBox(width: size * 0.3),
        ],
        RichText(
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.02 * size,
            ),
            children: [
              const TextSpan(text: 'My'),
              TextSpan(
                text: 'C',
                style: TextStyle(color: markColor ?? color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

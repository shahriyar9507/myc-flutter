import 'dart:math';
import 'package:flutter/material.dart';

// Empty Painter
class EmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// 1. Rain
class RainPainter extends CustomPainter {
  final double t;
  RainPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    
    for (int i = 0; i < 100; i++) {
      final x = rnd.nextDouble() * size.width;
      final speed = 0.5 + rnd.nextDouble();
      final offset = rnd.nextDouble();
      // Drop falls downwards
      final y = ((t * speed * 2 + offset) % 1.0) * size.height;
      final len = 10 + rnd.nextDouble() * 20;
      canvas.drawLine(Offset(x, y), Offset(x + rnd.nextDouble() * 2 - 1, y + len), paint);
    }
  }
  @override
  bool shouldRepaint(RainPainter old) => old.t != t;
}

// 2. Snow
class SnowPainter extends CustomPainter {
  final double t;
  SnowPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(123);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    
    for (int i = 0; i < 80; i++) {
      final speed = 0.2 + rnd.nextDouble() * 0.5;
      final xOffset = rnd.nextDouble() * 2 * pi;
      final offset = rnd.nextDouble();
      
      final y = ((t * speed + offset) % 1.0) * size.height;
      // Swaying motion
      final x = (rnd.nextDouble() * size.width) + sin(t * 4 * pi + xOffset) * 15;
      final r = 1 + rnd.nextDouble() * 3;
      
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }
  @override
  bool shouldRepaint(SnowPainter old) => old.t != t;
}

// 3. Confetti
class ConfettiPainter extends CustomPainter {
  final double t;
  ConfettiPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(456);
    final colors = [
      const Color(0xFFFF4A8C), const Color(0xFF6A5EF7), 
      const Color(0xFF43E97B), const Color(0xFFFFCF4A)
    ];
    
    for (int i = 0; i < 60; i++) {
      final speed = 0.4 + rnd.nextDouble() * 0.6;
      final offset = rnd.nextDouble();
      final y = ((t * speed + offset) % 1.0) * size.height;
      final x = rnd.nextDouble() * size.width + sin(t * 2 * pi + offset) * 20;
      
      final paint = Paint()..color = colors[rnd.nextInt(colors.length)];
      final rot = t * 10 * pi * (rnd.nextBool() ? 1 : -1) + offset * pi;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRect(const Rect.fromLTWH(-4, -8, 8, 16), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(ConfettiPainter old) => old.t != t;
}

// 4. Bubbles
class BubblesPainter extends CustomPainter {
  final double t;
  BubblesPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(789);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < 40; i++) {
      final speed = 0.3 + rnd.nextDouble() * 0.4;
      final offset = rnd.nextDouble();
      // Bubbles go up
      final y = size.height - (((t * speed + offset) % 1.0) * size.height);
      final x = rnd.nextDouble() * size.width + sin(t * 3 * pi + offset) * 10;
      final r = 4 + rnd.nextDouble() * 12;
      
      canvas.drawCircle(Offset(x, y), r, paint);
      // Small highlight
      canvas.drawCircle(
        Offset(x - r*0.3, y - r*0.3), 
        r*0.2, 
        Paint()..color = Colors.white.withValues(alpha: 0.6)
      );
    }
  }
  @override
  bool shouldRepaint(BubblesPainter old) => old.t != t;
}

// 5. Aurora
class AuroraPainter extends CustomPainter {
  final double t;
  AuroraPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;
    
    path.moveTo(0, h * 0.6);
    path.quadraticBezierTo(
      w * 0.25, h * 0.4 + sin(t * 2 * pi) * 50, 
      w * 0.5, h * 0.5 + cos(t * 2 * pi) * 30
    );
    path.quadraticBezierTo(
      w * 0.75, h * 0.6 - sin(t * 2 * pi) * 50, 
      w, h * 0.4
    );
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(
      path, 
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9DFFD8).withValues(alpha: 0.4),
            const Color(0xFF9DFFD8).withValues(alpha: 0.0)
          ]
        ).createShader(Rect.fromLTWH(0, 0, w, h))
    );
  }
  @override
  bool shouldRepaint(AuroraPainter old) => old.t != t;
}

// 6. Fireflies
class FirefliesPainter extends CustomPainter {
  final double t;
  FirefliesPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(321);
    final w = size.width;
    final h = size.height;
    
    for (int i = 0; i < 50; i++) {
      final speedX = rnd.nextDouble() - 0.5;
      final speedY = rnd.nextDouble() - 0.5;
      final offset = rnd.nextDouble() * 2 * pi;
      
      final x = (rnd.nextDouble() * w + sin(t * 2 * pi * speedX) * 50) % w;
      final y = (rnd.nextDouble() * h + cos(t * 2 * pi * speedY) * 50) % h;
      
      final alpha = (sin(t * 4 * pi + offset) + 1) / 2; // Pulsing 0 to 1
      
      final paint = Paint()
        ..color = const Color(0xFFFFF3A8).withValues(alpha: alpha * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
      canvas.drawCircle(Offset(x < 0 ? x + w : x, y < 0 ? y + h : y), 2.5, paint);
    }
  }
  @override
  bool shouldRepaint(FirefliesPainter old) => old.t != t;
}

// 7. Sakura
class SakuraPainter extends CustomPainter {
  final double t;
  SakuraPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(654);
    final paint = Paint()..color = const Color(0xFFFF6B9D).withValues(alpha: 0.7);
    
    for (int i = 0; i < 40; i++) {
      final speed = 0.2 + rnd.nextDouble() * 0.3;
      final offset = rnd.nextDouble();
      final y = ((t * speed + offset) % 1.0) * size.height;
      final x = rnd.nextDouble() * size.width + sin(t * 2 * pi + offset) * 30;
      
      final rot = t * 4 * pi + offset;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      
      // Petal shape
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(5, -5, 10, 0)
        ..quadraticBezierTo(5, 5, 0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(SakuraPainter old) => old.t != t;
}

// 8. Starfield
class StarfieldPainter extends CustomPainter {
  final double t;
  StarfieldPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(987);
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    for (int i = 0; i < 150; i++) {
      final angle = rnd.nextDouble() * 2 * pi;
      final dist = rnd.nextDouble();
      
      // Expand outwards
      final currDist = (dist + t) % 1.0;
      final x = cx + cos(angle) * currDist * size.width;
      final y = cy + sin(angle) * currDist * size.height;
      
      final sizeMult = currDist * 3;
      canvas.drawCircle(
        Offset(x, y), 
        sizeMult, 
        Paint()..color = const Color(0xFFC4B5FF).withValues(alpha: currDist)
      );
    }
  }
  @override
  bool shouldRepaint(StarfieldPainter old) => old.t != t;
}

// 9. Lava
class LavaPainter extends CustomPainter {
  final double t;
  LavaPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    for (int i = 0; i < 4; i++) {
      final cx = w * (0.2 + 0.6 * (i%2)) + sin(t * 2 * pi + i) * w * 0.2;
      final cy = h * (0.8 - 0.2 * i) + cos(t * 2 * pi + i*1.5) * h * 0.1;
      final r = w * 0.4;
      
      canvas.drawCircle(
        Offset(cx, cy), r, 
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFF4FA3).withValues(alpha: 0.3),
              const Color(0xFFFF4FA3).withValues(alpha: 0)
            ]
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
          ..blendMode = BlendMode.screen
      );
    }
  }
  @override
  bool shouldRepaint(LavaPainter old) => old.t != t;
}

// 10. Matrix
class MatrixPainter extends CustomPainter {
  final double t;
  MatrixPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(111);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final cols = (size.width / 20).floor();
    
    for (int i = 0; i < cols; i++) {
      final speed = 0.5 + rnd.nextDouble();
      final offset = rnd.nextDouble();
      final yPos = ((t * speed + offset) % 1.0) * size.height;
      
      // Draw a vertical streak of 5 chars
      for (int j = 0; j < 5; j++) {
        textPainter.text = TextSpan(
          text: String.fromCharCode(0x30A0 + rnd.nextInt(96)), // Katakana
          style: TextStyle(
            color: const Color(0xFF00FF9C).withValues(alpha: 1.0 - (j * 0.2)),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(i * 20.0, yPos - (j * 20.0)));
      }
    }
  }
  @override
  bool shouldRepaint(MatrixPainter old) => old.t != t;
}

// 11. Ocean
class OceanPainter extends CustomPainter {
  final double t;
  OceanPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Light rays (caustics)
    for(int i = 0; i < 5; i++) {
      final path = Path();
      final topX = w * 0.2 * i + sin(t*2*pi + i) * 50;
      path.moveTo(topX, 0);
      path.lineTo(topX + 100, 0);
      path.lineTo(w * 0.2 * i + 50 + sin(t*2*pi + i + 1) * 100, h);
      path.lineTo(w * 0.2 * i - 50 + sin(t*2*pi + i + 1) * 100, h);
      path.close();
      
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFF4FC3E0).withValues(alpha: 0.1)
        ..blendMode = BlendMode.screen
      );
    }
  }
  @override
  bool shouldRepaint(OceanPainter old) => old.t != t;
}

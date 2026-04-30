import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/astro_snapshot.dart';
import '../theme/cosmic_theme.dart';

class ZodiacWheel extends StatelessWidget {
  final AstroSnapshot snapshot;
  final double size;

  const ZodiacWheel({super.key, required this.snapshot, this.size = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ZodiacWheelPainter(snapshot),
      ),
    );
  }
}

class _ZodiacWheelPainter extends CustomPainter {
  final AstroSnapshot snapshot;
  static const _signEmoji = [
    '♈', '♉', '♊', '♋', '♌', '♍',
    '♎', '♏', '♐', '♑', '♒', '♓',
  ];

  _ZodiacWheelPainter(this.snapshot);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 4;
    final signR = outerR * 0.85;
    final innerR = outerR * 0.65;
    final planetR = outerR * 0.45;

    _drawBackground(canvas, center, outerR);
    _drawSignSegments(canvas, center, outerR, signR, innerR);
    _drawAscendantLine(canvas, center, outerR);
    _drawPlanets(canvas, center, planetR, innerR);
  }

  void _drawBackground(Canvas canvas, Offset center, double r) {
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          CosmicColors.surface,
          CosmicColors.background,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, bgPaint);

    final borderPaint = Paint()
      ..color = CosmicColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r, borderPaint);
  }

  void _drawSignSegments(Canvas canvas, Offset center, double outerR,
      double signR, double innerR) {
    final segmentPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.5..color = CosmicColors.divider;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 30 - 90 - snapshot.ascendant) * math.pi / 180;
      final midAngle = startAngle + 15 * math.pi / 180;

      // Sign divider line
      final lineEnd = Offset(
        center.dx + outerR * math.cos(startAngle),
        center.dy + outerR * math.sin(startAngle),
      );
      final lineStart = Offset(
        center.dx + innerR * math.cos(startAngle),
        center.dy + innerR * math.sin(startAngle),
      );
      canvas.drawLine(lineStart, lineEnd, segmentPaint);

      // Emoji glyph in middle of segment
      final glyphR = (signR + innerR) / 2;
      final glyphPos = Offset(
        center.dx + glyphR * math.cos(midAngle),
        center.dy + glyphR * math.sin(midAngle),
      );
      textPainter.text = TextSpan(
        text: _signEmoji[i],
        style: const TextStyle(fontSize: 11, color: CosmicColors.textMuted),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        glyphPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Inner circle
    canvas.drawCircle(center, innerR,
        Paint()..color = CosmicColors.divider..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawAscendantLine(Canvas canvas, Offset center, double outerR) {
    final paint = Paint()
      ..color = CosmicColors.neonCyan
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // Ascendant is the left horizon (180°)
    canvas.drawLine(
      Offset(center.dx - outerR * 0.65, center.dy),
      Offset(center.dx + outerR * 0.65, center.dy),
      paint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
          text: 'ASC', style: TextStyle(color: CosmicColors.neonCyan, fontSize: 8)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(center.dx + outerR * 0.66, center.dy - 6));
  }

  void _drawPlanets(Canvas canvas, Offset center, double planetR, double innerR) {
    const planetSymbols = {
      Planet.sun: '☉',
      Planet.moon: '☽',
      Planet.mercury: '☿',
      Planet.venus: '♀',
      Planet.mars: '♂',
      Planet.jupiter: '♃',
      Planet.saturn: '♄',
      Planet.uranus: '⛢',
      Planet.neptune: '♆',
      Planet.pluto: '♇',
    };
    const planetColors = {
      Planet.sun: CosmicColors.neonYellow,
      Planet.moon: Colors.white,
      Planet.mercury: CosmicColors.neonCyan,
      Planet.venus: CosmicColors.neonPink,
      Planet.mars: Color(0xFFFF4444),
      Planet.jupiter: CosmicColors.neonYellow,
      Planet.saturn: CosmicColors.textSecondary,
      Planet.uranus: CosmicColors.neonGreen,
      Planet.neptune: CosmicColors.neonCyan,
      Planet.pluto: CosmicColors.neonLavender,
    };

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final entry in snapshot.positions.entries) {
      final planet = entry.key;
      final pos = entry.value;
      final angle = (pos.eclipticLongitude - 90 - snapshot.ascendant) * math.pi / 180;

      final dotPos = Offset(
        center.dx + planetR * math.cos(angle),
        center.dy + planetR * math.sin(angle),
      );

      // Draw planet dot
      canvas.drawCircle(
        dotPos,
        3,
        Paint()..color = planetColors[planet] ?? Colors.white,
      );

      // Draw symbol
      textPainter.text = TextSpan(
        text: planetSymbols[planet],
        style: TextStyle(
          fontSize: 10,
          color: planetColors[planet] ?? Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        dotPos + Offset(4, -textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZodiacWheelPainter oldDelegate) => false;
}

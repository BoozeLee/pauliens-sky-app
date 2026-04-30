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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ZodiacWheelPainter(snapshot),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(CosmicColors.neonCyan, 'Tropical'),
            const SizedBox(width: 16),
            _LegendDot(CosmicColors.neonLavender, 'Sidereal'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: color, fontSize: 9, letterSpacing: 0.5)),
      ],
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
    final outerR     = size.width / 2 - 4;
    final midR       = outerR * 0.72;   // between tropical & sidereal rings
    final siderealR  = outerR * 0.54;   // inner edge of sidereal ring
    final planetR    = outerR * 0.38;   // planet dot radius

    _drawBackground(canvas, center, outerR);
    _drawTropicalRing(canvas, center, outerR, midR);
    _drawSiderealRing(canvas, center, midR, siderealR);
    _drawAscMcLines(canvas, center, siderealR);
    _drawPlanets(canvas, center, planetR, siderealR);
  }

  void _drawBackground(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center, r,
      Paint()
        ..shader = RadialGradient(
          colors: [CosmicColors.surface, CosmicColors.background],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawCircle(
      center, r,
      Paint()
        ..color = CosmicColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawTropicalRing(
      Canvas canvas, Offset center, double outerR, double midR) {
    final divPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = CosmicColors.neonCyan.withValues(alpha: 0.25);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 12; i++) {
      final startAngle =
          (i * 30 - 90 - snapshot.ascendant) * math.pi / 180;
      final midAngle = startAngle + 15 * math.pi / 180;

      // Divider spoke
      canvas.drawLine(
        _point(center, midR, startAngle),
        _point(center, outerR, startAngle),
        divPaint,
      );

      // Glyph in center of band
      final glyphR = (outerR + midR) / 2;
      textPainter.text = TextSpan(
        text: _signEmoji[i],
        style: TextStyle(
            fontSize: 10,
            color: CosmicColors.neonCyan.withValues(alpha: 0.9)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        _point(center, glyphR, midAngle) -
            Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Ring border
    canvas.drawCircle(center, midR,
        Paint()
          ..color = CosmicColors.neonCyan.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _drawSiderealRing(
      Canvas canvas, Offset center, double midR, double innerR) {
    final divPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = CosmicColors.neonLavender.withValues(alpha: 0.25);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Sidereal sign boundaries are offset by ayanamsha
    for (int i = 0; i < 12; i++) {
      final startAngle =
          (i * 30 + snapshot.siderealOffset - 90 - snapshot.ascendant) *
              math.pi / 180;
      final midAngle = startAngle + 15 * math.pi / 180;

      canvas.drawLine(
        _point(center, innerR, startAngle),
        _point(center, midR, startAngle),
        divPaint,
      );

      final glyphR = (midR + innerR) / 2;
      textPainter.text = TextSpan(
        text: _signEmoji[i],
        style: TextStyle(
            fontSize: 9,
            color: CosmicColors.neonLavender.withValues(alpha: 0.9)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        _point(center, glyphR, midAngle) -
            Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Inner border
    canvas.drawCircle(center, innerR,
        Paint()
          ..color = CosmicColors.neonLavender.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _drawAscMcLines(Canvas canvas, Offset center, double innerR) {
    // Horizon (ASC–DSC)
    canvas.drawLine(
      Offset(center.dx - innerR, center.dy),
      Offset(center.dx + innerR, center.dy),
      Paint()
        ..color = CosmicColors.neonCyan.withValues(alpha: 0.6)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    // Meridian (MC–IC)
    canvas.drawLine(
      Offset(center.dx, center.dy - innerR),
      Offset(center.dx, center.dy + innerR),
      Paint()
        ..color = CosmicColors.neonCyan.withValues(alpha: 0.3)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);

    void _label(String text, Offset pos) {
      tp.text = TextSpan(
        text: text,
        style: const TextStyle(
            color: CosmicColors.neonCyan, fontSize: 7, letterSpacing: 0.5),
      );
      tp.layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    _label('ASC', Offset(center.dx + innerR - 8, center.dy - 7));
    _label('DSC', Offset(center.dx - innerR + 8, center.dy - 7));
    _label('MC',  Offset(center.dx + 8, center.dy - innerR + 7));
  }

  void _drawPlanets(
      Canvas canvas, Offset center, double planetR, double innerR) {
    const planetSymbols = {
      Planet.sun: '☉', Planet.moon: '☽', Planet.mercury: '☿',
      Planet.venus: '♀', Planet.mars: '♂', Planet.jupiter: '♃',
      Planet.saturn: '♄', Planet.uranus: '⛢', Planet.neptune: '♆',
      Planet.pluto: '♇',
    };
    const planetColors = {
      Planet.sun:     CosmicColors.neonYellow,
      Planet.moon:    Colors.white,
      Planet.mercury: CosmicColors.neonCyan,
      Planet.venus:   CosmicColors.neonPink,
      Planet.mars:    Color(0xFFFF4444),
      Planet.jupiter: CosmicColors.neonYellow,
      Planet.saturn:  CosmicColors.textSecondary,
      Planet.uranus:  CosmicColors.neonGreen,
      Planet.neptune: CosmicColors.neonCyan,
      Planet.pluto:   CosmicColors.neonLavender,
    };

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Spread planets on slightly varying radii so they don't overlap
    int idx = 0;
    for (final entry in snapshot.positions.entries) {
      final planet = entry.key;
      final pos = entry.value;
      final angle =
          (pos.eclipticLongitude - 90 - snapshot.ascendant) * math.pi / 180;

      // Alternate inner/outer to reduce crowding
      final r = planetR * (0.85 + (idx % 3) * 0.10);
      final dotPos = _point(center, r, angle);

      canvas.drawCircle(
        dotPos, 2.5,
        Paint()..color = (planetColors[planet] ?? Colors.white),
      );

      textPainter.text = TextSpan(
        text: planetSymbols[planet],
        style: TextStyle(
          fontSize: 9,
          color: planetColors[planet] ?? Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        dotPos + Offset(3.5, -textPainter.height / 2),
      );
      idx++;
    }
  }

  Offset _point(Offset center, double r, double angle) =>
      Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));

  @override
  bool shouldRepaint(covariant _ZodiacWheelPainter old) =>
      old.snapshot != snapshot;
}

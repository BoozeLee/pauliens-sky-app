import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/chart_engine.dart';
import '../theme/cosmic_theme.dart';

class PersonalityRadar extends StatelessWidget {
  final PersonalityProfile profile;
  final double size;

  const PersonalityRadar({super.key, required this.profile, this.size = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(profile),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final PersonalityProfile profile;

  _RadarPainter(this.profile);

  static const _labels = [
    'Intuition', 'Creativity', 'Intellect',
    'Drive', 'Empathy', 'Independence',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 32;

    _drawGrid(canvas, center, r);
    _drawData(canvas, center, r);
    _drawLabels(canvas, center, r);
  }

  List<double> get _values => [
    profile.intuition,
    profile.creativity,
    profile.intellect,
    profile.drive,
    profile.empathy,
    profile.independence,
  ];

  Offset _point(int i, double radius, Offset center) {
    final angle = (i * 2 * math.pi / 6) - math.pi / 2;
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  void _drawGrid(Canvas canvas, Offset center, double r) {
    final gridPaint = Paint()
      ..color = CosmicColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Concentric hexagons
    for (final scale in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final p = _point(i, r * scale, center);
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Spokes
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(center, _point(i, r, center), gridPaint);
    }
  }

  void _drawData(Canvas canvas, Offset center, double r) {
    final values = _values;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final p = _point(i, r * values[i], center);
      if (i == 0) path.moveTo(p.dx, p.dy);
      else path.lineTo(p.dx, p.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            CosmicColors.neonLavender.withValues(alpha: 0.5),
            CosmicColors.neonCyan.withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = CosmicColors.neonLavender
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Dot at each vertex
    for (int i = 0; i < 6; i++) {
      final p = _point(i, r * values[i], center);
      canvas.drawCircle(p, 3.5, Paint()..color = CosmicColors.neonCyan);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double r) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 6; i++) {
      final p = _point(i, r + 22, center);
      final value = (_values[i] * 100).round();
      textPainter.text = TextSpan(
        children: [
          TextSpan(
            text: '${_labels[i]}\n',
            style: const TextStyle(
              color: CosmicColors.textSecondary,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
          TextSpan(
            text: '$value%',
            style: const TextStyle(
              color: CosmicColors.neonLavender,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
      textPainter.textAlign = TextAlign.center;
      textPainter.layout(maxWidth: 70);
      textPainter.paint(
        canvas,
        Offset(p.dx - textPainter.width / 2, p.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => false;
}

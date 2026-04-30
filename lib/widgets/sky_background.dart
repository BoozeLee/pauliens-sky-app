import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';

class SkyBackground extends StatefulWidget {
  final Widget child;
  final int starCount;

  const SkyBackground({super.key, required this.child, this.starCount = 120});

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _stars = List.generate(widget.starCount, (_) => _Star(_rng));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF06011A), CosmicColors.background, Color(0xFF0E0730)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _StarfieldPainter(_stars, _controller.value),
            size: Size.infinite,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x; // 0–1
  final double y;
  final double size;
  final double twinkleOffset;
  final Color color;

  _Star(math.Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        size = rng.nextDouble() * 1.8 + 0.4,
        twinkleOffset = rng.nextDouble(),
        color = _starColor(rng);

  static Color _starColor(math.Random rng) {
    const colors = [
      Colors.white,
      Color(0xFFDDDDFF),
      Color(0xFFFFEECC),
      CosmicColors.neonLavender,
      CosmicColors.neonCyan,
    ];
    return colors[rng.nextInt(colors.length)];
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarfieldPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = (math.sin((t + star.twinkleOffset) * 2 * math.pi) + 1) / 2;
      final opacity = 0.3 + twinkle * 0.7;
      final paint = Paint()
        ..color = star.color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.8);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.t != t;
}

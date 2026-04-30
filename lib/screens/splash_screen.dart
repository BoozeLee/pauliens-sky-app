import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';
import 'main_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );
    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    _ctrl.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainNav(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.background,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final opacity = _fadeIn.value * (1.0 - _fadeOut.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Splash art
              Opacity(
                opacity: opacity,
                child: Image.asset(
                  'assets/art/splash.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Dark overlay so text reads
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      CosmicColors.background.withValues(alpha: 0.6 * opacity),
                      CosmicColors.background.withValues(alpha: 0.95 * opacity),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),
              // Title
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: opacity,
                  child: Column(
                    children: [
                      Text(
                        "Paulien's Sky",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'One sky · Many traditions',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/cosmic_theme.dart';

class PauliensApp extends StatelessWidget {
  const PauliensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Paulien's Sky",
      theme: CosmicTheme.dark,
      debugShowCheckedModeBanner: false,
      // Constrain to phone-width on desktop so the mobile UI looks correct
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

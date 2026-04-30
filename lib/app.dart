import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/cosmic_theme.dart';

class PauliensApp extends StatelessWidget {
  const PauliensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Paulien's Sky",
      theme: CosmicTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/cosmic_theme.dart';

class PauliensApp extends StatelessWidget {
  final AppState appState;
  const PauliensApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        title: "Paulien's Sky",
        theme: CosmicTheme.dark,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child!,
            ),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}

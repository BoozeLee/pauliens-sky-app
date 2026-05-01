import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/locale_service.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/cosmic_theme.dart';

class PauliensApp extends StatelessWidget {
  final AppState appState;
  const PauliensApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<LocaleService>.value(
            value: LocaleService.instance),
      ],
      child: MaterialApp(
        title: "Paulien's Sky V2",
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

// Convenience extension so any widget can do: context.t('key')
extension TrExt on BuildContext {
  String t(String key) => LocaleService.instance.t(key);
}

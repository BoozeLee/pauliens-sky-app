import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'services/fixed_stars.dart';
import 'services/locale_service.dart';
import 'services/premium_service.dart';
import 'services/supabase_service.dart';
import 'services/ui_schema.dart';
import 'state/app_state.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://example@sentry.io/example'; // TODO: Load from env
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      GoogleFonts.config.allowRuntimeFetching = false;

      final appState = AppState();

      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0A0520),
        ));
      }

      runApp(PauliensApp(appState: appState));
      _initializeAfterFirstFrame(appState);
    },
  );
}

Future<void> _initializeAfterFirstFrame(AppState appState) async {
  try {
    await PremiumService.init();
    await PremiumService.instance.loadApiKeys();
    await LocaleService.init();
    await UiSchema.load();
    await FixedStars.loadCatalog();
    await SupabaseService.instance.init();
    await appState.init();
  } catch (error, stackTrace) {
    debugPrint('Startup initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    appState.computeFallbackChart();
  }
}

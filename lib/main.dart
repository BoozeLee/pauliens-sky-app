import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/fixed_stars.dart';
import 'services/locale_service.dart';
import 'services/premium_service.dart';
import 'services/ui_schema.dart';
import 'state/app_state.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PremiumService.init();
  await PremiumService.instance.loadApiKeys();
  await LocaleService.init();
  await UiSchema.load();
  await FixedStars.loadCatalog();

  final appState = AppState();
  await appState.init();

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
}

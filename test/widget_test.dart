import 'package:flutter_test/flutter_test.dart';
import 'package:pauliens_sky/app.dart';
import 'package:pauliens_sky/state/app_state.dart';
import 'package:pauliens_sky/services/locale_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Set up mock shared preferences for testing
    SharedPreferences.setMockInitialValues({});
    // Initialize LocaleService before each test
    await LocaleService.init();
  });

  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(PauliensApp(appState: AppState()));
    expect(find.text("Paulien's Sky"), findsOneWidget);
  });
}

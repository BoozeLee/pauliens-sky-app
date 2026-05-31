import 'package:flutter_test/flutter_test.dart';
import 'package:pauliens_sky/app.dart';
import 'package:pauliens_sky/state/app_state.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(PauliensApp(appState: AppState()));
    expect(find.text("Paulien's Sky"), findsOneWidget);
  });
}

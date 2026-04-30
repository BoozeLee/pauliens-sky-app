import 'package:flutter_test/flutter_test.dart';
import 'package:pauliens_sky/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PauliensApp());
    expect(find.text("Paulien's Sky"), findsOneWidget);
  });
}

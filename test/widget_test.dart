import 'package:flutter_test/flutter_test.dart';
import 'package:plantify/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlantifyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Detect Disease'), findsOneWidget);
    expect(find.text('My Crops Articles'), findsOneWidget);
  });
}
import 'package:bockaire/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize GetIt before testing
    await setupGetIt();

    // Build our app and trigger a frame
    await tester.pumpWidget(const BockaireApp());
    await tester.pumpAndSettle();

    // Verify home page loads
    expect(find.text('Bockaire'), findsOneWidget);
    expect(find.text('Recent Shipments'), findsOneWidget);
  });
}

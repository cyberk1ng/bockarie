import 'package:bockaire/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize GetIt before testing
    await setupGetIt();

    // Build our app and trigger a frame
    await tester.pumpWidget(const BockaireApp());

    // Verify home page loads
    expect(find.text('Bockaire - Shipping Optimizer'), findsOneWidget);
    expect(find.text('Recent Shipments'), findsOneWidget);
  });
}

import 'package:bockaire/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize GetIt before testing
    await setupGetIt();

    // Build our app and trigger a frame (wrap in ProviderScope)
    await tester.pumpWidget(const ProviderScope(child: BockaireApp()));

    // Use pump() instead of pumpAndSettle() because HomePage uses StreamProvider
    // which continuously emits updates
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify home page loads
    expect(find.text('Bockaire'), findsOneWidget);
    expect(find.text('Recent Shipments'), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_vms/app.dart';

void main() {
  testWidgets('Stark VMS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify Stark VMS brand tag renders on screen
    expect(find.text('STARK VMS'), findsWidgets);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stark_vms/app.dart';
import 'package:stark_vms/src/data/services/cache/cache_service.dart';

void main() {
  testWidgets('Stark VMS app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Stark VMS brand tag renders on screen
    expect(find.text('STARK VMS'), findsWidgets);
  });
}

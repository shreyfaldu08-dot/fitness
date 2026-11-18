import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitora/main.dart';
import 'package:fitora/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();
  });

  testWidgets('FITORA app launches and displays initial brand view', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FitoraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FitoraApp), findsOneWidget);
  });
}

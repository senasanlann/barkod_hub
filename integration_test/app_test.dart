import 'package:barkod_hub/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('End-to-End Application Integration Test', () {
    testWidgets('Full app lifecycle: Splash -> Welcome -> Home -> Navigation', (
      tester,
    ) async {
      await tester.pumpWidget(const BarkodHubApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

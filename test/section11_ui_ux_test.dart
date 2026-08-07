import 'package:barkod_hub/core/theme/app_theme.dart';
import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:barkod_hub/features/sectors/sector_detail_screen.dart';
import 'package:barkod_hub/shared/widgets/app_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section 11 UI/UX Enhancements', () {
    test('AppTheme renders light theme without font family error', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, isNotNull);
      expect(theme.colorScheme.primary, isNotNull);
    });

    testWidgets('AppSkeleton widget renders pulse animation container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSkeleton(width: 200, height: 50),
          ),
        ),
      );

      expect(find.byType(AppSkeleton), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('SectorDetailScreen renders AppSkeleton widgets while loading', (tester) async {
      const sector = SectorModel(
        id: 's-test',
        name: 'Test Sektör',
        slug: 'test',
        itemCount: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SectorDetailScreen(sector: sector),
        ),
      );

      expect(find.byType(AppSkeleton), findsWidgets);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    });
  });
}

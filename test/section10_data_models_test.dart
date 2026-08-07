import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/features/admin/admin_reports_screen.dart';
import 'package:barkod_hub/features/auth/models/user_model.dart';
import 'package:barkod_hub/features/home/home_screen.dart';
import 'package:barkod_hub/features/home/widgets/sector_card.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:barkod_hub/features/suggestion/models/suggestion_model.dart';
import 'package:barkod_hub/features/suggestion/suggestion_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ServiceLocator.suggestionQueueService.clearAll();
  });

  group('Section 10 Data Models & UI Integration', () {
    test('ProductModel supports id, sector and updatedAt fields', () {
      final product = ProductModel(
        id: 'p100',
        barcode: '8690000000100',
        name: 'Test Product',
        sector: 'Gıda',
        updatedAt: '2026-08-07T12:00:00Z',
        rawData: const {},
      );

      expect(product.id, equals('p100'));
      expect(product.sector, equals('Gıda'));
      expect(product.updatedAt, equals('2026-08-07T12:00:00Z'));
    });

    test(
      'AuthService supports explicit UserRole assignment on login',
      () async {
        final auth = ServiceLocator.authService;
        await auth.login('custom@email.com', '123456', role: UserRole.editor);
        final user = await auth.getCurrentUser();

        expect(user.role, equals(UserRole.editor));
        expect(user.role.displayName, equals('Editör'));
      },
    );

    testWidgets(
      'HomeScreen displays Gelen Ürün Önerileri & Bildirimler button for Editor role',
      (tester) async {
        await ServiceLocator.authService.login(
          'editor@bilsoft.com',
          '123456',
          role: UserRole.editor,
        );

        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Gelen Ürün Önerileri & Bildirimler'), findsOneWidget);
      },
    );

    testWidgets('SectorCard displays network image when imageUrl is present', (
      tester,
    ) async {
      const sector = SectorModel(
        id: 's-gida',
        name: 'Gıda',
        slug: 'gida',
        itemCount: 42,
        imageUrl: 'https://example.com/gida.png',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectorCard(sector: sector, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    test(
      'SuggestionModel contains all required fields and JSON round-trip',
      () {
        final suggestion = SuggestionModel.create(
          type: 'product_suggestion',
          barcode: '8690000000101',
          productName: 'Yeni Ürün Önerisi',
          sector: 'Temel Gıda',
          note: 'Eksik marka bilgisi',
          imagePath: '/tmp/image.jpg',
        );

        final json = suggestion.toJson();
        final back = SuggestionModel.fromJson(json);

        expect(back.barcode, equals('8690000000101'));
        expect(back.productName, equals('Yeni Ürün Önerisi'));
        expect(back.sector, equals('Temel Gıda'));
        expect(back.note, equals('Eksik marka bilgisi'));
        expect(back.imagePath, equals('/tmp/image.jpg'));
        expect(back.syncStatus, equals('pending'));
      },
    );

    testWidgets(
      'SuggestionFormScreen pre-fills fields and sector picker when initialProduct is provided',
      (tester) async {
        const product = ProductModel(
          barcode: '8690504018087',
          name: 'Ülker Çikolatalı Gofret',
          brand: 'Ülker',
          category: 'Atıştırmalık',
          sector: 'Atıştırmalık',
          rawData: {},
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: SuggestionFormScreen(
              barcode: '8690504018087',
              initialProduct: product,
            ),
          ),
        );

        expect(find.text('Ürün Bilgisini Düzenle'), findsWidgets);
        expect(find.text('Ülker Çikolatalı Gofret'), findsOneWidget);
        expect(find.text('Ülker'), findsOneWidget);
        expect(find.text('Atıştırmalık'), findsWidgets);
        expect(find.text('Süt & Süt Ürünleri'), findsOneWidget);
        expect(find.text('Sektör Seçin'), findsOneWidget);
      },
    );

    testWidgets(
      'mock suggestion remains queued and is visible in AdminReportsScreen',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SuggestionFormScreen(barcode: '8690000000999'),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        await tester.enterText(
          find.widgetWithText(TextField, 'Ürün Adı *'),
          'Panelde Bekleyen Ürün',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Marka'),
          'Test Marka',
        );
        await tester.ensureVisible(find.text('Öneriyi Kaydet'));
        await tester.tap(find.text('Öneriyi Kaydet'));
        await tester.pump(const Duration(seconds: 1));

        final queued = await ServiceLocator.suggestionQueueService.getAll();
        expect(queued, hasLength(1));
        expect(queued.single.productName, 'Panelde Bekleyen Ürün');
        expect(queued.single.syncStatus, 'pending');

        await tester.pumpWidget(const MaterialApp(home: AdminReportsScreen()));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Ürün Adı: Panelde Bekleyen Ürün'), findsOneWidget);
        expect(find.text('Marka: Test Marka'), findsOneWidget);
        expect(find.text('Onayla'), findsOneWidget);
        expect(find.text('Reddet'), findsOneWidget);

        await tester.tap(find.text('Onayla'));
        await tester.pump(const Duration(seconds: 1));
        expect(await ServiceLocator.suggestionQueueService.getAll(), isEmpty);

        final rejectedSuggestion = SuggestionModel.create(
          type: 'product_suggestion',
          barcode: '8690000001000',
          productName: 'Reddedilecek Ürün',
        );
        await ServiceLocator.suggestionQueueService.enqueue(rejectedSuggestion);
        await tester.pumpWidget(const MaterialApp(home: AdminReportsScreen()));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Ürün Adı: Reddedilecek Ürün'), findsOneWidget);
        await tester.tap(find.text('Reddet'));
        await tester.pump(const Duration(seconds: 1));
        expect(await ServiceLocator.suggestionQueueService.getAll(), isEmpty);
      },
    );
  });
}

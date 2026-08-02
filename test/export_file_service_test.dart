import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/services/export_file_service.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final products = [
    ProductModel.fromJson({
      'barcode': '111',
      'name': 'Ürün A',
      'brand': 'Marka A',
      'category': 'Kategori A',
      'price': '10.5',
      'imageUrl': 'https://example.com/a.jpg',
    }),
    ProductModel.fromJson({
      'barcode': '222',
      'name': 'Ürün B',
      'brand': 'Marka B',
      'category': 'Kategori B',
      'price': '20.0',
      'imageUrl': 'https://example.com/b.jpg',
    }),
  ];

  group('ExportFileService.buildPdf', () {
    test('produces bytes with a valid PDF header', () async {
      final service = ExportFileService(dio: ApiClient().dio);

      final bytes = await service.buildPdf(
        title: 'Test Listesi',
        products: products,
      );

      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    });

    test('produces PDF bytes for long filtered lists', () async {
      final service = ExportFileService(dio: ApiClient().dio);
      final longList = List.generate(
        400,
        (index) => ProductModel.fromJson({
          'barcode': '869000000$index',
          'name': 'Filtreli Ürün $index',
          'brand': 'Marka',
          'category': 'Dondurma',
          'price': '10.5',
        }),
      );

      final bytes = await service.buildPdf(
        title: 'Uzun Test Listesi',
        products: longList,
      );

      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    });
  });

  group('ExportFileService.buildExcel', () {
    test(
      'produces a readable xlsx with a header row and product rows',
      () async {
        final service = ExportFileService(dio: ApiClient().dio);

        final bytes = await service.buildExcel(
          title: 'Test Listesi',
          products: products,
        );

        final decoded = excel_lib.Excel.decodeBytes(bytes);
        final sheet = decoded.tables[decoded.tables.keys.first]!;

        expect(sheet.maxRows, 3); // header + 2 products
        expect(sheet.rows[1][0]?.value.toString(), 'Ürün A');
        expect(sheet.rows[2][0]?.value.toString(), 'Ürün B');
      },
    );
  });

  group('ExportFileService.buildImagesZip', () {
    test('bundles images fetched through the injected fetcher', () async {
      final service = ExportFileService(
        dio: ApiClient().dio,
        imageFetcher: (url) async => utf8.encode('fake-image-bytes-$url'),
      );

      final result = await service.buildImagesZip(products: products);

      expect(result.totalImages, 2);
      expect(result.includedImages, 2);
      expect(result.hasFailures, isFalse);

      final archive = ZipDecoder().decodeBytes(result.bytes);
      expect(archive.files, hasLength(2));
    });

    test(
      'skips images that fail to fetch without failing the whole zip',
      () async {
        final service = ExportFileService(
          dio: ApiClient().dio,
          imageFetcher: (url) async {
            if (url.contains('a.jpg')) {
              throw Exception('network error');
            }
            return utf8.encode('fake-image-bytes-$url');
          },
        );

        final result = await service.buildImagesZip(products: products);

        expect(result.totalImages, 2);
        expect(result.includedImages, 1);
        expect(result.hasFailures, isTrue);
      },
    );

    test('retry only re-fetches previously failed images', () async {
      var callCount = 0;
      final service = ExportFileService(
        dio: ApiClient().dio,
        imageFetcher: (url) async {
          callCount++;
          if (url.contains('a.jpg')) {
            throw Exception('network error');
          }
          return utf8.encode('fake-image-bytes-$url');
        },
      );

      final first = await service.buildImagesZip(products: products);
      expect(first.includedImages, 1);

      final callsAfterFirst = callCount;

      final retry = await service.buildImagesZip(
        products: products,
        previousSuccesses: first.imageCache,
      );

      // Only the previously failed image ("a.jpg") should be retried.
      expect(callCount, callsAfterFirst + 1);
      expect(retry.includedImages, 1);
    });
  });
}

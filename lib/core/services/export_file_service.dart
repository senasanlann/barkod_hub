import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/product/models/product_model.dart';

class ZipBuildResult {
  final Uint8List bytes;
  final int totalImages;
  final int includedImages;
  final Map<String, List<int>> imageCache;

  const ZipBuildResult({
    required this.bytes,
    required this.totalImages,
    required this.includedImages,
    required this.imageCache,
  });

  bool get hasFailures => includedImages < totalImages;
}

class ExportFileService {
  ExportFileService({
    required Dio dio,
    Future<List<int>> Function(String url)? imageFetcher,
  }) : _imageFetcher = imageFetcher ?? _defaultImageFetcher(dio);

  final Future<List<int>> Function(String url) _imageFetcher;

  static Future<List<int>> Function(String url) _defaultImageFetcher(Dio dio) {
    return (url) async {
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      return response.data ?? const [];
    };
  }

  Future<pw.Font> _loadFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }

  Future<Uint8List> buildPdf({
    required String title,
    required List<ProductModel> products,
  }) async {
    final regularFont = await _loadFont('assets/fonts/NotoSans-Regular.ttf');
    final boldFont = await _loadFont('assets/fonts/NotoSans-Bold.ttf');

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );
    const headers = ['Ürün Adı', 'Barkod', 'Marka', 'Kategori', 'Fiyat'];
    final rows = products
        .map(
          (product) => [
            product.name ?? '-',
            product.barcode ?? '-',
            product.brand ?? '-',
            product.category ?? '-',
            product.price != null
                ? '${product.price!.toStringAsFixed(2)} TL'
                : '-',
          ],
        )
        .toList();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        maxPages: 1000,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('${products.length} ürün'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(headers: headers, data: rows),
        ],
      ),
    );

    return document.save();
  }

  Future<Uint8List> buildExcel({
    required String title,
    required List<ProductModel> products,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final sheet = excel[sheetName];

    sheet.appendRow([
      TextCellValue('Ürün Adı'),
      TextCellValue('Barkod'),
      TextCellValue('Marka'),
      TextCellValue('Kategori'),
      TextCellValue('Fiyat'),
    ]);

    for (final product in products) {
      sheet.appendRow([
        TextCellValue(product.name ?? '-'),
        TextCellValue(product.barcode ?? '-'),
        TextCellValue(product.brand ?? '-'),
        TextCellValue(product.category ?? '-'),
        product.price != null
            ? DoubleCellValue(product.price!)
            : TextCellValue('-'),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('Excel dosyası oluşturulamadı.');
    }

    return Uint8List.fromList(bytes);
  }

  Future<ZipBuildResult> buildImagesZip({
    required List<ProductModel> products,
    void Function(int done, int total)? onProgress,
    Map<String, List<int>>? previousSuccesses,
  }) async {
    final archive = Archive();
    final withImages = products
        .where((product) => (product.imageUrl ?? '').trim().isNotEmpty)
        .toList();
    final total = withImages.length;
    var done = 0;
    var included = 0;
    final imageCache = Map<String, List<int>>.from(previousSuccesses ?? {});

    for (final product in withImages) {
      final url = product.imageUrl!;
      var bytes = imageCache[url];

      if (bytes == null) {
        try {
          final fetched = await _imageFetcher(url);
          if (fetched.isNotEmpty) {
            bytes = fetched;
            imageCache[url] = fetched;
          }
        } catch (_) {
          bytes = null;
        }
      }

      if (bytes != null && bytes.isNotEmpty) {
        final fileName = '${_safeFileName(product)}.${_extensionFromUrl(url)}';
        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
        included++;
      }

      done++;
      onProgress?.call(done, total);
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw Exception('ZIP dosyası oluşturulamadı.');
    }

    return ZipBuildResult(
      bytes: Uint8List.fromList(encoded),
      totalImages: total,
      includedImages: included,
      imageCache: imageCache,
    );
  }

  String _safeFileName(ProductModel product) {
    final base =
        product.barcode ?? product.name ?? product.imageUrl.hashCode.toString();
    return base.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  String _extensionFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final dotIndex = path.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == path.length - 1) return 'jpg';

    final extension = path.substring(dotIndex + 1).toLowerCase();
    return extension.length <= 4 ? extension : 'jpg';
  }
}

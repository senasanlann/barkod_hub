import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../../features/product/models/product_model.dart';
import '../../features/sectors/models/barcode_list_model.dart';
import '../../features/sectors/models/sector_model.dart';
import '../../features/suggestion/models/suggestion_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_exception.dart';

class ApiService {
  final ApiClient client;
  final bool useMockData;
  Future<List<Map<String, dynamic>>>? _csvProducts;

  ApiService({required this.client, bool? useMockData})
    : useMockData = useMockData ?? ApiConstants.useMockData;

  Future<bool> postProductSuggestion(SuggestionModel suggestion) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    try {
      await client.post(
        ApiConstants.productSuggestions,
        data: suggestion.toJson(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> postImageReport(SuggestionModel report) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    try {
      await client.post(ApiConstants.imageReports, data: report.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return client.get(path, queryParameters: queryParameters);
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return client.post(path, data: data, queryParameters: queryParameters);
  }

  Future<ProductModel> getProductByBarcode(String barcode) async {
    // 1. Önce CSV'de ara (hızlı, offline çalışır)
    final csvProducts = await _loadCsvProducts();
    for (final product in csvProducts) {
      if (product['barcode']?.toString().trim() == barcode) {
        final model = ProductModel.fromJson(product);
        if (model.name != null && model.name!.trim().isNotEmpty) {
          return model;
        }
      }
    }

    if (useMockData) {
      return ProductModel.fromJson({
        'barcode': barcode,
        'status': 'CSV dosyasında ürün bulunamadı',
      });
    }

    // 2. CSV'de bulunamazsa OFF'a git (Open Food Facts API)
    try {
      final offUrl =
          '${ApiConstants.offBaseUrl}${ApiConstants.offProductPath}/$barcode.json';
      final response = await client.get(
        offUrl,
        queryParameters: {
          'fields': 'code,product_name,brands,categories,image_url,quantity',
        },
      );

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final status = map['status'];

        if (status == 0 || status == '0') {
          return ProductModel.fromJson({
            'barcode': barcode,
            'status': 'Ürün bulunamadı',
          });
        }

        if (map['product'] is Map) {
          final productMap = Map<String, dynamic>.from(map['product'] as Map);

          final rawCategories = productMap['categories']?.toString().trim();
          String? category;
          if (rawCategories != null && rawCategories.isNotEmpty) {
            category = rawCategories.split(',').first.trim();
          }

          final mappedProduct = <String, dynamic>{
            ...productMap,
            'barcode': productMap['code']?.toString() ?? barcode,
            'name': productMap['product_name']?.toString(),
            'brand': productMap['brands']?.toString(),
            'category': category ?? productMap['categories']?.toString(),
            'imageUrl': productMap['image_url']?.toString(),
            'source': 'OpenFoodFacts',
          };

          final product = ProductModel.fromJson(mappedProduct);
          if (product.name != null && product.name!.trim().isNotEmpty) {
            return product;
          }
        }
      }
    } catch (_) {
      // Ağ hatasında exception fırlatmak yerine "Ürün bulunamadı" durumuna düş
    }

    return ProductModel.fromJson({
      'barcode': barcode,
      'status': 'Ürün bulunamadı',
    });
  }

  Future<bool> postScanLog(String barcode, String status) async {
    try {
      await client.post(
        ApiConstants.scanLogs,
        data: {
          'barcode': barcode,
          'status': status,
          'scannedAt': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<SectorModel>> getSectors() async {
    // 1. Önce yerel CSV'den sektörleri üret. Uygulama API beklemeden açılır.
    final csvSectors = await _getMockSectors();
    if (csvSectors.isNotEmpty || useMockData) {
      return csvSectors;
    }

    // 2. CSV boşsa gerçek API ikinci kaynak olarak denenir.
    final response = await client.get(ApiConstants.sectors);
    final data = _extractData(response);

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => SectorModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Sektör listesi beklenen formatta gelmedi.');
  }

  Future<({BarcodeListModel list, List<ProductModel> items})> getSectorList(
    String sectorId,
  ) async {
    // 1. Önce CSV'den sektör ürünlerini getir. API ikinci sıradadır.
    final csvResult = await _getMockSectorList(sectorId);
    if (csvResult.items.isNotEmpty || useMockData) {
      return csvResult;
    }

    // 2. CSV'de bu sektör yoksa gerçek API denenir.
    final response = await client.get(
      '${ApiConstants.listItems}/$sectorId/items',
    );
    final data = _extractData(response);

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      return (
        list: BarcodeListModel.fromJson(map),
        items: _parseItems(map['items']),
      );
    }

    if (data is List) {
      final items = _parseItems(data);

      return (
        list: BarcodeListModel(
          id: sectorId,
          sectorId: sectorId,
          title: '',
          version: '',
          itemCount: items.length,
          exportLinks: const {},
        ),
        items: items,
      );
    }

    throw Exception('Liste ürünleri beklenen formatta gelmedi.');
  }

  Future<Map<String, dynamic>> getExportJob(String jobId) async {
    if (useMockData) {
      return _getMockExportJob(jobId);
    }

    final response = await client.get('${ApiConstants.exportJobs}/$jobId');
    final data = _extractData(response);

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Export bilgisi beklenen formatta gelmedi.');
  }

  List<ProductModel> _parseItems(dynamic itemsData) {
    if (itemsData is! List) return const [];

    return itemsData
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    final csvProducts = await _loadCsvProducts();
    final matches = csvProducts.where((p) {
      final name = p['name']?.toString().toLowerCase() ?? '';
      final barcode = p['barcode']?.toString().toLowerCase() ?? '';
      final brand = p['brand']?.toString().toLowerCase() ?? '';
      return name.contains(trimmed) || barcode.contains(trimmed) || brand.contains(trimmed);
    }).map((json) => ProductModel.fromJson(json)).toList();

    if (matches.isNotEmpty || useMockData) {
      return matches;
    }

    final response = await client.get(
      '/api/v1/products/search',
      queryParameters: {'q': query},
    );
    final data = _extractData(response);

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const [];
  }

  dynamic _extractData(dynamic response) {
    if (response is Map) {
      if (response.containsKey('success') && response['success'] == false) {
        final message = response['message']?.toString() ?? 'İşlem başarısız oldu.';
        throw ApiException(message);
      }
      if (response.containsKey('data')) {
        return response['data'];
      }
    }

    return response;
  }

  Future<List<SectorModel>> _getMockSectors() async {
    final products = await _loadCsvProducts();
    final counts = <String, int>{};

    for (final product in products) {
      final sector = product['sector']?.toString().trim() ?? '';
      if (sector.isNotEmpty) {
        counts.update(sector, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    return counts.entries
        .map(
          (entry) => SectorModel(
            id: 's-${_slugify(entry.key)}',
            name: entry.key,
            slug: _slugify(entry.key),
            itemCount: entry.value,
          ),
        )
        .toList();
  }

  Future<({BarcodeListModel list, List<ProductModel> items})>
  _getMockSectorList(String sectorId) async {
    final products = await _loadCsvProducts();
    final sectorSlug = sectorId.startsWith('s-')
        ? sectorId.substring(2)
        : sectorId;
    final itemsJson = products
        .where(
          (item) => _slugify(item['sector']?.toString() ?? '') == sectorSlug,
        )
        .toList();
    final sectorName = itemsJson.isEmpty
        ? 'Sektör'
        : itemsJson.first['sector']?.toString() ?? 'Sektör';

    final list = BarcodeListModel(
      id: 'l-$sectorId',
      sectorId: sectorId,
      title: '$sectorName Listesi',
      version: '2026.07',
      itemCount: itemsJson.length,
      exportLinks: {
        'pdf': 'https://example.com/lists/$sectorId.pdf',
        'excel': 'https://example.com/lists/$sectorId.xlsx',
      },
    );

    final items = itemsJson.map((item) => ProductModel.fromJson(item)).toList();

    return (list: list, items: items);
  }

  Future<Map<String, dynamic>> _getMockExportJob(String jobId) async {
    return {
      'id': jobId,
      'status': 'ready',
      'links': {
        'pdf': 'https://example.com/export/$jobId.pdf',
        'excel': 'https://example.com/export/$jobId.xlsx',
        'zip': 'https://example.com/export/$jobId.zip',
      },
    };
  }

  Future<List<Map<String, dynamic>>> _loadCsvProducts() {
    return _csvProducts ??= _readCsvProducts();
  }

  Future<List<Map<String, dynamic>>> _readCsvProducts() async {
    final data = await rootBundle.load('docs/barkod_listesi_mock.csv');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    late final String content;

    try {
      content = utf8.decode(bytes);
    } on FormatException {
      content = latin1.decode(bytes);
    }

    final rows = csv.decode(content);

    if (rows.isEmpty) return const [];

    final headers = rows.first
        .map((cell) => _normalize(cell.toString()))
        .toList();
    final products = <Map<String, dynamic>>[];

    for (final row in rows.skip(1)) {
      final product = <String, dynamic>{};

      for (
        var index = 0;
        index < headers.length && index < row.length;
        index++
      ) {
        final value = row[index].toString().trim();
        if (value.isEmpty) continue;

        final key = _productKey(headers[index]);
        if (key != null) product[key] = value;
      }

      if ((product['barcode']?.toString().trim() ?? '').isNotEmpty) {
        products.add(product);
      }
    }

    return products;
  }

  static String? _productKey(String header) {
    const keys = {
      'sektor': 'sector',
      'sector': 'sector',
      'barkod': 'barcode',
      'barcode': 'barcode',
      'urun adi': 'name',
      'name': 'name',
      'marka': 'brand',
      'brand': 'brand',
      'kategori': 'category',
      'category': 'category',
      'fiyat': 'price',
      'fiyat tl': 'price',
      'price': 'price',
      'urun gorseli': 'imageUrl',
      'gorsel': 'imageUrl',
      'image url': 'imageUrl',
      'imageurl': 'imageUrl',
      'kaynak': 'source',
      'source': 'source',
      'kdv': 'vat',
      'kdv oranı': 'vat',
      'vat': 'vat',
      'tax': 'vat',
    };

    return keys[header];
  }

  static String _slugify(String value) {
    return _normalize(value).replaceAll(' ', '-');
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}

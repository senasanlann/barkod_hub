import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../../features/product/models/product_model.dart';
import '../../features/sectors/models/barcode_list_model.dart';
import '../../features/sectors/models/sector_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

class ApiService {
  final ApiClient client;
  final bool useMockData;
  Future<List<Map<String, dynamic>>>? _csvProducts;

  ApiService({required this.client, bool? useMockData})
    : useMockData = useMockData ?? ApiConstants.useMockData;

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
    if (useMockData) {
      return _getMockProductByBarcode(barcode);
    }

    final response = await client.get(
      ApiConstants.productsByBarcode,
      queryParameters: {'barcode': barcode},
    );

    if (response is Map<String, dynamic>) {
      return ProductModel.fromJson(response);
    }

    if (response is Map) {
      return ProductModel.fromJson(Map<String, dynamic>.from(response));
    }

    return ProductModel(rawData: {'response': response});
  }

  Future<List<SectorModel>> getSectors() async {
    if (useMockData) {
      return _getMockSectors();
    }

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
    if (useMockData) {
      return _getMockSectorList(sectorId);
    }

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

  List<ProductModel> _parseItems(dynamic itemsData) {
    if (itemsData is! List) return const [];

    return itemsData
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  dynamic _extractData(dynamic response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
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

  Future<ProductModel> _getMockProductByBarcode(String barcode) async {
    final products = await _loadCsvProducts();

    for (final product in products) {
      if (product['barcode']?.toString().trim() == barcode) {
        return ProductModel.fromJson(product);
      }
    }

    return ProductModel.fromJson({
      'barcode': barcode,
      'status': 'CSV dosyasında ürün bulunamadı',
    });
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

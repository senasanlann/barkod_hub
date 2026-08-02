import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/downloads/models/download_file_model.dart';
import '../../features/history/models/scan_history_model.dart';
import '../../features/product/models/product_model.dart';
import '../../features/sectors/models/barcode_list_model.dart';

class CachedProduct {
  final ProductModel product;
  final DateTime cachedAt;

  const CachedProduct({required this.product, required this.cachedAt});

  bool get isStale =>
      DateTime.now().difference(cachedAt) > OfflineCacheService.productCacheTtl;
}

class CachedSectorList {
  final BarcodeListModel list;
  final List<ProductModel> items;
  final DateTime cachedAt;

  const CachedSectorList({
    required this.list,
    required this.items,
    required this.cachedAt,
  });
}

class OfflineCacheService {
  OfflineCacheService({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  static const Duration productCacheTtl = Duration(days: 14);
  static const Duration scanHistoryRetention = Duration(days: 30);
  static const int scanHistoryMaxEntries = 100;

  static const String _scanHistoryKey = 'cache_scan_history';
  static const String _downloadedFilesKey = 'cache_downloaded_files';
  static const String _productCachePrefix = 'cache_product_';
  static const String _sectorListCachePrefix = 'cache_sector_list_';


  Future<void> cacheProduct(ProductModel product) async {
    final barcode = product.barcode;
    if (barcode == null || barcode.isEmpty) return;

    final prefs = await _preferences;
    final entry = {
      'product': product.rawData,
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString('$_productCachePrefix$barcode', jsonEncode(entry));
  }

  Future<CachedProduct?> getCachedProduct(String barcode) async {
    final prefs = await _preferences;
    final raw = prefs.getString('$_productCachePrefix$barcode');
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final productJson = Map<String, dynamic>.from(decoded['product'] as Map);
      final cachedAt =
          DateTime.tryParse(decoded['cachedAt']?.toString() ?? '') ??
          DateTime.now();

      return CachedProduct(
        product: ProductModel.fromJson(productJson),
        cachedAt: cachedAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheSectorList(
    String sectorId,
    BarcodeListModel list,
    List<ProductModel> items,
  ) async {
    final prefs = await _preferences;
    final entry = {
      'list': list.toJson(),
      'items': items.map((item) => item.rawData).toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(
      '$_sectorListCachePrefix$sectorId',
      jsonEncode(entry),
    );
  }

  Future<CachedSectorList?> getCachedSectorList(String sectorId) async {
    final prefs = await _preferences;
    final raw = prefs.getString('$_sectorListCachePrefix$sectorId');
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final listJson = Map<String, dynamic>.from(decoded['list'] as Map);
      final itemsJson = (decoded['items'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final cachedAt =
          DateTime.tryParse(decoded['cachedAt']?.toString() ?? '') ??
          DateTime.now();

      return CachedSectorList(
        list: BarcodeListModel.fromJson(listJson),
        items: itemsJson.map(ProductModel.fromJson).toList(),
        cachedAt: cachedAt,
      );
    } catch (_) {
      return null;
    }
  }

  // --- Geçmiş ---

  Future<List<ScanHistoryModel>> getScanHistory() async {
    final prefs = await _preferences;
    final raw = prefs.getStringList(_scanHistoryKey) ?? const [];

    return raw
        .map((item) => ScanHistoryModel.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> addScanHistory(ScanHistoryModel entry) async {
    final prefs = await _preferences;
    final current = await getScanHistory();
    final cutoff = DateTime.now().subtract(scanHistoryRetention);

    final pruned = [
      entry,
      ...current,
    ].where((item) {
      final scannedAt = DateTime.tryParse(item.scannedAt);
      return scannedAt == null || scannedAt.isAfter(cutoff);
    }).take(scanHistoryMaxEntries).toList();

    await prefs.setStringList(
      _scanHistoryKey,
      pruned.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> clearScanHistory() async {
    final prefs = await _preferences;
    await prefs.remove(_scanHistoryKey);
  }

  // --- İndirilen dosyalar ---

  Future<List<DownloadFileModel>> getDownloadedFiles() async {
    final prefs = await _preferences;
    final raw = prefs.getStringList(_downloadedFilesKey) ?? const [];

    return raw
        .map((item) => DownloadFileModel.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> addDownloadedFile(DownloadFileModel file) async {
    final prefs = await _preferences;
    final current = await getDownloadedFiles();
    final updated = [file, ...current];

    await prefs.setStringList(
      _downloadedFilesKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> removeDownloadedFile(String path) async {
    final prefs = await _preferences;
    final current = await getDownloadedFiles();
    final updated = current.where((item) => item.path != path).toList();

    await prefs.setStringList(
      _downloadedFilesKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

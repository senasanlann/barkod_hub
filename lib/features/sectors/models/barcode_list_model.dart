class BarcodeListModel {
  final String id;
  final String sectorId;
  final String title;
  final String version;
  final int itemCount;
  final Map<String, dynamic> exportLinks;

  const BarcodeListModel({
    required this.id,
    required this.sectorId,
    required this.title,
    required this.version,
    required this.itemCount,
    required this.exportLinks,
  });

  factory BarcodeListModel.fromJson(Map<String, dynamic> json) {
    return BarcodeListModel(
      id: _readFirst(json, ['id', 'listId', 'list_id']) ?? '',
      sectorId: _readFirst(json, ['sectorId', 'sector_id']) ?? '',
      title: _readFirst(json, ['title', 'name', 'listName', 'list_name']) ?? '',
      version: _readFirst(json, ['version', 'updatedAt', 'updated_at']) ?? '',
      itemCount: _readInt(json, [
        'itemCount',
        'item_count',
        'productCount',
        'product_count',
      ]),
      exportLinks: _readMap(json, ['exportLinks', 'export_links', 'downloads']),
    );
  }

  static String? _readFirst(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return null;
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    final value = _readFirst(json, keys);

    return int.tryParse(value ?? '') ?? 0;
  }

  static Map<String, dynamic> _readMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value is Map<String, dynamic>) {
        return value;
      }

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectorId': sectorId,
      'title': title,
      'version': version,
      'itemCount': itemCount,
      'exportLinks': exportLinks,
    };
  }
}
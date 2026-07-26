class SectorModel {
  final String id;
  final String name;
  final String slug;
  final int itemCount;
  final String? imageUrl;

  const SectorModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.itemCount,
    this.imageUrl,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: _readFirst(json, ['id', 'sectorId', 'sector_id']) ?? '',
      name:
          _readFirst(json, ['name', 'title', 'sectorName', 'sector_name']) ??
          '',
      slug: _readFirst(json, ['slug', 'code']) ?? '',
      itemCount: _readInt(json, [
        'itemCount',
        'item_count',
        'productCount',
        'product_count',
      ]),
      imageUrl: _readFirst(json, [
        'imageUrl',
        'image_url',
        'iconUrl',
        'icon_url',
      ]),
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
}

class ProductModel {
  final String? id;
  final String? barcode;
  final String? name;
  final String? brand;
  final String? sector;
  final String? category;
  final double? price;
  final String? imageUrl;
  final String? updatedAt;
  final Map<String, dynamic> rawData;

  const ProductModel({
    required this.rawData,
    this.id,
    this.barcode,
    this.name,
    this.brand,
    this.sector,
    this.category,
    this.price,
    this.imageUrl,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      rawData: json,
      id: _readFirst(json, ['id', 'productId', 'product_id']),
      barcode: _readFirst(json, ['barcode', 'barCode', 'barkod']),
      name: _readFirst(json, ['name', 'productName', 'title', 'urunAdi']),
      brand: _readFirst(json, ['brand', 'brandName', 'manufacturer', 'marka']),
      sector: _readFirst(json, ['sector', 'sectorName', 'sector_name']),
      category: _readFirst(json, ['category', 'categoryName', 'kategori']),
      price: _readDouble(json, ['price', 'salePrice', 'sale_price', 'fiyat']),
      imageUrl: _readFirst(json, ['imageUrl', 'image_url', 'image', 'gorsel']),
      updatedAt: _readFirst(json, ['updatedAt', 'updated_at', 'lastUpdate']),
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

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    final value = _readFirst(json, keys);

    if (value == null) return null;

    return double.tryParse(value.replaceAll(',', '.'));
  }
}

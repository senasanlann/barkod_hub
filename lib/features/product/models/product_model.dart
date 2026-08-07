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

  ProductModel copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    String? sector,
    String? category,
    double? price,
    String? imageUrl,
    String? updatedAt,
    Map<String, dynamic>? rawData,
  }) {
    return ProductModel(
      rawData: rawData ?? this.rawData,
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      sector: sector ?? this.sector,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      rawData: json,
      id: _readFirst(json, ['id', 'productId', 'product_id', '_id']),
      barcode: _readFirst(json, ['barcode', 'barCode', 'barkod', 'code']),
      name: _readFirst(json, [
        'name',
        'productName',
        'title',
        'urunAdi',
        'product_name',
        'product_name_tr',
        'product_name_en',
      ]),
      brand: _readFirst(json, [
        'brand',
        'brandName',
        'manufacturer',
        'marka',
        'brands',
      ]),
      sector: _readFirst(json, ['sector', 'sectorName', 'sector_name']),
      category: _readFirst(json, [
        'category',
        'categoryName',
        'kategori',
        'categories',
      ]),
      price: _readDouble(json, ['price', 'salePrice', 'sale_price', 'fiyat']),
      imageUrl: _readFirst(json, [
        'imageUrl',
        'image_url',
        'image',
        'gorsel',
        'image_front_url',
        'image_small_url',
      ]),
      updatedAt: _readFirst(json, ['updatedAt', 'updated_at', 'lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...rawData,
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (sector != null) 'sector': sector,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
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

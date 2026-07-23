class ProductModel {
  final String? barcode;
  final String? name;
  final String? brand;
  final String? category;
  final Map<String, dynamic> rawData;

  const ProductModel({
    required this.rawData,
    this.barcode,
    this.name,
    this.brand,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      rawData: json,
      barcode: _readFirst(json, ['barcode', 'barCode', 'barkod']),
      name: _readFirst(json, ['name', 'productName', 'title', 'urunAdi']),
      brand: _readFirst(json, ['brand', 'brandName', 'manufacturer', 'marka']),
      category: _readFirst(json, ['category', 'categoryName', 'kategori']),
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
}
class SuggestionModel {
  final String id;
  final String type; // 'product_suggestion' | 'image_report'
  final String barcode;
  final String? productName;
  final String? brand;
  final String? category;
  final String? sector;
  final String? note;
  final String? imagePath;
  final DateTime createdAt;
  final String syncStatus; // 'pending' | 'syncing' | 'synced' | 'failed'
  final int attemptCount;

  const SuggestionModel({
    required this.id,
    required this.type,
    required this.barcode,
    this.productName,
    this.brand,
    this.category,
    this.sector,
    this.note,
    this.imagePath,
    required this.createdAt,
    required this.syncStatus,
    required this.attemptCount,
  });

  static int _counter = 0;

  factory SuggestionModel.create({
    required String type,
    required String barcode,
    String? productName,
    String? brand,
    String? category,
    String? sector,
    String? note,
    String? imagePath,
  }) {
    final now = DateTime.now();
    final uniqueId = '${now.millisecondsSinceEpoch}_${_counter++}';

    return SuggestionModel(
      id: uniqueId,
      type: type,
      barcode: barcode,
      productName: productName,
      brand: brand,
      category: category,
      sector: sector,
      note: note,
      imagePath: imagePath,
      createdAt: now,
      syncStatus: 'pending',
      attemptCount: 0,
    );
  }

  SuggestionModel copyWith({
    String? id,
    String? type,
    String? barcode,
    String? productName,
    String? brand,
    String? category,
    String? sector,
    String? note,
    String? imagePath,
    DateTime? createdAt,
    String? syncStatus,
    int? attemptCount,
  }) {
    return SuggestionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      sector: sector ?? this.sector,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'category': category,
      'sector': sector,
      'note': note,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
      'attemptCount': attemptCount,
    };
  }

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = _readFirst(json, ['createdAt', 'created_at']);
    final parsedDate = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
        : DateTime.now();

    return SuggestionModel(
      id: _readFirst(json, ['id']) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _readFirst(json, ['type']) ?? 'product_suggestion',
      barcode: _readFirst(json, ['barcode', 'code']) ?? '',
      productName: _readFirst(json, ['productName', 'product_name', 'name']),
      brand: _readFirst(json, ['brand', 'brands']),
      category: _readFirst(json, ['category', 'categories']),
      sector: _readFirst(json, ['sector', 'sektor']),
      note: _readFirst(json, ['note', 'description']),
      imagePath: _readFirst(json, ['imagePath', 'image_path']),
      createdAt: parsedDate,
      syncStatus: _readFirst(json, ['syncStatus', 'sync_status']) ?? 'pending',
      attemptCount: _readInt(json, ['attemptCount', 'attempt_count']),
    );
  }

  static String? _readFirst(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        if (value is int) return value;
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }
}

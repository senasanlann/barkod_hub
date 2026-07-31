class ScanHistoryModel {
  final String barcode;
  final String? productName;
  final String? imageUrl;
  final String scannedAt;
  final String status;

  const ScanHistoryModel({
    required this.barcode,
    required this.scannedAt,
    required this.status,
    this.productName,
    this.imageUrl,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      barcode: json['barcode']?.toString() ?? '',
      productName: json['productName']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      scannedAt: json['scannedAt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'productName': productName,
      'imageUrl': imageUrl,
      'scannedAt': scannedAt,
      'status': status,
    };
  }
}

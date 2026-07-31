class DownloadFileModel {
  final String fileName;
  final String fileType;
  final String path;
  final int size;
  final String downloadedAt;

  const DownloadFileModel({
    required this.fileName,
    required this.fileType,
    required this.path,
    required this.size,
    required this.downloadedAt,
  });

  factory DownloadFileModel.fromJson(Map<String, dynamic> json) {
    return DownloadFileModel(
      fileName: json['fileName']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      size: int.tryParse(json['size']?.toString() ?? '') ?? 0,
      downloadedAt: json['downloadedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'path': path,
      'size': size,
      'downloadedAt': downloadedAt,
    };
  }
}

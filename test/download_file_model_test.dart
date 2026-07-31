import 'package:barkod_hub/features/downloads/models/download_file_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadFileModel', () {
    test('reads json fields', () {
      final file = DownloadFileModel.fromJson({
        'fileName': 'market.pdf',
        'fileType': 'pdf',
        'path': '/local/market.pdf',
        'size': '2048',
        'downloadedAt': '2026-07-30T10:00:00.000',
      });

      expect(file.fileName, 'market.pdf');
      expect(file.fileType, 'pdf');
      expect(file.path, '/local/market.pdf');
      expect(file.size, 2048);
      expect(file.downloadedAt, '2026-07-30T10:00:00.000');
    });

    test('converts to json', () {
      const file = DownloadFileModel(
        fileName: 'liste.xlsx',
        fileType: 'excel',
        path: '/local/liste.xlsx',
        size: 4096,
        downloadedAt: '2026-07-30T11:00:00.000',
      );

      expect(file.toJson(), {
        'fileName': 'liste.xlsx',
        'fileType': 'excel',
        'path': '/local/liste.xlsx',
        'size': 4096,
        'downloadedAt': '2026-07-30T11:00:00.000',
      });
    });
  });
}

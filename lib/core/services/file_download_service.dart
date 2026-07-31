import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/downloads/models/download_file_model.dart';

class FileDownloadService {
  final Dio dio;

  const FileDownloadService({required this.dio});

  Future<Directory> getDownloadsDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final downloadsDirectory = Directory('${appDirectory.path}/downloads');

    if (!downloadsDirectory.existsSync()) {
      await downloadsDirectory.create(recursive: true);
    }

    return downloadsDirectory;
  }

  Future<DownloadFileModel> downloadFile({
    required String url,
    required String fileName,
    required String fileType,
  }) async {
    final downloadsDirectory = await getDownloadsDirectory();
    final filePath = '${downloadsDirectory.path}/$fileName';

    await dio.download(url, filePath);

    final file = File(filePath);
    final stat = await file.stat();

    return DownloadFileModel(
      fileName: fileName,
      fileType: fileType,
      path: filePath,
      size: stat.size,
      downloadedAt: DateTime.now().toIso8601String(),
    );
  }

  Future<DownloadFileModel> saveGeneratedFile({
    required Uint8List bytes,
    required String fileName,
    required String fileType,
  }) async {
    final downloadsDirectory = await getDownloadsDirectory();
    final filePath = '${downloadsDirectory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return DownloadFileModel(
      fileName: fileName,
      fileType: fileType,
      path: filePath,
      size: bytes.length,
      downloadedAt: DateTime.now().toIso8601String(),
    );
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> openDownloadedFile(String path) async {
    await OpenFilex.open(path);
  }

  Future<void> shareFile(String path) async {
    await Share.shareXFiles([XFile(path)]);
  }
}

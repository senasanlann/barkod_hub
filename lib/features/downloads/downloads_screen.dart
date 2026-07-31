import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon_box.dart';
import '../../shared/widgets/app_snack_bar.dart';
import 'models/download_file_model.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<DownloadFileModel>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = ServiceLocator.offlineCacheService.getDownloadedFiles();
  }

  void _reload() {
    setState(() {
      _filesFuture = ServiceLocator.offlineCacheService.getDownloadedFiles();
    });
  }

  Future<void> _delete(DownloadFileModel file) async {
    await ServiceLocator.offlineCacheService.removeDownloadedFile(file.path);
    if (!mounted) return;
    AppSnackBar.showSuccess(context, '${file.fileName} silindi.');
    _reload();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.${date.year} $hour:$minute';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'excel':
        return Icons.table_chart_outlined;
      case 'zip':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İndirilenler')),
      body: SafeArea(
        child: FutureBuilder<List<DownloadFileModel>>(
          future: _filesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final files = snapshot.data ?? const [];

            if (files.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'Henüz indirilmiş bir dosya yok. Sektör listelerinden '
                    'PDF, Excel veya ZIP indirdiğinizde burada görünecek.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: files.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final file = files[index];

                return AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIconBox(
                        icon: _iconForType(file.fileType),
                        color: AppColors.primary,
                        backgroundColor: const Color(0x1F0055C7),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${_formatSize(file.size)} • ${_formatDate(file.downloadedAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.xs,
                              children: [
                                TextButton.icon(
                                  onPressed: () => ServiceLocator
                                      .fileDownloadService
                                      .openDownloadedFile(file.path),
                                  icon: const Icon(
                                    Icons.open_in_new,
                                    size: 18,
                                  ),
                                  label: const Text('Aç'),
                                ),
                                TextButton.icon(
                                  onPressed: () => ServiceLocator
                                      .fileDownloadService
                                      .shareFile(file.path),
                                  icon: const Icon(
                                    Icons.share_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Paylaş'),
                                ),
                                IconButton(
                                  onPressed: () => _delete(file),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Sil',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

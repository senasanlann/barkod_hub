import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon_box.dart';
import 'models/scan_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanHistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ServiceLocator.offlineCacheService.getScanHistory();
  }

  void _reload() {
    setState(() {
      _historyFuture = ServiceLocator.offlineCacheService.getScanHistory();
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Geçmişi Temizle'),
        content: const Text(
          'Tüm sorgu geçmişi silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ServiceLocator.offlineCacheService.clearScanHistory();
      _reload();
    }
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

  ({IconData icon, Color color, String label}) _statusMeta(String status) {
    switch (status) {
      case 'success':
        return (
          icon: Icons.check_circle_outline,
          color: Colors.green,
          label: 'Bulundu',
        );
      case 'offline_cache':
        return (
          icon: Icons.cloud_off,
          color: AppColors.secondaryText,
          label: 'Önbellek',
        );
      case 'not_found':
        return (
          icon: Icons.search_off,
          color: Colors.orange,
          label: 'Bulunamadı',
        );
      default:
        return (icon: Icons.error_outline, color: Colors.red, label: 'Hata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          IconButton(
            onPressed: _confirmClear,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Geçmişi Temizle',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<ScanHistoryModel>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data ?? const [];

            if (history.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'Henüz sorgulanan bir ürün bulunmuyor. Barkod '
                    'tarayınca ya da elle arayınca burada listelenecek.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final entry = history[index];
                final meta = _statusMeta(entry.status);

                return AppCard(
                  child: Row(
                    children: [
                      if (entry.imageUrl != null &&
                          entry.imageUrl!.trim().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            entry.imageUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => AppIconBox(
                              icon: meta.icon,
                              color: meta.color,
                              backgroundColor: meta.color.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                        )
                      else
                        AppIconBox(
                          icon: meta.icon,
                          color: meta.color,
                          backgroundColor: meta.color.withValues(alpha: 0.12),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.productName ?? entry.barcode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${entry.barcode} • ${meta.label} • '
                              '${_formatDate(entry.scannedAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.secondaryText),
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

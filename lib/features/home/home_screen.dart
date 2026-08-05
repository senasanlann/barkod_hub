import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import 'widgets/home_header.dart';
import 'widgets/manual_card.dart';
import 'widgets/recent_section.dart';
import 'widgets/scanner_card.dart';
import 'widgets/sector_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _syncPendingQueue();
  }

  Future<void> _syncPendingQueue() async {
    final pending = await ServiceLocator.suggestionQueueService.getPending();
    for (final item in pending) {
      final success = item.type == 'product_suggestion'
          ? await ServiceLocator.apiService.postProductSuggestion(item)
          : await ServiceLocator.apiService.postImageReport(item);

      if (success) {
        await ServiceLocator.suggestionQueueService.markSynced(item.id);
      } else {
        await ServiceLocator.suggestionQueueService.markFailed(item.id);
      }
    }

    final count = await ServiceLocator.suggestionQueueService.pendingCount();
    if (mounted) {
      setState(() {
        _pendingCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(),
              if (_pendingCount > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '$_pendingCount öneri gönderilmeyi bekliyor',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              ScannerCard(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.barcode);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              ManualCard(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.manualBarcode);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton(
                text: 'İndirilenler',
                icon: Icons.download_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.downloads);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton(
                text: 'Geçmiş',
                icon: Icons.history,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.history);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              const SectorSection(),

              const SizedBox(height: AppSpacing.md),

              const RecentSection(),
            ],
          ),
        ),
      ),
    );
  }
}

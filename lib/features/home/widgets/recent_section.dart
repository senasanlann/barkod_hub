import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_icon_box.dart';
import '../../history/models/scan_history_model.dart';

class RecentSection extends StatefulWidget {
  const RecentSection({super.key});

  @override
  State<RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<RecentSection> {
  late Future<List<ScanHistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ServiceLocator.offlineCacheService.getScanHistory();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Son Sorgular',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.history),
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<ScanHistoryModel>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              final history = (snapshot.data ?? const []).take(3).toList();

              if (history.isEmpty) {
                return Row(
                  children: [
                    const AppIconBox(icon: Icons.history),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Barkod sorguladıkça geçmiş kayıtlar burada listelenecek.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            AppIconBox(
                              icon: entry.status == 'success'
                                  ? Icons.check_circle_outline
                                  : Icons.qr_code,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.productName ?? entry.barcode,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    entry.barcode,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

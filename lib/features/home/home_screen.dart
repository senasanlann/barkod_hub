import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../auth/models/user_model.dart';
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

  Future<void> _checkPermissionAndNavigate(
    String route,
    String featureName,
  ) async {
    final currentUser = await ServiceLocator.authService.getCurrentUser();

    if (!mounted) return;

    if (currentUser.isRegistered) {
      Navigator.pushNamed(context, route);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Giriş Yapılması Gerekiyor'),
          content: Text(
            '$featureName özelliğini kullanabilmek için lütfen kayıtlı kullanıcı olarak giriş yapın.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushNamed(context, AppRoutes.login);
              },
              child: const Text('Giriş Yap'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            user.isRegistered ? Icons.account_circle : Icons.person_outline,
            color: user.isRegistered ? AppColors.primary : AppColors.secondaryText,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.isRegistered ? user.name : 'Misafir Modu',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  user.role.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              if (user.isRegistered) {
                await ServiceLocator.authService.logout();
                if (mounted) setState(() {});
              } else {
                Navigator.pushNamed(context, AppRoutes.login);
              }
            },
            child: Text(user.isRegistered ? 'Çıkış Yap' : 'Giriş Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: SafeArea(
        child: FutureBuilder<UserModel>(
          future: ServiceLocator.authService.getCurrentUser(),
          builder: (context, snapshot) {
            final user = snapshot.data ?? UserModel.guest();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserHeader(user),
                  const SizedBox(height: AppSpacing.md),
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
                    text: 'Favorilerim',
                    icon: Icons.favorite_outline,
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      _checkPermissionAndNavigate(
                        AppRoutes.favorites,
                        'Favorilerim',
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton(
                    text: 'İndirilenler',
                    icon: Icons.download_outlined,
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      _checkPermissionAndNavigate(
                        AppRoutes.downloads,
                        'İndirilenler',
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton(
                    text: 'Geçmiş',
                    icon: Icons.history,
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      _checkPermissionAndNavigate(
                        AppRoutes.history,
                        'Geçmiş',
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const SectorSection(),

                  const SizedBox(height: AppSpacing.md),

                  const RecentSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

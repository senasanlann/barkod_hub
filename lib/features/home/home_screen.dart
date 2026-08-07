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
  UserModel _currentUser = UserModel.guest();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _syncPendingQueue();
  }

  Future<void> _loadUser() async {
    final user = await ServiceLocator.authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
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
      await Navigator.pushNamed(context, route);
      await _loadUser();
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
              onPressed: () async {
                Navigator.pop(dialogContext);
                await Navigator.pushNamed(context, AppRoutes.login);
                await _loadUser();
              },
              child: const Text('Giriş Yap'),
            ),
          ],
        );
      },
    );
  }

  void _showRoleSwitcherDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Hızlı Rol Değiştir'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ServiceLocator.authService.logout();
                await _loadUser();
              },
              child: const Text('Misafir (Guest)'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ServiceLocator.authService.login(
                  'user@bilsoft.com',
                  '123',
                );
                await _loadUser();
              },
              child: const Text('Kayıtlı Kullanıcı (User)'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ServiceLocator.authService.login(
                  'editor@bilsoft.com',
                  '123',
                );
                await _loadUser();
              },
              child: const Text('Editör (Editor)'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ServiceLocator.authService.login(
                  'admin@bilsoft.com',
                  '123',
                );
                await _loadUser();
              },
              child: const Text('Yönetici (Admin)'),
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
          IconButton(
            icon: Icon(
              user.isRegistered ? Icons.account_circle : Icons.person_outline,
              color: user.isRegistered
                  ? AppColors.primary
                  : AppColors.secondaryText,
            ),
            onPressed: _showRoleSwitcherDialog,
            tooltip: 'Rol Değiştir',
          ),
          Expanded(
            child: InkWell(
              onTap: _showRoleSwitcherDialog,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.isRegistered ? user.name : 'Misafir Modu',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${user.role.displayName} (Tıkla Değiştir)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (user.isRegistered) {
                await ServiceLocator.authService.logout();
                await _loadUser();
              } else {
                await Navigator.pushNamed(context, AppRoutes.login);
                await _loadUser();
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
    final user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.settings);
              await _loadUser();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

              if (user.role == UserRole.admin) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: 'Yönetim Özeti & Loglar',
                  icon: Icons.admin_panel_settings_outlined,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.adminLogs);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  text: 'Veri Kontrolü & Bildirimler',
                  icon: Icons.assignment_turned_in_outlined,
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.adminReports);
                  },
                ),
              ],

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

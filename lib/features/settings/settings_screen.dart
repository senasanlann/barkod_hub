import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../auth/models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _currentUser;
  bool _isCheckingApi = false;
  String _apiStatusText = 'Kontrol ediliyor...';
  bool _apiIsHealthy = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _checkApiStatus();
  }

  Future<void> _loadUser() async {
    final user = await ServiceLocator.authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _checkApiStatus() async {
    setState(() {
      _isCheckingApi = true;
    });

    try {
      final sectors = await ServiceLocator.apiService.getSectors();
      if (mounted) {
        setState(() {
          _isCheckingApi = false;
          _apiIsHealthy = true;
          _apiStatusText = 'Aktif (200 OK • ${sectors.length} Sektör Yüklü)';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingApi = false;
          _apiIsHealthy = false;
          _apiStatusText = 'Bağlantı Hatası (Çevrimdışı Mod)';
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Önbelleği Temizle'),
        content: const Text(
          'Çevrimdışı kaydedilen tüm ürünler, sektör özetleri ve uygulama önbelleği silinecek.',
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

    if (confirm == true) {
      await ServiceLocator.offlineCacheService.clearAllCache();
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Tüm çevrimdışı önbellek temizlendi.');
      }
    }
  }

  Future<void> _logout() async {
    await ServiceLocator.authService.logout();
    await _loadUser();
    if (mounted) {
      AppSnackBar.showSuccess(context, 'Oturum kapatıldı, misafir moduna geçildi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (user != null) ...[
              Text(
                'Oturum Bilgisi',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.isRegistered)
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: _logout,
                        tooltip: 'Oturumu Kapat',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              'Sistem & Bağlantı',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _apiIsHealthy ? Icons.check_circle : Icons.error_outline,
                        color: _apiIsHealthy ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'API Bağlantı Durumu',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              _apiStatusText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _isCheckingApi
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh, size: 20),
                        onPressed: _checkApiStatus,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Depolama & Önbellek',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: const Text('Çevrimdışı Önbelleği Temizle'),
                    subtitle: const Text(
                      'Ürün detayı, sektör özetleri ve geçici önbellek verilerini siler.',
                    ),
                    onTap: _clearCache,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Yasal & Gizlilik',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.gavel_outlined, color: AppColors.primary),
                title: const Text('KVKK Aydınlatma Metni'),
                subtitle: const Text('Kişisel verilerin işlenmesi ve gizlilik ilkeleri'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('KVKK Aydınlatma Metni'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '6698 Sayılı KVKK kapsamında, BarkodHub uygulaması kişisel verilerinizi '
                          'yalnızca ürün arama, tarama geçmişi ve üyelik işlemleriyle sınırlı olarak '
                          'güvenli altyapıda işlemektedir. Verileriniz 3. şahıslarla paylaşılmaz.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (user?.isRegistered == true)
              AppButton(
                text: 'Oturumu Kapat',
                icon: Icons.logout,
                variant: AppButtonVariant.outline,
                onPressed: _logout,
              ),
          ],
        ),
      ),
    );
  }
}

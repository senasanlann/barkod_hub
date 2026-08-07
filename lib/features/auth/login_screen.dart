import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import 'models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final arg = ModalRoute.of(context)?.settings.arguments as String?;
      if (arg != null && arg.isNotEmpty) {
        if (arg.contains('editor')) {
          _emailController.text = 'editor@bilsoft.com';
          _passwordController.text = '123456';
          _selectedRole = UserRole.editor;
        } else if (arg.contains('admin')) {
          _emailController.text = 'admin@bilsoft.com';
          _passwordController.text = '123456';
          _selectedRole = UserRole.admin;
        } else {
          _emailController.text = arg;
          _passwordController.text = '123456';
          _selectedRole = UserRole.user;
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRolePreset(UserRole role) {
    setState(() {
      _selectedRole = role;
      switch (role) {
        case UserRole.editor:
          _emailController.text = 'editor@bilsoft.com';
          _passwordController.text = '123456';
          break;
        case UserRole.admin:
          _emailController.text = 'admin@bilsoft.com';
          _passwordController.text = '123456';
          break;
        case UserRole.user:
        default:
          _emailController.text = 'kullanici@bilsoft.com';
          _passwordController.text = '123456';
          break;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackBar.showError(
        context,
        'Lütfen e-posta adresinizi ve şifrenizi girin.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ServiceLocator.authService.login(
        email,
        password,
        role: _selectedRole,
      );
      if (!mounted) return;

      if (success) {
        AppSnackBar.showSuccess(
          context,
          '${_selectedRole.displayName} olarak giriş yapıldı! Hoş geldiniz.',
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        AppSnackBar.showError(
          context,
          'Giriş yapılamadı. Bilgilerinizi kontrol edin.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Bir hata oluştu.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueAsGuest() async {
    await ServiceLocator.authService.loginAsGuest();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Barkod Hub\'a Hoş Geldiniz',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Giriş yapacağınız rolü seçip e-posta ve şifrenizi girerek işlem yapabilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Giriş Rolü Seçin',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      avatar: const Icon(Icons.person_outline, size: 16),
                      label: const Text('Kayıtlı Kullanıcı'),
                      selected: _selectedRole == UserRole.user,
                      onSelected: (_) => _selectRolePreset(UserRole.user),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      avatar: const Icon(Icons.edit_note, size: 16),
                      label: const Text('Editör'),
                      selected: _selectedRole == UserRole.editor,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      onSelected: (_) => _selectRolePreset(UserRole.editor),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      avatar: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                      label: const Text('Yönetici (Admin)'),
                      selected: _selectedRole == UserRole.admin,
                      selectedColor: Colors.orange.withValues(alpha: 0.2),
                      onSelected: (_) => _selectRolePreset(UserRole.admin),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _emailController,
                      labelText: 'E-posta Adresi',
                      hintText: 'ornek@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      labelText: 'Şifre',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: '${_selectedRole.displayName} Olarak Giriş Yap',
                      icon: Icons.login,
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Misafir Olarak Devam Et',
                icon: Icons.flash_on_outlined,
                variant: AppButtonVariant.outline,
                onPressed: _continueAsGuest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

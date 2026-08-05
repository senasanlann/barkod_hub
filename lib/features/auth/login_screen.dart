import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      final success = await ServiceLocator.authService.login(email, password);
      if (!mounted) return;

      if (success) {
        AppSnackBar.showSuccess(context, 'Giriş başarılı! Hoş geldiniz.');
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
                'Tüm özellikleri (sınırsız sorgulama, liste indirme ve geçmiş takibi) kullanmak için giriş yapın.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
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
                      text: 'Giriş Yap',
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
                icon: Icons.person_outline,
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

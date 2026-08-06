import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/barcode_validator.dart';
import '../../features/history/models/scan_history_model.dart';
import '../../features/product/models/product_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import 'widgets/product_result_card.dart';

class ManualBarcodeScreen extends StatefulWidget {
  const ManualBarcodeScreen({super.key});

  @override
  State<ManualBarcodeScreen> createState() => _ManualBarcodeScreenState();
}

class _ManualBarcodeScreenState extends State<ManualBarcodeScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isSubmitting = false;
  ProductModel? _productResult;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String barcode) {
    AppSnackBar.showSuccess(context, 'Barkod sorgusu tamamlandı: $barcode');
  }

  void _showErrorMessage(String message) {
    AppSnackBar.showError(context, message);
  }

  void _showLimitExceededDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Günlük Misafir Limiti Doldu'),
          content: const Text(
            'Misafir kullanıcı olarak günlük 10 barkod sorgulama hakkınızı doldurdunuz. Sınırsız sorgulama yapmak için lütfen giriş yapın.',
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

  Future<void> _submitBarcode() async {
    if (_isSubmitting) return;

    final barcode = _barcodeController.text.trim();

    if (barcode.isEmpty) {
      _showErrorMessage('Lütfen barkod numarası girin.');
      return;
    }

    if (!BarcodeValidator.isValid(barcode)) {
      _showErrorMessage(
        'Barkod yalnızca rakamlardan oluşmalı ve 8, 12, 13 veya 14 hane olmalıdır.',
      );
      return;
    }

    final canQuery = await ServiceLocator.authService.canPerformGuestQuery();
    if (!canQuery) {
      if (!mounted) return;
      _showLimitExceededDialog();
      return;
    }

    await ServiceLocator.authService.incrementGuestQueryCount();

    setState(() {
      _isSubmitting = true;
      _productResult = null;
    });

    try {
      final result = await ServiceLocator.apiService.getProductByBarcode(
        barcode,
      );
      if (!mounted) return;
      setState(() {
        _productResult = result;
      });

      final found = result.name != null;
      await ServiceLocator.offlineCacheService.cacheProduct(result);
      await ServiceLocator.offlineCacheService.addScanHistory(
        ScanHistoryModel(
          barcode: barcode,
          productName: result.name,
          imageUrl: result.imageUrl,
          scannedAt: DateTime.now().toIso8601String(),
          status: found ? 'success' : 'not_found',
        ),
      );

      if (!mounted) return;
      _showSuccessMessage(barcode);
    } on ApiException catch (e) {
      final cached = await ServiceLocator.offlineCacheService.getCachedProduct(
        barcode,
      );
      if (!mounted) return;

      if (cached != null) {
        setState(() {
          _productResult = cached.product;
        });

        await ServiceLocator.offlineCacheService.addScanHistory(
          ScanHistoryModel(
            barcode: barcode,
            productName: cached.product.name,
            imageUrl: cached.product.imageUrl,
            scannedAt: DateTime.now().toIso8601String(),
            status: 'offline_cache',
          ),
        );

        if (!mounted) return;
        AppSnackBar.showSuccess(
          context,
          'Çevrimdışı: önbellekten gösteriliyor.',
        );
      } else {
        setState(() {
          _productResult = null;
        });

        await ServiceLocator.offlineCacheService.addScanHistory(
          ScanHistoryModel(
            barcode: barcode,
            productName: null,
            imageUrl: null,
            scannedAt: DateTime.now().toIso8601String(),
            status: 'error',
          ),
        );

        if (!mounted) return;
        _showErrorMessage(e.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productResult = _productResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Manuel Barkod')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Barkod Numarası',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ürün barkodunu elle girerek sorgulama yapabilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _barcodeController,
                      labelText: 'Barkod',
                      hintText: 'Örn: 8690123456789',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.qr_code,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: 'Sorgula',
                      icon: Icons.search,
                      onPressed: _submitBarcode,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
              if (productResult != null) ...[
                const SizedBox(height: AppSpacing.md),
                ProductResultCard(product: productResult),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

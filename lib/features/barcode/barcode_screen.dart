import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/barcode_validator.dart';
import '../../features/product/models/product_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snack_bar.dart';
import 'widgets/product_result_card.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  ProductModel? _productResult;
  String? _lastScannedBarcode;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String? barcode) async {
    if (_isProcessing || barcode == null || barcode.isEmpty) return;
    if (_lastScannedBarcode == barcode) return;

    if (!BarcodeValidator.isValid(barcode)) {
      _showErrorMessage(
        'Okunan barkod geçerli değil. Barkod 8 veya 13 haneli olmalıdır.',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _productResult = null;
      _lastScannedBarcode = barcode;
    });

    await _scannerController.stop();

    try {
      final result = await ServiceLocator.apiService.getProductByBarcode(
        barcode,
      );
      if (!mounted) return;

      setState(() {
        _productResult = result;
      });

      _showSuccessMessage(barcode);
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _productResult = null;
      });

      _showErrorMessage(e.message);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        await _scannerController.start();
      }
    }
  }

  Future<void> _restartScanner() async {
    setState(() {
      _productResult = null;
      _isProcessing = false;
      _lastScannedBarcode = null;
    });

    await _scannerController.start();
  }

  void _showSuccessMessage(String barcode) {
    AppSnackBar.showSuccess(context, 'Barkod sorgusu tamamlandı: $barcode');
  }

  void _showErrorMessage(String message) {
    AppSnackBar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final productResult = _productResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Barkod Tara')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kamera ile Barkod Tara',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Barkodu kamera alanına hizalayın. Okuma tamamlandığında ürün bilgisi otomatik sorgulanır.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      final barcode = capture.barcodes.isEmpty
                          ? null
                          : capture.barcodes.first.rawValue;
                      _handleBarcode(barcode);
                    },
                  ),
                ),
              ),
              if (_isProcessing) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Barkod sorgulanıyor...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (productResult != null) ...[
                const SizedBox(height: AppSpacing.md),
                ProductResultCard(product: productResult),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: 'Tekrar Tara',
                  icon: Icons.refresh,
                  onPressed: _restartScanner,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Manuel Girişe Git',
                icon: Icons.edit,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.manualBarcode);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

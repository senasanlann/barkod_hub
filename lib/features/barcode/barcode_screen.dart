import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/error_tracker.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/barcode_validator.dart';
import '../../features/history/models/scan_history_model.dart';
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
  bool _isTorchOn = false;
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
        'Okunan barkod geçerli değil. Barkod 8, 12, 13 veya 14 haneli olmalıdır.',
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

      final found = result.name != null && result.name!.trim().isNotEmpty;
      await ServiceLocator.offlineCacheService.cacheProduct(result);
      await ServiceLocator.apiService.postScanLog(
        barcode,
        found ? 'success' : 'not_found',
      );
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

      if (found) {
        setState(() {
          _productResult = result;
        });
        _showSuccessMessage(barcode);
      } else {
        setState(() {
          _productResult = null;
        });
        Navigator.pushNamed(
          context,
          AppRoutes.productNotFound,
          arguments: barcode,
        );
      }
    } on ApiException catch (e) {
      await ErrorTracker.trackCameraError(e);
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
        Navigator.pushNamed(
          context,
          AppRoutes.productNotFound,
          arguments: barcode,
        );
      }
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
                Navigator.pushNamed(context, AppRoutes.welcomeAuth);
              },
              child: const Text('Giriş Yap'),
            ),
          ],
        );
      },
    );
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
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        errorBuilder: (context, error) {
                          return Container(
                            color: Colors.black87,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 48,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    'Kamera İzni Gerekli',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  const Text(
                                    'Barkod okutabilmek için kamera izni gereklidir.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AppButton(
                                    text: 'Kamera İzni Ver / Ayarlar',
                                    icon: Icons.security,
                                    onPressed: () async {
                                      final status = await Permission.camera.request();
                                      if (status.isPermanentlyDenied) {
                                        await openAppSettings();
                                      } else {
                                        _restartScanner();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  AppButton(
                                    text: 'Manuel Girişe Git',
                                    icon: Icons.edit,
                                    variant: AppButtonVariant.outline,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.manualBarcode,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onDetect: (capture) {
                          final barcode = capture.barcodes.isEmpty
                              ? null
                              : capture.barcodes.first.rawValue;
                          _handleBarcode(barcode);
                        },
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isTorchOn ? Icons.flash_on : Icons.flash_off,
                              color: _isTorchOn ? Colors.amber : Colors.white,
                            ),
                            tooltip: _isTorchOn ? 'Flaş Kapat' : 'Flaş Aç',
                            onPressed: () async {
                              await _scannerController.toggleTorch();
                              setState(() {
                                _isTorchOn = !_isTorchOn;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_lastScannedBarcode != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Son Okunan: $_lastScannedBarcode',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
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
                variant: AppButtonVariant.outline,
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

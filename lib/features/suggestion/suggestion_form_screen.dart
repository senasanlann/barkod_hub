import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import 'models/suggestion_model.dart';

class SuggestionFormScreen extends StatefulWidget {
  final String barcode;

  const SuggestionFormScreen({super.key, required this.barcode});

  @override
  State<SuggestionFormScreen> createState() => _SuggestionFormScreenState();
}

class _SuggestionFormScreenState extends State<SuggestionFormScreen> {
  late final TextEditingController _barcodeController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.barcode);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveSuggestion() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppSnackBar.showError(context, 'Lütfen ürün adını girin.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final suggestion = SuggestionModel.create(
        type: 'product_suggestion',
        barcode: widget.barcode,
        productName: name,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      await ServiceLocator.suggestionQueueService.enqueue(suggestion);

      final sent = await ServiceLocator.apiService.postProductSuggestion(
        suggestion,
      );
      if (sent) {
        await ServiceLocator.suggestionQueueService.markSynced(suggestion.id);
      } else {
        await ServiceLocator.suggestionQueueService.markFailed(suggestion.id);
      }

      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        'Öneriniz kaydedildi, bağlantı sağlandığında gönderilecek.',
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Öneri kaydedilirken bir hata oluştu.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Önerisi Yap')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Yeni Ürün Bilgisi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Eksik ürün bilgisini tamamlayarak ürün havuzuna katkıda bulunabilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _barcodeController,
                      labelText: 'Barkod',
                      readOnly: true,
                      prefixIcon: Icons.qr_code,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _nameController,
                      labelText: 'Ürün Adı *',
                      hintText: 'Örn: Dost Tam Yağlı Süt 1L',
                      prefixIcon: Icons.shopping_bag_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _brandController,
                      labelText: 'Marka',
                      hintText: 'Örn: Dost',
                      prefixIcon: Icons.branding_watermark_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _categoryController,
                      labelText: 'Kategori',
                      hintText: 'Örn: Süt ve Süt Ürünleri',
                      prefixIcon: Icons.category_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _noteController,
                      labelText: 'Not / Açıklama',
                      hintText: 'Ürün hakkında ek notlar...',
                      prefixIcon: Icons.note_alt_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: 'Öneriyi Kaydet',
                      icon: Icons.send,
                      onPressed: _saveSuggestion,
                      isLoading: _isSaving,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

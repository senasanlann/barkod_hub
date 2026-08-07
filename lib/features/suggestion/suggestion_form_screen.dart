import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../product/models/product_model.dart';
import '../sectors/models/sector_model.dart';
import 'models/suggestion_model.dart';

class SuggestionFormScreen extends StatefulWidget {
  final String barcode;
  final ProductModel? initialProduct;

  const SuggestionFormScreen({
    super.key,
    required this.barcode,
    this.initialProduct,
  });

  @override
  State<SuggestionFormScreen> createState() => _SuggestionFormScreenState();
}

class _SuggestionFormScreenState extends State<SuggestionFormScreen> {
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _categoryController;
  final TextEditingController _noteController = TextEditingController();

  late Future<List<SectorModel>> _sectorsFuture;
  String? _selectedSector;
  bool _isSaving = false;

  static const _suggestedCategories = [
    'Süt & Süt Ürünleri',
    'Gazlı İçecek',
    'Meyve Suyu',
    'Atıştırmalık',
    'Çikolata & Gofret',
    'Bisküvi & Kek',
    'Sıvı Deterjan',
    'Temizlik Ürünleri',
    'Şampuan & Sıvı Sabun',
    'Kişisel Bakım',
    'Konserve & Sos',
    'Çay & Kahve',
    'Bakliyat & Makarna',
    'Hırdavat',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _barcodeController = TextEditingController(
      text: p?.barcode ?? widget.barcode,
    );
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _selectedSector = p?.sector;
    _sectorsFuture = ServiceLocator.apiService.getSectors();
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
        sector: _selectedSector,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      await ServiceLocator.suggestionQueueService.enqueue(suggestion);

      // Mock modunda başarılı yanıt gerçek bir sunucu kaydı anlamına gelmez.
      // Öneri, Editör/Admin tarafından incelenene kadar yerel kuyrukta kalır.
      if (!ServiceLocator.apiService.useMockData) {
        final sent = await ServiceLocator.apiService.postProductSuggestion(
          suggestion,
        );
        if (sent) {
          await ServiceLocator.suggestionQueueService.markSynced(suggestion.id);
        } else {
          await ServiceLocator.suggestionQueueService.markFailed(suggestion.id);
        }
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
    final isEditing = widget.initialProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ürün Bilgisini Düzenle' : 'Ürün Önerisi Yap'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Ürün Bilgilerini Güncelle' : 'Yeni Ürün Bilgisi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isEditing
                    ? 'Mevcut ürün bilgilerini güncelleyerek ürün havuzuna katkıda bulunabilirsiniz.'
                    : 'Eksik ürün bilgisini tamamlayarak ürün havuzuna katkıda bulunabilirsiniz.',
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
                    const SizedBox(height: AppSpacing.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _suggestedCategories.map((cat) {
                          final isSelected =
                              _categoryController.text.trim().toLowerCase() ==
                              cat.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xs,
                            ),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _categoryController.text = selected
                                      ? cat
                                      : '';
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Sektör Seçin',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FutureBuilder<List<SectorModel>>(
                      future: _sectorsFuture,
                      builder: (context, snapshot) {
                        final sectors = snapshot.data ?? [];
                        if (sectors.isEmpty) {
                          return const SizedBox();
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: sectors.map((sector) {
                              final isSelected = _selectedSector == sector.name;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.xs,
                                ),
                                child: ChoiceChip(
                                  label: Text(sector.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSector = selected
                                          ? sector.name
                                          : null;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
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

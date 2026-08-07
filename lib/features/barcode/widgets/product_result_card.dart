import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_icon_box.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../product/models/product_model.dart';
import '../../suggestion/models/suggestion_model.dart';

class ProductResultCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onFavoriteChanged;

  const ProductResultCard({
    super.key,
    required this.product,
    this.onFavoriteChanged,
  });

  @override
  State<ProductResultCard> createState() => _ProductResultCardState();
}

class _ProductResultCardState extends State<ProductResultCard> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  void didUpdateWidget(covariant ProductResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.barcode != widget.product.barcode) {
      _checkFavorite();
    }
  }

  Future<void> _checkFavorite() async {
    final fav = await ServiceLocator.favoritesService.isFavorite(
      widget.product.barcode,
    );
    if (mounted) {
      setState(() {
        _isFav = fav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = await ServiceLocator.authService.getCurrentUser();
    if (!mounted) return;

    if (!user.isRegistered) {
      _showLoginRequiredDialog(
        'Favorilere ürün eklemek için lütfen kayıtlı kullanıcı olarak giriş yapın.',
      );
      return;
    }

    final newlyAdded = await ServiceLocator.favoritesService.toggleFavorite(
      widget.product,
    );
    if (!mounted) return;

    setState(() {
      _isFav = newlyAdded;
    });

    AppSnackBar.showSuccess(
      context,
      newlyAdded ? 'Ürün favorilere eklendi.' : 'Ürün favorilerden çıkarıldı.',
    );

    widget.onFavoriteChanged?.call();
  }

  Future<void> _handleReportAction(String title) async {
    final user = await ServiceLocator.authService.getCurrentUser();
    if (!mounted) return;

    if (!user.isRegistered) {
      _showLoginRequiredDialog(
        'Eksik bilgi veya görsel bildirimi yapmak için lütfen giriş yapın.',
      );
      return;
    }

    _showReportDialog(title: title);
  }

  Future<void> _handleSuggestAction() async {
    final user = await ServiceLocator.authService.getCurrentUser();
    if (!mounted) return;

    if (!user.isRegistered) {
      _showLoginRequiredDialog(
        'Ürün bilgisi düzenlemek veya önermek için lütfen giriş yapın.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.suggestionForm,
      arguments: widget.product.barcode ?? '',
    );
  }

  void _showLoginRequiredDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Giriş Yapılması Gerekiyor'),
          content: Text(message),
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
    final product = widget.product;
    final detailEntries = product.rawData.entries
        .where((entry) => !_isPrimaryKey(entry.key))
        .toList();

    return AppCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIconBox(
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                  backgroundColor: Color(0x1F0055C7),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Sorgu Sonucu',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    Share.share(
                      '${product.name ?? "Ürün"} - Barkod: ${product.barcode}\n'
                      'BarkodHub uygulamasından sorgulandı.',
                    );
                  },
                  tooltip: 'Ürün Paylaş',
                ),
                IconButton(
                  icon: Icon(
                    _isFav ? Icons.favorite : Icons.favorite_border,
                    color: _isFav ? Colors.red : AppColors.secondaryText,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: _isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildImage(context),
            const SizedBox(height: AppSpacing.md),
            if (_hasValue(product.name)) ...[
              Text(
                product.name!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (_hasValue(product.barcode)) ...[
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: product.barcode!));
                  AppSnackBar.showSuccess(
                    context,
                    'Barkod kopyalandı: ${product.barcode}',
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_2_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.barcode!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.copy_outlined,
                        size: 14,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _barcodeTypeLabel(product.barcode!),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_hasValue(product.brand) || _hasValue(product.category)) ...[
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (_hasValue(product.brand))
                    Chip(
                      avatar: const Icon(
                        Icons.branding_watermark_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      label: Text(product.brand!),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  if (_hasValue(product.category))
                    Chip(
                      avatar: const Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      label: Text(product.category!),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  if (_hasValue(product.sector))
                    Chip(
                      avatar: const Icon(
                        Icons.dashboard_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      label: Text(product.sector!),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.border),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            _buildPriceBlock(context),
            if (detailEntries.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.xs),
              Text('Detaylar', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              ...detailEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ResultRow(
                    label: entry.key.toString(),
                    value: entry.value?.toString() ?? '-',
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Hata Bildir',
                    icon: Icons.report_problem_outlined,
                    variant: AppButtonVariant.outline,
                    onPressed: () =>
                        _handleReportAction('Hatalı / Eksik Bilgi Bildir'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'Düzenle',
                    icon: Icons.edit_note_outlined,
                    variant: AppButtonVariant.outline,
                    onPressed: _handleSuggestAction,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBlock(BuildContext context) {
    final product = widget.product;
    final priceText = product.price != null
        ? '${product.price!.toStringAsFixed(2).replaceAll('.', ',')} TL'
        : 'Fiyat belirtilmedi';
    final priceStyle = product.price != null
        ? Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary)
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText);

    final sourceRaw = _readRawString(product.rawData, ['source', 'kaynak']);
    final sourceText = sourceRaw != null ? 'Kaynak: $sourceRaw' : null;

    String? dateText;
    if (_hasValue(product.updatedAt)) {
      final dt = DateTime.tryParse(product.updatedAt!.trim());
      if (dt != null) {
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        dateText = '$day.$month.${dt.year}';
      }
    }

    final metaParts = [?sourceText, ?dateText];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const Divider(color: AppColors.border),
        const SizedBox(height: AppSpacing.xs),
        Text(priceText, style: priceStyle),
        if (metaParts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            metaParts.join(' • '),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ],
    );
  }

  String? _readRawString(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final val = raw[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    return null;
  }

  Widget _buildImage(BuildContext context) {
    if (!_hasValue(widget.product.imageUrl)) {
      return _placeholder(context);
    }
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMd,
        child: Image.network(
          widget.product.imageUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _placeholder(context),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusMd,
      child: Container(
        height: 200,
        width: double.infinity,
        color: AppColors.background,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Görsel bulunamadı',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Görsel Bildir',
                icon: Icons.add_a_photo_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => _handleReportAction('Eksik Görsel Bildir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog({required String title}) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Açıklamanızı veya eksik bilgiyi yazabilirsiniz...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final note = noteController.text.trim();
                Navigator.pop(dialogContext);

                final report = SuggestionModel.create(
                  type: 'image_report',
                  barcode: widget.product.barcode ?? '',
                  productName: widget.product.name,
                  note: note.isEmpty ? title : note,
                );

                await ServiceLocator.suggestionQueueService.enqueue(report);
                final sent = await ServiceLocator.apiService.postImageReport(
                  report,
                );
                if (sent) {
                  await ServiceLocator.suggestionQueueService.markSynced(
                    report.id,
                  );
                } else {
                  await ServiceLocator.suggestionQueueService.markFailed(
                    report.id,
                  );
                }

                if (mounted) {
                  AppSnackBar.showSuccess(
                    context,
                    'Bildiriminiz alındı, teşekkür ederiz.',
                  );
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool _isPrimaryKey(String key) {
    final k = key.trim().toLowerCase();
    return k == 'name' ||
        k == 'brand' ||
        k == 'category' ||
        k == 'barcode' ||
        k == 'price' ||
        k == 'fiyat' ||
        k == 'fiyat (tl)' ||
        k == 'fiyat tl' ||
        k == 'saleprice' ||
        k == 'sale_price' ||
        k == 'source' ||
        k == 'kaynak' ||
        k == 'source_url' ||
        k == 'sourceurl' ||
        k == 'image' ||
        k == 'imageurl' ||
        k == 'image_url' ||
        k == 'updatedat' ||
        k == 'updated_at' ||
        k == 'createdat' ||
        k == 'created_at' ||
        k == 'lastupdate' ||
        k == 'sector' ||
        k == 'sektor' ||
        k == 'status' ||
        k == 'id' ||
        k == 'download' ||
        k == 'vat' ||
        k == 'kdv' ||
        k == 'tax';
  }

  String _barcodeTypeLabel(String barcode) {
    final len = barcode.length;
    if (len == 8) return 'EAN-8';
    if (len == 12) return 'UPC-A';
    if (len == 13) return 'EAN-13';
    if (len == 14) return 'GTIN-14';
    return 'Barkod';
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

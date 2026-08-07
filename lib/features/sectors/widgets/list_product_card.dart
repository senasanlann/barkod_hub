import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/product/models/product_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_sector_emblem.dart';
import '../../barcode/widgets/product_result_card.dart';

class ListProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ListProductCard({super.key, required this.product, this.onTap});

  void _showProductDetail(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(bottomSheetContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProductResultCard(product: product),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = product.name ?? 'Ürün adı bulunamadı';
    final barcode = product.barcode ?? '-';
    final brand = product.brand;
    final category = product.category;
    final price = product.price;

    final hasImage =
        product.imageUrl != null &&
        product.imageUrl!.trim().isNotEmpty &&
        product.imageUrl != 'bilinmiyor';

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showProductDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => AppSectorEmblem(
                      sector: product.sector,
                      category: category,
                      productName: title,
                      height: 44,
                      style: SectorEmblemStyle.compactSquare,
                    ),
                  ),
                )
              else
                AppSectorEmblem(
                  sector: product.sector,
                  category: category,
                  productName: title,
                  height: 44,
                  style: SectorEmblemStyle.compactSquare,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Barkod: $barcode',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (brand != null || category != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        [?brand, ?category].join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                    if (price != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${price.toStringAsFixed(2)} TL',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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

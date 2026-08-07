import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/product/models/product_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_sector_emblem.dart';

class ListProductCard extends StatelessWidget {
  final ProductModel product;

  const ListProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final title = product.name ?? 'Ürün adı bulunamadı';
    final barcode = product.barcode ?? '-';
    final brand = product.brand;
    final category = product.category;
    final price = product.price;

    final hasImage = product.imageUrl != null && product.imageUrl!.trim().isNotEmpty && product.imageUrl != 'bilinmiyor';

    return AppCard(
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
                errorBuilder: (_, __, ___) => AppSectorEmblem(
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

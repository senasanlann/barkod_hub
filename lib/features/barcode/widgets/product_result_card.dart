import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../product/models/product_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_icon_box.dart';

class ProductResultCard extends StatelessWidget {
  final ProductModel product;

  const ProductResultCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final primaryRows = <_ResultRowData>[
      if (_hasValue(product.name))
        _ResultRowData(label: 'Ürün Adı', value: product.name!),
      if (_hasValue(product.brand))
        _ResultRowData(label: 'Marka', value: product.brand!),
      if (_hasValue(product.category))
        _ResultRowData(label: 'Kategori', value: product.category!),
      if (_hasValue(product.barcode))
        _ResultRowData(label: 'Barkod', value: product.barcode!),
    ];
    final detailEntries = product.rawData.entries
        .where((entry) => !_isPrimaryKey(entry.key))
        .toList();

    return AppCard(
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
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (primaryRows.isNotEmpty) ...[
            ...primaryRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ResultRow(label: row.label, value: row.value),
              ),
            ),
          ] else if (detailEntries.isEmpty)
            Text(
              'Ürün bilgisi bulunamadı.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (detailEntries.isNotEmpty) ...[
            if (primaryRows.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.xs),
            ],
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
        ],
      ),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool _isPrimaryKey(String key) {
    return key == 'name' ||
        key == 'brand' ||
        key == 'category' ||
        key == 'barcode';
  }
}

class _ResultRowData {
  final String label;
  final String value;

  const _ResultRowData({required this.label, required this.value});
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
          width: 96,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

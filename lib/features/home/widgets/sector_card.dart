import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/sectors/models/sector_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_icon_box.dart';

class SectorCard extends StatelessWidget {
  final SectorModel sector;
  final VoidCallback onTap;

  const SectorCard({
    super.key,
    required this.sector,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (sector.imageUrl != null && sector.imageUrl!.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    sector.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const AppIconBox(
                      icon: Icons.category,
                      color: AppColors.primary,
                      backgroundColor: Color(0x1F0055C7),
                    ),
                  ),
                )
              else
                const AppIconBox(
                  icon: Icons.category,
                  color: AppColors.primary,
                  backgroundColor: Color(0x1F0055C7),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${sector.itemCount} ürün',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
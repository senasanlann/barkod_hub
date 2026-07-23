import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_size.dart';
import '../../../core/theme/app_spacing.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.darkPrimary,
            borderRadius: AppRadius.radiusLg,
          ),
          child: const Icon(
            Icons.qr_code_2,
            color: AppColors.card,
            size: AppSize.iconLg,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Barkod Hub',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ürün barkodlarını hızlıca tarayın, sorgulayın ve geçmiş kayıtlarını takip edin.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
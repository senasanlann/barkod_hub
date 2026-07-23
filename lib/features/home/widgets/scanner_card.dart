import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_icon_box.dart';

class ScannerCard extends StatelessWidget {
  final VoidCallback onPressed;

  const ScannerCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppIconBox(
                icon: Icons.qr_code_scanner,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Barkod ile Sorgula',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kamera ile ürün barkodunu hızlıca tara.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Barkod Tara',
            icon: Icons.qr_code_scanner,
            variant: AppButtonVariant.primary,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
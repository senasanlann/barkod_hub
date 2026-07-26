import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import 'widgets/home_header.dart';
import 'widgets/manual_card.dart';
import 'widgets/scanner_card.dart';
import 'widgets/recent_section.dart';
import 'widgets/sector_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(),

              const SizedBox(height: AppSpacing.xl),

              ScannerCard(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.barcode);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              ManualCard(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.manualBarcode);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              const SizedBox(height: AppSpacing.md),

              const SectorSection(),
              
              const RecentSection(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/sectors/models/sector_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'sector_card.dart';
import '../../../shared/widgets/app_card.dart';

class SectorSection extends StatefulWidget {
  const SectorSection({super.key});

  @override
  State<SectorSection> createState() => _SectorSectionState();
}

class _SectorSectionState extends State<SectorSection> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<SectorModel>> _sectorsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _sectorsFuture = ServiceLocator.apiService.getSectors();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadSectors() {
    setState(() {
      _sectorsFuture = ServiceLocator.apiService.getSectors();
    });
  }

  void _openSectorDetail(SectorModel sector) {
    Navigator.pushNamed(context, AppRoutes.sectorDetail, arguments: sector);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SectorModel>>(
      future: _sectorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppCard(
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Sektör listeleri yükleniyor...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sektör Listeleri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sektör listeleri şu anda yüklenemedi. API bağlantısı hazır olduğunda burada listeler gösterilecek.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: 'Tekrar Dene',
                  icon: Icons.refresh,
                  onPressed: _reloadSectors,
                ),
              ],
            ),
          );
        }

        final sectors = snapshot.data ?? [];

        if (sectors.isEmpty) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sektör Listeleri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Henüz sektör listesi bulunmuyor.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final filteredSectors = sectors
            .where(
              (sector) => sector.name.toLowerCase().contains(_searchQuery),
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sektör Listeleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _searchController,
              labelText: 'Sektör Ara',
              hintText: 'Sektör adı ara',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: AppSpacing.md),
            if (filteredSectors.isEmpty)
              AppCard(
                child: Text(
                  'Aramanıza uygun sektör bulunamadı.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ...filteredSectors.map(
                (sector) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SectorCard(
                    sector: sector,
                    onTap: () => _openSectorDetail(sector),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../barcode/widgets/product_result_card.dart';
import '../product/models/product_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final list = await ServiceLocator.favoritesService.getFavorites();

    if (mounted) {
      setState(() {
        _favorites = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(String barcode) async {
    await ServiceLocator.favoritesService.removeFavorite(barcode);
    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Ürün favorilerden çıkarıldı.');
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: AppColors.secondaryText.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Henüz favori ürününüz yok',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sorguladığınız ürünleri kart üzerindeki kalp butonuna basarak favorilerinize ekleyebilirsiniz.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _favorites.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = _favorites[index];
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name ?? 'İsimsiz Ürün',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _removeFavorite(item.barcode ?? ''),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ProductResultCard(
                              product: item,
                              onFavoriteChanged: _loadFavorites,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

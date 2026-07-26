import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/product/models/product_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../shared/widgets/app_text_field.dart';
import 'models/barcode_list_model.dart';
import 'models/sector_model.dart';
import 'widgets/list_product_card.dart';

typedef _SectorList = ({BarcodeListModel list, List<ProductModel> items});

class SectorDetailScreen extends StatefulWidget {
  final SectorModel sector;

  const SectorDetailScreen({super.key, required this.sector});

  @override
  State<SectorDetailScreen> createState() => _SectorDetailScreenState();
}

class _SectorDetailScreenState extends State<SectorDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<_SectorList> _listFuture;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _listFuture = ServiceLocator.apiService.getSectorList(widget.sector.id);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _reloadProducts() {
    setState(() {
      _listFuture = ServiceLocator.apiService.getSectorList(widget.sector.id);
    });
  }

  void _copyExportLink(String label, String url) {
    Clipboard.setData(ClipboardData(text: url));
    AppSnackBar.showSuccess(context, '$label linki kopyalandı.');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sector = widget.sector;

    return Scaffold(
      appBar: AppBar(title: Text(sector.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${sector.name} Listesi',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${sector.itemCount} ürün',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _searchController,
                labelText: 'Arama',
                hintText: 'Ürün adı veya barkod ara',
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: FutureBuilder<_SectorList>(
                  future: _listFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Text(
                          'Ürünler yükleniyor...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return AppCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Ürün listesi yüklenemedi.',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'API bağlantısı hazır olduğunda bu sektörün ürünleri burada gösterilecek.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              text: 'Tekrar Dene',
                              icon: Icons.refresh,
                              onPressed: _reloadProducts,
                            ),
                          ],
                        ),
                      );
                    }

                    final result = snapshot.data;
                    final list = result?.list;
                    final products = result?.items ?? [];
                    final categories =
                        products
                            .map((product) => product.category)
                            .whereType<String>()
                            .where((category) => category.trim().isNotEmpty)
                            .toSet()
                            .toList()
                          ..sort();
                    final filteredProducts = products.where((product) {
                      final name = product.name?.toLowerCase() ?? '';
                      final barcode = product.barcode?.toLowerCase() ?? '';
                      final matchesSearch =
                          name.contains(_searchQuery) ||
                          barcode.contains(_searchQuery);
                      final matchesCategory =
                          _selectedCategory == null ||
                          product.category == _selectedCategory;

                      return matchesSearch && matchesCategory;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${filteredProducts.length} ürün gösteriliyor',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (list != null && list.version.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Son güncelleme: ${list.version}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.secondaryText),
                          ),
                        ],
                        if (list != null && list.exportLinks.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: list.exportLinks.entries
                                .map(
                                  (entry) => ActionChip(
                                    avatar: const Icon(
                                      Icons.download_outlined,
                                      size: 16,
                                    ),
                                    label: Text(entry.key.toUpperCase()),
                                    onPressed: () => _copyExportLink(
                                      entry.key.toUpperCase(),
                                      entry.value.toString(),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        if (categories.isNotEmpty) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.sm,
                                  ),
                                  child: ChoiceChip(
                                    label: const Text('Tümü'),
                                    selected: _selectedCategory == null,
                                    onSelected: (_) {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                    },
                                  ),
                                ),
                                ...categories.map(
                                  (category) => Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.sm,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(category),
                                      selected: _selectedCategory == category,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Center(
                                  child: Text(
                                    _emptyMessage,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filteredProducts.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: AppSpacing.sm),
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];

                                    return ListProductCard(product: product);
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _emptyMessage {
    if (_searchQuery.isNotEmpty || _selectedCategory != null) {
      return 'Aramanıza uygun ürün bulunamadı.';
    }

    return 'Bu sektörde gösterilecek ürün bulunamadı.';
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/downloads/models/download_file_model.dart';
import '../../features/product/models/product_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon_box.dart';
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
  bool _usingCache = false;
  DateTime? _cachedAt;
  final Set<String> _downloadingFormats = {};
  Map<String, List<int>> _zipImageCache = {};

  @override
  void initState() {
    super.initState();
    _listFuture = _loadList();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<_SectorList> _loadList() async {
    try {
      final result = await ServiceLocator.apiService.getSectorList(
        widget.sector.id,
      );

      unawaited(
        ServiceLocator.offlineCacheService.cacheSectorList(
          widget.sector.id,
          result.list,
          result.items,
        ),
      );

      if (mounted) {
        setState(() {
          _usingCache = false;
          _cachedAt = null;
        });
      }

      return result;
    } catch (error) {
      final cached = await ServiceLocator.offlineCacheService
          .getCachedSectorList(widget.sector.id);

      if (cached != null) {
        if (mounted) {
          setState(() {
            _usingCache = true;
            _cachedAt = cached.cachedAt;
          });
        }

        return (list: cached.list, items: cached.items);
      }

      rethrow;
    }
  }

  void _reloadProducts() {
    setState(() {
      _listFuture = _loadList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _buildFileName(String format) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = format == 'excel' ? 'xlsx' : format;

    return '${widget.sector.slug}_$timestamp.$extension';
  }

  void _showDownloadSuccess(DownloadFileModel file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${file.fileName} indirildi.'),
        action: SnackBarAction(
          label: 'Aç',
          onPressed: () => ServiceLocator.fileDownloadService
              .openDownloadedFile(file.path),
        ),
      ),
    );
  }

  Future<void> _handleSimpleDownload(
    String format,
    List<ProductModel> products,
  ) async {
    if (_downloadingFormats.contains(format)) return;

    setState(() => _downloadingFormats.add(format));

    try {
      final title = '${widget.sector.name} Listesi';
      final Uint8List bytes = format == 'pdf'
          ? await ServiceLocator.exportFileService.buildPdf(
              title: title,
              products: products,
            )
          : await ServiceLocator.exportFileService.buildExcel(
              title: title,
              products: products,
            );

      final file = await ServiceLocator.fileDownloadService.saveGeneratedFile(
        bytes: bytes,
        fileName: _buildFileName(format),
        fileType: format,
      );

      await ServiceLocator.offlineCacheService.addDownloadedFile(file);

      if (!mounted) return;
      _showDownloadSuccess(file);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Dosya indirilemedi. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _downloadingFormats.remove(format));
    }
  }

  Future<void> _handleZipDownload(List<ProductModel> products) async {
    if (_downloadingFormats.contains('zip')) return;

    final imageCount = products
        .where((product) => (product.imageUrl ?? '').trim().isNotEmpty)
        .length;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ZIP İndir'),
        content: Text(
          '$imageCount ürün görseli indirilip ZIP olarak kaydedilecek. '
          'Büyük dosyalar için Wi-Fi bağlantısı önerilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('İndir'),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    final progress = ValueNotifier<String>('Hazırlanıyor...');
    setState(() => _downloadingFormats.add('zip'));

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: ValueListenableBuilder<String>(
          valueListenable: progress,
          builder: (context, value, _) => Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(value)),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await ServiceLocator.exportFileService.buildImagesZip(
        products: products,
        previousSuccesses: _zipImageCache,
        onProgress: (done, total) {
          progress.value = '$done / $total görsel işlendi';
        },
      );

      _zipImageCache = result.imageCache;

      final file = await ServiceLocator.fileDownloadService.saveGeneratedFile(
        bytes: result.bytes,
        fileName: _buildFileName('zip'),
        fileType: 'zip',
      );

      await ServiceLocator.offlineCacheService.addDownloadedFile(file);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (result.hasFailures) {
        AppSnackBar.showError(
          context,
          '${result.includedImages}/${result.totalImages} görsel indirildi. '
          'Eksik kalanlar için tekrar deneyebilirsiniz.',
        );
      } else {
        _showDownloadSuccess(file);
      }
    } catch (_) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) {
        AppSnackBar.showError(context, 'ZIP indirilemedi. Tekrar deneyin.');
      }
    } finally {
      if (mounted) setState(() => _downloadingFormats.remove('zip'));
    }
  }

  void _handleDownload(String format, List<ProductModel> products) {
    if (format == 'zip') {
      _handleZipDownload(products);
    } else {
      _handleSimpleDownload(format, products);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
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
                              'İnternet bağlantısı yok ve bu sektör için önbellek '
                              'bulunamadı. Bağlantı geldiğinde tekrar deneyin.',
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
                        if (_usingCache) ...[
                          AppCard(
                            child: Row(
                              children: [
                                const AppIconBox(
                                  icon: Icons.cloud_off,
                                  color: AppColors.secondaryText,
                                  backgroundColor: Color(0x1F6B7280),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Çevrimdışı: '
                                    '${_cachedAt != null ? _formatDate(_cachedAt!) : '-'} '
                                    'tarihli önbellek gösteriliyor.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _reloadProducts,
                                  child: const Text('Tekrar Dene'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
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
                            children: list.exportLinks.keys.map((format) {
                              final isDownloading = _downloadingFormats
                                  .contains(format);

                              return ActionChip(
                                avatar: isDownloading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.download_outlined,
                                        size: 16,
                                      ),
                                label: Text(format.toUpperCase()),
                                onPressed: isDownloading
                                    ? null
                                    : () => _handleDownload(format, products),
                              );
                            }).toList(),
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

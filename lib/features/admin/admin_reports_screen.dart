import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../suggestion/models/suggestion_model.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<SuggestionModel> _reports = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    final list = await ServiceLocator.suggestionQueueService.getAll();

    if (mounted) {
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveReport(SuggestionModel report) async {
    await ServiceLocator.suggestionQueueService.markSynced(report.id);
    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Bildirim onaylandı ve işlendi.');
    await _loadReports();
  }

  Future<void> _rejectReport(SuggestionModel report) async {
    await ServiceLocator.suggestionQueueService.remove(report.id);
    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Bildirim reddedildi ve listeden kaldırıldı.');
    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'ALL'
        ? _reports
        : _reports.where((r) => r.type == _selectedFilter).toList();

    final suggestionsCount =
        _reports.where((r) => r.type == 'product_suggestion').length;
    final imageReportsCount =
        _reports.where((r) => r.type == 'image_report').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatalı Barkod ve Öneri Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text('Tümü (${_reports.length})'),
                            selected: _selectedFilter == 'ALL',
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = 'ALL';
                              });
                            },
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ChoiceChip(
                            label: Text('Ürün Önerileri ($suggestionsCount)'),
                            selected: _selectedFilter == 'product_suggestion',
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = 'product_suggestion';
                              });
                            },
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ChoiceChip(
                            label: Text('Hata/Görsel ($imageReportsCount)'),
                            selected: _selectedFilter == 'image_report',
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = 'image_report';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'İncelenecek bildirim kaydı bulunamadı.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isSuggestion =
                                  item.type == 'product_suggestion';

                              return AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isSuggestion
                                              ? Icons.add_box_outlined
                                              : Icons.report_problem_outlined,
                                          color: isSuggestion
                                              ? AppColors.primary
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: Text(
                                            isSuggestion
                                                ? 'Yeni Ürün Önerisi'
                                                : 'Hata / Görsel Bildirimi',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(item.syncStatus)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.syncStatus.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(
                                                item.syncStatus,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text('Barkod: ${item.barcode}'),
                                    if (item.productName != null &&
                                        item.productName!.isNotEmpty)
                                      Text('Ürün Adı: ${item.productName}'),
                                    if (item.brand != null && item.brand!.isNotEmpty)
                                      Text('Marka: ${item.brand}'),
                                    if (item.category != null &&
                                        item.category!.isNotEmpty)
                                      Text('Kategori: ${item.category}'),
                                    if (item.note != null && item.note!.isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Not: ${item.note}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.secondaryText,
                                            ),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => _rejectReport(item),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Reddet'),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        ElevatedButton(
                                          onPressed: () => _approveReport(item),
                                          child: const Text('Onayla'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'synced':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}

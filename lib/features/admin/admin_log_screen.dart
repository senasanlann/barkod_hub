import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/log_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_snack_bar.dart';

class AdminLogScreen extends StatefulWidget {
  const AdminLogScreen({super.key});

  @override
  State<AdminLogScreen> createState() => _AdminLogScreenState();
}

class _AdminLogScreenState extends State<AdminLogScreen> {
  List<LogEntry> _logs = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    final logs = await ServiceLocator.logService.getLogs();

    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    await ServiceLocator.logService.clearLogs();
    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Tüm loglar temizlendi.');
    await _loadLogs();
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'ERROR':
        return Colors.red;
      case 'WARN':
      case 'WARNING':
        return Colors.orange;
      case 'INFO':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _selectedFilter == 'ALL'
        ? _logs
        : _logs.where((l) => l.level == _selectedFilter).toList();

    final errorCount = _logs.where((l) => l.level == 'ERROR').length;
    final warnCount = _logs.where((l) => l.level == 'WARN').length;
    final infoCount = _logs.where((l) => l.level == 'INFO').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobil Log Kontrolü'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in_outlined),
            tooltip: 'Gelen Öneriler & Bildirimler',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminReports);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Logları Temizle',
            onPressed: _clearLogs,
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
                    child: Row(
                      children: [
                        _buildMetricChip('Toplam', '${_logs.length}', AppColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        _buildMetricChip('Hata', '$errorCount', Colors.red),
                        const SizedBox(width: AppSpacing.xs),
                        _buildMetricChip('Uyarı', '$warnCount', Colors.orange),
                        const SizedBox(width: AppSpacing.xs),
                        _buildMetricChip('Bilgi', '$infoCount', Colors.blue),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: ['ALL', 'ERROR', 'WARN', 'INFO'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: ChoiceChip(
                            label: Text(filter == 'ALL' ? 'Tümü' : filter),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: filteredLogs.isEmpty
                        ? Center(
                            child: Text(
                              'Log kaydı bulunamadı.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: filteredLogs.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.xs),
                            itemBuilder: (context, index) {
                              final item = filteredLogs[index];
                              final color = _getLevelColor(item.level);

                              return AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.level,
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (item.tag != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '[${item.tag}]',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.secondaryText,
                                                ),
                                          ),
                                        ],
                                        const Spacer(),
                                        Text(
                                          item.timestamp.length >= 19
                                              ? item.timestamp.substring(0, 19).replaceAll('T', ' ')
                                              : item.timestamp,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.message,
                                      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildMetricChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

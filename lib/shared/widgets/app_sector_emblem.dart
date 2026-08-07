import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

enum SectorEmblemStyle { fullCard, compactSquare, smallBadge }

class AppSectorEmblem extends StatelessWidget {
  final String? sector;
  final String? category;
  final String? productName;
  final double height;
  final SectorEmblemStyle style;
  final VoidCallback? onReportAction;

  const AppSectorEmblem({
    super.key,
    this.sector,
    this.category,
    this.productName,
    this.height = 200,
    this.style = SectorEmblemStyle.fullCard,
    this.onReportAction,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _resolveSectorMeta();

    if (style == SectorEmblemStyle.compactSquare) {
      return Container(
        width: height,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: meta.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(meta.icon, color: Colors.white, size: height * 0.5),
      );
    }

    if (style == SectorEmblemStyle.smallBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: meta.gradient.first.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: meta.gradient.first.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(meta.icon, size: 14, color: meta.gradient.first),
            const SizedBox(width: 4),
            Text(
              meta.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: meta.gradient.first,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            meta.gradient.first,
            meta.gradient.last,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: meta.gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              meta.icon,
              size: height * 0.85,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Icon(
                      meta.icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    meta.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'BARKOD HUB • ÜRÜN HAVUZU',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (onReportAction != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: onReportAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Görsel Öner / Bildir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _SectorMeta _resolveSectorMeta() {
    final query = '${sector ?? ''} ${category ?? ''} ${productName ?? ''}'.toLowerCase();

    if (query.contains('kahvaltılık') || query.contains('zeytin') || query.contains('reçel') || query.contains('bal')) {
      return _SectorMeta(
        title: 'Kahvaltılık',
        icon: Icons.breakfast_dining_outlined,
        gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      );
    }
    if (query.contains('süt') || query.contains('yoğurt') || query.contains('peynir') || query.contains('kefir')) {
      return _SectorMeta(
        title: 'Süt & Süt Ürünleri',
        icon: Icons.water_drop_outlined,
        gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
      );
    }
    if (query.contains('meyve') || query.contains('sebze') || query.contains('kuruyemiş') || query.contains('fıstık') || query.contains('ceviz')) {
      return _SectorMeta(
        title: 'Meyve, Sebze & Kuruyemiş',
        icon: Icons.eco_outlined,
        gradient: const [Color(0xFF059669), Color(0xFF10B981)],
      );
    }
    if (query.contains('sos') || query.contains('baharat') || query.contains('çeşni') || query.contains('tuz') || query.contains('yağ')) {
      return _SectorMeta(
        title: 'Sos, Baharat & Çeşni',
        icon: Icons.flatware_outlined,
        gradient: const [Color(0xFFDC2626), Color(0xFFF87171)],
      );
    }
    if (query.contains('gıda dışı') || query.contains('ev') || query.contains('mutfak')) {
      return _SectorMeta(
        title: 'Gıda Dışı Ürünler',
        icon: Icons.inventory_2_outlined,
        gradient: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
      );
    }
    if (query.contains('kırtasiye') || query.contains('kalem') || query.contains('defter') || query.contains('okul')) {
      return _SectorMeta(
        title: 'Kırtasiye & Okul',
        icon: Icons.menu_book_outlined,
        gradient: const [Color(0xFF5B21B6), Color(0xFF7C3AED)],
      );
    }
    if (query.contains('temizlik') || query.contains('deterjan') || query.contains('sabun') || query.contains('hijyen')) {
      return _SectorMeta(
        title: 'Temizlik & Hijyen',
        icon: Icons.cleaning_services_outlined,
        gradient: const [Color(0xFF0F766E), Color(0xFF0D9488)],
      );
    }
    if (query.contains('kozmetik') || query.contains('bakım') || query.contains('krem') || query.contains('şampuan')) {
      return _SectorMeta(
        title: 'Kozmetik & Bakım',
        icon: Icons.spa_outlined,
        gradient: const [Color(0xFFBE185D), Color(0xFFDB2777)],
      );
    }
    if (query.contains('hırdavat') || query.contains('matkap') || query.contains('tamir') || query.contains('alet')) {
      return _SectorMeta(
        title: 'Hırdavat & Nalburiye',
        icon: Icons.handyman_outlined,
        gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
      );
    }
    if (query.contains('içecek') || query.contains('kola') || query.contains('kahve') || query.contains('su')) {
      return _SectorMeta(
        title: 'İçecek Sektörü',
        icon: Icons.local_drink_outlined,
        gradient: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      );
    }
    if (query.contains('atıştırmalık') || query.contains('çikolata') || query.contains('şeker') || query.contains('bisküvi')) {
      return _SectorMeta(
        title: 'Atıştırmalık & Şekerleme',
        icon: Icons.cookie_outlined,
        gradient: const [Color(0xFFEA580C), Color(0xFFFB923C)],
      );
    }
    if (query.contains('temel gıda') || query.contains('market') || query.contains('gıda') || query.contains('un') || query.contains('makarna') || query.contains('pirinç')) {
      return _SectorMeta(
        title: 'Market & Gıda',
        icon: Icons.shopping_bag_outlined,
        gradient: const [Color(0xFF0055C7), Color(0xFF0077FF)],
      );
    }

    return _SectorMeta(
      title: sector ?? category ?? 'Genel Ürün Havuzu',
      icon: Icons.qr_code_2_outlined,
      gradient: const [Color(0xFF0055C7), Color(0xFF1E40AF)],
    );
  }
}

class _SectorMeta {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  _SectorMeta({
    required this.title,
    required this.icon,
    required this.gradient,
  });
}

import 'package:flutter/material.dart';

import '../../features/barcode/barcode_screen.dart';
import '../../features/barcode/manual_barcode_screen.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/sectors/models/sector_model.dart';
import '../../features/sectors/sector_detail_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.barcode:
        return MaterialPageRoute(builder: (_) => const BarcodeScreen());

      case AppRoutes.manualBarcode:
        return MaterialPageRoute(builder: (_) => const ManualBarcodeScreen());

      case AppRoutes.downloads:
        return MaterialPageRoute(builder: (_) => const DownloadsScreen());

      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case AppRoutes.sectorDetail:
        final sector = settings.arguments;

        if (sector is SectorModel) {
          return MaterialPageRoute(
            builder: (_) => SectorDetailScreen(sector: sector),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Sektör bilgisi bulunamadı.')),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}

import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../../features/admin/admin_log_screen.dart';
import '../../features/admin/admin_reports_screen.dart';
import '../../features/barcode/barcode_screen.dart';
import '../../features/barcode/manual_barcode_screen.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/sectors/models/sector_model.dart';
import '../../features/sectors/sector_detail_screen.dart';
import '../../features/suggestion/product_not_found_screen.dart';
import '../../features/suggestion/suggestion_form_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());

      case AppRoutes.adminLogs:
        return MaterialPageRoute(builder: (_) => const AdminLogScreen());

      case AppRoutes.adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());

      case AppRoutes.barcode:
        return MaterialPageRoute(builder: (_) => const BarcodeScreen());

      case AppRoutes.manualBarcode:
        return MaterialPageRoute(builder: (_) => const ManualBarcodeScreen());

      case AppRoutes.downloads:
        return MaterialPageRoute(builder: (_) => const DownloadsScreen());

      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case AppRoutes.productNotFound:
        final barcode = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ProductNotFoundScreen(barcode: barcode),
        );

      case AppRoutes.suggestionForm:
        final barcode = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => SuggestionFormScreen(barcode: barcode),
        );

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

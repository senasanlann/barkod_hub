import 'package:flutter/material.dart';

import '../../features/barcode/barcode_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/barcode/manual_barcode_screen.dart';
import 'app_routes.dart';
  

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.barcode:
        return MaterialPageRoute(
          builder: (_) => const BarcodeScreen(),
        );
        
      case AppRoutes.manualBarcode:
        return MaterialPageRoute(
          builder: (_) => const ManualBarcodeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
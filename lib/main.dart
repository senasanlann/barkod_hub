import 'package:flutter/material.dart';

import 'core/services/error_tracker.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorTracker.setupGlobalErrorHandling();
  runApp(const BarkodHubApp());
}

class BarkodHubApp extends StatelessWidget {
  const BarkodHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barkod Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
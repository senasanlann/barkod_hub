import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}
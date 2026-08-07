import 'package:flutter/material.dart';

import '../../features/auth/models/user_model.dart';
import '../../core/di/service_locator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_duration.dart';
import '../../core/theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDuration.splash,
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final results = await Future.wait([
      ServiceLocator.authService.getCurrentUser(),
      Future.delayed(AppDuration.splash),
    ]);

    final user = results.first;
    if (mounted) {
      if (user is UserModel && user.isRegistered) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.welcomeAuth);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _fillAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(180, 100),
                    painter: _BarcodeFillPainter(progress: _fillAnimation.value),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Barkod Hub',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ürün & Barkod Havuzu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                      letterSpacing: 0.8,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeFillPainter extends CustomPainter {
  final double progress;

  _BarcodeFillPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // Barkod dikey çizgilerinin oranları (ince & kalın alternatif çubuklar)
    final barWidths = [4.0, 8.0, 3.0, 10.0, 5.0, 3.0, 12.0, 4.0, 7.0, 3.0, 9.0, 4.0];
    final totalBarWidth = barWidths.reduce((a, b) => a + b);
    final gapCount = barWidths.length - 1;
    final gapWidth = (size.width - totalBarWidth) / gapCount;

    double currentX = 0.0;
    final fillX = size.width * progress;

    for (int i = 0; i < barWidths.length; i++) {
      final width = barWidths[i];
      final rect = Rect.fromLTWH(currentX, 0, width, size.height);

      // Önce gri (taban) çizgi çizilir
      canvas.drawRect(rect, basePaint);

      // Mavi dolma animasyonu çizgiyi kapsıyorsa mavi renk ile üstü kaplanır
      if (currentX < fillX) {
        final filledWidth = (fillX - currentX).clamp(0.0, width);
        final filledRect = Rect.fromLTWH(currentX, 0, filledWidth, size.height);
        canvas.drawRect(filledRect, fillPaint);
      }

      currentX += width + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodeFillPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

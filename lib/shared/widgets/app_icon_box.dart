import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_size.dart';

class AppIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const AppIconBox({
    super.key,
    required this.icon,
    this.color = AppColors.accent,
    this.backgroundColor = const Color(0x1FF48220),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.iconBox,
      height: AppSize.iconBox,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.iconBox),
      ),
      child: Icon(
        icon,
        color: color,
        size: AppSize.iconMd,
      ),
    );
  }
}
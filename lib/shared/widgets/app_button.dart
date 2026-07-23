import 'package:flutter/material.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_size.dart';
import '../../core/theme/app_spacing.dart';

enum AppButtonVariant {
  primary,
  outline,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final double height;
  final bool fullWidth;
  final double radius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.height = AppSize.buttonHeight,
    this.fullWidth = true,
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutline = variant == AppButtonVariant.outline;

    final Widget content = isLoading
        ? const SizedBox(
            width: AppSize.loadingSize,
            height: AppSize.loadingSize,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(text),
            ],
          );

    final ButtonStyle buttonStyle = isOutline
        ? OutlinedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          )
        : ElevatedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          );

    if (isOutline) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
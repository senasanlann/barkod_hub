import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../widgets/app_button.dart';

enum UiStatus { idle, loading, success, error }

class UiState<T> {
  final UiStatus status;
  final T? data;
  final String? errorMessage;
  final bool isFromCache;

  const UiState._({
    required this.status,
    this.data,
    this.errorMessage,
    this.isFromCache = false,
  });

  factory UiState.idle() {
    return const UiState._(status: UiStatus.idle);
  }

  factory UiState.loading() {
    return const UiState._(status: UiStatus.loading);
  }

  factory UiState.success(T data, {bool isFromCache = false}) {
    return UiState._(
      status: UiStatus.success,
      data: data,
      isFromCache: isFromCache,
    );
  }

  factory UiState.error(String message) {
    return UiState._(
      status: UiStatus.error,
      errorMessage: message,
    );
  }

  bool get isIdle => status == UiStatus.idle;
  bool get isLoading => status == UiStatus.loading;
  bool get isSuccess => status == UiStatus.success;
  bool get isError => status == UiStatus.error;
}

class UiStateBuilder<T> extends StatelessWidget {
  final UiState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String message)? errorBuilder;
  final Widget Function(BuildContext context)? idleBuilder;
  final VoidCallback? onRetry;

  const UiStateBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.idleBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case UiStatus.idle:
        if (idleBuilder != null) return idleBuilder!(context);
        return const SizedBox.shrink();

      case UiStatus.loading:
        if (loadingBuilder != null) return loadingBuilder!(context);
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          ),
        );

      case UiStatus.error:
        final message = state.errorMessage ?? 'Bir hata oluştu.';
        if (errorBuilder != null) return errorBuilder!(context, message);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Tekrar Deneyin',
                    icon: Icons.refresh,
                    variant: AppButtonVariant.outline,
                    onPressed: onRetry,
                  ),
                ],
              ],
            ),
          ),
        );

      case UiStatus.success:
        if (state.data != null) {
          return builder(context, state.data as T);
        }
        return const SizedBox.shrink();
    }
  }
}

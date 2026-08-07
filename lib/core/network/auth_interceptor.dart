import 'package:dio/dio.dart';

import '../di/service_locator.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = await ServiceLocator.authService.getCurrentUser();
      final isOwnApi = options.uri.toString().startsWith(ApiConstants.baseUrl);
      if (isOwnApi && user.token != null && user.token!.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${user.token}';
      }
    } catch (_) {
      // Ignore if authService fails
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode == 401 || statusCode == 403) {
      await ServiceLocator.logService.log(
        'WARN',
        'Oturum süresi doldu veya yetkisiz erişim ($statusCode): $path',
        tag: 'AUTH',
      );
    } else if (statusCode == 429) {
      await ServiceLocator.logService.log(
        'ERROR',
        'API istek limiti aşıldı ($statusCode): $path',
        tag: 'RATE_LIMIT',
      );
    } else if (statusCode != null && statusCode >= 500) {
      await ServiceLocator.logService.log(
        'ERROR',
        'Sunucu hatası ($statusCode): $path',
        tag: 'SERVER',
      );
    }

    handler.next(err);
  }
}

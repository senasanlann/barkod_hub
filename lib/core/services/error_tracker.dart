import 'package:flutter/foundation.dart';

import '../di/service_locator.dart';

class ErrorTracker {
  static Future<void> trackApiError(
    dynamic error, {
    StackTrace? stackTrace,
  }) async {
    final message = 'API Hatası: ${error.toString()}';
    await ServiceLocator.logService.log('ERROR', message, tag: 'API');
  }

  static Future<void> trackCameraError(
    dynamic error, {
    StackTrace? stackTrace,
  }) async {
    final message = 'Kamera / Tarayıcı Hatası: ${error.toString()}';
    await ServiceLocator.logService.log('ERROR', message, tag: 'CAMERA');
  }

  static Future<void> trackDownloadError(
    dynamic error, {
    StackTrace? stackTrace,
  }) async {
    final message = 'İndirme / Dosya Hatası: ${error.toString()}';
    await ServiceLocator.logService.log('ERROR', message, tag: 'DOWNLOAD');
  }

  static Future<void> trackUnhandledError(
    Object error,
    StackTrace stackTrace,
  ) async {
    final message = 'Yakalanamayan Hata: ${error.toString()}';
    await ServiceLocator.logService.log('ERROR', message, tag: 'CRASH');
  }

  static void setupGlobalErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      trackUnhandledError(details.exception, details.stack ?? StackTrace.current);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      trackUnhandledError(error, stack);
      return true;
    };
  }
}

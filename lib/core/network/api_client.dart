import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'BarkodHub/1.0 (destek@bilsoft.com)',
      },
    ),
  );

  ApiClient() {
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (_) {
      throw const ApiException('Beklenmeyen bir hata oluştu.');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (_) {
      throw const ApiException('Beklenmeyen bir hata oluştu.');
    }
  }

  ApiException _handleDioException(DioException e) {
    final data = e.response?.data;
    String? serverMessage;
    if (data is Map) {
      final msg = data['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        serverMessage = msg.toString().trim();
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      if (statusCode == 404) {
        return ApiException(serverMessage ?? 'Ürün bulunamadı');
      }
      if (statusCode == 429) {
        return ApiException(
          serverMessage ?? 'Çok fazla istek gönderildi, lütfen bekleyin',
        );
      }
      if (statusCode >= 500) {
        return ApiException(serverMessage ?? 'Sunucu hatası');
      }
      if (serverMessage != null) {
        return ApiException(serverMessage);
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException('İnternet bağlantısı yok');
    }

    return ApiException(serverMessage ?? 'İnternet bağlantısı yok');
  }
}

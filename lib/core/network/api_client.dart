import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Sunucuya ulaşılamadı.',
      );
    } catch (_) {
      throw const ApiException('Beklenmeyen bir hata oluştu.');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Sunucuya ulaşılamadı.',
      );
    } catch (_) {
      throw const ApiException('Beklenmeyen bir hata oluştu.');
    }
  }
}
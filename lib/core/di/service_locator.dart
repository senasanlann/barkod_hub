import '../network/api_client.dart';
import '../services/api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ApiClient apiClient = ApiClient();

  static final ApiService _apiService = ApiService(client: apiClient);

  static ApiService? _apiServiceOverride;

  static ApiService get apiService => _apiServiceOverride ?? _apiService;

  static void setApiServiceOverride(ApiService? apiService) {
    _apiServiceOverride = apiService;
  }
}

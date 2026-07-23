import '../network/api_client.dart';
import '../services/api_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ApiClient apiClient = ApiClient();

  static final ApiService apiService = ApiService(
    client: apiClient,
  );
}
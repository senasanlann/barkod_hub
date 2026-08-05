import '../network/api_client.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/export_file_service.dart';
import '../services/favorites_service.dart';
import '../services/file_download_service.dart';
import '../services/offline_cache_service.dart';
import '../services/suggestion_queue_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ApiClient apiClient = ApiClient();

  static final ApiService _apiService = ApiService(client: apiClient);

  static final FileDownloadService fileDownloadService = FileDownloadService(
    dio: apiClient.dio,
  );

  static final ExportFileService exportFileService = ExportFileService(
    dio: apiClient.dio,
  );

  static final OfflineCacheService offlineCacheService = OfflineCacheService();

  static final SuggestionQueueService suggestionQueueService =
      SuggestionQueueService();

  static final AuthService authService = AuthService();

  static final FavoritesService favoritesService = FavoritesService();

  static ApiService? _apiServiceOverride;

  static ApiService get apiService => _apiServiceOverride ?? _apiService;

  static void setApiServiceOverride(ApiService? apiService) {
    _apiServiceOverride = apiService;
  }
}

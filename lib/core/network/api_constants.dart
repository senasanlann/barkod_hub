class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://example.com',
  );

  static const String productsByBarcode = '/api/v1/products/by-barcode';

  static const String offBaseUrl = 'https://world.openfoodfacts.org';
  static const String offProductPath = '/api/v2/product';

  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  static const String sectors = '/api/v1/sectors';

  static const String listItems = '/api/v1/lists';

  static const String exportJobs = '/api/v1/export/jobs';

  static const String productSuggestions = '/api/v1/product-suggestions';

  static const String imageReports = '/api/v1/image-reports';
}

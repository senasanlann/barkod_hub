import '../../features/product/models/product_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

class ApiService {
  final ApiClient client;

  ApiService({required this.client});

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return client.get(path, queryParameters: queryParameters);
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return client.post(path, data: data, queryParameters: queryParameters);
  }

  Future<ProductModel> getProductByBarcode(String barcode) async {
    if (ApiConstants.useMockData) {
      return _getMockProductByBarcode(barcode);
    }

    final response = await client.get(
      ApiConstants.productsByBarcode,
      queryParameters: {'barcode': barcode},
    );

    if (response is Map<String, dynamic>) {
      return ProductModel.fromJson(response);
    }

    if (response is Map) {
      return ProductModel.fromJson(Map<String, dynamic>.from(response));
    }

    return ProductModel(rawData: {'response': response});
  }

  Future<ProductModel> _getMockProductByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return ProductModel.fromJson({
      'barcode': barcode,
      'name': 'Örnek Ürün',
      'brand': 'Bilsoft',
      'category': 'Demo Kategori',
      'status': 'Mock veri',
    });
  }
}

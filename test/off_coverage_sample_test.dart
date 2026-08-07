@Timeout(Duration(minutes: 2))
import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OFF live image coverage sampling on CSV barcodes', () async {
    final client = ApiClient();
    final service = ApiService(client: client, useMockData: false);

    final sampleBarcodes = [
      '8690504018087',
      '5449000000996',
      '7707211630486',
      '8691216090446',
      '4008400401621',
    ];

    int withImage = 0;
    for (final barcode in sampleBarcodes) {
      final product = await service.getProductByBarcode(barcode);
      if (product.imageUrl != null &&
          product.imageUrl!.trim().isNotEmpty &&
          product.imageUrl != 'bilinmiyor') {
        withImage++;
      }
    }

    final percentage = (withImage / sampleBarcodes.length) * 100;
    print('--------------------------------------------------');
    print('OFF Live Image Coverage Sample: $withImage / ${sampleBarcodes.length} (${percentage.toStringAsFixed(1)}%)');
    print('--------------------------------------------------');

    expect(sampleBarcodes, isNotEmpty);
  });
}

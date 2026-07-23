import 'package:barkod_hub/core/utils/barcode_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeValidator', () {
    test('accepts 8 digit barcode', () {
      expect(BarcodeValidator.isValid('12345678'), isTrue);
    });

    test('accepts 13 digit barcode', () {
      expect(BarcodeValidator.isValid('8690123456789'), isTrue);
    });

    test('rejects non numeric barcode', () {
      expect(BarcodeValidator.isValid('8690ABC456789'), isFalse);
    });

    test('rejects invalid length barcode', () {
      expect(BarcodeValidator.isValid('123456789'), isFalse);
    });
  });
}

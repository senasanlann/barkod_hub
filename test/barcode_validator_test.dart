import 'package:barkod_hub/core/utils/barcode_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeValidator', () {
    test('accepts 8 digit barcode', () {
      expect(BarcodeValidator.isValid('12345678'), isTrue);
    });

    test('accepts 12 digit UPC-A barcode', () {
      expect(BarcodeValidator.isValid('012345678905'), isTrue);
    });

    test('accepts 13 digit EAN-13 barcode', () {
      expect(BarcodeValidator.isValid('8690123456789'), isTrue);
    });

    test('accepts 14 digit GTIN-14 barcode', () {
      expect(BarcodeValidator.isValid('10012345678902'), isTrue);
    });

    test('rejects non numeric barcode', () {
      expect(BarcodeValidator.isValid('8690ABC456789'), isFalse);
    });

    test('rejects invalid length barcode', () {
      expect(BarcodeValidator.isValid('123456789'), isFalse);
    });
  });
}

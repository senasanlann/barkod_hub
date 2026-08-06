class BarcodeValidator {
  BarcodeValidator._();

  static bool isValid(String barcode) {
    final isOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(barcode);
    final hasValidLength = barcode.length == 8 ||
        barcode.length == 12 ||
        barcode.length == 13 ||
        barcode.length == 14;

    return isOnlyNumbers && hasValidLength;
  }
}

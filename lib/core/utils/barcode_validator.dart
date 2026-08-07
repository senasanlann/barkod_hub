class BarcodeValidator {
  BarcodeValidator._();

  static bool isValid(String barcode) {
    final isOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(barcode);
    final hasValidLength = barcode.length == 8 ||
        barcode.length == 12 ||
        barcode.length == 13 ||
        barcode.length == 14;

    if (!isOnlyNumbers || !hasValidLength) return false;
    return isValidChecksum(barcode);
  }

  static bool isValidChecksum(String barcode) {
    if (!RegExp(r'^[0-9]+$').hasMatch(barcode)) return false;
    final digits = barcode.split('').map(int.parse).toList();
    final checkDigit = digits.last;
    
    int sum = 0;
    bool multiplyByThree = true;
    for (int i = digits.length - 2; i >= 0; i--) {
      sum += digits[i] * (multiplyByThree ? 3 : 1);
      multiplyByThree = !multiplyByThree;
    }
    
    final calculatedCheck = (10 - (sum % 10)) % 10;
    return checkDigit == calculatedCheck;
  }
}

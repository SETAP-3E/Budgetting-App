import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCurrency', () {
    test('formats a typical value with two decimal places', () {
      expect(formatCurrency(49.99), '£49.99');
    });

    test('formats zero as £0.00', () {
      expect(formatCurrency(0), '£0.00');
    });

    test('pads a single decimal digit to two places', () {
      expect(formatCurrency(1234.5), '£1,234.50');
    });

    test('includes thousand separators for large amounts', () {
      expect(formatCurrency(1234567.89), '£1,234,567.89');
    });

    test('rounds sub-penny values to two decimal places', () {
      expect(formatCurrency(0.1), '£0.10');
    });
  });
}

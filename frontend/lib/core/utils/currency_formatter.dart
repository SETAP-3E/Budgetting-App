import 'package:intl/intl.dart';

/// Formats a monetary amount as a GBP string with thousand separators.
///
/// Example: 1234567.89 → '£1,234,567.89'
String formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'en_GB',
    symbol: '£',
    decimalDigits: 2,
  ).format(amount);
}

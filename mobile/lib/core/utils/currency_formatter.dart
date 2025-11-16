import 'package:intl/intl.dart';
import '../config/constants.dart';

class CurrencyFormatter {
  static String format(double amount, {String? currency}) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  static String formatWithCurrency(double amount, String currency) {
    if (currency == 'TZS') {
      return format(amount);
    }
    final formatter = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}


























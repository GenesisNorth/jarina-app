import 'package:decimal/decimal.dart';
import 'package:jarina_core/src/money/currency.dart';
import 'package:jarina_core/src/money/money.dart';

/// Formats money the way the designs show it:
/// `₦184,200` · `GH₵1,250.00` · `CFA 85,000` · `FCFA 42,000` · `0.0042 BTC`.
///
/// Formatting is done on the decimal string, never via `double`, so large
/// balances and 8-decimal crypto amounts print exactly.
abstract final class MoneyFormat {
  /// [decimals] overrides how many fraction digits are shown. By default fiat
  /// shows its precision except NGN, which hides kobo on whole amounts.
  static String format(Money m, {int? decimals, bool signed = false}) {
    final c = m.currency;
    final shown = decimals ?? _defaultDecimals(m);
    final body = _group(m.amount.abs(), shown, trimZeros: c.isCrypto && decimals == null);
    final sign = m.isNegative ? '-' : (signed && m.isPositive ? '+' : '');
    if (c.isCrypto) return '$sign$body ${c.code}';
    final spaced = c == Currency.xof || c == Currency.xaf;
    return '$sign${c.symbol}${spaced ? ' ' : ''}$body';
  }

  /// Plain grouped number without symbol, e.g. for keypad entry fields.
  static String number(Decimal value, {int decimals = 0}) => _group(value, decimals, trimZeros: false);

  /// Percentage change with sign, e.g. `+1.20%`, `-0.13%`.
  static String percent(Decimal value, {int decimals = 2}) {
    final s = _group(value.abs(), decimals, trimZeros: false);
    return '${value.sign < 0 ? '-' : '+'}$s%';
  }

  static int _defaultDecimals(Money m) {
    final c = m.currency;
    if (c.isCrypto) return c.decimals;
    if (c == Currency.ngn && m.amount == m.amount.floor()) return 0;
    return c.decimals;
  }

  static String _group(Decimal value, int decimals, {required bool trimZeros}) {
    final fixed = value.floor(scale: decimals).toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    if (parts.length > 1) {
      var frac = parts[1];
      if (trimZeros) frac = frac.replaceFirst(RegExp(r'0+$'), '');
      if (frac.isNotEmpty) buf.write('.$frac');
    }
    return buf.toString();
  }
}

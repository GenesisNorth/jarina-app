import 'package:meta/meta.dart';

enum CurrencyKind { fiat, crypto }

/// A unit of account: a fiat currency or a crypto asset.
///
/// [decimals] is the precision amounts are stored and rounded to, not
/// necessarily how many digits the UI shows.
@immutable
class Currency {
  const Currency._(this.code, this.symbol, this.decimals, this.kind);

  /// Crypto assets are identified by ticker and kept at 8 decimals unless the
  /// asset catalogue says otherwise.
  const Currency.crypto(String code, {int decimals = 8}) : this._(code, '', decimals, CurrencyKind.crypto);

  factory Currency.fromCode(String code) {
    final upper = code.toUpperCase();
    for (final c in fiats) {
      if (c.code == upper) return c;
    }
    return Currency.crypto(upper);
  }

  static const ngn = Currency._('NGN', '₦', 2, CurrencyKind.fiat);
  static const ghs = Currency._('GHS', 'GH₵', 2, CurrencyKind.fiat);
  // CFA francs have no minor unit.
  static const xof = Currency._('XOF', 'CFA', 0, CurrencyKind.fiat);
  static const xaf = Currency._('XAF', 'FCFA', 0, CurrencyKind.fiat);
  static const usd = Currency._('USD', r'$', 2, CurrencyKind.fiat);

  static const List<Currency> fiats = [ngn, ghs, xof, xaf, usd];

  /// Home-currency wallets users can hold (stocks settle into these).
  static const List<Currency> homeCurrencies = [ngn, ghs, xof, xaf];

  final String code;
  final String symbol;
  final int decimals;
  final CurrencyKind kind;

  bool get isFiat => kind == CurrencyKind.fiat;
  bool get isCrypto => kind == CurrencyKind.crypto;

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

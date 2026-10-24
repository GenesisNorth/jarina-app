import 'package:decimal/decimal.dart';
import 'package:jarina_core/src/money/currency.dart';
import 'package:meta/meta.dart';

/// An exact amount in a [Currency]. Never use `double` for money.
@immutable
class Money implements Comparable<Money> {
  const Money(this.amount, this.currency);

  Money.zero(Currency currency) : this(Decimal.zero, currency);

  /// Parses a decimal string, e.g. `Money.parse('184200', Currency.ngn)`.
  factory Money.parse(String value, Currency currency) => Money(Decimal.parse(value), currency);

  final Decimal amount;
  final Currency currency;

  bool get isZero => amount == Decimal.zero;
  bool get isNegative => amount < Decimal.zero;
  bool get isPositive => amount > Decimal.zero;

  Money operator +(Money other) => Money(amount + _same(other).amount, currency);
  Money operator -(Money other) => Money(amount - _same(other).amount, currency);
  Money operator -() => Money(-amount, currency);

  /// Multiplies by a factor (quantity, rate, percentage). Result is not rounded.
  Money times(Decimal factor) => Money(amount * factor, currency);

  /// Converts at [rate] = units of [to] per one unit of this currency, rounded
  /// half-even to the target precision.
  Money convert(Currency to, Decimal rate) => Money(amount * rate, to).rounded();

  /// Rounds to the currency's precision. Half-even avoids systematic bias
  /// when many fees are summed in the ledger.
  Money rounded() => Money(_roundHalfEven(amount, currency.decimals), currency);

  /// Rounds down — use for "max you can spend/receive" so we never overstate.
  Money floored() => Money(amount.floor(scale: currency.decimals), currency);

  Money abs() => isNegative ? -this : this;

  bool operator <(Money other) => amount < _same(other).amount;
  bool operator <=(Money other) => amount <= _same(other).amount;
  bool operator >(Money other) => amount > _same(other).amount;
  bool operator >=(Money other) => amount >= _same(other).amount;

  @override
  int compareTo(Money other) => amount.compareTo(_same(other).amount);

  Money _same(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    return other;
  }

  @override
  bool operator ==(Object other) => other is Money && other.currency == currency && other.amount == amount;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => '$amount ${currency.code}';
}

Decimal _roundHalfEven(Decimal value, int scale) {
  final down = value.floor(scale: scale);
  final step = Decimal.ten.pow(-scale).toDecimal();
  final half = step * Decimal.parse('0.5');
  final rest = value - down;
  if (rest < half) return down;
  if (rest > half) return down + step;
  // Exactly half: pick the even neighbour.
  final lastDigit = (down * Decimal.ten.pow(scale).toDecimal()).toBigInt() % BigInt.two;
  return lastDigit == BigInt.zero ? down : down + step;
}

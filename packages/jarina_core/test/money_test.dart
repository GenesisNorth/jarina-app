import 'package:jarina_core/jarina_core.dart';
import 'package:test/test.dart';

Decimal d(String s) => Decimal.parse(s);

void main() {
  group('Money', () {
    test('adds exactly where double would drift', () {
      final a = Money.parse('0.1', Currency.ngn);
      final b = Money.parse('0.2', Currency.ngn);
      expect((a + b).amount, d('0.3'));
    });

    test('refuses to mix currencies', () {
      expect(
        () => Money.parse('1', Currency.ngn) + Money.parse('1', Currency.ghs),
        throwsArgumentError,
      );
    });

    test('2.5% trade fee on ₦100,000', () {
      final fee = Money.parse('100000', Currency.ngn).times(d('0.025')).rounded();
      expect(fee, Money.parse('2500', Currency.ngn));
    });

    test('rounds half-even to currency precision', () {
      expect(Money.parse('1.005', Currency.ngn).rounded().amount, d('1.00'));
      expect(Money.parse('1.015', Currency.ngn).rounded().amount, d('1.02'));
      expect(Money.parse('1.0151', Currency.ngn).rounded().amount, d('1.02'));
      expect(Money.parse('85000.5', Currency.xof).rounded().amount, d('85000'));
    });

    test('floored never overstates a max amount', () {
      expect(Money.parse('0.123456789', const Currency.crypto('BTC')).floored().amount, d('0.12345678'));
    });

    test('convert NGN → XOF at sample rate', () {
      final xof = Money.parse('25000', Currency.ngn).convert(Currency.xof, d('0.39'));
      expect(xof, Money.parse('9750', Currency.xof));
    });
  });

  group('MoneyFormat', () {
    test('matches the design strings', () {
      expect(MoneyFormat.format(Money.parse('184200', Currency.ngn)), '₦184,200');
      expect(MoneyFormat.format(Money.parse('861.9', Currency.ngn)), '₦861.90');
      expect(MoneyFormat.format(Money.parse('1250', Currency.ghs)), 'GH₵1,250.00');
      expect(MoneyFormat.format(Money.parse('85000', Currency.xof)), 'CFA 85,000');
      expect(MoneyFormat.format(Money.parse('42000', Currency.xaf)), 'FCFA 42,000');
      expect(MoneyFormat.format(Money.parse('0.0042', const Currency.crypto('BTC'))), '0.0042 BTC');
      expect(MoneyFormat.format(Money.parse('98000000', Currency.ngn)), '₦98,000,000');
    });

    test('signs', () {
      expect(MoneyFormat.format(Money.parse('-15630', Currency.ngn)), '-₦15,630');
      expect(MoneyFormat.format(Money.parse('450', Currency.ghs), signed: true), '+GH₵450.00');
      expect(MoneyFormat.percent(d('1.2')), '+1.20%');
      expect(MoneyFormat.percent(d('-0.13')), '-0.13%');
    });
  });

  group('Result', () {
    test('when / map', () {
      const Result<int> ok = Ok(2);
      expect(ok.map((v) => v * 2).valueOrNull, 4);
      const Result<int> err = Err(InsufficientFundsFailure());
      expect(err.when(ok: (_) => 'ok', err: (f) => f.runtimeType.toString()), 'InsufficientFundsFailure');
    });
  });
}

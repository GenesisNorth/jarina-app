import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina_core/jarina_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLedger l;
  setUp(() => l = FakeLedger(latency: Duration.zero, tick: Duration.zero));
  tearDown(() => l.dispose());

  const usdt = Currency.crypto('USDT', decimals: 2);
  Decimal d(String v) => Decimal.parse(v);
  Failure? fail<T>(Result<T> r) => r.when(ok: (_) => null, err: (f) => f);

  test('deposit addresses are valid for their network, stable, and renewable', () async {
    for (final coin in ['BTC', 'USDT', 'ETH', 'SOL', 'XRP', 'TRX', 'DOGE', 'LTC', 'SUI']) {
      for (final n in await l.networks(coin)) {
        final a = (await l.depositAddress(coin, n)).valueOrNull!;
        expect(AddressRules.isValid(n.id, a.address), isTrue, reason: '$coin ${n.id} ${a.address}');
        expect(a.memo != null, n.memoRequired, reason: '$coin memo');
      }
    }
    final trc = (await l.networks('USDT')).first;
    final a1 = (await l.depositAddress('USDT', trc)).valueOrNull!.address;
    expect((await l.depositAddress('USDT', trc)).valueOrNull!.address, a1, reason: 'stable');
    expect((await l.depositAddress('USDT', trc, fresh: true)).valueOrNull!.address, isNot(a1));
  });

  test('swap USDT → BTC charges 2.5% and moves both balances', () async {
    final price = (await l.watchQuotes().first)['USDT']!.price;
    expect((price - Decimal.parse('1550')).abs() < Decimal.parse('2'), isTrue, reason: 'USDT holds its peg');
    final q = (await l.quoteSwap(Money.parse('100', usdt), 'BTC')).valueOrNull!;
    expect(q.fee, Money(Decimal.fromInt(100) * price, Currency.ngn).times(Decimal.parse('0.025')).rounded());
    await l.swap(q, pinToken: 't');
    final b = await l.watchBalances().first;
    expect(b.qtyOf('USDT'), d('220'));
    expect(b.qtyOf('BTC'), d('0.0042') + q.receive.amount);
  });

  test('swap cannot exceed the balance', () async {
    expect(fail(await l.quoteSwap(Money.parse('321', usdt), 'BTC')), isA<InsufficientFundsFailure>());
  });

  test('withdrawal validates the address, charges the network fee, and can be cancelled', () async {
    final trc = (await l.networks('USDT')).first;
    final bad = await l.withdraw(
      coin: 'USDT',
      network: trc,
      address: '0x52908400098527886E0F7030069857D2E4169EE7',
      amount: d('50'),
      pinToken: 'p',
      twofaToken: 't',
    );
    expect(fail(bad), isA<InvalidAddressFailure>());
    final tiny = await l.withdraw(
      coin: 'USDT',
      network: trc,
      address: 'TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf',
      amount: d('1'),
      pinToken: 'p',
      twofaToken: 't',
    );
    expect(fail(tiny), isA<BelowMinimumFailure>(), reason: 'amount must exceed the 1 USDT fee');

    final w = (await l.withdraw(
      coin: 'USDT',
      network: trc,
      address: 'TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf',
      amount: d('50'),
      pinToken: 'p',
      twofaToken: 't',
    )).valueOrNull!;
    expect(w.status, TransferStatus.processing);
    expect((await l.watchBalances().first).qtyOf('USDT'), d('270'));
    expect((await l.cancelWithdrawal(w.id)).isOk, isTrue);
    expect((await l.watchBalances().first).qtyOf('USDT'), d('320'), reason: 'refunded');
    expect((await l.watchTransfers().first).first.status, TransferStatus.cancelled);
  });

  test('internal transfer only to existing users', () async {
    expect(
      fail(await l.sendToUser(coin: 'USDT', username: '@nobody', amount: d('5'), pinToken: 'p', twofaToken: 't')),
      isA<UserNotFoundFailure>(),
    );
    final ok = await l.sendToUser(coin: 'USDT', username: '@zainab', amount: d('5'), pinToken: 'p', twofaToken: 't');
    expect(ok.valueOrNull!.status, TransferStatus.successful);
  });

  test('limit orders reserve funds; cancelling refunds; marketable orders fill', () async {
    final far = await l.placeLimitOrder(
      coin: 'BTC',
      side: OrderSide.buy,
      price: d('50000000'),
      amount: d('0.001'),
      pinToken: 'p',
    );
    final o = far.valueOrNull!;
    expect(o.status, OrderStatus.open);
    final reserved = Money.parse('50000', Currency.ngn) + Money.parse('1250', Currency.ngn);
    expect((await l.watchBalances().first).fiatOf(Currency.ngn), Money.parse('184200', Currency.ngn) - reserved);
    await l.cancelOrder(o.id);
    expect((await l.watchBalances().first).fiatOf(Currency.ngn), Money.parse('184200', Currency.ngn));

    final sell = await l.placeLimitOrder(
      coin: 'USDT',
      side: OrderSide.sell,
      price: d('1'),
      amount: d('10'),
      pinToken: 'p',
    );
    expect(sell.valueOrNull!.status, OrderStatus.filled, reason: 'below market price fills at once');
  });

  test('cash out needs the minimum and pays out the Naira value minus fee', () async {
    final acct = (await l.resolveAccount('GTBank', '0123456789')).valueOrNull!;
    expect(
      fail(await l.cashOut(amount: Money.parse('5', usdt), account: acct, pinToken: 'p', twofaToken: 't')),
      isA<BelowMinimumFailure>(),
    );
    final price = (await l.watchQuotes().first)['USDT']!.price;
    final r = await l.cashOut(amount: Money.parse('100', usdt), account: acct, pinToken: 'p', twofaToken: 't');
    final gross = Money(Decimal.fromInt(100) * price, Currency.ngn).rounded();
    expect(r.valueOrNull!.subtitle, MoneyFormat.format(gross - gross.times(Decimal.parse('0.025')).rounded()));
    expect(fail(await l.resolveAccount('GTBank', '12345')), isA<ValidationFailure>());
  });

  test('loan: 40% LTV of BTC collateral, 3.5% a month, liquidation at 85% LTV', () async {
    const btc = Currency.crypto('BTC');
    final q = (await l.quoteLoan(Money.parse('0.004', btc), ltv: 0.4, days: 30)).valueOrNull!;
    final price = (await l.watchQuotes().first)['BTC']!.price;
    expect(q.borrow, Money(Decimal.parse('0.004') * price * Decimal.parse('0.4'), Currency.ngn).floored());
    expect(q.interest, q.borrow.times(Decimal.parse('0.035')).rounded());
    await l.takeLoan(q, pinToken: 'p');
    final b = await l.watchBalances().first;
    expect(b.qtyOf('BTC'), Decimal.parse('0.0002'));
    expect(b.fiatOf(Currency.ngn), Money.parse('184200', Currency.ngn) + q.borrow);
  });
}

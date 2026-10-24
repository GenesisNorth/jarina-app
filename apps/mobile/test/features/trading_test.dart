import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina_core/jarina_core.dart';

/// 2026-10-19 is a Monday. 10:00 UTC = 11:00 WAT (market open).
final mondayOpen = DateTime.utc(2026, 10, 19, 10);
final saturday = DateTime.utc(2026, 10, 24, 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FakeLedger ledger(DateTime now) {
    final l = FakeLedger(latency: Duration.zero, tick: Duration.zero, clock: () => now);
    addTearDown(l.dispose);
    return l;
  }

  Money ngn(String v) => Money.parse(v, Currency.ngn);

  test('buy quotes whole NGX shares and adds the 2.5% fee on top', () async {
    final l = ledger(mondayOpen);
    final q = (await l.quoteBuy('MTNN', ngn('50000'))).valueOrNull!;
    final expectedQty = (Decimal.parse('50000') / q.price).toDecimal(scaleOnInfinitePrecision: 8).floor();
    expect(q.quantity, expectedQty);
    expect(q.quantity, q.quantity.floor(), reason: 'whole shares');
    expect(q.gross, Money(q.quantity * q.price, Currency.ngn).rounded());
    expect(q.fee, q.gross.times(Decimal.parse('0.025')).rounded());
    expect(q.total, q.gross + q.fee);
    expect(q.gross <= ngn('50000'), isTrue, reason: 'never spend more than asked before fee');
    expect(q.marketOpen, isTrue);
  });

  test('buy rejects less than one share and more than the balance', () async {
    final l = ledger(mondayOpen);
    final tiny = await l.quoteBuy('NESTLE', ngn('100'));
    expect(tiny.when(ok: (_) => null, err: (f) => f), isA<BelowMinimumFailure>());
    final big = await l.quoteBuy('MTNN', ngn('184000')); // + fee > ₦184,200
    expect(big.when(ok: (_) => null, err: (f) => f), isA<InsufficientFundsFailure>());
  });

  test('sell cannot exceed holdings or use fractional shares', () async {
    final l = ledger(mondayOpen);
    final tooMany = await l.quoteSell('MTNN', Decimal.fromInt(401));
    expect(tooMany.when(ok: (_) => null, err: (f) => f), isA<InsufficientFundsFailure>());
    final frac = await l.quoteSell('MTNN', Decimal.parse('1.5'));
    expect(frac.isOk, isFalse);
  });

  test('a filled buy moves cash and shares and records a successful trade', () async {
    final l = ledger(mondayOpen);
    final q = (await l.quoteBuy('MTNN', ngn('50000'))).valueOrNull!;
    final tx = (await l.placeOrder(q, pinToken: 't')).valueOrNull!;
    final b = await l.watchBalances().first;
    expect(b.fiatOf(Currency.ngn), ngn('184200') - q.total);
    expect(b.qtyOf('MTNN'), Decimal.fromInt(400) + q.quantity);
    expect(tx.status, TxStatus.successful);
    expect(tx.title, 'Bought MTNN');
    expect(tx.amount, -q.total);
  });

  test('a sell credits the wallet minus the fee', () async {
    final l = ledger(mondayOpen);
    final q = (await l.quoteSell('GTCO', Decimal.fromInt(100))).valueOrNull!;
    await l.placeOrder(q, pinToken: 't');
    final b = await l.watchBalances().first;
    expect(b.qtyOf('GTCO'), Decimal.fromInt(200));
    expect(b.fiatOf(Currency.ngn), ngn('184200') + q.gross - q.fee);
  });

  test('on a weekend the stock order queues: cash reserved, shares not yet credited', () async {
    final l = ledger(saturday);
    final q = (await l.quoteBuy('MTNN', ngn('20000'))).valueOrNull!;
    expect(q.marketOpen, isFalse);
    final tx = (await l.placeOrder(q, pinToken: 't')).valueOrNull!;
    final b = await l.watchBalances().first;
    expect(tx.status, TxStatus.pending);
    expect(b.fiatOf(Currency.ngn), ngn('184200') - q.total);
    expect(b.qtyOf('MTNN'), Decimal.fromInt(400));
  });

  test('crypto trades 24/7 and allows fractions', () async {
    final l = ledger(saturday);
    final q = (await l.quoteBuy('BTC', ngn('10000'))).valueOrNull!;
    expect(q.marketOpen, isTrue);
    expect(q.quantity, isNot(q.quantity.floor()));
  });

  test('an expired quote is refused', () async {
    var now = mondayOpen;
    final l = FakeLedger(latency: Duration.zero, tick: Duration.zero, clock: () => now);
    addTearDown(l.dispose);
    final q = (await l.quoteBuy('MTNN', ngn('10000'))).valueOrNull!;
    now = now.add(const Duration(minutes: 1));
    final r = await l.placeOrder(q, pinToken: 't');
    expect(r.when(ok: (_) => null, err: (f) => f), isA<QuoteExpiredFailure>());
  });
}

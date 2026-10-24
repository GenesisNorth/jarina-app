import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/fake/fake_payments.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina_core/jarina_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLedger l;
  late FakePayments p;
  setUp(() {
    l = FakeLedger(latency: Duration.zero, tick: Duration.zero);
    p = FakePayments(l, latency: Duration.zero);
  });
  tearDown(() => l.dispose());

  Money ngn(String v) => Money.parse(v, Currency.ngn);
  Failure? fail<T>(Result<T> r) => r.when(ok: (_) => null, err: (f) => f);
  Future<Recipient> who(RecipientKind k) async => (await p.recipients()).firstWhere((r) => r.kind == k);
  Future<Decimal> ngnBalance() async => (await l.watchBalances().first).fiatOf(Currency.ngn).amount;

  test('fees: Jarina users free, bank ₦25, cross-border ₦300', () async {
    expect((await p.quoteSend(await who(RecipientKind.jarina), ngn('1000'))).valueOrNull!.fee, ngn('0'));
    expect((await p.quoteSend(await who(RecipientKind.bank), ngn('1000'))).valueOrNull!.fee, ngn('25'));
    final xb = (await p.quoteSend(await who(RecipientKind.crossBorder), ngn('10000'))).valueOrNull!;
    expect(xb.fee, ngn('300'));
    expect(xb.debit, ngn('10300'));
    expect(xb.receive.currency, xb.recipient.currency);
    expect(xb.receive.isPositive, isTrue);
  });

  test('bank send debits amount + fee and records a receipt', () async {
    final before = await ngnBalance();
    final q = (await p.quoteSend(await who(RecipientKind.bank), ngn('5000'))).valueOrNull!;
    final t = (await p.send(q, pinToken: 'p', note: 'Rent')).valueOrNull!;
    expect(t.kind, TxKind.bankTransfer);
    expect(t.amount, -ngn('5025'));
    expect(t.description, contains('Rent'));
    expect(await ngnBalance(), before - Decimal.parse('5025'));
  });

  test('cross-border requires 2FA and an unexpired quote', () async {
    final q = (await p.quoteSend(await who(RecipientKind.crossBorder), ngn('5000'))).valueOrNull!;
    expect(fail(await p.send(q, pinToken: 'p')), isA<StepUpRequiredFailure>());
    final stale = FakePayments(
      FakeLedger(
        latency: Duration.zero,
        tick: Duration.zero,
        clock: () => DateTime.now().add(const Duration(hours: 1)),
      ),
      latency: Duration.zero,
    );
    expect(fail(await stale.send(q, pinToken: 'p', twofaToken: 't')), isA<QuoteExpiredFailure>());
    final t = (await p.send(q, pinToken: 'p', twofaToken: 't')).valueOrNull!;
    expect(t.status, TxStatus.pending);
    expect(t.corridor, ('NG', q.recipient.countryIso));
  });

  test('cannot send more than the balance', () async {
    final bal = await ngnBalance();
    final q = await p.quoteSend(await who(RecipientKind.bank), Money(bal, Currency.ngn));
    expect(fail(q), isA<InsufficientFundsFailure>(), reason: 'fee pushes it over');
  });

  test('paying from crypto sells enough of the coin', () async {
    final before = (await l.watchBalances().first).qtyOf('USDT');
    final q = (await p.quoteSend(await who(RecipientKind.bank), ngn('10000'), from: 'USDT')).valueOrNull!;
    expect(q.debit.currency.code, 'USDT');
    await p.send(q, pinToken: 'p');
    expect((await l.watchBalances().first).qtyOf('USDT'), before - q.debit.amount);
  });

  test('P2P: cash, coins, whole shares; unknown users and self rejected', () async {
    expect(
      fail(await p.sendP2p(handle: '@nobody', asset: 'NGN', amount: Decimal.ten, pinToken: 'p')),
      isA<UserNotFoundFailure>(),
    );
    expect(
      fail(await p.sendP2p(handle: 'aminu', asset: 'NGN', amount: Decimal.ten, pinToken: 'p')),
      isA<ValidationFailure>(),
    );
    final before = await ngnBalance();
    final cash = (await p.sendP2p(
      handle: '@Zainab',
      asset: 'NGN',
      amount: Decimal.fromInt(2000),
      pinToken: 'p',
    )).valueOrNull!;
    expect(cash.amount, -ngn('2000'));
    expect(await ngnBalance(), before - Decimal.fromInt(2000));
    final stock = (await l.catalog()).firstWhere((a) => a.isStock).id;
    expect(
      fail(await p.sendP2p(handle: 'zainab', asset: stock, amount: Decimal.parse('0.5'), pinToken: 'p')),
      isA<ValidationFailure>(),
    );
    final usdt = await p.sendP2p(handle: 'musa_dj', asset: 'USDT', amount: Decimal.fromInt(5), pinToken: 'p');
    expect(usdt.valueOrNull!.category, TxCategory.crypto);
  });

  test('bills: limits, customer lookup, electricity token', () async {
    final e = await p.biller(BillKind.electricity);
    expect(e.needsCustomerLookup, isTrue);
    expect(e.providers, contains('KEDCO'));
    expect(fail(await p.verifyCustomer(BillKind.electricity, 'KEDCO', '123')), isA<ValidationFailure>());
    expect((await p.verifyCustomer(BillKind.electricity, 'KEDCO', '01234567890')).valueOrNull, contains('Prepaid'));
    expect(
      fail(
        await p.pay(
          kind: BillKind.electricity,
          provider: 'KEDCO',
          number: '01234567890',
          amount: ngn('10'),
          pinToken: 'p',
        ),
      ),
      isA<ValidationFailure>(),
    );
    final t = (await p.pay(
      kind: BillKind.electricity,
      provider: 'KEDCO',
      number: '01234567890',
      amount: ngn('5000'),
      pinToken: 'p',
    )).valueOrNull!;
    expect(t.description, matches(RegExp(r'^Token \d{4}(-\d{4}){4}$')));
    final data = await p.biller(BillKind.data);
    expect(data.plans, hasLength(4));
    final dt = (await p.pay(
      kind: BillKind.data,
      provider: 'MTN',
      number: '08012345678',
      amount: data.plans.first.price,
      plan: data.plans.first.name,
      pinToken: 'p',
    )).valueOrNull!;
    expect(dt.subtitle, '1.5 GB · 30 days');
  });
}

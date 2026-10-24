import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina_core/jarina_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLedger ledger;
  setUp(() => ledger = FakeLedger(latency: Duration.zero));
  tearDown(() => ledger.dispose());

  Money ngn(String v) => Money.parse(v, Currency.ngn);

  test('portfolio at opening prices matches the prototype dashboard', () async {
    final catalog = {for (final a in await ledger.catalog()) a.id: a};
    final balances = await ledger.watchBalances().first;
    final rates = await ledger.rates();
    // Quotes pinned at the open, as the prototype's static figures are.
    final quotes = {
      for (final a in catalog.values) a.id: Quote(assetId: a.id, price: a.openPrice, changePct: 0, intraday: const [1]),
    };
    final p = computePortfolio(balances, quotes, catalog, rates);

    expect(MoneyFormat.format(p.cash, decimals: 0), '₦678,591');
    expect(MoneyFormat.format(p.stocks, decimals: 0), '₦479,985');
    expect(MoneyFormat.format(p.crypto, decimals: 0), '₦1,040,100');
    expect(MoneyFormat.format(p.total, decimals: 0), '₦2,198,676');
    expect(p.holdings.first.asset.id, 'USDT', reason: 'sorted by value');
  });

  test('convert moves money, charges 0.5% and records a transaction', () async {
    final quote = (await ledger.quoteConvert(ngn('13500'), Currency.ghs)).valueOrNull!;
    expect(quote.receive, Money.parse('99.50', Currency.ghs)); // 100 GHS − 0.5%
    expect(quote.fee, Money.parse('0.50', Currency.ghs));

    final tx = await ledger.convert(quote, pinToken: 't');
    expect(tx.isOk, isTrue);
    final b = await ledger.watchBalances().first;
    expect(b.fiatOf(Currency.ngn), ngn('170700'));
    expect(b.fiatOf(Currency.ghs), Money.parse('1349.50', Currency.ghs));
    expect((await ledger.watch().first).first.id, tx.valueOrNull!.id);
  });

  test('cannot convert more than the balance', () async {
    final r = await ledger.quoteConvert(ngn('184201'), Currency.ghs);
    expect(r.when(ok: (_) => null, err: (f) => f), isA<InsufficientFundsFailure>());
  });

  test('paying a request debits the wallet and removes it', () async {
    expect((await ledger.watchRequests().first).length, 2);
    final r = await ledger.payRequest('q1', pinToken: 't');
    expect(r.isOk, isTrue);
    expect((await ledger.watchBalances().first).fiatOf(Currency.ngn), ngn('181200'));
    expect((await ledger.watchRequests().first).map((r) => r.id), ['q2']);
  });

  test('prices tick while someone is listening, and stop after', () async {
    final live = FakeLedger(latency: Duration.zero, tick: const Duration(milliseconds: 10));
    addTearDown(live.dispose);
    final snapshots = await live.watchQuotes().take(3).toList();
    expect(snapshots.first['BTC']!.price, isNot(snapshots.last['BTC']!.price));
  });

  test('history ends at the live price', () async {
    final quotes = await ledger.watchQuotes().first;
    final h = await ledger.history('BTC', ChartRange.month);
    expect(h.length, 30);
    expect(h.last, closeTo(quotes['BTC']!.price.toDouble(), 1));
  });
}

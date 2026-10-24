import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina_core/jarina_core.dart';

/// In-memory ledger, market feed and activity for the demo account, seeded
/// from the prototype's sample data. Writes (convert, pay, deposit) move money
/// between wallets and record transactions, so flows can be tested end to end.
class FakeLedger implements MarketRepository, WalletRepository, ActivityRepository, TradingRepository {
  FakeLedger({
    AssetBundle? bundle,
    this.latency = const Duration(milliseconds: 350),
    this.tick = const Duration(milliseconds: 1300),
    DateTime Function()? clock,
    int seed = 7,
  }) : _bundle = bundle ?? rootBundle,
       _now = clock ?? DateTime.now,
       _random = Random(seed);

  /// Fee charged on currency conversion (prototype: 0.5%).
  static final Decimal convertFee = Decimal.parse('0.005');

  /// Fee on every stock and crypto trade (prototype: 2.5%).
  static final Decimal tradeFee = Decimal.parse('0.025');

  final AssetBundle _bundle;
  final Duration latency;

  /// Price tick interval; `Duration.zero` freezes prices (deterministic tests).
  final Duration tick;
  final DateTime Function() _now;
  final Random _random;

  late final Future<void> _ready = _load();
  late List<AssetInfo> _catalog;
  late FxRates _rates;
  final _prices = <String, double>{};
  final _intraday = <String, List<double>>{};

  final _Latest<Balances> _balances = _Latest();
  final _Latest<List<Transaction>> _activity = _Latest();
  final _Latest<List<PaymentRequest>> _requests = _Latest();
  StreamController<Map<String, Quote>>? _quotes;
  Timer? _timer;

  Future<void> _wait() => latency == Duration.zero ? Future.value() : Future.delayed(latency);

  Future<void> _load() async {
    final assets = jsonDecode(await _bundle.loadString('assets/seed/assets.json')) as List;
    _catalog = assets.map((e) => AssetInfo.fromJson(e as Map<String, dynamic>)).toList();
    final fx = jsonDecode(await _bundle.loadString('assets/seed/fx.json')) as Map<String, dynamic>;
    _rates = FxRates({
      for (final e in fx.entries) Currency.fromCode(e.key): Decimal.parse((e.value as Map)['perNgn'] as String),
    });

    for (final a in _catalog) {
      final open = a.openPrice.toDouble();
      // Seeded so every launch shows the same morning; ends near today's move.
      final r = Random(a.id.hashCode);
      final points = <double>[open];
      for (var i = 1; i < 40; i++) {
        points.add(points.last * (1 + (r.nextDouble() - 0.5) * 0.012));
      }
      _intraday[a.id] = points;
      _prices[a.id] = points.last;
    }

    _balances.value = Balances(
      fiat: {
        Currency.ngn: Money.parse('184200', Currency.ngn),
        Currency.ghs: Money.parse('1250', Currency.ghs),
        Currency.xof: Money.parse('85000', Currency.xof),
        Currency.xaf: Money.parse('42000', Currency.xaf),
      },
      holdings: {
        for (final e in {
          'MTNN': '400',
          'DANGCEM': '25',
          'GTCO': '300',
          'ZENITHBANK': '500',
          'BTC': '0.0042',
          'USDT': '320',
          'ETH': '0.05',
        }.entries)
          e.key: Decimal.parse(e.value),
      },
    );
    _activity.value = _seedActivity();
    _requests.value = [
      PaymentRequest(
        id: 'q1',
        fromName: 'Zainab Yusuf',
        fromHandle: 'zainab',
        amount: Money.parse('3000', Currency.ngn),
        note: 'Suya on Friday',
      ),
      PaymentRequest(
        id: 'q2',
        fromName: 'Musa Danjuma',
        fromHandle: 'musa_dj',
        amount: Money.parse('1500', Currency.ngn),
        note: 'Data bundle',
      ),
    ];
  }

  String _txId() => List.generate(15, (i) => i == 0 ? 1 + _random.nextInt(9) : _random.nextInt(10)).join();

  List<Transaction> _seedActivity() {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int daysAgo, int h, int m) =>
        today.subtract(Duration(days: daysAgo)).add(Duration(hours: h, minutes: m));
    Money ngn(String v) => Money.parse(v, Currency.ngn);
    Transaction tx(
      TxCategory c,
      TxKind k,
      String title,
      String sub,
      Money amt,
      DateTime when, {
      String? party,
      (String, String)? corridor,
    }) => Transaction(
      id: _txId(),
      category: c,
      kind: k,
      title: title,
      subtitle: sub,
      amount: amt,
      createdAt: when,
      counterparty: party,
      corridor: corridor,
    );
    return [
      tx(TxCategory.stocks, TxKind.stockTrade, 'Bought GTCO', '300 shares', ngn('-15630'), at(0, 10, 24)),
      tx(
        TxCategory.transfers,
        TxKind.crossBorder,
        'Sent to Halima Issoufou',
        'Niger · XOF',
        ngn('-50000'),
        at(1, 18, 2),
        party: 'Halima Issoufou · Niger',
        corridor: ('NG', 'NE'),
      ),
      tx(
        TxCategory.transfers,
        TxKind.crossBorder,
        'Received from Kwame Mensah',
        'Accra · MoMo',
        Money.parse('450', Currency.ghs),
        at(3, 9, 15),
        party: 'Kwame Mensah · Ghana',
        corridor: ('GH', 'NG'),
      ),
      tx(
        TxCategory.transfers,
        TxKind.deposit,
        'Deposit · Mobile money',
        'Niamey',
        Money.parse('60000', Currency.xof),
        at(5, 14, 40),
      ),
      tx(TxCategory.bills, TxKind.bill, 'Electricity · KEDCO', 'Prepaid token', ngn('-10000'), at(1, 7, 58)),
      tx(
        TxCategory.transfers,
        TxKind.deposit,
        'Deposit · Bank transfer',
        'From your account',
        ngn('150000'),
        at(2, 12, 11),
      ),
      tx(
        TxCategory.crypto,
        TxKind.cryptoTrade,
        'Received USDT',
        'TRC-20',
        Money.parse('120', const Currency.crypto('USDT', decimals: 2)),
        at(4, 16, 37),
      ),
      tx(TxCategory.bills, TxKind.bill, 'Airtime · MTN', '0801 234 5678', ngn('-1000'), at(6, 8, 20)),
      tx(TxCategory.stocks, TxKind.stockTrade, 'Bought DANGCEM', '25 shares', ngn('-12000'), at(8, 10, 2)),
      tx(TxCategory.crypto, TxKind.cryptoTrade, 'Bought BTC', '0.0042 BTC', ngn('-436800'), at(10, 11, 45)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _record(Transaction t) => _activity.value = [t, ..._activity.value];

  // ── Market ──────────────────────────────────────────────────────────────

  @override
  Future<List<AssetInfo>> catalog() async {
    await _ready;
    return _catalog;
  }

  Map<String, Quote> _snapshot() => {
    for (final a in _catalog)
      a.id: Quote(
        assetId: a.id,
        price: Decimal.parse(_prices[a.id]!.toStringAsFixed(2)),
        changePct: (_prices[a.id]! / a.openPrice.toDouble() - 1) * 100,
        intraday: List.unmodifiable(_intraday[a.id]!),
      ),
  };

  void _step() {
    for (final a in _catalog) {
      final p = _prices[a.id]!;
      final open = a.openPrice.toDouble();
      // Small random move with a gentle pull back towards the open.
      final next = p * (1 + (_random.nextDouble() - 0.5) * 0.004) + (open - p) * 0.01;
      _prices[a.id] = next;
      _intraday[a.id] = [..._intraday[a.id]!.skip(1), next];
    }
    _quotes?.add(_snapshot());
  }

  @override
  Stream<Map<String, Quote>> watchQuotes() async* {
    await _ready;
    _quotes ??= StreamController<Map<String, Quote>>.broadcast(
      onListen: () {
        if (tick > Duration.zero) _timer = Timer.periodic(tick, (_) => _step());
      },
      onCancel: () {
        _timer?.cancel();
        _timer = null;
      },
    );
    yield _snapshot();
    yield* _quotes!.stream;
  }

  @override
  Future<List<double>> history(String assetId, ChartRange range) async {
    await _ready;
    final n = switch (range) {
      ChartRange.day => 40,
      ChartRange.week => 7 * 8,
      ChartRange.month => 30,
      ChartRange.year => 52,
      ChartRange.all => 60,
    };
    if (range == ChartRange.day) return _intraday[assetId]!;
    // Walk backwards from today's price so the line ends where the quote is.
    final r = Random(assetId.hashCode ^ range.index);
    final out = <double>[_prices[assetId]!];
    for (var i = 1; i < n; i++) {
      final step = switch (range) {
        ChartRange.year => 0.05,
        ChartRange.all => 0.08,
        _ => 0.02,
      };
      out.add(out.last / (1 + (r.nextDouble() - 0.48) * step));
    }
    return out.reversed.toList();
  }

  // ── Wallets ─────────────────────────────────────────────────────────────

  @override
  Stream<Balances> watchBalances() async* {
    await _ready;
    yield* _balances.stream;
  }

  @override
  Future<FxRates> rates() async {
    await _ready;
    return _rates;
  }

  @override
  Future<Result<FundingAccount>> fundingAccount(Currency currency) async {
    await _wait();
    return const Ok(
      FundingAccount(accountName: 'Jarina / Aminu Bello', accountNumber: '9012345678', bankName: 'Partner bank'),
    );
  }

  @override
  Future<Result<ConvertQuote>> quoteConvert(Money from, Currency to) async {
    await _ready;
    await _wait();
    if (!from.isPositive || from.currency == to) return const Err(ValidationFailure('Invalid amount'));
    if (from > _balances.value.fiatOf(from.currency)) return const Err(InsufficientFundsFailure());
    final gross = _rates.convert(from, to);
    final fee = gross.times(convertFee).rounded();
    return Ok(
      ConvertQuote(
        id: _txId(),
        from: from,
        receive: gross - fee,
        fee: fee,
        rate: _rates.rate(from.currency, to),
        expiresAt: _now().add(const Duration(minutes: 10)),
      ),
    );
  }

  @override
  Future<Result<Transaction>> convert(ConvertQuote quote, {required String pinToken}) async {
    await _wait();
    if (_now().isAfter(quote.expiresAt)) return const Err(QuoteExpiredFailure());
    final b = _balances.value;
    if (quote.from > b.fiatOf(quote.from.currency)) return const Err(InsufficientFundsFailure());
    final to = quote.receive.currency;
    _balances.value = Balances(
      fiat: {
        ...b.fiat,
        quote.from.currency: b.fiatOf(quote.from.currency) - quote.from,
        to: b.fiatOf(to) + quote.receive,
      },
      holdings: b.holdings,
    );
    final t = Transaction(
      id: _txId(),
      category: TxCategory.transfers,
      kind: TxKind.conversion,
      title: 'Converted ${quote.from.currency.code} to ${to.code}',
      subtitle: '${MoneyFormat.format(quote.from)} → ${MoneyFormat.format(quote.receive)}',
      amount: -quote.from,
      createdAt: _now(),
      description: 'Fee ${MoneyFormat.format(quote.fee)}',
    );
    _record(t);
    return Ok(t);
  }

  @override
  Stream<List<PaymentRequest>> watchRequests() async* {
    await _ready;
    yield* _requests.stream;
  }

  @override
  Future<Result<void>> declineRequest(String id) async {
    await _wait();
    _requests.value = _requests.value.where((r) => r.id != id).toList();
    return const Ok(null);
  }

  @override
  Future<Result<Transaction>> payRequest(String id, {required String pinToken}) async {
    await _wait();
    final req = _requests.value.where((r) => r.id == id).firstOrNull;
    if (req == null) return const Err(ValidationFailure('Request not found'));
    final b = _balances.value;
    final c = req.amount.currency;
    if (req.amount > b.fiatOf(c)) return const Err(InsufficientFundsFailure());
    _balances.value = Balances(fiat: {...b.fiat, c: b.fiatOf(c) - req.amount}, holdings: b.holdings);
    _requests.value = _requests.value.where((r) => r.id != id).toList();
    final t = Transaction(
      id: _txId(),
      category: TxCategory.transfers,
      kind: TxKind.p2p,
      title: 'Paid ${req.fromName}',
      subtitle: '@${req.fromHandle}${req.note == null ? '' : ' · ${req.note}'}',
      amount: -req.amount,
      createdAt: _now(),
      counterparty: '${req.fromName} · @${req.fromHandle}',
    );
    _record(t);
    return Ok(t);
  }

  @override
  Future<Result<Transaction>> simulateDeposit(Money amount) async {
    await _wait();
    final b = _balances.value;
    _balances.value = Balances(
      fiat: {...b.fiat, amount.currency: b.fiatOf(amount.currency) + amount},
      holdings: b.holdings,
    );
    final t = Transaction(
      id: _txId(),
      category: TxCategory.transfers,
      kind: TxKind.deposit,
      title: 'Deposit · Bank transfer',
      subtitle: 'From your account',
      amount: amount,
      createdAt: _now(),
    );
    _record(t);
    return Ok(t);
  }

  // ── Trading ─────────────────────────────────────────────────────────────

  @override
  Decimal get feeRate => tradeFee;

  AssetInfo? _asset(String id) => _catalog.where((a) => a.id == id).firstOrNull;

  Decimal _livePrice(String id) => Decimal.parse(_prices[id]!.toStringAsFixed(2));

  bool _isOpen(AssetInfo a) => !a.isStock || NgxSchedule.isOpen(_now());

  TradeQuote _quote(AssetInfo a, TradeSide side, Decimal qty, Decimal price) {
    final gross = Money(qty * price, Currency.ngn).rounded();
    return TradeQuote(
      id: _txId(),
      asset: a,
      side: side,
      price: price,
      quantity: qty,
      gross: gross,
      fee: gross.times(tradeFee).rounded(),
      marketOpen: _isOpen(a),
      expiresAt: _now().add(const Duration(seconds: 30)),
    );
  }

  @override
  Future<Result<TradeQuote>> quoteBuy(String assetId, Money spend) async {
    await _ready;
    await _wait();
    final a = _asset(assetId);
    if (a == null || !spend.isPositive) return const Err(ValidationFailure('Invalid order'));
    final price = _livePrice(assetId);
    // NGX trades whole shares; crypto to 8 decimals. Never round up.
    final raw = (spend.amount / price).toDecimal(scaleOnInfinitePrecision: 12);
    final qty = a.isStock ? raw.floor() : raw.floor(scale: 8);
    if (qty <= Decimal.zero) return const Err(BelowMinimumFailure());
    final q = _quote(a, TradeSide.buy, qty, price);
    if (q.total > _balances.value.fiatOf(Currency.ngn)) return const Err(InsufficientFundsFailure());
    return Ok(q);
  }

  @override
  Future<Result<TradeQuote>> quoteSell(String assetId, Decimal quantity) async {
    await _ready;
    await _wait();
    final a = _asset(assetId);
    if (a == null || quantity <= Decimal.zero) return const Err(ValidationFailure('Invalid order'));
    if (a.isStock && quantity != quantity.floor()) return const Err(ValidationFailure('Whole shares only'));
    if (quantity > _balances.value.qtyOf(assetId)) return const Err(InsufficientFundsFailure());
    return Ok(_quote(a, TradeSide.sell, quantity, _livePrice(assetId)));
  }

  @override
  Future<Result<Transaction>> placeOrder(TradeQuote q, {required String pinToken}) async {
    await _wait();
    if (_now().isAfter(q.expiresAt)) return const Err(QuoteExpiredFailure());
    final b = _balances.value;
    final cash = b.fiatOf(Currency.ngn);
    final held = b.qtyOf(q.asset.id);
    if (q.isBuy && q.total > cash) return const Err(InsufficientFundsFailure());
    if (!q.isBuy && q.quantity > held) return const Err(InsufficientFundsFailure());

    // Out of hours, a buy reserves the cash and a sell reserves the shares;
    // the other leg settles when the order fills at the open.
    final open = q.marketOpen;
    _balances.value = Balances(
      fiat: {
        ...b.fiat,
        Currency.ngn: q.isBuy ? cash - q.total : (open ? cash + q.total : cash),
      },
      holdings: {
        ...b.holdings,
        q.asset.id: q.isBuy ? (open ? held + q.quantity : held) : held - q.quantity,
      },
    );
    final qtyText = q.asset.isStock ? '${q.quantity} shares' : MoneyFormat.format(Money(q.quantity, q.asset.unit));
    final t = Transaction(
      id: _txId(),
      category: q.asset.isStock ? TxCategory.stocks : TxCategory.crypto,
      kind: q.asset.isStock ? TxKind.stockTrade : TxKind.cryptoTrade,
      title: '${q.isBuy ? 'Bought' : 'Sold'} ${q.asset.id}',
      subtitle: qtyText,
      amount: q.isBuy ? -q.total : q.total,
      createdAt: _now(),
      status: open ? TxStatus.successful : TxStatus.pending,
      description: '$qtyText @ ${MoneyFormat.format(Money(q.price, Currency.ngn))} · fee ${MoneyFormat.format(q.fee)}',
    );
    _record(t);
    return Ok(t);
  }

  // ── Activity ────────────────────────────────────────────────────────────

  @override
  Stream<List<Transaction>> watch() async* {
    await _ready;
    yield* _activity.stream;
  }

  void dispose() {
    _timer?.cancel();
    unawaited(_quotes?.close());
    _balances.close();
    _activity.close();
    _requests.close();
  }
}

/// Holds the latest value and replays it to each new listener.
class _Latest<T> {
  final _c = StreamController<T>.broadcast();
  late T _value;

  T get value => _value;
  set value(T v) {
    _value = v;
    _c.add(v);
  }

  /// Subscribes to updates synchronously, then emits the current value, so
  /// no update can slip in between (an `async*` generator leaves that gap).
  Stream<T> get stream => Stream.multi((out) {
    final sub = _c.stream.listen(out.add, onError: out.addError, onDone: out.close);
    out
      ..add(_value)
      ..onCancel = sub.cancel;
  });

  void close() => unawaited(_c.close());
}

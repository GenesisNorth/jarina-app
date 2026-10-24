import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina_core/jarina_core.dart';

/// In-memory ledger, market feed and activity for the demo account, seeded
/// from the prototype's sample data. Writes (convert, pay, deposit) move money
/// between wallets and record transactions, so flows can be tested end to end.
class FakeLedger
    implements MarketRepository, WalletRepository, ActivityRepository, TradingRepository, CryptoRepository {
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
  final _Latest<List<CryptoTransfer>> _transfers = _Latest();
  final _Latest<List<LimitOrder>> _orders = _Latest();
  final _Latest<String?> _autoSwap = _Latest();
  late Map<String, List<CryptoNetwork>> _networks;
  final _addressSalt = <String, int>{};
  StreamController<Map<String, Quote>>? _quotes;
  Timer? _timer;

  /// Every call waits for the seed data, then simulates network latency.
  Future<void> _wait() async {
    await _ready;
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  /// Stablecoins hold their peg; everything else moves freely.
  static bool _stable(String id) => id == 'USDT' || id == 'USDC';

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
      final step = _stable(a.id) ? 0.0004 : 0.012;
      for (var i = 1; i < 40; i++) {
        points.add(
          points.last * (1 + (r.nextDouble() - 0.5) * step) + (open - points.last) * (_stable(a.id) ? 0.5 : 0),
        );
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
    final nets = jsonDecode(await _bundle.loadString('assets/seed/networks.json')) as Map<String, dynamic>;
    _networks = {
      for (final e in nets.entries)
        e.key: (e.value as List).map((n) => CryptoNetwork.fromJson(n as Map<String, dynamic>)).toList(),
    };
    _activity.value = _seedActivity();
    _seedCrypto();
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
      final next = _stable(a.id)
          ? open * (1 + (_random.nextDouble() - 0.5) * 0.0004)
          : p * (1 + (_random.nextDouble() - 0.5) * 0.004) + (open - p) * 0.01;
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

  // ── Crypto ──────────────────────────────────────────────────────────────

  static const _users = {'zainab', 'musa_dj', 'fatimab', 'aminu', 'halima', 'kwame'};
  static const _bankNames = [
    'Access Bank', 'Ecobank', 'Fidelity Bank', 'First Bank', 'FCMB', 'GTBank', 'Kuda', 'Moniepoint', //
    'OPay', 'PalmPay', 'Stanbic IBTC', 'Sterling Bank', 'UBA', 'Union Bank', 'Wema Bank', 'Zenith Bank',
  ];
  static final Decimal _loanInterestPerMonth = Decimal.parse('0.035');
  static final Money _minCashOut = Money.parse('15000', Currency.ngn);

  void _seedCrypto() {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int daysAgo, int h, int m) =>
        today.subtract(Duration(days: daysAgo)).add(Duration(hours: h, minutes: m));
    Decimal d(String v) => Decimal.parse(v);
    _transfers.value = [
      CryptoTransfer(
        id: _txId(),
        coin: 'BTC',
        direction: TransferDirection.deposit,
        amount: d('0.0012'),
        status: TransferStatus.confirming,
        createdAt: at(0, 9, 30),
        network: 'BTC',
        confirmations: 1,
        requiredConfirmations: 3,
      ),
      CryptoTransfer(
        id: _txId(),
        coin: 'USDT',
        direction: TransferDirection.withdrawal,
        amount: d('50'),
        status: TransferStatus.processing,
        createdAt: at(0, 9, 2),
        network: 'TRC-20',
        address: 'TJ4mP8kR2wQeX9bNcV7dLfHs3aZt6yUoPq',
      ),
      CryptoTransfer(
        id: _txId(),
        coin: 'USDT',
        direction: TransferDirection.deposit,
        amount: d('120'),
        status: TransferStatus.successful,
        createdAt: at(4, 16, 37),
        network: 'TRC-20',
        address: 'TQ7nX3kLm2Pq8RsTuVwXyZaBcDeFdG0aZe',
      ),
      CryptoTransfer(
        id: _txId(),
        coin: 'ETH',
        direction: TransferDirection.deposit,
        amount: d('0.05'),
        status: TransferStatus.onHold,
        createdAt: at(7, 11, 5),
        network: 'ERC-20',
        note: 'Held for a routine compliance review. Usually cleared within 24 hours.',
      ),
      CryptoTransfer(
        id: _txId(),
        coin: 'BTC',
        direction: TransferDirection.withdrawal,
        amount: d('0.0005'),
        status: TransferStatus.successful,
        createdAt: at(9, 14, 20),
        network: 'BTC',
        address: 'bc1qx9ar0srrr7xfkvy5l643lydnw9re7fl3m2',
      ),
      CryptoTransfer(
        id: _txId(),
        coin: 'USDT',
        direction: TransferDirection.deposit,
        amount: d('40'),
        status: TransferStatus.rejected,
        createdAt: at(12, 10, 0),
        network: 'BEP-20',
        note: 'Failed the AML screening. Contact support to arrange a return.',
      ),
    ];
    _orders.value = [
      LimitOrder(
        id: _txId(),
        coin: 'BTC',
        side: OrderSide.buy,
        type: OrderType.limit,
        price: d('95000000'),
        amount: d('0.001'),
        filled: 0,
        status: OrderStatus.open,
        createdAt: at(0, 8, 12),
      ),
      LimitOrder(
        id: _txId(),
        coin: 'ETH',
        side: OrderSide.sell,
        type: OrderType.limit,
        price: d('2720000'),
        amount: d('0.04'),
        filled: 0.4,
        status: OrderStatus.partiallyFilled,
        createdAt: at(1, 21, 40),
      ),
      LimitOrder(
        id: _txId(),
        coin: 'USDT',
        side: OrderSide.buy,
        type: OrderType.market,
        price: d('1549'),
        amount: d('120'),
        filled: 1,
        status: OrderStatus.filled,
        createdAt: at(4, 14, 5),
      ),
      LimitOrder(
        id: _txId(),
        coin: 'SOL',
        side: OrderSide.buy,
        type: OrderType.limit,
        price: d('199000'),
        amount: d('0.5'),
        filled: 0,
        status: OrderStatus.cancelled,
        createdAt: at(6, 10, 30),
      ),
    ];
    _autoSwap.value = null;
    // Recent swaps from the prototype.
    _activity.value = [
      ..._activity.value,
      Transaction(
        id: _txId(),
        category: TxCategory.crypto,
        kind: TxKind.cryptoTrade,
        title: 'Swapped USDT → BTC',
        subtitle: '100 USDT → 0.00158 BTC',
        amount: Money.parse('0.00158', const Currency.crypto('BTC')),
        createdAt: at(1, 16, 20),
      ),
      Transaction(
        id: _txId(),
        category: TxCategory.crypto,
        kind: TxKind.cryptoTrade,
        title: 'Swapped NGN → USDT',
        subtitle: '₦50,000 → 32.10 USDT',
        amount: Money.parse('32.10', const Currency.crypto('USDT', decimals: 2)),
        createdAt: at(11, 11, 5),
      ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Currency _unit(String code) =>
      code == 'NGN' ? Currency.ngn : Currency.crypto(code, decimals: code == 'USDT' || code == 'USDC' ? 2 : 8);

  Decimal _priceOf(String code) => code == 'NGN' ? Decimal.one : _livePrice(code);

  Money _available(String code) {
    final b = _balances.value;
    return code == 'NGN' ? b.fiatOf(Currency.ngn) : Money(b.qtyOf(code), _unit(code));
  }

  void _adjust(String code, Decimal delta) {
    final b = _balances.value;
    if (code == 'NGN') {
      _balances.value = Balances(
        fiat: {...b.fiat, Currency.ngn: b.fiatOf(Currency.ngn) + Money(delta, Currency.ngn)},
        holdings: b.holdings,
      );
    } else {
      _balances.value = Balances(fiat: b.fiat, holdings: {...b.holdings, code: b.qtyOf(code) + delta});
    }
  }

  @override
  Future<List<CryptoNetwork>> networks(String coin) async {
    await _ready;
    return _networks[coin] ??
        [CryptoNetwork(id: coin, name: coin, withdrawFee: Decimal.parse('0.01'), memoRequired: false)];
  }

  @override
  Future<Result<DepositAddress>> depositAddress(String coin, CryptoNetwork network, {bool fresh = false}) async {
    await _ready;
    await _wait();
    final key = '$coin|${network.id}';
    if (fresh) _addressSalt[key] = (_addressSalt[key] ?? 0) + 1;
    final address = _fakeAddress(coin, network.id, _addressSalt[key] ?? 0);
    final memo = network.memoRequired ? '${100000000 + address.codeUnitAt(3) * 7919 % 899999999}' : null;
    return Ok(DepositAddress(coin: coin, network: network, address: address, memo: memo));
  }

  /// Deterministic, format-valid demo addresses (ported from the prototype).
  static String _fakeAddress(String coin, String net, int n) {
    var x = 0;
    for (final c in '$coin$net$n'.codeUnits) {
      x = (x * 31 + c) & 0xFFFFFFFF;
    }
    if (x == 0) x = 1;
    String rnd(String al, int len) {
      final out = StringBuffer();
      for (var i = 0; i < len; i++) {
        x ^= (x << 13) & 0xFFFFFFFF;
        x ^= x >> 17;
        x ^= (x << 5) & 0xFFFFFFFF;
        out.write(al[x % al.length]);
      }
      return out.toString();
    }

    const b58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    const hex = '0123456789abcdef';
    const b32 = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
    return switch (net) {
      'BTC' => 'bc1q${rnd(b32, 38)}',
      'TRC-20' => 'T${rnd(b58, 33)}',
      'ERC-20' || 'BEP-20' || 'Arbitrum' || 'Polygon' || 'Base' || 'C-Chain' || 'HyperEVM' => '0x${rnd(hex, 40)}',
      'XRP' => 'r${rnd(b58, 33)}',
      'XLM' => 'G${rnd('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567', 55)}',
      'TON' => 'UQ${rnd('$b58-_', 46)}',
      'DOGE' => 'D${rnd(b58, 33)}',
      'LTC' => 'ltc1q${rnd(b32, 38)}',
      'ADA' => 'addr1q${rnd(b32, 52)}',
      'SUI' => '0x${rnd(hex, 64)}',
      'DOT' => '1${rnd(b58, 46)}',
      _ => rnd(b58, 44),
    };
  }

  @override
  Future<Result<SwapQuote>> quoteSwap(Money pay, String to) async {
    await _ready;
    await _wait();
    final from = pay.currency.code;
    if (!pay.isPositive || from == to) return const Err(ValidationFailure('Invalid swap'));
    if (pay > _available(from)) return const Err(InsufficientFundsFailure());
    final payNgn = pay.amount * _priceOf(from);
    final fee = Money(payNgn * tradeFee, Currency.ngn).rounded();
    final net = payNgn - fee.amount;
    final unit = _unit(to);
    final qty = (net / _priceOf(to)).toDecimal(scaleOnInfinitePrecision: 12).floor(scale: unit.decimals);
    if (qty <= Decimal.zero) return const Err(BelowMinimumFailure());
    return Ok(
      SwapQuote(
        id: _txId(),
        pay: pay,
        receive: Money(qty, unit),
        fee: fee,
        rate: (qty / pay.amount).toDecimal(scaleOnInfinitePrecision: 10),
        expiresAt: _now().add(const Duration(seconds: 15)),
      ),
    );
  }

  @override
  Future<Result<Transaction>> swap(SwapQuote q, {required String pinToken}) async {
    await _wait();
    if (_now().isAfter(q.expiresAt)) return const Err(QuoteExpiredFailure());
    if (q.pay > _available(q.pay.currency.code)) return const Err(InsufficientFundsFailure());
    _adjust(q.pay.currency.code, -q.pay.amount);
    _adjust(q.receive.currency.code, q.receive.amount);
    final t = Transaction(
      id: _txId(),
      category: TxCategory.crypto,
      kind: TxKind.cryptoTrade,
      title: 'Swapped ${q.pay.currency.code} → ${q.receive.currency.code}',
      subtitle: '${MoneyFormat.format(q.pay)} → ${MoneyFormat.format(q.receive)}',
      amount: q.receive,
      createdAt: _now(),
      description: 'Fee ${MoneyFormat.format(q.fee)}',
    );
    _record(t);
    return Ok(t);
  }

  void _recordTransfer(CryptoTransfer t) => _transfers.value = [t, ..._transfers.value];

  @override
  Future<Result<CryptoTransfer>> withdraw({
    required String coin,
    required CryptoNetwork network,
    required String address,
    required Decimal amount,
    required String pinToken,
    required String twofaToken,
    String? memo,
  }) async {
    await _wait();
    if (!AddressRules.isValid(network.id, address)) return const Err(InvalidAddressFailure());
    if (amount <= network.withdrawFee) return const Err(BelowMinimumFailure());
    if (amount > _available(coin).amount) return const Err(InsufficientFundsFailure());
    _adjust(coin, -amount);
    final t = CryptoTransfer(
      id: _txId(),
      coin: coin,
      direction: TransferDirection.withdrawal,
      amount: amount,
      status: TransferStatus.processing,
      createdAt: _now(),
      network: network.id,
      address: address,
    );
    _recordTransfer(t);
    _record(
      Transaction(
        id: t.id,
        category: TxCategory.crypto,
        kind: TxKind.withdrawal,
        title: 'Withdrawal · $coin',
        subtitle: '${network.id} · ${AddressRules.shorten(address)}',
        amount: -Money(amount, _unit(coin)),
        createdAt: _now(),
        status: TxStatus.pending,
        description: 'Network fee ${network.withdrawFee} $coin · recipient gets ${amount - network.withdrawFee} $coin',
      ),
    );
    return Ok(t);
  }

  @override
  Future<Result<CryptoTransfer>> sendToUser({
    required String coin,
    required String username,
    required Decimal amount,
    required String pinToken,
    required String twofaToken,
  }) async {
    await _wait();
    final handle = UsernameRules.normalize(username);
    if (!_users.contains(handle)) return const Err(UserNotFoundFailure());
    if (amount <= Decimal.zero) return const Err(ValidationFailure('Invalid amount'));
    if (amount > _available(coin).amount) return const Err(InsufficientFundsFailure());
    _adjust(coin, -amount);
    final t = CryptoTransfer(
      id: _txId(),
      coin: coin,
      direction: TransferDirection.withdrawal,
      amount: amount,
      status: TransferStatus.successful,
      createdAt: _now(),
      toUser: handle,
    );
    _recordTransfer(t);
    _record(
      Transaction(
        id: t.id,
        category: TxCategory.crypto,
        kind: TxKind.p2p,
        title: 'Sent $coin to @$handle',
        subtitle: 'Jarina user · free',
        amount: -Money(amount, _unit(coin)),
        createdAt: _now(),
        counterparty: '@$handle',
      ),
    );
    return Ok(t);
  }

  @override
  Stream<List<CryptoTransfer>> watchTransfers() async* {
    await _ready;
    yield* _transfers.stream;
  }

  @override
  Future<Result<void>> cancelWithdrawal(String id) async {
    await _wait();
    final t = _transfers.value.where((x) => x.id == id).firstOrNull;
    if (t == null || !t.cancellable) return const Err(ValidationFailure('Not cancellable'));
    _adjust(t.coin, t.amount);
    _transfers.value = _transfers.value
        .map((x) => x.id == id ? x.copyWith(status: TransferStatus.cancelled) : x)
        .toList();
    _activity.value = _activity.value
        .map(
          (x) => x.id == id
              ? Transaction(
                  id: x.id,
                  category: x.category,
                  kind: x.kind,
                  title: x.title,
                  subtitle: x.subtitle,
                  amount: x.amount,
                  createdAt: x.createdAt,
                  status: TxStatus.failed,
                  description: 'Cancelled before broadcast · funds returned',
                )
              : x,
        )
        .toList();
    return const Ok(null);
  }

  @override
  Stream<List<LimitOrder>> watchOrders() async* {
    await _ready;
    yield* _orders.stream;
  }

  @override
  Future<Result<LimitOrder>> placeLimitOrder({
    required String coin,
    required OrderSide side,
    required Decimal price,
    required Decimal amount,
    required String pinToken,
  }) async {
    await _wait();
    if (price <= Decimal.zero || amount <= Decimal.zero) return const Err(ValidationFailure('Invalid order'));
    final value = Money(price * amount, Currency.ngn).rounded();
    final fee = value.times(tradeFee).rounded();
    final buy = side == OrderSide.buy;
    // Funds move to "in orders" when the order is placed.
    if (buy && value + fee > _available('NGN')) return const Err(InsufficientFundsFailure());
    if (!buy && amount > _available(coin).amount) return const Err(InsufficientFundsFailure());
    final market = _livePrice(coin);
    final marketable = buy ? price >= market : price <= market;
    if (buy) {
      _adjust('NGN', -(value + fee).amount);
      if (marketable) _adjust(coin, amount);
    } else {
      _adjust(coin, -amount);
      if (marketable) _adjust('NGN', (value - fee).amount);
    }
    final o = LimitOrder(
      id: _txId(),
      coin: coin,
      side: side,
      type: OrderType.limit,
      price: price,
      amount: amount,
      filled: marketable ? 1 : 0,
      status: marketable ? OrderStatus.filled : OrderStatus.open,
      createdAt: _now(),
    );
    _orders.value = [o, ..._orders.value];
    if (marketable) {
      _record(
        Transaction(
          id: o.id,
          category: TxCategory.crypto,
          kind: TxKind.cryptoTrade,
          title: '${buy ? 'Bought' : 'Sold'} $coin',
          subtitle:
              '${MoneyFormat.format(Money(amount, _unit(coin)))} @ ${MoneyFormat.format(Money(price, Currency.ngn))}',
          amount: buy ? -(value + fee) : value - fee,
          createdAt: _now(),
          description: 'Limit order · fee ${MoneyFormat.format(fee)}',
        ),
      );
    }
    return Ok(o);
  }

  @override
  Future<Result<void>> cancelOrder(String id) async {
    await _wait();
    final o = _orders.value.where((x) => x.id == id).firstOrNull;
    if (o == null || (o.status != OrderStatus.open && o.status != OrderStatus.partiallyFilled)) {
      return const Err(ValidationFailure('Not cancellable'));
    }
    final remaining = o.amount * Decimal.parse((1 - o.filled).toStringAsFixed(4));
    if (o.side == OrderSide.buy) {
      final value = Money(o.price * remaining, Currency.ngn).rounded();
      _adjust('NGN', (value + value.times(tradeFee).rounded()).amount);
    } else {
      _adjust(o.coin, remaining);
    }
    _orders.value = _orders.value.map((x) => x.id == id ? x.copyWith(status: OrderStatus.cancelled) : x).toList();
    return const Ok(null);
  }

  @override
  List<String> banks() => _bankNames;

  @override
  Future<Result<BankAccount>> resolveAccount(String bank, String number) async {
    await _wait();
    if (!RegExp(r'^\d{10}$').hasMatch(number)) return const Err(ValidationFailure('NUBAN is 10 digits'));
    // Name enquiry returns the account holder; only accounts in the user's name are allowed.
    return Ok(BankAccount(bank: bank, number: number, name: 'AMINU BELLO'));
  }

  @override
  Future<Result<Transaction>> cashOut({
    required Money amount,
    required BankAccount account,
    required String pinToken,
    required String twofaToken,
  }) async {
    await _wait();
    final coin = amount.currency.code;
    if (amount > _available(coin)) return const Err(InsufficientFundsFailure());
    final gross = Money(amount.amount * _priceOf(coin), Currency.ngn).rounded();
    if (gross < _minCashOut) return const Err(BelowMinimumFailure());
    final fee = gross.times(tradeFee).rounded();
    _adjust(coin, -amount.amount);
    final t = Transaction(
      id: _txId(),
      category: TxCategory.crypto,
      kind: TxKind.withdrawal,
      title: 'Cash out to ${account.bank}',
      subtitle: MoneyFormat.format(gross - fee),
      amount: -amount,
      createdAt: _now(),
      counterparty: '${account.name} · ${account.bank} ••${account.number.substring(6)}',
      description: '${MoneyFormat.format(amount)} sold · fee ${MoneyFormat.format(fee)}',
    );
    _record(t);
    return Ok(t);
  }

  @override
  Future<Result<LoanQuote>> quoteLoan(Money collateral, {required double ltv, required int days}) async {
    await _ready;
    await _wait();
    final coin = collateral.currency.code;
    if (!collateral.isPositive) return const Err(ValidationFailure('Invalid amount'));
    if (collateral > _available(coin)) return const Err(InsufficientFundsFailure());
    final price = _priceOf(coin);
    final value = collateral.amount * price;
    final ltvD = Decimal.parse(ltv.toString());
    final borrow = Money(value * ltvD, Currency.ngn).floored();
    final interest = Money(
      (borrow.amount * _loanInterestPerMonth * Decimal.fromInt(days) / Decimal.fromInt(30)).toDecimal(
        scaleOnInfinitePrecision: 4,
      ),
      Currency.ngn,
    ).rounded();
    // Collateral is sold if the loan reaches 85% of its value.
    final liquidation = Money(
      (price * ltvD / Decimal.parse('0.85')).toDecimal(scaleOnInfinitePrecision: 4),
      Currency.ngn,
    ).rounded();
    return Ok(
      LoanQuote(
        collateral: collateral,
        ltv: ltv,
        days: days,
        borrow: borrow,
        interest: interest,
        liquidationPrice: liquidation,
      ),
    );
  }

  @override
  Future<Result<Transaction>> takeLoan(LoanQuote q, {required String pinToken}) async {
    await _wait();
    final coin = q.collateral.currency.code;
    if (q.collateral > _available(coin)) return const Err(InsufficientFundsFailure());
    _adjust(coin, -q.collateral.amount);
    _adjust('NGN', q.borrow.amount);
    final t = Transaction(
      id: _txId(),
      category: TxCategory.crypto,
      kind: TxKind.loan,
      title: 'Loan against $coin',
      subtitle: '${q.days} days · ${MoneyFormat.format(q.collateral)} held',
      amount: q.borrow,
      createdAt: _now(),
      description:
          'Repay ${MoneyFormat.format(q.totalToRepay)} · liquidation at ${MoneyFormat.format(q.liquidationPrice)}',
    );
    _record(t);
    return Ok(t);
  }

  @override
  Stream<String?> watchAutoSwapTarget() async* {
    await _ready;
    yield* _autoSwap.stream;
  }

  @override
  Future<void> setAutoSwap(String? target) async {
    await _wait();
    _autoSwap.value = target;
  }

  // ── Activity ────────────────────────────────────────────────────────────

  @override
  Stream<List<Transaction>> watch() async* {
    await _ready;
    yield* _activity.stream;
  }

  void dispose() {
    _timer?.cancel();
    _transfers.close();
    _orders.close();
    _autoSwap.close();
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

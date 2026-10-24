import 'package:flutter/foundation.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'portfolio.g.dart';

@Riverpod(keepAlive: true)
Future<Map<String, AssetInfo>> catalog(Ref ref) async {
  final list = await ref.watch(marketRepositoryProvider).catalog();
  return {for (final a in list) a.id: a};
}

/// Live quotes. Not kept alive: the feed stops when no screen shows prices.
@riverpod
Stream<Map<String, Quote>> quotes(Ref ref) => ref.watch(marketRepositoryProvider).watchQuotes();

@Riverpod(keepAlive: true)
Stream<Balances> balances(Ref ref) => ref.watch(walletRepositoryProvider).watchBalances();

@Riverpod(keepAlive: true)
Future<FxRates> fxRates(Ref ref) => ref.watch(walletRepositoryProvider).rates();

@Riverpod(keepAlive: true)
Stream<List<Transaction>> activity(Ref ref) => ref.watch(activityRepositoryProvider).watch();

@Riverpod(keepAlive: true)
Stream<List<PaymentRequest>> paymentRequests(Ref ref) => ref.watch(walletRepositoryProvider).watchRequests();

/// One held asset with its live value.
@immutable
class Holding {
  const Holding({required this.asset, required this.quantity, required this.quote, required this.value});

  final AssetInfo asset;
  final Decimal quantity;
  final Quote quote;

  /// Quantity × price, in NGN.
  final Money value;
}

/// Everything the Home and Wallets screens show, valued in NGN.
@immutable
class Portfolio {
  const Portfolio({
    required this.cash,
    required this.stocks,
    required this.crypto,
    required this.dayChange,
    required this.holdings,
    required this.history,
  });

  /// All home-currency wallets converted to NGN.
  final Money cash;
  final Money stocks;
  final Money crypto;

  /// Change in value of holdings since the open.
  final Money dayChange;

  /// Sorted by value, largest first.
  final List<Holding> holdings;

  /// Total value over the intraday window, for the balance chart.
  final List<double> history;

  Money get total => cash + stocks + crypto;
  double get dayChangePct =>
      total.isZero ? 0 : dayChange.amount.toDouble() / (total - dayChange).amount.toDouble() * 100;
}

/// Combines balances × live prices × FX. Recomputes on every price tick.
@riverpod
AsyncValue<Portfolio> portfolio(Ref ref) {
  final balancesV = ref.watch(balancesProvider);
  final quotesV = ref.watch(quotesProvider);
  final catalogV = ref.watch(catalogProvider);
  final ratesV = ref.watch(fxRatesProvider);
  if (balancesV.value == null || quotesV.value == null || catalogV.value == null || ratesV.value == null) {
    final error = [balancesV, quotesV, catalogV, ratesV].where((v) => v.hasError).firstOrNull;
    return error == null ? const AsyncLoading() : AsyncError(error.error!, error.stackTrace!);
  }
  return AsyncData(computePortfolio(balancesV.value!, quotesV.value!, catalogV.value!, ratesV.value!));
}

/// Pure so it can be unit-tested against the prototype's figures.
Portfolio computePortfolio(Balances b, Map<String, Quote> quotes, Map<String, AssetInfo> catalog, FxRates fx) {
  var cash = Money.zero(Currency.ngn);
  for (final m in b.fiat.values) {
    cash += fx.convert(m, Currency.ngn);
  }
  var stocks = Money.zero(Currency.ngn);
  var crypto = Money.zero(Currency.ngn);
  var change = Money.zero(Currency.ngn);
  final holdings = <Holding>[];
  final history = List<double>.filled(quotes.values.firstOrNull?.intraday.length ?? 0, cash.amount.toDouble());

  for (final e in b.holdings.entries) {
    final asset = catalog[e.key];
    final quote = quotes[e.key];
    if (asset == null || quote == null || e.value == Decimal.zero) continue;
    final value = Money(quote.price * e.value, Currency.ngn).rounded();
    if (asset.isStock) {
      stocks += value;
    } else {
      crypto += value;
    }
    change += Money((quote.price - asset.openPrice) * e.value, Currency.ngn).rounded();
    holdings.add(Holding(asset: asset, quantity: e.value, quote: quote, value: value));
    final q = e.value.toDouble();
    for (var i = 0; i < history.length && i < quote.intraday.length; i++) {
      history[i] += quote.intraday[i] * q;
    }
  }
  holdings.sort((a, b) => b.value.compareTo(a.value));
  return Portfolio(cash: cash, stocks: stocks, crypto: crypto, dayChange: change, holdings: holdings, history: history);
}

/// Currency the user chose to see totals in (balance card switcher).
@Riverpod(keepAlive: true)
class DisplayCurrency extends _$DisplayCurrency {
  static const _key = 'display.currency';

  @override
  Currency build() => Currency.fromCode(ref.watch(sharedPreferencesProvider).getString(_key) ?? 'NGN');

  Future<void> set(Currency c) async {
    state = c;
    await ref.read(sharedPreferencesProvider).setString(_key, c.code);
  }
}

/// "Hide balances" eye toggle, remembered across launches.
@Riverpod(keepAlive: true)
class HideBalances extends _$HideBalances {
  static const _key = 'display.hide';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> toggle() async {
    state = !state;
    await ref.read(sharedPreferencesProvider).setBool(_key, state);
  }
}

/// Portfolio value over [range] (week/month/year) for the balance card.
/// Cash is held flat; holdings use each asset's daily closes.
@riverpod
Future<List<double>> portfolioHistory(Ref ref, ChartRange range) async {
  final b = await ref.watch(balancesProvider.future);
  final fx = await ref.watch(fxRatesProvider.future);
  final market = ref.watch(marketRepositoryProvider);
  var cash = 0.0;
  for (final m in b.fiat.values) {
    cash += fx.convert(m, Currency.ngn).amount.toDouble();
  }
  List<double>? total;
  for (final e in b.holdings.entries) {
    final h = await market.history(e.key, range);
    total ??= List.filled(h.length, cash);
    final q = e.value.toDouble();
    for (var i = 0; i < h.length && i < total.length; i++) {
      total[i] += h[i] * q;
    }
  }
  return total ?? [cash, cash];
}

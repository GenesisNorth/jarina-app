import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/trading/application/trading_state.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _Interval { m15, h1, h4, d1, w1 }

const Map<_Interval, String> _intervalLabels = {
  _Interval.m15: '15m',
  _Interval.h1: '1H',
  _Interval.h4: '4H',
  _Interval.d1: '1D',
  _Interval.w1: '1W',
};
const _pairs = ['BTC', 'USDT', 'ETH', 'SOL', 'BNB', 'XRP'];

/// Candles built from a price series: consecutive points become open/close,
/// with deterministic wicks and volume. The real feed supplies OHLCV directly.
List<Candle> candlesFrom(List<double> series, int seed) {
  final r = math.Random(seed);
  return [
    for (var i = 1; i < series.length; i++)
      () {
        final o = series[i - 1];
        final c = series[i];
        final wick = (o - c).abs() * 0.6 + o * 0.0015;
        return Candle(
          o,
          math.max(o, c) + wick * r.nextDouble(),
          math.min(o, c) - wick * r.nextDouble(),
          c,
          20 + r.nextDouble() * 80,
        );
      }(),
  ];
}

/// Pro trade: candles + MA, order book, limit/market orders on coin/NGN pairs.
class ProTradeScreen extends ConsumerStatefulWidget {
  const ProTradeScreen({super.key, this.coin = 'BTC'});

  final String coin;

  @override
  ConsumerState<ProTradeScreen> createState() => _ProTradeScreenState();
}

class _ProTradeScreenState extends ConsumerState<ProTradeScreen> {
  late String _coin = widget.coin;
  _Interval _interval = _Interval.h1;
  bool _ma = true;
  bool _line = false;
  int? _inspect;
  OrderSide _side = OrderSide.buy;
  OrderType _type = OrderType.limit;
  final _price = TextEditingController();
  final _amount = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _price.dispose();
    _amount.dispose();
    super.dispose();
  }

  ChartRange get _range => switch (_interval) {
    _Interval.m15 || _Interval.h1 => ChartRange.day,
    _Interval.h4 => ChartRange.week,
    _Interval.d1 => ChartRange.month,
    _Interval.w1 => ChartRange.year,
  };

  Future<void> _place(Decimal livePrice) async {
    final l = AppLocalizations.of(context);
    final amount = Decimal.tryParse(_amount.text) ?? Decimal.zero;
    final price = _type == OrderType.market ? livePrice : (Decimal.tryParse(_price.text) ?? livePrice);
    final buy = _side == OrderSide.buy;
    final token = await confirmWithPin(
      context,
      action:
          '${buy ? l.buyCoin(_coin) : l.sellCoin(_coin)} · $amount @ ${MoneyFormat.format(Money(price, Currency.ngn))}',
    );
    if (!mounted || token == null) return;
    setState(() => _busy = true);
    final crypto = ref.read(cryptoRepositoryProvider);
    if (_type == OrderType.market) {
      // Market orders execute through the instant-swap engine.
      final pay = buy ? Money(amount * price, Currency.ngn).rounded() : Money(amount, Currency.crypto(_coin));
      final q = await crypto.quoteSwap(pay, buy ? _coin : 'NGN');
      final tx = q.valueOrNull == null ? null : await crypto.swap(q.valueOrNull!, pinToken: token);
      if (!mounted) return;
      setState(() => _busy = false);
      final ok = tx?.valueOrNull;
      if (ok != null) {
        context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': ok.id});
      } else {
        showToast(context, l.failure((tx ?? q).when(ok: (_) => const UnknownFailure(''), err: (f) => f)));
      }
      return;
    }
    final r = await crypto.placeLimitOrder(coin: _coin, side: _side, price: price, amount: amount, pinToken: token);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (o) {
        showToast(context, o.status == OrderStatus.filled ? l.orderFilled : l.orderPlacedShort);
        context.pushReplacementNamed(AppRoute.qorders.name);
      },
      err: (f) => showToast(context, f is InsufficientFundsFailure ? l.notEnoughBalance : l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final quote = ref.watch(quotesProvider).value?[_coin];
    final balances = ref.watch(balancesProvider).value;
    final feeRate = ref.watch(tradingRepositoryProvider).feeRate;
    final asset = catalog?[_coin];
    if (asset == null || quote == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final series = _range == ChartRange.day
        ? quote.intraday
        : ref.watch(assetHistoryProvider(_coin, _range)).value ?? quote.intraday;
    final candles = candlesFrom(series, _coin.hashCode ^ _interval.index);
    final ins = _inspect == null || _inspect! >= candles.length ? null : candles[_inspect!];
    final last = candles.isEmpty ? null : candles.last;
    final price = quote.price;

    final buy = _side == OrderSide.buy;
    // An empty limit price means "at the live price" (shown as the hint).
    final orderPrice = _type == OrderType.market ? price : (Decimal.tryParse(_price.text) ?? price);
    final amount = Decimal.tryParse(_amount.text) ?? Decimal.zero;
    final value = Money(orderPrice * amount, Currency.ngn).rounded();
    final fee = value.times(feeRate).rounded();
    final cash = balances?.fiatOf(Currency.ngn) ?? Money.zero(Currency.ngn);
    final held = balances?.qtyOf(_coin) ?? Decimal.zero;
    final over = buy ? value + fee > cash : amount > held;
    final ready = amount > Decimal.zero && orderPrice > Decimal.zero && !over && !_busy;
    final hi = quote.intraday.reduce(math.max);
    final lo = quote.intraday.reduce(math.min);
    String ngn(double v) => MoneyFormat.format(Money(Decimal.parse(v.toStringAsFixed(2)), Currency.ngn));

    void setPct(double p) {
      final pp = Decimal.parse(p.toStringAsFixed(2));
      final q = buy
          ? (orderPrice == Decimal.zero
                ? Decimal.zero
                : ((cash.amount / (Decimal.one + feeRate)).toDecimal(scaleOnInfinitePrecision: 8) * pp / orderPrice)
                      .toDecimal(scaleOnInfinitePrecision: 10))
          : held * pp;
      setState(() => _amount.text = q.floor(scale: asset.unit.decimals).toString());
    }

    // A synthetic book around the live price (the exchange streams the real one).
    final r = math.Random(_coin.hashCode);
    final asks = [for (var k = 6; k >= 1; k--) (price.toDouble() * (1 + 0.0009 * k), 0.005 + r.nextDouble() * 0.03)];
    final bids = [for (var k = 1; k <= 6; k++) (price.toDouble() * (1 - 0.0009 * k), 0.005 + r.nextDouble() * 0.03)];

    Widget bookRow((double, double) e, Color color) => InkWell(
      onTap: () => setState(() {
        _type = OrderType.limit;
        _price.text = e.$1.toStringAsFixed(2);
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ngn(e.$1),
                style: t.caption.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              e.$2.toStringAsFixed(4),
              style: t.caption.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.proTrade),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 32),
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final p in _pairs) ...[
                  JChip(
                    label: '$p/NGN',
                    selected: p == _coin,
                    onTap: () => setState(() {
                      _coin = p;
                      _price.clear();
                      _amount.clear();
                      _inspect = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AssetBadge(asset),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_coin/NGN', style: t.h2),
                    Text(
                      MoneyFormat.format(Money(price, Currency.ngn), decimals: 2),
                      style: t.title.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              Text(
                '${quote.changePct >= 0 ? '+' : ''}${quote.changePct.toStringAsFixed(2)}%',
                style: t.body.copyWith(color: quote.changePct >= 0 ? c.up : c.down, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (label, v) in [
                (l.s24hHigh, ngn(hi)),
                (l.s24hLow, ngn(lo)),
                (l.s24hVolume, '${(r.nextDouble() * 9 + 1).toStringAsFixed(1)} $_coin'),
              ])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: t.caption.copyWith(color: c.muted, fontSize: 11)),
                        FittedBox(child: Text(v, style: t.num.copyWith(fontSize: 13))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          JCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final i in _Interval.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setState(() {
                                    _interval = i;
                                    _inspect = null;
                                  }),
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: i == _interval ? c.black : c.fill,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _intervalLabels[i]!,
                                      style: t.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: i == _interval ? Colors.white : c.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'MA',
                      onPressed: () => setState(() => _ma = !_ma),
                      icon: Text(
                        'MA',
                        style: t.caption.copyWith(fontWeight: FontWeight.w800, color: _ma ? c.goldDeep : c.muted),
                      ),
                    ),
                    IconButton(
                      tooltip: _line ? 'Candles' : 'Line',
                      onPressed: () => setState(() => _line = !_line),
                      icon: Icon(
                        _line ? Icons.candlestick_chart_outlined : Icons.show_chart_rounded,
                        size: 20,
                        color: c.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ins == null
                      ? l.candles('${candles.length}')
                      : 'O ${ngn(ins.open)}  H ${ngn(ins.high)}  L ${ngn(ins.low)}  C ${ngn(ins.close)}',
                  style: t.caption.copyWith(color: c.muted, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                const SizedBox(height: 8),
                JCandleChart(
                  candles: candles,
                  showMa: _ma,
                  lineMode: _line,
                  onInspect: (i) => setState(() => _inspect = i),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(width: 12, height: 2, color: c.goldDeep),
                          Text('MA 7', style: t.caption.copyWith(fontSize: 11)),
                          Container(width: 12, height: 2, color: const Color(0xFF3C6FD8)),
                          Text('MA 25', style: t.caption.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    if (last != null) Text(ngn(last.close), style: t.caption.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l.dragToInspect, style: t.caption.copyWith(color: c.muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          JCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                JSegmented<OrderSide>(
                  segments: {OrderSide.buy: l.buy, OrderSide.sell: l.sell},
                  value: _side,
                  onChanged: (s) => setState(() {
                    _side = s;
                    _amount.clear();
                  }),
                ),
                const SizedBox(height: 10),
                JSegmented<OrderType>(
                  segments: {OrderType.limit: l.limit, OrderType.market: l.market},
                  value: _type,
                  onChanged: (v) => setState(() => _type = v),
                ),
                const SizedBox(height: 12),
                if (_type == OrderType.limit) ...[
                  JTextField(
                    label: l.priceNgn,
                    controller: _price,
                    hint: price.toStringAsFixed(2),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    onChanged: (_) => setState(() {}),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text('NGN', style: t.caption),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                JTextField(
                  label: '${l.amount} ($_coin)',
                  controller: _amount,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}'))],
                  errorText: over && amount > Decimal.zero ? l.notEnoughBalance : null,
                  onChanged: (_) => setState(() {}),
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(_coin, style: t.caption),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final p in [0.25, 0.5, 0.75, 1.0])
                      Expanded(
                        child: TextButton(
                          onPressed: () => setPct(p),
                          child: Text('${(p * 100).round()}%', style: t.caption.copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      SummaryRow(l.available, buy ? MoneyFormat.format(cash) : '$held $_coin'),
                      SummaryRow(l.total, MoneyFormat.format(buy ? value + fee : value - fee), strong: true),
                      SummaryRow(l.fee, '${feeRate * Decimal.fromInt(100)}% · ${MoneyFormat.format(fee)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: buy ? c.up : c.down,
                    disabledBackgroundColor: (buy ? c.up : c.down).withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: ready ? () => _place(price) : null,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(buy ? l.buyCoin(_coin) : l.sellCoin(_coin)),
                ),
              ],
            ),
          ),
          JSectionHeader(title: l.orderBook, trailing: l.tapAPriceToUseIt),
          JCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l.priceNgn, style: t.caption.copyWith(color: c.muted)),
                    ),
                    Text('${l.amount} ($_coin)', style: t.caption.copyWith(color: c.muted)),
                  ],
                ),
                const SizedBox(height: 6),
                for (final a in asks) bookRow(a, c.down),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(MoneyFormat.format(Money(price, Currency.ngn), decimals: 2), style: t.h2),
                ),
                for (final b in bids) bookRow(b, c.up),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

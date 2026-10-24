import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/application/trading_state.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/trading/presentation/market_status.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Buy / Sell (swap-style). Stocks pay from and sell into the Naira wallet.
class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({required this.assetId, super.key, this.side = TradeSide.buy});

  final String assetId;
  final TradeSide side;

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

/// Preview of an order, computed locally from the live price. The server
/// re-prices on quote; the Review screen shows the authoritative numbers.
class _Preview {
  _Preview({required this.qty, required this.gross, required this.fee, required this.side});

  final Decimal qty;
  final Money gross;
  final Money fee;
  final TradeSide side;

  Money get total => side == TradeSide.buy ? gross + fee : gross - fee;
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  late TradeSide _side = widget.side;
  final _amount = TextEditingController();
  double _pct = 0;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Decimal get _input => Decimal.tryParse(_amount.text.replaceAll(',', '')) ?? Decimal.zero;

  _Preview _preview(AssetInfo a, Decimal price, Decimal feeRate) {
    final Decimal qty;
    if (_side == TradeSide.buy) {
      final raw = price == Decimal.zero ? Decimal.zero : (_input / price).toDecimal(scaleOnInfinitePrecision: 12);
      qty = a.isStock ? raw.floor() : raw.floor(scale: 8);
    } else {
      qty = _input;
    }
    final gross = Money(qty * price, Currency.ngn).rounded();
    return _Preview(qty: qty, gross: gross, fee: gross.times(feeRate).rounded(), side: _side);
  }

  void _setPct(double p, AssetInfo a, Money cash, Decimal held, Decimal feeRate) {
    final Decimal v;
    if (_side == TradeSide.buy) {
      // Leave room for the fee so the total never exceeds the balance.
      v =
          (cash.amount / (Decimal.one + feeRate)).toDecimal(scaleOnInfinitePrecision: 4).floor(scale: 2) *
          Decimal.parse(p.toStringAsFixed(4));
      _amount.text = v.floor(scale: a.isStock ? 0 : 2).toString();
    } else {
      v = held * Decimal.parse(p.toStringAsFixed(4));
      _amount.text = (a.isStock ? v.floor() : v.floor(scale: 8)).toString();
    }
    setState(() {
      _pct = p;
      _error = null;
    });
  }

  Future<void> _continue(AssetInfo a, String livePrice) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(tradingRepositoryProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = _side == TradeSide.buy
        ? await repo.quoteBuy(a.id, Money(_input, Currency.ngn))
        : await repo.quoteSell(a.id, _input);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (q) {
        ref.read(pendingTradeProvider.notifier).set(q);
        context.pushNamed(AppRoute.review.name);
      },
      err: (f) => setState(
        () => _error = switch (f) {
          InsufficientFundsFailure() => _side == TradeSide.buy ? l.notEnoughBalance : l.notEnoughShares,
          BelowMinimumFailure() => l.minOneShare(livePrice),
          _ => l.failure(f),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final asset = ref.watch(catalogProvider).value?[widget.assetId];
    final quote = ref.watch(quotesProvider).value?[widget.assetId];
    final balances = ref.watch(balancesProvider).value;
    final feeRate = ref.watch(tradingRepositoryProvider).feeRate;
    if (asset == null || quote == null || balances == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final buy = _side == TradeSide.buy;
    final cash = balances.fiatOf(Currency.ngn);
    final held = balances.qtyOf(asset.id);
    final p = _preview(asset, quote.price, feeRate);
    final over = buy ? p.total > cash : p.qty > held;
    final belowOne = buy && _input > Decimal.zero && p.qty == Decimal.zero;
    final valid = p.qty > Decimal.zero && !over;
    final now = ref.watch(clockProvider)();
    final marketClosed = asset.isStock && !NgxSchedule.isOpen(now);
    final price = MoneyFormat.format(Money(quote.price, Currency.ngn), decimals: 2);

    final hint =
        _error ??
        (over
            ? (buy ? l.notEnoughBalance : l.notEnoughShares)
            : belowOne
            ? l.minOneShare(price)
            : null);

    final nairaPill = _Pill(
      badge: JAssetBadge(label: '₦', color: c.black, ring: c.fill, ink: Colors.white, round: true, size: 26),
      title: 'Naira',
      subtitle: l.walletLabel,
      locked: true,
    );
    final assetPill = _Pill(
      badge: AssetBadge(asset, size: 26),
      title: asset.id,
      subtitle: asset.isStock ? l.ngxShares : asset.name,
    );
    final qtyText = asset.isStock ? p.qty.toString() : p.qty.toStringAsFixed(p.qty == Decimal.zero ? 0 : 8);

    return JFlowScaffold(
      onBack: () => context.pop(),
      backLabel: l.back,
      trailing: Text(buy ? l.buyAsset(asset.id) : l.sellAsset(asset.id), style: t.h2),
      bottom: _busy
          ? const SizedBox(height: 58, child: Center(child: CircularProgressIndicator()))
          : JSlideToConfirm(
              label: buy ? l.slideToBuy : l.slideToSell,
              disabledLabel: l.enterAnAmount,
              onConfirm: valid ? () => _continue(asset, price) : null,
            ),
      children: [
        JBrandCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AssetBadge(asset, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buy ? l.buyAsset(asset.id) : l.sellAsset(asset.id),
                          style: t.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          asset.isStock ? l.pricePerShare(price) : l.pricePerUnit(asset.id, price),
                          style: t.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  JChangePill(percent: quote.changePct, onDark: true),
                ],
              ),
              const SizedBox(height: 6),
              JAreaChart(values: quote.intraday, color: BrandColors.gold, height: 40, stroke: 1.6),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JSegmented<TradeSide>(
          segments: {TradeSide.buy: l.buy, TradeSide.sell: l.sell},
          value: _side,
          onChanged: (s) {
            if (s == TradeSide.sell && held <= Decimal.zero) return;
            setState(() {
              _side = s;
              _amount.clear();
              _pct = 0;
              _error = null;
            });
          },
        ),
        const SizedBox(height: 14),
        _Box(
          label: buy ? l.youPay : l.youSell,
          aside: buy ? l.balanceOf(MoneyFormat.format(cash)) : l.balanceOf(quantityText(l, asset, held)),
          onAside: () => _setPct(1, asset, cash, held, feeRate),
          pill: buy ? nairaPill : assetPill,
          value: TextField(
            controller: _amount,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.numberWithOptions(decimal: buy || !asset.isStock),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(buy ? r'^\d*\.?\d{0,2}' : (asset.isStock ? r'^\d*' : r'^\d*\.?\d{0,8}')),
              ),
              LengthLimitingTextInputFormatter(14),
            ],
            onChanged: (_) => setState(() {
              _pct = 0;
              _error = null;
            }),
            style: t.amountL.copyWith(fontSize: 28),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: t.amountL.copyWith(fontSize: 28, color: c.muted.withValues(alpha: 0.6)),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          footer: JPercentSlider(
            value: _pct,
            maxLabel: l.max,
            onChanged: (v) => _setPct(v, asset, cash, held, feeRate),
          ),
        ),
        Center(
          child: Transform.translate(
            offset: const Offset(0, -2),
            child: IconButton.filled(
              tooltip: buy ? l.sell : l.buy,
              style: IconButton.styleFrom(backgroundColor: c.black, fixedSize: const Size(44, 44)),
              onPressed: !buy || held > Decimal.zero
                  ? () => setState(() {
                      _side = buy ? TradeSide.sell : TradeSide.buy;
                      _amount.clear();
                      _pct = 0;
                      _error = null;
                    })
                  : null,
              icon: const JarinaIcon(JIcon.swap, size: 20, color: Colors.white),
            ),
          ),
        ),
        _Box(
          label: buy ? l.youGet : l.youReceiveEst,
          aside: buy ? l.youHold(quantityText(l, asset, held)) : l.balanceOf(MoneyFormat.format(cash)),
          pill: buy ? assetPill : nairaPill,
          value: Text(
            buy ? qtyText : MoneyFormat.format(p.total).replaceAll('₦', ''),
            textAlign: TextAlign.right,
            style: t.amountL.copyWith(fontSize: 28),
          ),
          footer: Row(
            children: [
              Expanded(
                child: Text(
                  '≈ ${MoneyFormat.format(p.gross)} · ${l.feeAmount(MoneyFormat.format(p.fee))}',
                  style: t.caption.copyWith(color: c.muted),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: c.up, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                l.livePrice,
                style: t.caption.copyWith(color: c.up, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              hint,
              style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 12),
        JCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                l.price,
                style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, fontSize: 14),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  l.pricePerUnit(asset.id, price),
                  textAlign: TextAlign.right,
                  style: t.num.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (marketClosed) ...[
          const SizedBox(height: 12),
          JCallout(text: l.ngxClosedOrderNote(nextOpenText(l, now)), icon: JIcon.activity),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.label,
    required this.aside,
    required this.pill,
    required this.value,
    required this.footer,
    this.onAside,
  });

  final String label;
  final String aside;
  final VoidCallback? onAside;
  final Widget pill;
  final Widget value;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return JCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.caption.copyWith(
                    color: c.muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: GestureDetector(
                  onTap: onAside,
                  child: Text(
                    aside,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.caption.copyWith(
                      color: c.muted,
                      decoration: onAside == null ? null : TextDecoration.underline,
                      decorationColor: c.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              pill,
              const SizedBox(width: 12),
              Expanded(child: value),
            ],
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.badge, required this.title, required this.subtitle, this.locked = false});

  final Widget badge;
  final String title;
  final String subtitle;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14, height: 1.1)),
              Text(subtitle, style: t.caption.copyWith(color: c.muted, fontSize: 10)),
            ],
          ),
          if (locked) ...[const SizedBox(width: 6), JarinaIcon(JIcon.lock, size: 14, color: c.muted)],
        ],
      ),
    );
  }
}

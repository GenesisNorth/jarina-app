import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/chart_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/application/trading_state.dart';
import 'package:jarina/features/trading/presentation/market_status.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Asset detail (stock or coin): price, range chart, position, day stats,
/// about, and Buy / Sell.
class AssetScreen extends ConsumerStatefulWidget {
  const AssetScreen({required this.assetId, super.key});

  final String assetId;

  @override
  ConsumerState<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends ConsumerState<AssetScreen> {
  ChartRange _range = ChartRange.month;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final asset = ref.watch(catalogProvider).value?[widget.assetId];
    final quote = ref.watch(quotesProvider).value?[widget.assetId];
    final held = ref.watch(balancesProvider).value?.qtyOf(widget.assetId) ?? Decimal.zero;
    final starred = ref.watch(watchlistProvider).contains(widget.assetId);

    if (asset == null || quote == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(),
        body: Center(
          child: ref.watch(catalogProvider).isLoading ? const CircularProgressIndicator() : Text(l.noResults),
        ),
      );
    }

    final history = _range == ChartRange.day
        ? quote.intraday
        : ref.watch(assetHistoryProvider(asset.id, _range)).value ?? quote.intraday;
    final up = quote.changePct >= 0;
    final lineUp = history.length < 2 || history.last >= history.first;
    final dayHigh = quote.intraday.reduce(math.max);
    final dayLow = quote.intraday.reduce(math.min);
    final position = Money(quote.price * held, Currency.ngn).rounded();
    Money ngn(double v) => Money(Decimal.parse(v.toStringAsFixed(2)), Currency.ngn);

    void trade(String side) =>
        context.pushNamed(AppRoute.entry.name, queryParameters: {'asset': asset.id, 'side': side});

    Widget stat(String label, Money v) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.caption.copyWith(color: c.muted)),
          const SizedBox(height: 2),
          Text(MoneyFormat.format(v, decimals: 2), style: t.num.copyWith(fontSize: 14)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: JCircleButton(icon: JIcon.arrowLeft, semanticLabel: l.back, onPressed: () => context.pop()),
        ),
        actions: [
          IconButton(
            tooltip: starred ? l.removeFromWatchlist : l.addToWatchlist,
            onPressed: () => unawaited(ref.read(watchlistProvider.notifier).toggle(asset.id)),
            icon: Icon(starred ? Icons.star_rounded : Icons.star_outline_rounded, color: starred ? c.goldDeep : c.ink),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 24),
        children: [
          Row(
            children: [
              AssetBadge(asset, size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.id, style: t.h2),
                    Text(
                      asset.isStock ? '${asset.name} · NGX · ${asset.sector ?? ''}' : '${asset.name} · ${l.crypto}',
                      style: t.caption.copyWith(color: c.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              MoneyFormat.format(Money(quote.price, Currency.ngn), decimals: 2),
              style: t.amountXl.copyWith(fontSize: 34),
            ),
          ),
          Text(
            l.todaySuffix('${up ? '+' : ''}${quote.changePct.toStringAsFixed(2)}%'),
            style: t.body.copyWith(color: up ? c.up : c.down, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          if (asset.isStock) ...[const SizedBox(height: 8), const MarketStatusLine()],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => context.pushNamed(AppRoute.alert.name, queryParameters: {'asset': asset.id}),
                  icon: JarinaIcon(JIcon.bell, size: 18, color: c.ink),
                  label: Text(l.setAlert, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => context.pushNamed(AppRoute.rule.name, queryParameters: {'asset': asset.id}),
                  icon: JarinaIcon(JIcon.auto, size: 18, color: c.ink),
                  label: Text(l.autopilot, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          JAreaChart(values: history, color: lineUp ? c.goldDeep : c.down, height: 190),
          const SizedBox(height: 10),
          RangeSelector(value: _range, onChanged: (r) => setState(() => _range = r)),
          const SizedBox(height: 18),
          if (held > Decimal.zero)
            JCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.yourPosition, style: t.caption.copyWith(color: c.muted)),
                        const SizedBox(height: 2),
                        Text(
                          quantityText(l, asset, held),
                          style: t.body.copyWith(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  MoneyText(position, decimals: wholeFor(position), style: t.num.copyWith(fontSize: 17)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              stat(l.open, Money(asset.openPrice, Currency.ngn)),
              stat(l.dayHigh, ngn(dayHigh)),
              stat(l.dayLow, ngn(dayLow)),
            ],
          ),
          if (asset.about != null) ...[
            JSectionHeader(title: l.about),
            Text(
              asset.about!,
              style: t.body.copyWith(fontWeight: FontWeight.w400, height: 1.55, color: c.ink2),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: Row(
          children: [
            Expanded(
              child: JButton(
                label: l.sell,
                variant: JButtonVariant.soft,
                onPressed: held > Decimal.zero ? () => trade('sell') : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: JButton(label: l.buy, onPressed: () => trade('buy')),
            ),
          ],
        ),
      ),
    );
  }
}

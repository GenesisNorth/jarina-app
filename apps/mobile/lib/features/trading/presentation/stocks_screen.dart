import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/home/presentation/app_drawer.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/presentation/market_status.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Stocks tab: NGX portfolio, holdings, trading tools and all listed stocks.
class StocksScreen extends ConsumerStatefulWidget {
  const StocksScreen({super.key});

  @override
  ConsumerState<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends ConsumerState<StocksScreen> {
  String _query = '';
  String? _sector;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final quotes = ref.watch(quotesProvider).value;
    final portfolio = ref.watch(portfolioProvider).value;

    final stocks = catalog?.values.where((a) => a.isStock).toList() ?? const <AssetInfo>[];
    final sectors = {for (final a in stocks) ?a.sector}.toList()..sort();
    final q = _query.trim().toLowerCase();
    final filtered = stocks
        .where((a) => _sector == null || a.sector == _sector)
        .where((a) => q.isEmpty || a.id.toLowerCase().contains(q) || a.name.toLowerCase().contains(q))
        .toList();
    final holdings = portfolio?.holdings.where((h) => h.asset.isStock).toList() ?? const <Holding>[];

    // Portfolio value line: sum of each stock holding's intraday prices.
    final spark = <double>[];
    for (final h in holdings) {
      final qty = h.quantity.toDouble();
      for (var i = 0; i < h.quote.intraday.length; i++) {
        if (spark.length <= i) spark.add(0);
        spark[i] += h.quote.intraday[i] * qty;
      }
    }
    var change = Money.zero(Currency.ngn);
    for (final h in holdings) {
      change += Money((h.quote.price - h.asset.openPrice) * h.quantity, Currency.ngn).rounded();
    }
    final value = portfolio?.stocks ?? Money.zero(Currency.ngn);
    final base = value - change;
    final pct = base.isZero ? 0.0 : change.amount.toDouble() / base.amount.toDouble() * 100;
    final up = change.amount >= Decimal.zero;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(header: true, child: Text(l.stocks, style: t.largeTitle)),
                      ),
                      JIconButton(icon: JIcon.menu, semanticLabel: l.menu, onPressed: () => showAppDrawer(context)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const MarketStatusLine(),
                  const SizedBox(height: 14),
                  JCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.stockPortfolioValue, style: t.caption.copyWith(color: c.muted, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  MoneyText(value, decimals: 0, style: t.amountL.copyWith(fontSize: 28)),
                                  const SizedBox(height: 4),
                                  Text(
                                    l.todaySuffix(
                                      '${MoneyFormat.format(change, decimals: 0, signed: true)} '
                                      '(${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%)',
                                    ),
                                    style: t.caption.copyWith(color: up ? c.up : c.down, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            if (spark.length > 1)
                              JSparkline(values: spark, color: up ? c.up : c.down, width: 90, height: 40),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: JButton(
                                label: l.buy,
                                height: 50,
                                onPressed: () =>
                                    context.pushNamed(AppRoute.picker.name, queryParameters: {'kind': 'stocks'}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: JButton(
                                label: l.sell,
                                height: 50,
                                variant: JButtonVariant.soft,
                                onPressed: holdings.isEmpty
                                    ? null
                                    : () => context.pushNamed(
                                        AppRoute.picker.name,
                                        queryParameters: {'kind': 'stocks', 'side': 'sell'},
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  JSectionHeader(title: l.yourHoldings, trailing: l.stocksCount('${holdings.length}')),
                  if (holdings.isEmpty)
                    JCard(
                      child: Text(l.noHoldings, style: t.body.copyWith(color: c.muted)),
                    )
                  else
                    RowsCard(children: [for (final h in holdings) HoldingRow(holding: h)]),
                  const SizedBox(height: 14),
                  RowsCard(
                    children: [
                      _ToolRow(
                        icon: JIcon.auto,
                        title: l.autopilot,
                        subtitle: l.autoBuyDipsAndAutoSell,
                        dark: true,
                        onTap: () =>
                            context.pushNamed(AppRoute.autopilot.name, queryParameters: const {'type': 'stock'}),
                      ),
                      _ToolRow(
                        icon: JIcon.bell,
                        title: l.priceAlerts,
                        onTap: () => context.pushNamed(AppRoute.alerts.name),
                      ),
                    ],
                  ),
                  JSectionHeader(title: l.nigerianStocksNgx, trailing: '${stocks.length}'),
                  JTextField(
                    hint: l.searchCompanyOrTicker,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: JarinaIcon(JIcon.search, size: 18, color: c.muted),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        JChip(label: l.all, selected: _sector == null, onTap: () => setState(() => _sector = null)),
                        for (final s in sectors) ...[
                          const SizedBox(width: 8),
                          JChip(label: s, selected: _sector == s, onTap: () => setState(() => _sector = s)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // The full list is built lazily: 130+ rows with live sparklines.
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 0, SpacingTokens.screenGutter, 120),
              sliver: filtered.isEmpty
                  ? SliverToBoxAdapter(
                      child: JCard(
                        child: Text(l.noResults, style: t.body.copyWith(color: c.muted)),
                      ),
                    )
                  : SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => JCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: MarketRow(asset: filtered[i], quote: quotes?[filtered[i].id]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.icon, required this.title, required this.onTap, this.subtitle, this.dark = false});

  final JIcon icon;
  final String title;
  final String? subtitle;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: dark ? c.black : c.fill, borderRadius: BorderRadius.circular(12)),
              child: Center(child: JarinaIcon(icon, size: 20, color: dark ? Colors.white : c.ink)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle!, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                ],
              ),
            ),
            Transform.flip(flipX: true, child: JarinaIcon(JIcon.back, size: 16, color: c.muted)),
          ],
        ),
      ),
    );
  }
}

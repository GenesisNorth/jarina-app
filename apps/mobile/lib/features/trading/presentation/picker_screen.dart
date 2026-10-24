import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Pick an asset to trade. Sell mode lists only what the user holds.
class PickerScreen extends ConsumerStatefulWidget {
  const PickerScreen({super.key, this.kind, this.side = TradeSide.buy});

  /// Null shows stocks and crypto.
  final AssetKind? kind;
  final TradeSide side;

  @override
  ConsumerState<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends ConsumerState<PickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final quotes = ref.watch(quotesProvider).value;
    final balances = ref.watch(balancesProvider).value;
    final sell = widget.side == TradeSide.sell;
    final q = _query.trim().toLowerCase();

    final list = (catalog?.values ?? const <AssetInfo>[])
        .where((a) => widget.kind == null || a.kind == widget.kind)
        .where((a) => !sell || (balances?.qtyOf(a.id) ?? Decimal.zero) > Decimal.zero)
        .where((a) => q.isEmpty || a.id.toLowerCase().contains(q) || a.name.toLowerCase().contains(q))
        .toList();

    final title = switch ((widget.kind, sell)) {
      (AssetKind.stock, false) => l.buyStocks,
      (AssetKind.stock, true) => l.sellStocks,
      (AssetKind.crypto, false) => l.buyCrypto,
      (AssetKind.crypto, true) => l.sellCrypto,
      (null, _) => sell ? l.sell : l.buy,
    };

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: JCircleButton(icon: JIcon.arrowLeft, semanticLabel: l.back, onPressed: () => context.pop()),
        ),
        title: Text(title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 12),
            sliver: SliverList.list(
              children: [
                Text(
                  sell ? l.chooseAHoldingToSell : l.chooseWhatYouWantToBuy,
                  style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 12),
                JTextField(
                  hint: l.searchCompanyOrTicker,
                  onChanged: (v) => setState(() => _query = v),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: JarinaIcon(JIcon.search, size: 18, color: c.muted),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 0, SpacingTokens.screenGutter, 32),
            sliver: list.isEmpty
                ? SliverToBoxAdapter(
                    child: JCard(
                      child: Text(sell ? l.noHoldings : l.noResults, style: t.body.copyWith(color: c.muted)),
                    ),
                  )
                : SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => JCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: MarketRow(
                        asset: list[i],
                        quote: quotes?[list[i].id],
                        onTap: () => context.pushReplacementNamed(
                          AppRoute.entry.name,
                          queryParameters: {'asset': list[i].id, 'side': widget.side.name},
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

class AssetBadge extends StatelessWidget {
  const AssetBadge(this.asset, {super.key, this.size = 40});

  final AssetInfo asset;
  final double size;

  @override
  Widget build(BuildContext context) => JAssetBadge(
    label: asset.badge.label,
    color: Color(asset.badge.color),
    ring: Color(asset.badge.ring),
    ink: Color(asset.badge.ink),
    round: !asset.isStock,
    size: size,
  );
}

/// Quantity in the asset's own unit: "400 shares", "0.0042 BTC".
String quantityText(AppLocalizations l, AssetInfo a, Decimal qty) =>
    a.isStock ? '${MoneyFormat.number(qty)} ${l.shares2}' : MoneyFormat.format(Money(qty, a.unit));

/// Holding row: badge, ticker + quantity, live sparkline, value + change pill.
class HoldingRow extends StatelessWidget {
  const HoldingRow({required this.holding, super.key});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final a = holding.asset;
    final up = holding.quote.changePct >= 0;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.pushNamed(AppRoute.asset.name, pathParameters: {'id': a.id}),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              AssetBadge(a),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      quantityText(l, a, holding.quantity),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.caption.copyWith(color: c.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Sparklines are decoration; drop them when space is tight.
              if (MediaQuery.sizeOf(context).width >= 340 && MediaQuery.textScalerOf(context).scale(1) <= 1.3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: JSparkline(values: holding.quote.intraday, color: up ? c.up : c.down),
                ),
              RowAmount(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(holding.value, decimals: wholeFor(holding.value), style: t.num.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    JChangePill(percent: holding.quote.changePct),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

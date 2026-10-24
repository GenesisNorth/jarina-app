import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Standard app bar: round back button, centred title, optional actions.
PreferredSizeWidget jarinaAppBar(BuildContext context, String title, {List<Widget>? actions, VoidCallback? onBack}) {
  final l = AppLocalizations.of(context);
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: 8),
      child: JCircleButton(
        icon: JIcon.arrowLeft,
        semanticLabel: l.back,
        onPressed: onBack ?? () => context.canPop() ? context.pop() : context.go('/crypto'),
      ),
    ),
    title: Text(title),
    actions: actions,
  );
}

/// Horizontal coin selector (Buy / Cash out / Borrow screens).
class CoinChips extends StatelessWidget {
  const CoinChips({required this.coins, required this.selected, required this.onSelected, super.key});

  final List<AssetInfo> coins;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: coins.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final a = coins[i];
          final on = a.id == selected;
          return Semantics(
            selected: on,
            button: true,
            label: a.id,
            onTap: () => onSelected(a.id),
            excludeSemantics: true,
            child: Material(
              color: on ? c.black : c.card,
              shape: StadiumBorder(side: BorderSide(color: on ? c.black : c.line)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelected(a.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                  child: Row(
                    children: [
                      AssetBadge(a, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        a.id,
                        style: t.caption.copyWith(fontWeight: FontWeight.w700, color: on ? Colors.white : c.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small coloured status pill.
class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
    child: Text(
      label,
      style: context.text.caption.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 11),
    ),
  );
}

(String, Color) transferStatus(BuildContext context, TransferStatus s) {
  final l = AppLocalizations.of(context);
  final c = context.colors;
  return switch (s) {
    TransferStatus.confirming => (l.confirming, c.goldDeep),
    TransferStatus.processing => (l.processing, c.goldDeep),
    TransferStatus.successful => (l.successful, c.up),
    TransferStatus.onHold => (l.onHold, c.goldDeep),
    TransferStatus.rejected => (l.rejected, c.down),
    TransferStatus.cancelled => (l.cancelled, c.muted),
  };
}

(String, Color) orderStatus(BuildContext context, OrderStatus s) {
  final l = AppLocalizations.of(context);
  final c = context.colors;
  return switch (s) {
    OrderStatus.open => (l.open, c.goldDeep),
    OrderStatus.partiallyFilled => (l.partiallyFilled, c.goldDeep),
    OrderStatus.filled => (l.filled, c.up),
    OrderStatus.cancelled => (l.cancelled, c.muted),
  };
}

/// Two-column key/value row used in quote summaries.
class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: t.num.copyWith(fontSize: 14, fontWeight: strong ? FontWeight.w700 : FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// A card of [SummaryRow]s separated by hairlines.
class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => JCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.colors.line),
          rows[i],
        ],
      ],
    ),
  );
}

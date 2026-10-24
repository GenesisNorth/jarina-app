import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/trading/application/trading_state.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Order placed (or queued while NGX is closed).
class OrderDoneScreen extends ConsumerWidget {
  const OrderDoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final order = ref.watch(lastOrderProvider);
    void home() => context.goNamed(order?.$1.asset.isStock ?? true ? AppRoute.stocks.name : AppRoute.crypto.name);

    if (order == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => home());
      return Scaffold(backgroundColor: c.bg);
    }
    final (quote, tx) = order;
    final queued = !quote.marketOpen;

    return JFlowScaffold(
      centerBody: true,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JButton(label: l.done, onPressed: home),
          JButton(
            label: l.viewReceipt,
            variant: JButtonVariant.ghost,
            height: 48,
            onPressed: () => context.pushNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id}),
          ),
        ],
      ),
      children: [
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: queued ? c.goldDeep : c.up, shape: BoxShape.circle),
            child: JarinaIcon(queued ? JIcon.activity : JIcon.check, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(queued ? l.orderQueued : l.orderPlaced, textAlign: TextAlign.center, style: t.title),
        ),
        const SizedBox(height: 8),
        Text(
          queued ? l.orderQueuedBody : l.yourOrderHasBeenSentTo,
          textAlign: TextAlign.center,
          style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
        ),
        const SizedBox(height: 20),
        Center(child: MoneyText(quote.total, alwaysShow: true, style: t.amountL)),
        const SizedBox(height: 4),
        Text(
          tx.subtitle,
          textAlign: TextAlign.center,
          style: t.body.copyWith(color: c.muted),
        ),
      ],
    );
  }
}

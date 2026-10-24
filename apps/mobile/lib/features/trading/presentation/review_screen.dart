import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/trading/application/trading_state.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Review an order, then confirm with the transaction PIN.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _busy = false;
  String? _error;

  /// Re-prices after the server reports the quote expired (quotes live ~30s).
  /// Expiry is the server's call, never the phone's clock, which may be wrong.
  Future<void> _requote(TradeQuote q) async {
    final repo = ref.read(tradingRepositoryProvider);
    final r = q.isBuy ? await repo.quoteBuy(q.asset.id, q.gross) : await repo.quoteSell(q.asset.id, q.quantity);
    final next = r.valueOrNull;
    if (next != null) ref.read(pendingTradeProvider.notifier).set(next);
  }

  Future<void> _confirm(TradeQuote q) async {
    final l = AppLocalizations.of(context);
    setState(() => _error = null);
    final action = '${q.isBuy ? l.buyAsset(q.asset.id) : l.sellAsset(q.asset.id)} · ${MoneyFormat.format(q.total)}';
    final token = await confirmWithPin(context, action: action);
    if (!mounted || token == null) return;
    setState(() => _busy = true);
    final r = await ref.read(tradingRepositoryProvider).placeOrder(q, pinToken: token);
    if (!mounted) return;
    if (r.when(ok: (_) => false, err: (f) => f is QuoteExpiredFailure)) {
      await _requote(q);
      if (!mounted) return;
      setState(() => _busy = false);
      showToast(context, l.priceUpdated);
      return;
    }
    setState(() => _busy = false);
    r.when(
      ok: (tx) {
        ref.read(lastOrderProvider.notifier).set((q, tx));
        ref.read(pendingTradeProvider.notifier).set(null);
        context.goNamed(AppRoute.done.name);
      },
      err: (f) => setState(
        () =>
            _error = f is InsufficientFundsFailure ? (q.isBuy ? l.notEnoughBalance : l.notEnoughShares) : l.failure(f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final q = ref.watch(pendingTradeProvider);
    if (q == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) context.pop();
      });
      return Scaffold(backgroundColor: c.bg);
    }
    final qty = q.asset.isStock ? l.sharesCount('${q.quantity}') : MoneyFormat.format(Money(q.quantity, q.asset.unit));

    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
            ),
          ),
          Flexible(
            child: Text(v, textAlign: TextAlign.right, style: t.num),
          ),
        ],
      ),
    );

    return JFlowScaffold(
      onBack: () => context.pop(),
      backLabel: l.back,
      trailing: Text(l.review, style: t.h2),
      bottom: JButton(label: l.confirm, icon: JIcon.lock, loading: _busy, onPressed: () => _confirm(q)),
      children: [
        const SizedBox(height: 8),
        Text(
          q.isBuy ? l.buyAsset(q.asset.id) : l.sellAsset(q.asset.id),
          textAlign: TextAlign.center,
          style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 4),
        Center(child: MoneyText(q.total, alwaysShow: true, style: t.amountXl.copyWith(fontSize: 38))),
        const SizedBox(height: 20),
        JCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Column(
            children: [
              row(l.orderType, l.market),
              Divider(height: 1, color: c.line),
              row(l.price, MoneyFormat.format(Money(q.price, Currency.ngn), decimals: 2)),
              Divider(height: 1, color: c.line),
              row(l.quantity, qty),
              Divider(height: 1, color: c.line),
              row(l.amount, MoneyFormat.format(q.gross)),
              Divider(height: 1, color: c.line),
              row(
                '${l.fee} (${ref.read(tradingRepositoryProvider).feeRate * Decimal.fromInt(100)}%)',
                MoneyFormat.format(q.fee),
              ),
              Divider(height: 1, color: c.line),
              row(q.isBuy ? l.total : l.youReceive, MoneyFormat.format(q.total)),
              if (q.asset.isStock) ...[
                Divider(height: 1, color: c.line),
                row(l.executedBy, l.licensedPartnerBroker),
              ],
            ],
          ),
        ),
        if (!q.marketOpen) ...[
          const SizedBox(height: 12),
          JCallout(text: l.orderQueuedBody, icon: JIcon.activity),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 14),
        JNote(text: l.youLlConfirmWithYourTransaction),
      ],
    );
  }
}

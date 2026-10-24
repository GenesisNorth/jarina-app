import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/crypto/application/crypto_state.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/crypto/presentation/coin_screen.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _HistTab { deposits, withdrawals, swaps, trades }

/// Deposits & withdrawals with live statuses, plus swaps and buy/sell.
class CryptoHistoryScreen extends ConsumerStatefulWidget {
  const CryptoHistoryScreen({super.key});

  @override
  ConsumerState<CryptoHistoryScreen> createState() => _CryptoHistoryScreenState();
}

class _CryptoHistoryScreenState extends ConsumerState<CryptoHistoryScreen> {
  _HistTab _tab = _HistTab.deposits;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final transfers = ref.watch(cryptoTransfersProvider).value ?? const <CryptoTransfer>[];
    final activity = (ref.watch(activityProvider).value ?? const <Transaction>[]).where(
      (x) => x.category == TxCategory.crypto,
    );

    final Widget list = switch (_tab) {
      _HistTab.deposits || _HistTab.withdrawals => () {
        final dir = _tab == _HistTab.deposits ? TransferDirection.deposit : TransferDirection.withdrawal;
        final items = transfers.where((x) => x.direction == dir).toList();
        return items.isEmpty
            ? JCard(
                child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
              )
            : RowsCard(children: [for (final x in items) TransferRow(transfer: x)]);
      }(),
      _HistTab.swaps || _HistTab.trades => () {
        final swaps = _tab == _HistTab.swaps;
        final items = activity
            .where((x) => x.title.startsWith('Swapped') == swaps && x.kind == TxKind.cryptoTrade)
            .toList();
        return items.isEmpty
            ? JCard(
                child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
              )
            : RowsCard(children: [for (final x in items) ActivityRow(tx: x)]);
      }(),
    };

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.depositsWithdrawals),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          JSegmented<_HistTab>(
            segments: {
              _HistTab.deposits: l.deposits,
              _HistTab.withdrawals: l.withdrawals,
              _HistTab.swaps: l.swaps,
              _HistTab.trades: l.buySell,
            },
            value: _tab,
            onChanged: (v) => setState(() => _tab = v),
          ),
          const SizedBox(height: 14),
          list,
        ],
      ),
    );
  }
}

enum _OrderTab { open, filled, cancelled }

/// Open / filled / cancelled pro-trade orders, with cancel.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  _OrderTab _tab = _OrderTab.open;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final orders = (ref.watch(cryptoOrdersProvider).value ?? const <LimitOrder>[]).where((o) {
      return switch (_tab) {
        _OrderTab.open => o.status == OrderStatus.open || o.status == OrderStatus.partiallyFilled,
        _OrderTab.filled => o.status == OrderStatus.filled,
        _OrderTab.cancelled => o.status == OrderStatus.cancelled,
      };
    }).toList();
    final now = ref.watch(clockProvider)();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.orders),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          JSegmented<_OrderTab>(
            segments: {_OrderTab.open: l.open, _OrderTab.filled: l.filled, _OrderTab.cancelled: l.cancelled},
            value: _tab,
            onChanged: (v) => setState(() => _tab = v),
          ),
          const SizedBox(height: 14),
          if (orders.isEmpty)
            JCard(
              child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
            )
          else
            RowsCard(
              children: [
                for (final o in orders)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusPill(
                              label: o.side == OrderSide.buy ? l.buy : l.sell,
                              color: o.side == OrderSide.buy ? c.up : c.down,
                            ),
                            Text(
                              '${o.pair} · ${o.type == OrderType.limit ? l.limit : l.market}',
                              style: t.body.copyWith(fontWeight: FontWeight.w700),
                            ),
                            StatusPill(
                              label: orderStatus(context, o.status).$1,
                              color: orderStatus(context, o.status).$2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${o.amount} @ ${MoneyFormat.format(Money(o.price, Currency.ngn))} · ${activityDate(l, o.createdAt, now: now)}',
                          style: t.caption.copyWith(color: c.muted),
                        ),
                        if (o.status == OrderStatus.open || o.status == OrderStatus.partiallyFilled) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: o.filled,
                                    minHeight: 3,
                                    backgroundColor: c.line,
                                    valueColor: AlwaysStoppedAnimation(c.goldDeep),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l.percentFilled('${(o.filled * 100).round()}'),
                                style: t.caption.copyWith(color: c.muted),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                final r = await ref.read(cryptoRepositoryProvider).cancelOrder(o.id);
                                if (context.mounted && r.isOk) showToast(context, l.orderCancelled);
                              },
                              child: Text(
                                l.cancel,
                                style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 14),
          JButton(
            label: l.placeANewOrder,
            variant: JButtonVariant.soft,
            onPressed: () => context.pushNamed(AppRoute.qpro.name),
          ),
        ],
      ),
    );
  }
}

/// All crypto wallets with totals and a hide-zero switch.
class CryptoWalletsScreen extends ConsumerStatefulWidget {
  const CryptoWalletsScreen({super.key});

  @override
  ConsumerState<CryptoWalletsScreen> createState() => _CryptoWalletsScreenState();
}

class _CryptoWalletsScreenState extends ConsumerState<CryptoWalletsScreen> {
  bool _hideZero = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final quotes = ref.watch(quotesProvider).value;
    final balances = ref.watch(balancesProvider).value;
    final orders = ref.watch(cryptoOrdersProvider).value ?? const <LimitOrder>[];
    final fx = ref.watch(fxRatesProvider).value;
    final coins = (catalog?.values.where((a) => !a.isStock) ?? const <AssetInfo>[]).where((a) {
      return !_hideZero || (balances?.qtyOf(a.id) ?? Decimal.zero) + reservedInOrders(orders, a.id) > Decimal.zero;
    }).toList();
    var total = Money.zero(Currency.ngn);
    for (final a in catalog?.values.where((a) => !a.isStock) ?? const <AssetInfo>[]) {
      final q = quotes?[a.id];
      if (q != null && balances != null) {
        total += Money(q.price * (balances.qtyOf(a.id) + reservedInOrders(orders, a.id)), Currency.ngn).rounded();
      }
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.cryptoWallets),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          JBrandCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.totalCryptoBalance, style: t.caption.copyWith(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                MoneyText(total, decimals: 0, style: t.amountL.copyWith(color: Colors.white, fontSize: 30)),
                if (fx != null)
                  Text(
                    '≈ ${MoneyFormat.format(fx.convert(total, Currency.usd))} · ${l.nWallets('${catalog?.values.where((a) => !a.isStock).length ?? 0}')}',
                    style: t.caption.copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          JCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                JarinaIcon(JIcon.eye, color: c.ink),
                const SizedBox(width: 12),
                Expanded(child: Text(l.hideZeroBalances, style: t.body)),
                Switch(value: _hideZero, onChanged: (v) => setState(() => _hideZero = v)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          RowsCard(
            children: [
              for (final a in coins)
                InkWell(
                  onTap: () => context.pushNamed(AppRoute.qcoin.name, pathParameters: {'coin': a.id}),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        AssetBadge(a, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.id, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                reservedInOrders(orders, a.id) > Decimal.zero
                                    ? '${a.name} · ${reservedInOrders(orders, a.id)} ${l.inOpenOrders.toLowerCase()}'
                                    : a.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.caption.copyWith(color: c.muted),
                              ),
                            ],
                          ),
                        ),
                        RowAmount(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                ((balances?.qtyOf(a.id) ?? Decimal.zero) + reservedInOrders(orders, a.id))
                                    .toStringAsFixed(a.unit.decimals == 2 ? 2 : 6),
                                style: t.num.copyWith(fontSize: 14),
                              ),
                              if (quotes?[a.id] != null)
                                MoneyText(
                                  Money(
                                    quotes![a.id]!.price *
                                        ((balances?.qtyOf(a.id) ?? Decimal.zero) + reservedInOrders(orders, a.id)),
                                    Currency.ngn,
                                  ).rounded(),
                                  decimals: 0,
                                  style: t.caption.copyWith(color: c.muted),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Auto-swap incoming crypto deposits into a stable target.
class AutoSwapScreen extends ConsumerWidget {
  const AutoSwapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final target = ref.watch(autoSwapTargetProvider).value;
    final repo = ref.read(cryptoRepositoryProvider);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.autoSwapDeposits),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          Text(
            l.autoSwapIntro,
            style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
          ),
          const SizedBox(height: 16),
          JCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const JarinaIcon(JIcon.auto),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.autoSwap, style: t.body),
                        Text(
                          target == null ? l.convertNewDepositsAutomatically : l.autoSwapOn(target),
                          style: t.caption.copyWith(color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Switch(value: target != null, onChanged: (on) => unawaited(repo.setAutoSwap(on ? 'NGN' : null))),
                ],
              ),
            ),
          ),
          if (target != null) ...[
            const SizedBox(height: 16),
            Text(
              l.convertTo,
              style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
            ),
            const SizedBox(height: 8),
            JSegmented<String>(
              segments: const {'NGN': 'NGN', 'USDT': 'USDT', 'USDC': 'USDC'},
              value: target,
              onChanged: (v) => unawaited(repo.setAutoSwap(v)),
            ),
          ],
          const SizedBox(height: 14),
          JNote(text: l.autoSwapNote),
        ],
      ),
    );
  }
}

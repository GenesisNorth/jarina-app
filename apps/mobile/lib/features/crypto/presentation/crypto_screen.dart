import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/crypto/application/crypto_state.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/crypto/presentation/notifications_screen.dart';
import 'package:jarina/features/home/presentation/app_drawer.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Crypto tab: portfolio, holdings, services and shortcuts.
class CryptoScreen extends ConsumerWidget {
  const CryptoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final portfolio = ref.watch(portfolioProvider).value;
    final transfers = ref.watch(cryptoTransfersProvider).value ?? const <CryptoTransfer>[];
    final orders = ref.watch(cryptoOrdersProvider).value ?? const <LimitOrder>[];
    final autoSwap = ref.watch(autoSwapTargetProvider).value;
    final unread = ref.watch(unreadNotificationsProvider);
    final usdt = portfolio?.holdings.where((h) => h.asset.id == 'USDT').firstOrNull;

    final holdings =
        portfolio?.holdings.where((h) => !h.asset.isStock && h.asset.id != 'USDT').toList() ?? const <Holding>[];
    final spark = <double>[];
    var change = Money.zero(Currency.ngn);
    for (final h in portfolio?.holdings.where((h) => !h.asset.isStock) ?? const <Holding>[]) {
      change += Money((h.quote.price - h.asset.openPrice) * h.quantity, Currency.ngn).rounded();
      final q = h.quantity.toDouble();
      for (var i = 0; i < h.quote.intraday.length; i++) {
        if (spark.length <= i) spark.add(0);
        spark[i] += h.quote.intraday[i] * q;
      }
    }
    final value = portfolio?.crypto ?? Money.zero(Currency.ngn);
    final base = value - change;
    final pct = base.isZero ? 0.0 : change.amount.toDouble() / base.amount.toDouble() * 100;
    final up = change.amount >= Decimal.zero;
    final pending = transfers
        .where((x) => x.status == TransferStatus.confirming || x.status == TransferStatus.processing)
        .length;
    final open = orders.where((o) => o.status == OrderStatus.open || o.status == OrderStatus.partiallyFilled).length;

    void push(AppRoute r, {Map<String, String> query = const {}}) => context.pushNamed(r.name, queryParameters: query);

    final services = <(JIcon, String, VoidCallback)>[
      (JIcon.swap, l.swap, () => push(AppRoute.qswap)),
      (JIcon.stocks, l.proTrade, () => push(AppRoute.qpro)),
      (JIcon.receive, l.deposit2, () => context.pushNamed(AppRoute.qcoin.name, pathParameters: {'coin': 'USDT'})),
      (JIcon.send, l.withdraw, () => push(AppRoute.qwd, query: {'coin': 'USDT'})),
      (JIcon.bank, l.cashOut, () => push(AppRoute.qcashout)),
      (JIcon.wallet, l.wallets, () => push(AppRoute.qwallets)),
      (JIcon.doc, l.orders, () => push(AppRoute.qorders)),
      (JIcon.key, l.borrow, () => push(AppRoute.qloan)),
    ];

    Widget link(JIcon icon, String title, String? trailing, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(10)),
              child: Center(child: JarinaIcon(icon, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: t.body)),
            if (trailing != null)
              Text(
                trailing,
                style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
              ),
            const SizedBox(width: 6),
            Transform.flip(flipX: true, child: JarinaIcon(JIcon.back, size: 16, color: c.muted)),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(header: true, child: Text(l.crypto, style: t.largeTitle)),
                ),
                JIconButton(icon: JIcon.menu, semanticLabel: l.menu, onPressed: () => showAppDrawer(context)),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: c.up, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(l.trading247, style: t.caption.copyWith(color: c.muted, fontSize: 13)),
                ),
              ],
            ),
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
                            Text(l.cryptoPortfolioValue, style: t.caption.copyWith(color: c.muted, fontSize: 13)),
                            const SizedBox(height: 6),
                            MoneyText(value, decimals: 0, style: t.amountL.copyWith(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(
                              l.cryptoPortfolioChange(
                                '${MoneyFormat.format(change, decimals: 0, signed: true)} (${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%)',
                              ),
                              style: t.caption.copyWith(color: up ? c.up : c.down, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (spark.length > 1) JSparkline(values: spark, color: c.goldDeep, width: 90, height: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: JButton(
                          label: l.buy,
                          height: 50,
                          onPressed: () => push(AppRoute.picker, query: {'kind': 'crypto'}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: JButton(
                          label: l.sell,
                          height: 50,
                          variant: JButtonVariant.soft,
                          onPressed: () => push(AppRoute.picker, query: {'kind': 'crypto', 'side': 'sell'}),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            JSectionHeader(title: l.yourHoldings, trailing: l.coinsCount('${holdings.length}')),
            if (holdings.isEmpty)
              JCard(
                child: Text(l.noHoldings, style: t.body.copyWith(color: c.muted)),
              )
            else
              RowsCard(children: [for (final h in holdings) HoldingRow(holding: h)]),
            JSectionHeader(title: l.cryptoServices),
            JCard(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Fixed height (circle + label, growing with the text size) so
                // narrow phones don't squeeze the cells.
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 74 + MediaQuery.textScalerOf(context).scale(13) * 1.4 * 2,
                ),
                children: [
                  for (final (icon, label, onTap) in services) JActionButton(icon: icon, label: label, onTap: onTap),
                ],
              ),
            ),
            const SizedBox(height: 14),
            RowsCard(
              children: [
                link(JIcon.plus, l.buyWithBankCardOrMomo, null, () => push(AppRoute.qbuy)),
                link(
                  JIcon.activity,
                  l.depositsWithdrawals,
                  pending > 0 ? l.pendingCount('$pending') : null,
                  () => push(AppRoute.qhist),
                ),
                link(JIcon.doc, l.openOrders, '$open', () => push(AppRoute.qorders)),
                link(
                  JIcon.auto,
                  l.cryptoAutopilot,
                  null,
                  () => push(AppRoute.autopilot, query: const {'type': 'crypto'}),
                ),
                link(
                  JIcon.auto,
                  l.autoSwapDeposits,
                  autoSwap == null ? l.offLabel : l.onLabel,
                  () => push(AppRoute.qauto),
                ),
                link(
                  JIcon.bell,
                  l.notifications,
                  unread > 0 ? l.newCount('$unread') : null,
                  () => push(AppRoute.qnotif),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (usdt != null)
              JCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: InkWell(
                  onTap: () => push(AppRoute.usdt),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        AssetBadge(usdt.asset),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.usdtWallet, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                'TRC-20 · BEP-20 · ERC-20 · SPL',
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
                              MoneyText(Money(usdt.quantity, usdt.asset.unit), style: t.num),
                              MoneyText(usdt.value, decimals: 0, style: t.caption.copyWith(color: c.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

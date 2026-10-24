import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina/features/wallets/presentation/wallet_card.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// One home-currency wallet: balance, actions, funding rails, other wallets,
/// and this wallet's transactions.
class FiatWalletScreen extends ConsumerWidget {
  const FiatWalletScreen({required this.currency, super.key});

  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final info = FiatWalletInfo.of(currency);
    final balances = ref.watch(balancesProvider).value;
    final fx = ref.watch(fxRatesProvider).value;
    final txs = (ref.watch(activityProvider).value ?? const <Transaction>[])
        .where((tx) => tx.amount.currency == currency)
        .toList();
    final balance = balances?.fiatOf(currency) ?? Money.zero(currency);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: JCircleButton(icon: JIcon.arrowLeft, semanticLabel: l.back, onPressed: () => context.pop()),
        ),
        title: Text(l.walletOf(walletShortName(l, currency))),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 40),
        children: [
          JBrandCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currencyName(l, currency),
                        style: t.body.copyWith(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currency.code,
                        style: t.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MoneyText(balance, style: t.amountL.copyWith(color: Colors.white, fontSize: 34)),
                const SizedBox(height: 10),
                if (currency == Currency.ngn || fx == null)
                  Text(l.countryName(info.countryIso), style: t.caption.copyWith(color: Colors.white70, fontSize: 13))
                else
                  Text(
                    '≈ ${MoneyFormat.format(fx.convert(balance, Currency.ngn), decimals: 0)} · '
                    '1 ${currency.code} = ${MoneyFormat.format(fx.convert(Money.parse('1', currency), Currency.ngn))}',
                    style: t.caption.copyWith(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: JActionButton(
                  icon: JIcon.send,
                  label: l.transfer,
                  onTap: () => context.goNamed(AppRoute.transfer.name),
                ),
              ),
              Expanded(
                child: JActionButton(
                  icon: JIcon.receive,
                  label: l.receive,
                  onTap: () => context.pushNamed(AppRoute.fiatadd.name, pathParameters: {'currency': currency.code}),
                ),
              ),
              Expanded(
                child: JActionButton(
                  icon: JIcon.swap,
                  label: l.convert,
                  onTap: () => context.pushNamed(AppRoute.convert.name, queryParameters: {'from': currency.code}),
                ),
              ),
              Expanded(
                child: JActionButton(
                  icon: JIcon.activity,
                  label: l.history,
                  onTap: () => context.goNamed(AppRoute.activity.name),
                ),
              ),
            ],
          ),
          JSectionHeader(title: l.usedIn),
          JCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.countryName(info.countryIso), style: t.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l.fundWith(info.rails.join(' · ')), style: t.caption.copyWith(color: c.muted, height: 1.4)),
              ],
            ),
          ),
          JSectionHeader(title: l.otherWallets),
          RowsCard(
            children: [
              for (final w in FiatWalletInfo.all.where((w) => w.currency != currency))
                InkWell(
                  onTap: () =>
                      context.pushReplacementNamed(AppRoute.fiat.name, pathParameters: {'currency': w.currency.code}),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.gold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              w.currency.code,
                              style: t.caption.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(walletShortName(l, w.currency), style: t.body.copyWith(fontWeight: FontWeight.w600)),
                              Text(currencyName(l, w.currency), style: t.caption.copyWith(color: c.muted)),
                            ],
                          ),
                        ),
                        RowAmount(
                          child: MoneyText(
                            balances?.fiatOf(w.currency) ?? Money.zero(w.currency),
                            style: t.num.copyWith(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Transform.flip(flipX: true, child: JarinaIcon(JIcon.back, size: 16, color: c.muted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          JSectionHeader(title: l.transactionHistory),
          if (txs.isEmpty)
            JCard(
              child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
            )
          else
            RowsCard(children: [for (final tx in txs) ActivityRow(tx: tx)]),
        ],
      ),
    );
  }
}

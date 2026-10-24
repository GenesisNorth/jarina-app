import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/home/presentation/app_drawer.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina/features/wallets/presentation/wallet_card.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _Filter { all, currency, crypto }

/// All wallets: four home-currency wallets and every crypto wallet.
class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final balances = ref.watch(balancesProvider).value;
    final fx = ref.watch(fxRatesProvider).value;
    final catalog = ref.watch(catalogProvider).value;
    final quotes = ref.watch(quotesProvider).value;
    final portfolio = ref.watch(portfolioProvider).value;

    final coins = catalog?.values.where((a) => !a.isStock).toList() ?? const <AssetInfo>[];
    final cryptoTotal = portfolio?.crypto ?? Money.zero(Currency.ngn);
    final cashTotal = portfolio?.cash ?? Money.zero(Currency.ngn);
    final all = cashTotal + cryptoTotal;
    final share = all.isZero ? 0.0 : cashTotal.amount.toDouble() / all.amount.toDouble();

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
                  child: Semantics(header: true, child: Text(l.wallets, style: t.largeTitle)),
                ),
                JIconButton(icon: JIcon.menu, semanticLabel: l.menu, onPressed: () => showAppDrawer(context)),
              ],
            ),
            const SizedBox(height: 14),
            JBrandCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.allWallets.toUpperCase(),
                    style: t.caption.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MoneyText(all, decimals: 0, style: t.amountL.copyWith(color: Colors.white, fontSize: 30)),
                  Divider(height: 24, color: Colors.white.withValues(alpha: 0.12)),
                  Row(
                    children: [
                      _Split(label: l.currencyWallets, value: cashTotal, dot: Colors.white),
                      _Split(label: l.cryptoWallets, value: cryptoTotal, dot: BrandColors.gold),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (share * 1000).round().clamp(1, 999),
                          child: Container(height: 5, color: Colors.white),
                        ),
                        Expanded(
                          flex: ((1 - share) * 1000).round().clamp(1, 999),
                          child: Container(height: 5, color: BrandColors.gold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: c.gold.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: c.gold.withValues(alpha: 0.4)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.pushNamed(AppRoute.p2p.name),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: c.black, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: JarinaIcon(JIcon.send, size: 18, color: BrandColors.gold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.p2pTransfer, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                            Text(l.p2pTransferSub, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                          ],
                        ),
                      ),
                      Transform.flip(flipX: true, child: JarinaIcon(JIcon.back, size: 18, color: c.muted)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            JSegmented<_Filter>(
              segments: {_Filter.all: l.all, _Filter.currency: l.currencyLabel, _Filter.crypto: l.crypto},
              value: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            if (_filter != _Filter.crypto) ...[
              JSectionHeader(title: l.currencyWallets, trailing: '${FiatWalletInfo.all.length}'),
              RowsCard(
                children: [
                  for (final w in FiatWalletInfo.all)
                    _WalletRow(
                      leading: JFlag.fromIso(w.countryIso) == null
                          ? const SizedBox(width: 40)
                          : ClipOval(
                              child: SizedBox.square(
                                dimension: 40,
                                child: JarinaFlag(JFlag.fromIso(w.countryIso)!, width: 60),
                              ),
                            ),
                      title: l.walletOf(walletShortName(l, w.currency)),
                      subtitle: currencyName(l, w.currency),
                      value: balances?.fiatOf(w.currency) ?? Money.zero(w.currency),
                      ngn: fx == null || w.currency == Currency.ngn || balances == null
                          ? null
                          : fx.convert(balances.fiatOf(w.currency), Currency.ngn),
                      onTap: () => context.pushNamed(AppRoute.fiat.name, pathParameters: {'currency': w.currency.code}),
                    ),
                ],
              ),
            ],
            if (_filter != _Filter.currency) ...[
              JSectionHeader(title: l.cryptoWallets, trailing: '${coins.length}'),
              RowsCard(
                children: [
                  for (final a in coins)
                    _WalletRow(
                      leading: AssetBadge(a, size: 36),
                      title: a.name,
                      subtitle: l.walletOf(a.id),
                      value: Money(balances?.qtyOf(a.id) ?? Decimal.zero, a.unit),
                      ngn: quotes?[a.id] == null || balances == null
                          ? null
                          : Money(quotes![a.id]!.price * balances.qtyOf(a.id), Currency.ngn).rounded(),
                      onTap: () => context.pushNamed(AppRoute.qcoin.name, pathParameters: {'coin': a.id}),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Split extends StatelessWidget {
  const _Split({required this.label, required this.value, required this.dot});

  final String label;
  final Money value;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: t.caption.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          MoneyText(value, decimals: 0, style: t.num.copyWith(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
    this.ngn,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Money value;
  final Money? ngn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.caption.copyWith(color: c.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RowAmount(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(value, style: t.num.copyWith(fontSize: 14)),
                  if (ngn != null)
                    MoneyText(ngn!, decimals: 0, style: t.caption.copyWith(color: c.muted, fontSize: 12))
                  else
                    const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Transform.flip(flipX: true, child: JarinaIcon(JIcon.back, size: 16, color: c.muted)),
          ],
        ),
      ),
    );
  }
}

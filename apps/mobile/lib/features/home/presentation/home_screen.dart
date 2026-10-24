import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/chart_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/home/presentation/app_drawer.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina/features/wallets/presentation/wallet_card.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Dashboard: total balance, quick actions, wallets, assets and activity.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final portfolio = ref.watch(portfolioProvider);
    final balances = ref.watch(balancesProvider).value;
    final activity = ref.watch(activityProvider).value ?? const [];
    final profile = ref.watch(profileProvider).value;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: c.goldDeep,
          onRefresh: () async {
            ref
              ..invalidate(balancesProvider)
              ..invalidate(activityProvider);
            await ref.read(balancesProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(header: true, child: Text(l.dashboard, style: t.largeTitle)),
                  ),
                  JIconButton(
                    icon: JIcon.bell,
                    badge: true,
                    semanticLabel: l.notifications,
                    onPressed: () => context.pushNamed(AppRoute.qnotif.name),
                  ),
                  JIconButton(icon: JIcon.menu, semanticLabel: l.menu, onPressed: () => showAppDrawer(context)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: c.black,
                    child: Text(
                      profile?.initials ?? '',
                      style: t.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _greeting(l, profile?.firstName ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                  ),
                  if (profile != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.up.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JarinaIcon(JIcon.shield, size: 12, color: c.up),
                          const SizedBox(width: 4),
                          Text(
                            profile.tier == 2 ? l.tier2 : '${l.tier} ${profile.tier}',
                            style: t.caption.copyWith(color: c.up, fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              switch (portfolio) {
                AsyncData(:final value) => _BalanceCard(portfolio: value),
                AsyncError() => _ErrorCard(onRetry: () => ref.invalidate(balancesProvider)),
                _ => const _LoadingCard(height: 196),
              },
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: JActionButton(
                      icon: JIcon.plus,
                      label: l.addMoney,
                      onTap: () => context.pushNamed(AppRoute.fiatadd.name, pathParameters: {'currency': 'NGN'}),
                    ),
                  ),
                  Expanded(
                    child: JActionButton(
                      icon: JIcon.send,
                      label: l.send,
                      onTap: () => context.goNamed(AppRoute.transfer.name),
                    ),
                  ),
                  Expanded(
                    child: JActionButton(
                      icon: JIcon.stocks,
                      label: l.buy,
                      onTap: () => context.pushNamed(AppRoute.picker.name),
                    ),
                  ),
                  Expanded(
                    child: JActionButton(
                      icon: JIcon.bolt,
                      label: l.payBills,
                      onTap: () => context.pushNamed(AppRoute.bill.name, pathParameters: {'kind': 'airtime'}),
                    ),
                  ),
                ],
              ),
              JSectionHeader(title: l.wallets),
              SizedBox(
                height: 130,
                child: balances == null
                    ? const _LoadingCard(height: 130)
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: FiatWalletInfo.all.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final w = FiatWalletInfo.all[i];
                          return SizedBox(
                            width: 200,
                            child: WalletCard(
                              info: w,
                              balance: balances.fiatOf(w.currency),
                              tone: const [JCardTone.black, JCardTone.gold, JCardTone.white, JCardTone.black][i % 4],
                            ),
                          );
                        },
                      ),
              ),
              JSectionHeader(
                title: l.yourAssets,
                action: l.seeAll,
                onAction: () => context.goNamed(AppRoute.wallets.name),
              ),
              if (portfolio.value case final p?)
                RowsCard(children: [for (final h in p.holdings.take(6)) HoldingRow(holding: h)])
              else
                const _LoadingCard(height: 240),
              JSectionHeader(
                title: l.recentActivity,
                action: l.seeAll,
                onAction: () => context.goNamed(AppRoute.activity.name),
              ),
              if (activity.isEmpty)
                Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted))
              else
                RowsCard(children: [for (final tx in activity.take(3)) ActivityRow(tx: tx)]),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting(AppLocalizations l, String name) {
    final h = DateTime.now().hour;
    if (h < 12) return l.greetingMorning(name);
    if (h < 17) return l.greetingAfternoon(name);
    return l.greetingEvening(name);
  }
}

class _BalanceCard extends ConsumerStatefulWidget {
  const _BalanceCard({required this.portfolio});

  final Portfolio portfolio;

  @override
  ConsumerState<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<_BalanceCard> {
  ChartRange _range = ChartRange.month;

  Money _show(Money ngn, Currency to, FxRates? fx) => fx == null || to == Currency.ngn ? ngn : fx.convert(ngn, to);

  Future<void> _pickCurrency() async {
    final l = AppLocalizations.of(context);
    final current = ref.read(displayCurrencyProvider);
    final picked = await showModalBottomSheet<Currency>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text(l.displayCurrency, style: context.text.h2),
            ),
            for (final cur in Currency.fiats)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 22),
                title: Text(cur.code, style: context.text.body.copyWith(fontWeight: FontWeight.w600)),
                trailing: cur == current ? JarinaIcon(JIcon.check, color: context.colors.goldDeep) : null,
                onTap: () => Navigator.of(context).pop(cur),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) await ref.read(displayCurrencyProvider.notifier).set(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.text;
    final p = widget.portfolio;
    final cur = ref.watch(displayCurrencyProvider);
    final fx = ref.watch(fxRatesProvider).value;
    final hidden = ref.watch(hideBalancesProvider);
    final history = _range == ChartRange.day
        ? p.history
        : ref.watch(portfolioHistoryProvider(_range)).value ?? p.history;
    final total = _show(p.total, cur, fx);
    const white = Colors.white;
    final muted = white.withValues(alpha: 0.65);

    Widget chip(String label, {required VoidCallback onTap, bool gold = false}) => Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gold ? BrandColors.gold : white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: t.caption.copyWith(color: gold ? BrandColors.black : white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );

    Widget part(String label, Color dot, Money ngn) => Expanded(
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
                  style: t.caption.copyWith(color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          MoneyText(
            _show(ngn, cur, fx),
            decimals: 0,
            style: t.num.copyWith(color: white, fontSize: 14),
          ),
        ],
      ),
    );

    return JBrandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  l.totalBalance,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.caption.copyWith(color: muted, fontSize: 13),
                ),
              ),
              IconButton(
                tooltip: hidden ? l.showBalances : l.hideBalances,
                visualDensity: VisualDensity.compact,
                onPressed: () => unawaited(ref.read(hideBalancesProvider.notifier).toggle()),
                icon: JarinaIcon(JIcon.eye, size: 16, color: muted),
              ),
              const Spacer(),
              chip(
                rangeLabel(AppLocalizations.of(context), _range),
                gold: true,
                onTap: () => setState(() => _range = ChartRange.values[(_range.index + 1) % ChartRange.values.length]),
              ),
              const SizedBox(width: 6),
              chip('${cur.code} ▾', onTap: _pickCurrency),
            ],
          ),
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: MoneyText(
              total,
              decimals: wholeFor(total),
              style: t.amountL.copyWith(color: white, fontSize: 32),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MoneyText(
                _show(p.dayChange, cur, fx),
                signed: true,
                decimals: 0,
                style: t.num.copyWith(color: BrandColors.gold, fontSize: 13),
              ),
              JChangePill(percent: p.dayChangePct, onDark: true),
              Text(l.today, style: t.caption.copyWith(color: muted)),
            ],
          ),
          const SizedBox(height: 8),
          JAreaChart(values: history, color: BrandColors.gold, height: 56),
          Divider(height: 22, color: white.withValues(alpha: 0.12)),
          Row(
            children: [
              part(l.cash, white, p.cash),
              part(l.stocks, BrandColors.gold, p.stocks),
              part(l.crypto, white.withValues(alpha: 0.5), p.crypto),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(color: context.colors.fill, borderRadius: BorderRadius.circular(RadiusTokens.card)),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return JCard(
      child: Column(
        children: [
          Text(l.errGeneric, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          JButton(label: l.tryAgain, variant: JButtonVariant.soft, onPressed: onRetry),
        ],
      ),
    );
  }
}

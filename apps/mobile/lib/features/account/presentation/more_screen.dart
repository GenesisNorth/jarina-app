import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/app/widgets/settings_widgets.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/automation/application/automation_state.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/home/presentation/app_drawer.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Native names for the languages the app ships.
const languageNames = {'en': 'English', 'ha': 'Harshen Hausa', 'fr': 'Français'};

/// Asks, then signs out and clears the session from secure storage.
Future<void> confirmLogOut(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.logOutQuestion),
      content: Text(l.logOutBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.logOut2)),
      ],
    ),
  );
  if (ok != true) return;
  await ref.read(authRepositoryProvider).logout();
  await ref.read(sessionProvider.notifier).signOut();
}

/// More tab: profile, bills, P2P, trading tools, account and settings.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final profile = ref.watch(profileProvider).value;
    final catalog = ref.watch(catalogProvider).value ?? const <String, AssetInfo>{};
    final rules = ref.watch(autopilotRulesProvider).value ?? const <AutopilotRule>[];
    final alerts = ref.watch(priceAlertsProvider).value ?? const <PriceAlert>[];
    final activity = ref.watch(activityProvider).value ?? const [];
    final usdt = ref.watch(balancesProvider).value?.qtyOf('USDT') ?? Decimal.zero;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    int active(AssetKind k) => rules.where((r) => r.enabled && catalog[r.assetId]?.kind == k).length;
    final walletCount = Currency.homeCurrencies.length + catalog.values.where((a) => !a.isStock).length;

    void push(AppRoute r, [Map<String, String> query = const {}]) =>
        unawaited(context.pushNamed(r.name, queryParameters: query));

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
                  child: Semantics(header: true, child: Text(l.more, style: t.largeTitle)),
                ),
                JIconButton(icon: JIcon.menu, semanticLabel: l.menu, onPressed: () => showAppDrawer(context)),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: c.card,
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => push(AppRoute.account),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: c.black,
                        child: Text(
                          profile?.initials ?? '',
                          style: t.title.copyWith(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.title.copyWith(fontSize: 18),
                            ),
                            Text(
                              l.accountWithPhone(formatPhone(profile?.phoneE164)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.caption.copyWith(color: c.muted),
                            ),
                            const SizedBox(height: 4),
                            if (profile != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: c.up.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    JarinaIcon(JIcon.shield, size: 12, color: c.up),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        l.verifiedTier('${profile.tier}'),
                                        style: t.caption.copyWith(
                                          color: c.up,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      JarinaIcon(JIcon.chev, size: 14, color: c.muted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            JSectionHeader(title: l.payBills),
            const SizedBox(height: 10),
            JCard(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Row(
                children: [
                  for (final (icon, label, kind) in [
                    (JIcon.airtime, l.airtime, 'airtime'),
                    (JIcon.data, l.data, 'data'),
                    (JIcon.cable, l.cableTv, 'cable'),
                    (JIcon.bolt, l.electricity, 'electricity'),
                  ])
                    Expanded(
                      child: JActionButton(
                        icon: icon,
                        label: label,
                        onTap: () => unawaited(context.pushNamed(AppRoute.bill.name, pathParameters: {'kind': kind})),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: c.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => push(AppRoute.p2p),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: c.black, borderRadius: BorderRadius.circular(12)),
                        child: JarinaIcon(JIcon.user, size: 20, color: c.gold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.p2pRowTitle, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                            Text(l.p2pRowSub, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                          ],
                        ),
                      ),
                      JarinaIcon(JIcon.chev, size: 14, color: c.muted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            RowsCard(
              children: [
                SettingsRow(
                  icon: JIcon.activity,
                  title: l.activity,
                  value: l.transactionsCount('${activity.length}'),
                  onTap: () => context.goNamed(AppRoute.activity.name),
                ),
                SettingsRow(
                  icon: JIcon.wallet,
                  title: l.wallets,
                  value: l.walletsCount('$walletCount'),
                  onTap: () => context.goNamed(AppRoute.wallets.name),
                ),
              ],
            ),
            const SizedBox(height: 22),
            JSectionHeader(title: l.tradingTools),
            const SizedBox(height: 10),
            RowsCard(
              children: [
                SettingsRow(
                  icon: JIcon.auto,
                  title: l.stockAutopilot,
                  value: l.activeCount('${active(AssetKind.stock)}'),
                  onTap: () => push(AppRoute.autopilot, {'type': 'stock'}),
                ),
                SettingsRow(
                  icon: JIcon.auto,
                  title: l.cryptoAutopilot,
                  value: l.activeCount('${active(AssetKind.crypto)}'),
                  onTap: () => push(AppRoute.autopilot, {'type': 'crypto'}),
                ),
                SettingsRow(
                  icon: JIcon.bell,
                  title: l.priceAlerts,
                  value: l.activeCount('${alerts.where((a) => a.enabled).length}'),
                  onTap: () => push(AppRoute.alerts),
                ),
                SettingsRow(
                  icon: JIcon.wallet,
                  title: l.usdtWallet,
                  value: MoneyFormat.format(Money(usdt, const Currency.crypto('USDT', decimals: 2)), decimals: 2),
                  onTap: () => push(AppRoute.usdt),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RowsCard(
              children: [
                SettingsRow(icon: JIcon.user, title: l.accountProfile, onTap: () => push(AppRoute.account)),
                SettingsRow(
                  icon: JIcon.shield,
                  title: l.security2fa,
                  value: l.onLabel,
                  onTap: () => push(AppRoute.account),
                ),
                SettingsRow(
                  icon: JIcon.globe,
                  title: l.language,
                  value: languageNames[lang],
                  onTap: () => push(AppRoute.language),
                ),
                SettingsRow(
                  icon: dark ? JIcon.moon : JIcon.sun,
                  title: l.darkMode,
                  trailing: Switch(
                    value: dark,
                    onChanged: (v) => unawaited(
                      ref.read(themeModeSettingProvider.notifier).set(v ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                ),
                SettingsRow(icon: JIcon.help, title: l.helpSupport, value: l.chat, onTap: () => push(AppRoute.chat)),
              ],
            ),
            const SizedBox(height: 14),
            RowsCard(
              children: [
                SettingsRow(
                  icon: JIcon.logout,
                  title: l.logOut2,
                  danger: true,
                  onTap: () => unawaited(confirmLogOut(context, ref)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

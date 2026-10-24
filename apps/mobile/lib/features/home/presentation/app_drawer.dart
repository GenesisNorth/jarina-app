import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Full-screen dark menu opened from the ☰ button on the tab screens.
Future<void> showAppDrawer(BuildContext context) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  transitionDuration: const Duration(milliseconds: 260),
  pageBuilder: (_, _, _) => const _AppDrawer(),
  transitionBuilder: (_, anim, _, child) => SlideTransition(
    position: Tween(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  ),
);

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.text;
    final profile = ref.watch(profileProvider).value;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const white = Colors.white;

    void open(
      AppRoute r, {
      Map<String, String> params = const {},
      Map<String, String> query = const {},
      bool tab = false,
    }) {
      Navigator.of(context).pop();
      if (tab) {
        context.goNamed(r.name);
      } else {
        unawaited(context.pushNamed(r.name, pathParameters: params, queryParameters: query));
      }
    }

    final items = <(String, VoidCallback)>[
      (l.dashboard, () => open(AppRoute.home, tab: true)),
      (l.stocks, () => open(AppRoute.stocks, tab: true)),
      (l.crypto, () => open(AppRoute.crypto, tab: true)),
      (l.stockAutopilot, () => open(AppRoute.autopilot, query: const {'type': 'stock'})),
      (l.cryptoAutopilot, () => open(AppRoute.autopilot, query: const {'type': 'crypto'})),
      (l.priceAlerts, () => open(AppRoute.alerts)),
      (l.wallets, () => open(AppRoute.wallets, tab: true)),
      (l.activity, () => open(AppRoute.activity, tab: true)),
      (l.usdtWallet, () => open(AppRoute.usdt)),
      (l.payBills, () => open(AppRoute.bill, params: {'kind': 'airtime'})),
    ];

    return Material(
      color: BrandColors.black,
      child: JPattern(
        opacity: 0.06,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset('packages/jarina_ui/assets/logo/jarina-logo-white-text.png', height: 40),
                    const Spacer(),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const JarinaIcon(JIcon.x, color: BrandColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      for (final (label, onTap) in items)
                        InkWell(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Text(
                              label,
                              style: t.title.copyWith(color: white, fontWeight: FontWeight.w500, fontSize: 22),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: white,
                            minimumSize: const Size(0, 44),
                            side: BorderSide(color: white.withValues(alpha: 0.3)),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () =>
                              ref.read(themeModeSettingProvider.notifier).set(dark ? ThemeMode.light : ThemeMode.dark),
                          icon: JarinaIcon(dark ? JIcon.sun : JIcon.moon, size: 18, color: white),
                          label: Text(l.darkMode, style: t.body.copyWith(color: white, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: white.withValues(alpha: 0.15)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: white,
                        child: Text(
                          profile?.initials ?? '',
                          style: t.body.copyWith(fontWeight: FontWeight.w700, color: BrandColors.black),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? '',
                              style: t.body.copyWith(color: white, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '@${profile?.username ?? ''}',
                              style: t.caption.copyWith(color: white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await ref.read(authRepositoryProvider).logout();
                          await ref.read(sessionProvider.notifier).signOut();
                        },
                        child: Text(
                          l.logOut.toUpperCase(),
                          style: t.caption.copyWith(color: white, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

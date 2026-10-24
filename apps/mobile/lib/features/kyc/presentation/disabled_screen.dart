import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Account limited: 2FA is off, so money-moving screens are blocked.
class DisabledScreen extends StatelessWidget {
  const DisabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;

    Widget row(String text, {required bool allowed}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          JarinaIcon(allowed ? JIcon.check : JIcon.lock, size: 18, color: allowed ? c.up : c.down),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: t.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );

    return JFlowScaffold(
      onBack: () => context.canPop() ? context.pop() : context.go(AppRoute.home.path),
      backLabel: l.back,
      centerBody: true,
      bottom: JButton(label: l.turnOn2fa, icon: JIcon.shield, onPressed: () => context.go(AppRoute.kyc6.path)),
      children: [
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: c.down.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(22)),
            child: Center(child: JarinaIcon(JIcon.lock, size: 32, color: c.down)),
          ),
        ),
        const SizedBox(height: 22),
        Semantics(
          header: true,
          child: Text(l.accountDisabled, textAlign: TextAlign.center, style: t.title.copyWith(fontSize: 26)),
        ),
        const SizedBox(height: 10),
        Text(
          l.turnOnTwoFactorAuthenticationTo2,
          textAlign: TextAlign.center,
          style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
        ),
        const SizedBox(height: 22),
        JCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Column(
            children: [
              row(l.viewBalancesAndPrices, allowed: true),
              Divider(color: c.line),
              row(l.receiveMoney, allowed: true),
              Divider(color: c.line),
              row(l.sendTradeWithdrawAndPayBills, allowed: false),
            ],
          ),
        ),
      ],
    );
  }
}

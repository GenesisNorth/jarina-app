import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Short wallet name: Naira, Cedi, CFA · XOF, CFA · XAF.
String walletShortName(AppLocalizations l, Currency c) => switch (c.code) {
  'NGN' => 'Naira',
  'GHS' => 'Cedi',
  _ => 'CFA · ${c.code}',
};

/// Long currency name: Nigerian naira, Ghanaian cedi…
String currencyName(AppLocalizations l, Currency c) => switch (c.code) {
  'NGN' => l.nigerianNaira,
  'GHS' => l.ghanaianCedi,
  'XOF' => l.westAfricanCfaFranc,
  'XAF' => l.centralAfricanCfaFranc,
  _ => c.code,
};

/// Home-currency wallet tile in the Home carousel.
class WalletCard extends StatelessWidget {
  const WalletCard({required this.info, required this.balance, required this.tone, super.key});

  final FiatWalletInfo info;
  final Money balance;
  final JCardTone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.text;
    final ink = JBrandCard.inkOn(tone);
    return Semantics(
      button: true,
      label: walletShortName(l, info.currency),
      child: JBrandCard(
        tone: tone,
        padding: const EdgeInsets.all(14),
        onTap: () => context.pushNamed(AppRoute.fiat.name, pathParameters: {'currency': info.currency.code}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    walletShortName(l, info.currency),
                    style: t.body.copyWith(color: ink, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                JarinaIcon(JIcon.wallet, size: 16, color: ink.withValues(alpha: 0.8)),
              ],
            ),
            const Spacer(),
            MoneyText(balance, style: t.title.copyWith(color: ink, fontSize: 21)),
            const SizedBox(height: 2),
            Text(
              '${info.currency.code} · ${l.countryName(info.countryIso)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.caption.copyWith(color: ink.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

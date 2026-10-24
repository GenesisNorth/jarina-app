import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina/features/wallets/presentation/wallet_card.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Add money: the user's dedicated account details for this currency.
class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({required this.currency, super.key});

  final Currency currency;

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  late Future<Result<FundingAccount>> _account = ref.read(walletRepositoryProvider).fundingAccount(widget.currency);
  bool _busy = false;

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) showToast(context, AppLocalizations.of(context).copied);
  }

  Future<void> _simulate() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final amount = Money.parse(widget.currency == Currency.ghs ? '500' : '50000', widget.currency);
    final r = await ref.read(walletRepositoryProvider).simulateDeposit(amount);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(ok: (_) => showToast(context, l.depositSimulated), err: (f) => showToast(context, l.failure(f)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final info = FiatWalletInfo.of(widget.currency);
    final testBuild = ref.watch(envProvider).useFakeData;

    Widget detail(String label, String value, {required bool last}) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: t.caption.copyWith(color: c.muted)),
                    const SizedBox(height: 2),
                    Text(value, style: t.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _copy(value),
                icon: JarinaIcon(JIcon.copy, size: 16, color: c.ink),
                label: Text(l.copy, style: t.body.copyWith(fontSize: 14)),
              ),
            ],
          ),
        ),
        if (!last) Divider(height: 1, color: c.line),
      ],
    );

    return JFlowScaffold(
      onBack: () => context.pop(),
      backLabel: l.back,
      bottom: testBuild
          ? JButton(
              label: '${l.simulateADeposit} · ${l.testBuildOnly}',
              variant: JButtonVariant.soft,
              loading: _busy,
              onPressed: _simulate,
            )
          : null,
      children: [
        JStepHeader(
          title: l.addCurrency(widget.currency.code),
          subtitle: l.fundCurrencyFrom(
            l.walletOf(walletShortName(l, widget.currency)),
            l.countryName(info.countryIso),
            info.rails.join(', ').toLowerCase(),
          ),
        ),
        const SizedBox(height: 18),
        FutureBuilder(
          future: _account,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const JCard(
                child: SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
              );
            }
            final account = snap.data?.valueOrNull;
            if (account == null) {
              return JCard(
                child: Column(
                  children: [
                    Text(l.errGeneric),
                    const SizedBox(height: 12),
                    JButton(
                      label: l.tryAgain,
                      variant: JButtonVariant.soft,
                      onPressed: () =>
                          setState(() => _account = ref.read(walletRepositoryProvider).fundingAccount(widget.currency)),
                    ),
                  ],
                ),
              );
            }
            final number = account.accountNumber;
            return JCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Column(
                children: [
                  detail(l.accountName, account.accountName, last: false),
                  detail(
                    l.accountNumber,
                    number.length == 10
                        ? '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}'
                        : number,
                    last: false,
                  ),
                  detail(l.bank, account.bankName, last: true),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        JNote(text: l.fundingNote, icon: JIcon.shield),
      ],
    );
  }
}

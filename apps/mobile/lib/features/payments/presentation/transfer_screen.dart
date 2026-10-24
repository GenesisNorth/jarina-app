import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/fake/fake_payments.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/payments/presentation/payments_widgets.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Wallets that can pay a transfer. Crypto is sold at the swap rate.
const _payFrom = ['NGN', 'USDT', 'BTC'];

/// Transfers tab (Home → Send): pay-from, keypad, transfer types,
/// beneficiaries and receive details.
class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  /// Keeps amounts to ₦999,999,999; the server enforces the real tier limits.
  static const _maxDigits = 9;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final draft = ref.watch(transferDraftProvider);
    final notifier = ref.read(transferDraftProvider.notifier);
    final balances = ref.watch(balancesProvider).value;
    final recipients = ref.watch(recipientsProvider).value ?? const <Recipient>[];
    final beneficiaries = [...recipients.where((r) => r.lastSent != null)];
    final digits = draft.amount == Decimal.zero ? '' : draft.amount.toString();

    void setDigits(String d) {
      final v = d.isEmpty ? Decimal.zero : Decimal.parse(d);
      notifier.setAmount(v);
    }

    void openPeople({bool bank = false}) => context.pushNamed(
      AppRoute.people.name,
      queryParameters: bank ? const {'bank': '1'} : const {},
    );
    void request() => context.pushNamed(
      AppRoute.p2p.name,
      queryParameters: {'mode': 'request', if (draft.amount > Decimal.zero) 'amount': '${draft.amount}'},
    );

    final wallet = switch (draft.from) {
      'NGN' => l.nairaWallet,
      final code => '$code · ${l.walletLabel}',
    };
    final balance = draft.from == 'NGN'
        ? balances?.fiatOf(Currency.ngn)
        : balances == null
        ? null
        : Money(balances.qtyOf(draft.from), Currency.crypto(draft.from, decimals: draft.from == 'USDT' ? 2 : 8));

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 120),
          children: [
            Row(
              children: [
                if (context.canPop())
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: JIconButton(icon: JIcon.back, semanticLabel: l.back, onPressed: context.pop),
                  ),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(l.transfers, style: t.largeTitle),
                    ),
                  ),
                ),
                JIconButton(
                  icon: JIcon.qr,
                  semanticLabel: l.receive,
                  onPressed: () => context.pushNamed(AppRoute.receive.name),
                ),
                JIconButton(
                  icon: JIcon.activity,
                  semanticLabel: l.activity,
                  onPressed: () => context.goNamed(AppRoute.activity.name),
                ),
              ],
            ),
            const SizedBox(height: 16),
            JBrandCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        l.payFrom.toUpperCase(),
                        style: t.caption.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _PayFromSwitch(
                          value: draft.from,
                          labels: {'NGN': l.naira, 'USDT': 'USDT', 'BTC': 'Bitcoin'},
                          onChanged: notifier.setFrom,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (balance == null)
                    const SizedBox(height: 40)
                  else
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: MoneyText(balance, style: t.amountL.copyWith(color: Colors.white)),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          wallet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.body.copyWith(color: Colors.white70, fontWeight: FontWeight.w400),
                        ),
                      ),
                      JarinaIcon(JIcon.shield, size: 14, color: c.up),
                      const SizedBox(width: 4),
                      Text(
                        l.verified,
                        style: t.caption.copyWith(color: c.up, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.amount.toUpperCase(),
                    style: t.caption.copyWith(color: c.muted, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Semantics(
                    liveRegion: true,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        MoneyFormat.format(Money(draft.amount, Currency.ngn), decimals: 0),
                        style: t.amountL.copyWith(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.enterAmountToSendOrRequest,
                    style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final k in const [1000, 5000, 10000, 50000])
                        JChip(
                          label: '+₦${k ~/ 1000}k',
                          onTap: () => notifier.setAmount(draft.amount + Decimal.fromInt(k)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  JKeypad(
                    backspaceLabel: l.delete,
                    extraKey: '000',
                    onExtra: () {
                      if (digits.isNotEmpty && digits.length + 3 <= _maxDigits) setDigits('${digits}000');
                    },
                    onDigit: (d) {
                      if (digits.length < _maxDigits && !(digits.isEmpty && d == '0')) setDigits('$digits$d');
                    },
                    onBackspace: () => setDigits(digits.isEmpty ? '' : digits.substring(0, digits.length - 1)),
                    onClear: () => setDigits(''),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: JButton(
                          label: l.request,
                          icon: JIcon.receive,
                          variant: JButtonVariant.soft,
                          onPressed: request,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: JButton(
                          label: l.send,
                          icon: JIcon.send,
                          onPressed: draft.amount > Decimal.zero ? openPeople : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            JSectionHeader(title: l.transferTo),
            const SizedBox(height: 10),
            _TypeGrid(
              tiles: [
                (JIcon.user, l.jarinaUser, l.p2pFreeInstant, () => context.pushNamed(AppRoute.p2p.name)),
                (
                  JIcon.bank,
                  l.bankAccount,
                  l.nipFee(MoneyFormat.format(FakePayments.nipFee, decimals: 0)),
                  () => openPeople(bank: true),
                ),
                (JIcon.globe, l.crossBorder, l.countriesCount('6'), openPeople),
                (JIcon.receive, l.request, l.askToBePaid, request),
              ],
            ),
            if (beneficiaries.isNotEmpty) ...[
              const SizedBox(height: 22),
              JSectionHeader(title: l.beneficiaries, action: l.seeAll, onAction: openPeople),
              const SizedBox(height: 10),
              RowsCard(
                children: [
                  for (final r in beneficiaries)
                    _BeneficiaryRow(
                      recipient: r,
                      onTap: () {
                        ref.read(selectedRecipientProvider.notifier).set(r);
                        context.pushNamed(AppRoute.payconfirm.name);
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 22),
            JSectionHeader(title: l.receiveMoney),
            const SizedBox(height: 10),
            LinkCard(
              leading: const _TileIcon(icon: JIcon.qr),
              title: l.receiveMoney,
              subtitle: l.receiveMoneySub,
              onTap: () => context.pushNamed(AppRoute.receive.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayFromSwitch extends StatelessWidget {
  const _PayFromSwitch({required this.value, required this.labels, required this.onChanged});

  final String value;
  final Map<String, String> labels;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in _payFrom)
            JTapTarget(
              selected: code == value,
              onTap: () => onChanged(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: code == value ? c.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  labels[code]!,
                  style: t.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: code == value ? c.black : Colors.white70,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final JIcon icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.black, borderRadius: BorderRadius.circular(12)),
      child: JarinaIcon(icon, size: 20, color: c.gold),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.tiles});

  final List<(JIcon, String, String, VoidCallback)> tiles;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    Widget tile((JIcon, String, String, VoidCallback) x) => Material(
      color: c.card,
      borderRadius: BorderRadius.circular(RadiusTokens.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        onTap: x.$4,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TileIcon(icon: x.$1),
              const SizedBox(height: 12),
              Text(
                x.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                x.$3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.caption.copyWith(color: c.muted),
              ),
            ],
          ),
        ),
      ),
    );
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tile(tiles[i])),
                const SizedBox(width: 10),
                Expanded(child: tile(tiles[i + 1])),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BeneficiaryRow extends StatelessWidget {
  const _BeneficiaryRow({required this.recipient, required this.onTap});

  final Recipient recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final r = recipient;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            PersonAvatar(name: r.name, color: r.avatarColor, countryIso: r.countryIso),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    recipientSubtitle(l, r),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.caption.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            if (r.lastSent != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(r.lastSent!, decimals: 0, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                  Text(l.lastSent, style: t.caption.copyWith(color: c.muted)),
                ],
              ),
            const SizedBox(width: 6),
            JarinaIcon(JIcon.chev, size: 14, color: c.muted),
          ],
        ),
      ),
    );
  }
}

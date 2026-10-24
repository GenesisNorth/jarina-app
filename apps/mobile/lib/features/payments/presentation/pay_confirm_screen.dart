import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/payments/presentation/payments_widgets.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/security/presentation/twofa_sheet.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Confirm a payment to the selected recipient. Cross-border shows what they
/// receive and the locked rate, and needs PIN + 2FA.
class PayConfirmScreen extends ConsumerStatefulWidget {
  const PayConfirmScreen({super.key});

  @override
  ConsumerState<PayConfirmScreen> createState() => _PayConfirmScreenState();
}

class _PayConfirmScreenState extends ConsumerState<PayConfirmScreen> {
  late final _amount = TextEditingController(text: _initialAmount());
  final _note = TextEditingController();
  Timer? _debounce;
  SendQuote? _quote;
  String? _error;
  bool _quoting = false;

  String _initialAmount() {
    final a = ref.read(transferDraftProvider).amount;
    return a > Decimal.zero ? GroupedDigitsFormatter.group(a.toString()) : '';
  }

  Decimal get _value => Decimal.tryParse(_amount.text.replaceAll(',', '')) ?? Decimal.zero;

  @override
  void initState() {
    super.initState();
    if (_value > Decimal.zero) WidgetsBinding.instance.addPostFrameCallback((_) => _requote());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _onAmount(String _) {
    ref.read(transferDraftProvider.notifier).setAmount(_value);
    _debounce?.cancel();
    setState(() {
      _quote = null;
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 350), _requote);
  }

  Future<SendQuote?> _requote() async {
    final to = ref.read(selectedRecipientProvider);
    if (to == null || _value <= Decimal.zero) return null;
    final amount = _value;
    setState(() => _quoting = true);
    final r = await ref
        .read(paymentsRepositoryProvider)
        .quoteSend(to, Money(amount, Currency.ngn), from: ref.read(transferDraftProvider).from);
    if (!mounted || amount != _value) return null;
    final l = AppLocalizations.of(context);
    setState(() {
      _quoting = false;
      _quote = r.valueOrNull;
      _error = r.when(
        ok: (_) => null,
        err: (f) => f is InsufficientFundsFailure ? l.notEnoughBalance : l.failure(f),
      );
    });
    return _quote;
  }

  Future<void> _confirm(Recipient to) async {
    final l = AppLocalizations.of(context);
    // Re-quote so the rate the user approves is fresh and locked server-side.
    final q = await _requote();
    if (q == null || !mounted) return;
    final action = '${l.sendAmount(MoneyFormat.format(q.amount))} · ${to.name}';
    String? pin;
    String? twofa;
    if (q.crossBorder) {
      final auth = await confirmWithPinAnd2fa(context, () => confirmWithPin(context, action: action));
      if (auth == null) return;
      (pin, twofa) = auth;
    } else {
      pin = await confirmWithPin(context, action: action);
    }
    if (pin == null || !mounted) return;
    ref.read(pendingSendProvider.notifier).set((
      quote: q,
      pinToken: pin,
      twofaToken: twofa,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    ));
    context.pushReplacementNamed(AppRoute.sending.name);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final to = ref.watch(selectedRecipientProvider);
    if (to == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.goNamed(AppRoute.transfer.name));
      return Scaffold(backgroundColor: c.bg);
    }
    final from = ref.watch(transferDraftProvider).from;
    final profile = ref.watch(profileProvider).value;
    final q = _quote;
    final fee = q?.fee ?? Money.zero(Currency.ngn);
    final wallet = from == 'NGN' ? l.nairaWallet : '$from ${l.walletLabel}';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, ''),
      body: GestureDetector(
        // Dismisses the keyboard; not a control, so hidden from screen readers.
        excludeFromSemantics: true,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 0, SpacingTokens.screenGutter, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PersonAvatar(name: profile?.fullName ?? '', color: 0xFFE3EAF6, size: 52),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: JarinaIcon(JIcon.arrowRight, size: 22, color: c.ink2),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.ink, width: 2),
                  ),
                  child: PersonAvatar(name: to.name, color: to.avatarColor, size: 76, countryIso: to.countryIso),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(to.name, textAlign: TextAlign.center, style: t.title),
            const SizedBox(height: 2),
            Text(
              recipientSubtitle(l, to),
              textAlign: TextAlign.center,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 18),
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _amount,
                  autofocus: _amount.text.isEmpty,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [GroupedDigitsFormatter()],
                  style: t.amountL.copyWith(fontSize: 44),
                  decoration: bareAmountDecoration(
                    t.amountL.copyWith(fontSize: 44),
                    c.muted,
                    prefix: _amount.text.isEmpty ? null : '₦',
                  ),
                  onChanged: _onAmount,
                ),
              ),
            ),
            Text(
              l.fromWalletFee(wallet, fee.isPositive ? MoneyFormat.format(fee, decimals: 0) : l.free2),
              textAlign: TextAlign.center,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
            ),
            if (q != null && q.debit.currency != Currency.ngn) ...[
              const SizedBox(height: 4),
              Text(
                '≈ ${MoneyFormat.format(q.debit)}',
                textAlign: TextAlign.center,
                style: t.caption.copyWith(color: c.muted),
              ),
            ],
            if (to.kind == RecipientKind.crossBorder) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const JarinaIcon(JIcon.globe, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          q == null
                              ? l.rateLocked
                              : l.recipientGetsFx(
                                  to.firstName,
                                  MoneyFormat.format(q.receive),
                                  '${q.rate.round(scale: 4)}',
                                  to.currency.code,
                                ),
                          style: t.caption.copyWith(fontWeight: FontWeight.w700, color: c.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              l.whatSItFor,
              style: t.caption.copyWith(color: c.muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            JTextField(
              controller: _note,
              hint: l.addANote,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            NoteChips(controller: _note, onChanged: () => setState(() {})),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JSlideToConfirm(
          label: l.slideToSendAmount(MoneyFormat.format(Money(_value, Currency.ngn), decimals: 0)),
          onConfirm: q != null && !_quoting ? () => unawaited(_confirm(to)) : null,
        ),
      ),
    );
  }
}

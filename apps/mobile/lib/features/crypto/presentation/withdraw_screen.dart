import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/crypto/application/crypto_state.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/security/presentation/twofa_sheet.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _Mode { external, jarina }

/// Withdraw crypto to an external address or a Jarina user (free).
/// Always PIN + 2FA: crypto withdrawals can't be reversed.
class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({required this.coin, super.key});

  final String coin;

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  _Mode _mode = _Mode.external;
  CryptoNetwork? _network;
  final _address = TextEditingController();
  final _memo = TextEditingController();
  final _user = TextEditingController();
  final _amount = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_address, _memo, _user, _amount]) {
      c.dispose();
    }
    super.dispose();
  }

  Decimal get _input => Decimal.tryParse(_amount.text) ?? Decimal.zero;

  Future<void> _submit(CryptoNetwork network, Decimal available) async {
    final l = AppLocalizations.of(context);
    final auth = await confirmWithPinAnd2fa(
      context,
      () => confirmWithPin(context, action: '${l.withdrawCoin(widget.coin)} · ${_amount.text} ${widget.coin}'),
    );
    if (!mounted || auth == null) return;
    final (pin, twofa) = auth;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(cryptoRepositoryProvider);
    final r = _mode == _Mode.external
        ? await repo.withdraw(
            coin: widget.coin,
            network: network,
            address: _address.text.trim(),
            memo: _memo.text.trim().isEmpty ? null : _memo.text.trim(),
            amount: _input,
            pinToken: pin,
            twofaToken: twofa,
          )
        : await repo.sendToUser(
            coin: widget.coin,
            username: _user.text,
            amount: _input,
            pinToken: pin,
            twofaToken: twofa,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (t) {
        showToast(context, t.toUser != null ? l.sentToUser(t.toUser!) : l.withdrawalSent);
        context.pushReplacementNamed(AppRoute.qhist.name);
      },
      err: (f) => setState(
        () => _error = switch (f) {
          InvalidAddressFailure() => l.errInvalidAddress(network.label),
          UserNotFoundFailure() => l.errUserNotFound,
          BelowMinimumFailure() => l.errAmountBelowFee,
          InsufficientFundsFailure() => l.notEnoughBalance,
          _ => l.failure(f),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final networks = ref.watch(coinNetworksProvider(widget.coin)).value ?? const <CryptoNetwork>[];
    final network = _network ?? networks.firstOrNull;
    final available = ref.watch(balancesProvider).value?.qtyOf(widget.coin) ?? Decimal.zero;
    final price = ref.watch(quotesProvider).value?[widget.coin]?.price;
    if (network == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final external = _mode == _Mode.external;
    final fee = external ? network.withdrawFee : Decimal.zero;
    final gets = _input > fee ? _input - fee : Decimal.zero;
    final addressText = _address.text.trim();
    final addressOk = addressText.isEmpty || AddressRules.isValid(network.id, addressText);
    final userText = UsernameRules.normalize(_user.text);
    final over = _input > available;
    final ready =
        !over &&
        _input > fee &&
        (external
            ? addressText.isNotEmpty && addressOk && (!network.memoRequired || _memo.text.trim().isNotEmpty)
            : userText.length >= 3);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.withdrawCoin(widget.coin)),
      body: GestureDetector(
        // Dismisses the keyboard; not a control, so hidden from screen readers.
        excludeFromSemantics: true,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 24),
          children: [
            JSegmented<_Mode>(
              segments: {_Mode.external: l.externalAddress, _Mode.jarina: l.jarinaUser},
              value: _mode,
              onChanged: (m) => setState(() {
                _mode = m;
                _error = null;
              }),
            ),
            const SizedBox(height: 16),
            if (external) ...[
              Text(
                l.network,
                style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in networks)
                    JChip(
                      label: '${n.label} · ${l.fee} ${n.withdrawFee}',
                      selected: n.id == network.id,
                      onTap: () => setState(() {
                        _network = n;
                        _error = null;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              JTextField(
                label: l.recipientAddress,
                controller: _address,
                hint: network.id == 'TRC-20'
                    ? 'T…'
                    : (network.id.contains('20') || network.id == 'Base' ? '0x…' : null),
                keyboardType: TextInputType.visiblePassword,
                errorText: addressOk ? null : l.errInvalidAddress(network.label),
                onChanged: (_) => setState(() => _error = null),
                suffix: TextButton(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) setState(() => _address.text = data!.text!.trim());
                  },
                  child: Text(l.paste),
                ),
              ),
              if (network.memoRequired) ...[
                const SizedBox(height: 12),
                JTextField(
                  label: l.memoTag,
                  controller: _memo,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ] else
              JTextField(
                label: l.username,
                controller: _user,
                hint: l.yourName,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (_) => setState(() => _error = null),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: Text('@', style: t.h2.copyWith(color: c.goldDeep)),
                ),
              ),
            const SizedBox(height: 16),
            JTextField(
              label: l.amount,
              controller: _amount,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}'))],
              errorText: over ? l.notEnoughBalance : null,
              helperText: l.availableAmount('$available ${widget.coin}'),
              onChanged: (_) => setState(() => _error = null),
              suffix: TextButton(
                onPressed: () => setState(() => _amount.text = available.toString()),
                child: Text(l.max),
              ),
            ),
            const SizedBox(height: 14),
            SummaryCard(
              rows: [
                SummaryRow(external ? l.networkFee : l.transferFee, external ? '$fee ${widget.coin}' : l.free),
                SummaryRow(l.recipientGets, '$gets ${widget.coin}', strong: true),
                if (price != null) SummaryRow('≈', MoneyFormat.format(Money(gets * price, Currency.ngn).rounded())),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 14),
            JCallout(text: l.cryptoWithdrawalsCanTBeReversed),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JButton(
          label: l.withdraw,
          icon: JIcon.lock,
          loading: _busy,
          onPressed: ready ? () => _submit(network, available) : null,
        ),
      ),
    );
  }
}

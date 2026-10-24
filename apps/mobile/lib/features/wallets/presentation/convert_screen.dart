import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Convert between home-currency wallets (0.5% fee), approved with the PIN.
class ConvertScreen extends ConsumerStatefulWidget {
  const ConvertScreen({super.key, this.from = Currency.ngn});

  final Currency from;

  @override
  ConsumerState<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends ConsumerState<ConvertScreen> {
  late Currency _from = widget.from;
  late Currency _to = widget.from == Currency.ghs ? Currency.ngn : Currency.ghs;
  final _amount = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Decimal? get _value => Decimal.tryParse(_amount.text.replaceAll(',', ''));

  void _setFrom(Currency c) => setState(() {
    if (c == _to) _to = _from;
    _from = c;
    _error = null;
  });

  void _setTo(Currency c) => setState(() {
    if (c == _from) _from = _to;
    _to = c;
  });

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final v = _value;
    if (v == null || v <= Decimal.zero) return;
    final repo = ref.read(walletRepositoryProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    final quote = await repo.quoteConvert(Money(v, _from), _to);
    if (!mounted) return;
    final q = quote.valueOrNull;
    if (q == null) {
      setState(() {
        _busy = false;
        _error = quote.when(
          ok: (_) => null,
          err: (f) => f is InsufficientFundsFailure ? l.exceedsBalance : l.failure(f),
        );
      });
      return;
    }
    // Not "busy" while the PIN sheet is up: the user is in control there.
    setState(() => _busy = false);
    final token = await confirmWithPin(
      context,
      action: '${MoneyFormat.format(q.from)} → ${MoneyFormat.format(q.receive)}',
    );
    if (!mounted || token == null) return;
    setState(() => _busy = true);
    final r = await repo.convert(q, pinToken: token);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (tx) => context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id}),
      err: (f) => setState(() => _error = l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final balances = ref.watch(balancesProvider).value;
    final fx = ref.watch(fxRatesProvider).value;
    final balance = balances?.fiatOf(_from) ?? Money.zero(_from);
    final v = _value;
    final over = v != null && v > balance.amount;
    final gross = v == null || fx == null ? null : fx.convert(Money(v, _from), _to);
    final receive = gross == null ? Money.zero(_to) : gross - gross.times(Decimal.parse('0.005')).rounded();
    final canSubmit = v != null && v > Decimal.zero && !over && !_busy;

    Widget picker(Currency selected, ValueChanged<Currency> onPick) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final cur in Currency.homeCurrencies)
          JChip(label: cur.code, selected: cur == selected, onTap: () => onPick(cur)),
      ],
    );

    return JFlowScaffold(
      onBack: () => context.pop(),
      backLabel: l.back,
      bottom: JButton(label: l.convert, loading: _busy, onPressed: canSubmit ? _submit : null),
      children: [
        JStepHeader(title: l.convert),
        const SizedBox(height: 18),
        Text(
          l.fromBalance(MoneyFormat.format(balance)),
          style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
        ),
        const SizedBox(height: 8),
        picker(_from, _setFrom),
        const SizedBox(height: 14),
        JTextField(
          controller: _amount,
          hint: '0',
          large: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            LengthLimitingTextInputFormatter(14),
          ],
          errorText: over ? l.exceedsBalance : _error,
          onChanged: (_) => setState(() => _error = null),
          suffix: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(_from.code, style: t.h2),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: l.switchLabel,
            onPressed: () => setState(() {
              final f = _from;
              _from = _to;
              _to = f;
            }),
            icon: JarinaIcon(JIcon.swap, color: c.goldDeep),
          ),
        ),
        Text(
          l.to,
          style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
        ),
        const SizedBox(height: 8),
        picker(_to, _setTo),
        const SizedBox(height: 18),
        Text(l.youReceive, style: t.caption.copyWith(color: c.muted)),
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.gold, width: 1.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  MoneyFormat.format(receive).replaceAll(_to.symbol, '').trim(),
                  style: t.amountL.copyWith(fontSize: 30),
                ),
              ),
              Text(_to.code, style: t.h2),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (fx != null)
          Text(
            l.convertRateLine(_from.code, fx.rate(_from, _to).round(scale: 4).toString(), _to.code, '0.5%'),
            style: t.caption.copyWith(color: c.muted),
          ),
        if (_busy) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
      ],
    );
  }
}

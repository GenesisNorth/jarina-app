import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Airtime, data, cable TV and electricity. Cable and electricity check the
/// smartcard / meter with the provider before paying.
class BillScreen extends ConsumerStatefulWidget {
  const BillScreen({required this.kind, super.key});

  final BillKind kind;

  static BillKind kindOf(String? name) => BillKind.values.where((k) => k.name == name).firstOrNull ?? BillKind.airtime;

  @override
  ConsumerState<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends ConsumerState<BillScreen> {
  String? _provider;
  bool _prepaid = true;
  BillPlan? _plan;
  final _number = TextEditingController();
  final _amount = TextEditingController();
  String? _customer;
  bool _verifying = false;
  String? _lookupError;
  String? _error;
  bool _busy = false;

  BillKind get _kind => widget.kind;

  @override
  void dispose() {
    _number.dispose();
    _amount.dispose();
    super.dispose();
  }

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');

  bool get _numberComplete => switch (_kind) {
    BillKind.cable => _digits.length == 10,
    BillKind.electricity => _digits.length == 11 || _digits.length == 13,
    _ => _digits.length == 11,
  };

  Future<void> _lookup(Biller b) async {
    final provider = _provider ?? b.providers.first;
    if (!b.needsCustomerLookup || !_numberComplete) return;
    final number = _digits;
    final prepaid = _prepaid;
    setState(() {
      _verifying = true;
      _customer = null;
      _lookupError = null;
    });
    final r = await ref.read(billsRepositoryProvider).verifyCustomer(_kind, provider, number, prepaid: prepaid);
    if (!mounted || number != _digits || prepaid != _prepaid) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _verifying = false;
      _customer = r.valueOrNull;
      _lookupError = r.when(ok: (_) => null, err: (_) => l.errMeter);
    });
  }

  Money? _price(Biller b) {
    if (b.plans.isNotEmpty) return _plan?.price;
    final v = Decimal.tryParse(_amount.text.replaceAll(',', ''));
    return v == null ? null : Money(v, Currency.ngn);
  }

  Future<void> _pay(Biller b, Money amount, String title) async {
    final l = AppLocalizations.of(context);
    final provider = _provider ?? b.providers.first;
    final pin = await confirmWithPin(context, action: '$title · $provider · ${MoneyFormat.format(amount)}');
    if (pin == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(billsRepositoryProvider)
        .pay(
          kind: _kind,
          provider: provider,
          number: _digits,
          amount: amount,
          pinToken: pin,
          plan: _plan?.name,
          prepaid: _prepaid,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: _success,
      err: (f) async => setState(
        () => _error = switch (f) {
          InsufficientFundsFailure() => l.notEnoughBalance,
          _ => l.failure(f),
        },
      ),
    );
  }

  Future<void> _success(Transaction tx) async {
    final receipt = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: context.colors.bg,
      builder: (_) => _PaidSheet(tx: tx),
    );
    if (!mounted) return;
    if (receipt ?? false) {
      context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id});
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final title = switch (_kind) {
      BillKind.airtime => l.airtime,
      BillKind.data => l.data,
      BillKind.cable => l.cableTv,
      BillKind.electricity => l.electricity,
    };
    final biller = ref.watch(billerProvider(_kind)).value;
    if (biller == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: jarinaAppBar(context, title),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final provider = _provider ?? biller.providers.first;
    final price = _price(biller);
    final outOfRange =
        biller.plans.isEmpty && price != null && price.isPositive && (price < biller.min || price > biller.max);
    final phoneError = !biller.needsCustomerLookup && _digits.length > 11;
    final ready =
        !_busy &&
        _numberComplete &&
        price != null &&
        price.isPositive &&
        !outOfRange &&
        (!biller.needsCustomerLookup || _customer != null);

    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        s,
        style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
      ),
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, title),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 24),
          children: [
            label(l.provider),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in biller.providers)
                  JChip(
                    label: p,
                    selected: p == provider,
                    onTap: () {
                      setState(() {
                        _provider = p;
                        _customer = null;
                      });
                      unawaited(_lookup(biller));
                    },
                  ),
              ],
            ),
            if (_kind == BillKind.electricity) ...[
              const SizedBox(height: 18),
              JSegmented<bool>(
                segments: {true: l.prepaid, false: l.postpaid},
                value: _prepaid,
                onChanged: (v) {
                  setState(() {
                    _prepaid = v;
                    _customer = null;
                  });
                  unawaited(_lookup(biller));
                },
              ),
            ],
            const SizedBox(height: 18),
            JTextField(
              label: switch (_kind) {
                BillKind.cable => l.smartcardIucNumber,
                BillKind.electricity => l.meterNumber,
                _ => l.phoneNumber,
              },
              controller: _number,
              hint: switch (_kind) {
                BillKind.cable => '7023 4567 89',
                BillKind.electricity => '0123 4567 890',
                _ => '0801 234 5678',
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)],
              autofillHints: biller.needsCustomerLookup ? null : const [AutofillHints.telephoneNumber],
              errorText: phoneError ? l.errPhone : _lookupError,
              helperText: _customer == null ? (_verifying ? l.verifying : null) : l.customerName(_customer!),
              onChanged: (_) {
                setState(() {
                  _customer = null;
                  _lookupError = null;
                  _error = null;
                });
                unawaited(_lookup(biller));
              },
              suffix: _verifying
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
            const SizedBox(height: 18),
            if (biller.plans.isNotEmpty) ...[
              label(_kind == BillKind.cable ? l.package : l.bundle),
              _PlanList(
                plans: biller.plans,
                selected: _plan,
                onSelected: (p) => setState(() {
                  _plan = p;
                  _error = null;
                }),
              ),
            ] else ...[
              JTextField(
                label: l.amount,
                controller: _amount,
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 2),
                  child: Text('₦', style: t.body.copyWith(fontWeight: FontWeight.w700)),
                ),
                errorText: outOfRange
                    ? l.billMinMax(
                        MoneyFormat.format(biller.min, decimals: 0),
                        MoneyFormat.format(biller.max, decimals: 0),
                      )
                    : null,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in biller.quickAmounts)
                    JChip(
                      label: MoneyFormat.format(a, decimals: 0),
                      selected: price == a,
                      onTap: () => setState(() {
                        _amount.text = a.amount.toString();
                        _error = null;
                      }),
                    ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JButton(
          label: price != null && price.isPositive
              ? l.payBill(MoneyFormat.format(price, decimals: 0))
              : l.continueLabel,
          icon: JIcon.lock,
          loading: _busy,
          onPressed: ready ? () => unawaited(_pay(biller, price, title)) : null,
        ),
      ),
    );
  }
}

/// Data bundles / TV packages as a selectable list.
class _PlanList extends StatelessWidget {
  const _PlanList({required this.plans, required this.selected, required this.onSelected});

  final List<BillPlan> plans;
  final BillPlan? selected;
  final ValueChanged<BillPlan> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(RadiusTokens.card),
      clipBehavior: Clip.antiAlias,
      child: RadioGroup<String>(
        groupValue: selected?.name,
        onChanged: (v) => onSelected(plans.firstWhere((p) => p.name == v)),
        child: Column(
          children: [
            for (final p in plans)
              RadioListTile<String>(
                value: p.name,
                activeColor: c.ink,
                title: Text(p.name, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                secondary: Text(
                  MoneyFormat.format(p.price, decimals: 0),
                  style: t.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaidSheet extends StatelessWidget {
  const _PaidSheet({required this.tx});

  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final d = tx.description ?? '';
    final token = d.startsWith('Token ') ? d.substring(6) : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 24, SpacingTokens.screenGutter, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: c.up, shape: BoxShape.circle),
              child: const JarinaIcon(JIcon.check, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(l.billPaid, textAlign: TextAlign.center, style: t.title),
          ),
          const SizedBox(height: 4),
          Text(
            '${tx.title} · ${MoneyFormat.format(-tx.amount, decimals: 0)}',
            textAlign: TextAlign.center,
            style: t.body.copyWith(color: c.muted),
          ),
          if (token != null) ...[
            const SizedBox(height: 16),
            JCard(
              child: Column(
                children: [
                  Text(
                    l.electricityToken,
                    style: t.caption.copyWith(color: c.muted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SelectableText(token, style: t.h2.copyWith(letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const JarinaIcon(JIcon.copy, size: 16),
                    label: Text(l.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: token.replaceAll('-', '')));
                      if (context.mounted) showToast(context, l.tokenCopied);
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          JButton(label: l.done, onPressed: () => Navigator.of(context).pop(false)),
          JButton(
            label: l.viewReceipt,
            variant: JButtonVariant.ghost,
            height: 48,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

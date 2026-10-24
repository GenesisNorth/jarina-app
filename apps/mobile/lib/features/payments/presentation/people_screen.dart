import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/payments/presentation/payments_widgets.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Choose who to pay: Jarina users, cross-border beneficiaries, or any bank.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key, this.openBank = false});

  /// Opened from the "Bank account" tile: go straight to the bank form.
  final bool openBank;

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final _query = TextEditingController();
  Timer? _debounce;
  JarinaUser? _found;
  bool _looking = false;

  @override
  void initState() {
    super.initState();
    if (widget.openBank) WidgetsBinding.instance.addPostFrameCallback((_) => _bank());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _pay(Recipient r) {
    ref.read(selectedRecipientProvider.notifier).set(r);
    unawaited(context.pushNamed(AppRoute.payconfirm.name));
  }

  void _onQuery(String q) {
    _debounce?.cancel();
    final handle = UsernameRules.normalize(q);
    setState(() {
      _found = null;
      _looking = handle.length >= 3 && !RegExp(r'^\d+$').hasMatch(handle);
    });
    if (!_looking) return;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final r = await ref.read(paymentsRepositoryProvider).lookupUser(handle);
      if (!mounted || UsernameRules.normalize(_query.text) != handle) return;
      setState(() {
        _looking = false;
        _found = r.valueOrNull;
      });
    });
  }

  Future<void> _bank() async {
    final digits = _query.text.replaceAll(RegExp(r'\D'), '');
    final r = await showModalBottomSheet<Recipient>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.bg,
      builder: (_) => _BankSheet(initialNumber: digits.length == 10 ? digits : ''),
    );
    if (r != null && mounted) _pay(r);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final amount = ref.watch(transferDraftProvider).amount;
    final all = ref.watch(recipientsProvider).value ?? const <Recipient>[];
    final q = _query.text.trim().toLowerCase().replaceFirst('@', '');
    bool matches(Recipient r) =>
        q.isEmpty ||
        r.name.toLowerCase().contains(q) ||
        (r.handle?.contains(q) ?? false) ||
        (r.accountNumber?.contains(q) ?? false);
    final local = all.where((r) => r.kind != RecipientKind.crossBorder && matches(r)).toList();
    final abroad = all.where((r) => r.kind == RecipientKind.crossBorder && matches(r)).toList();
    final found = _found;
    final foundIsNew = found != null && !all.any((r) => r.handle == found.handle);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.sendAmount(MoneyFormat.format(Money(amount, Currency.ngn), decimals: 0))),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 32),
          children: [
            JTextField(
              controller: _query,
              hint: l.toSearchHint,
              keyboardType: TextInputType.visiblePassword,
              onChanged: _onQuery,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 16, right: 6),
                child: Text(l.toLabel, style: t.body.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            if (_looking) ...[
              const SizedBox(height: 10),
              Text(
                l.lookingUp(UsernameRules.normalize(_query.text)),
                style: t.caption.copyWith(color: c.muted),
              ),
            ],
            if (foundIsNew) ...[
              const SizedBox(height: 12),
              LinkCard(
                leading: PersonAvatar(name: found.name, color: 0xFFFBE9DC),
                title: found.name,
                subtitle: l.jarinaUserTag(found.handle),
                onTap: () => _pay(
                  Recipient(
                    id: 'u-${found.handle}',
                    name: found.name,
                    kind: RecipientKind.jarina,
                    countryIso: 'NG',
                    currency: Currency.ngn,
                    avatarColor: 0xFFFBE9DC,
                    handle: found.handle,
                  ),
                ),
              ),
            ],
            if (local.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l.onJarinaFree,
                style: t.caption.copyWith(color: c.muted, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _PeopleGrid(people: local, onTap: _pay),
            ],
            if (abroad.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l.crossBorderMinutes,
                style: t.caption.copyWith(color: c.muted, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _PeopleGrid(people: abroad, onTap: _pay),
            ],
            if (local.isEmpty && abroad.isEmpty && !foundIsNew && !_looking) ...[
              const SizedBox(height: 20),
              Text(
                l.noRecipients,
                style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
              ),
            ],
            const SizedBox(height: 24),
            LinkCard(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(10)),
                child: const JarinaIcon(JIcon.bank, size: 20),
              ),
              title: l.sendToAnyNigerianBank,
              subtitle: l.accountNumberBank,
              onTap: _bank,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleGrid extends StatelessWidget {
  const _PeopleGrid({required this.people, required this.onTap});

  final List<Recipient> people;
  final ValueChanged<Recipient> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    return LayoutBuilder(
      builder: (context, box) {
        // Four per row on phones, three when the text is very large.
        final perRow = MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 3 : 4;
        final w = box.maxWidth / perRow;
        return Wrap(
          runSpacing: 14,
          children: [
            for (final r in people)
              SizedBox(
                width: w,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onTap(r),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Column(
                      children: [
                        PersonAvatar(name: r.name, color: r.avatarColor, size: (w - 16).clamp(40, 60)),
                        const SizedBox(height: 6),
                        Text(
                          r.firstName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink),
                        ),
                        Text(
                          switch (r.kind) {
                            RecipientKind.jarina => '@${r.handle}',
                            RecipientKind.bank => l.bank,
                            RecipientKind.crossBorder => r.place!.split(',').last.trim(),
                          },
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.caption.copyWith(color: c.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Bank + account number with a name enquiry before it can be paid.
class _BankSheet extends ConsumerStatefulWidget {
  const _BankSheet({required this.initialNumber});

  final String initialNumber;

  @override
  ConsumerState<_BankSheet> createState() => _BankSheetState();
}

class _BankSheetState extends ConsumerState<_BankSheet> {
  String? _bank;
  late final _number = TextEditingController(text: widget.initialNumber);
  String? _name;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final bank = _bank;
    if (bank == null || _number.text.length != 10) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(paymentsRepositoryProvider).resolveBankAccount(bank, _number.text);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _name = r.valueOrNull?.name;
      _error = r.when(ok: (_) => null, err: l.failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.text;
    final banks = ref.watch(cryptoRepositoryProvider).banks();
    final name = _name;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.screenGutter,
        16,
        SpacingTokens.screenGutter,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.addBankRecipient, style: t.title),
            const SizedBox(height: 16),
            JSelect<String>(
              label: l.bankLabel,
              hint: l.selectBank,
              sheetTitle: l.selectBank,
              searchHint: l.search,
              items: banks,
              value: _bank,
              labelOf: (b) => b,
              onChanged: (b) {
                setState(() {
                  _bank = b;
                  _name = null;
                });
                unawaited(_verify());
              },
            ),
            const SizedBox(height: 12),
            JTextField(
              label: l.accountNumber,
              controller: _number,
              hint: l.digitsCount('10'),
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: _error,
              helperText: name == null ? null : l.accountVerified(name),
              onChanged: (v) {
                setState(() => _name = null);
                if (v.length == 10) unawaited(_verify());
              },
              suffix: _busy
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            JButton(
              label: l.continueLabel,
              onPressed: name == null
                  ? null
                  : () => Navigator.of(context).pop(
                      Recipient(
                        id: 'b-${_bank!}-${_number.text}',
                        name: _titleCase(name),
                        kind: RecipientKind.bank,
                        countryIso: 'NG',
                        currency: Currency.ngn,
                        avatarColor: 0xFFE3EAF6,
                        bank: _bank,
                        accountNumber: _number.text,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String s) =>
      s.toLowerCase().split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
}

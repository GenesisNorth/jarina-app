import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/payments/presentation/payments_widgets.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _Mode { send, request }

/// Free, instant P2P by @username: send cash, crypto or NGX shares, or
/// request Naira.
class P2pScreen extends ConsumerStatefulWidget {
  const P2pScreen({super.key, this.request = false, this.amount, this.to});

  final bool request;
  final String? amount;
  final String? to;

  @override
  ConsumerState<P2pScreen> createState() => _P2pScreenState();
}

class _P2pScreenState extends ConsumerState<P2pScreen> {
  late _Mode _mode = widget.request ? _Mode.request : _Mode.send;
  late final _user = TextEditingController(text: widget.to ?? '');
  late final _amount = TextEditingController(text: widget.amount ?? '');
  final _note = TextEditingController();
  String _asset = 'NGN';
  Timer? _debounce;
  JarinaUser? _found;
  bool _looking = false;
  bool _notFound = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_user.text.isNotEmpty) _onUser(_user.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_user, _amount, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Decimal get _value => Decimal.tryParse(_amount.text) ?? Decimal.zero;

  void _onUser(String v) {
    _debounce?.cancel();
    final handle = UsernameRules.normalize(v);
    setState(() {
      _found = null;
      _notFound = false;
      _error = null;
      _looking = handle.length >= 3;
    });
    if (!_looking) return;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final r = await ref.read(paymentsRepositoryProvider).lookupUser(handle);
      if (!mounted || UsernameRules.normalize(_user.text) != handle) return;
      setState(() {
        _looking = false;
        _found = r.valueOrNull;
        _notFound = _found == null;
      });
    });
  }

  void _pick(String handle) {
    _user.text = handle;
    _onUser(handle);
  }

  Future<void> _submit(JarinaUser to, String valueText) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(paymentsRepositoryProvider);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    if (_mode == _Mode.request) {
      setState(() => _busy = true);
      final r = await repo.requestMoney(handle: to.handle, amount: Money(_value, Currency.ngn), note: note);
      if (!mounted) return;
      setState(() => _busy = false);
      r.when(
        ok: (_) {
          ref.read(lastP2pProvider.notifier).set((
            name: to.name,
            handle: to.handle,
            value: valueText,
            request: true,
            tx: null,
          ));
          context.pushReplacementNamed(AppRoute.p2pdone.name);
        },
        err: (f) => setState(() => _error = l.failure(f)),
      );
      return;
    }
    final pin = await confirmWithPin(context, action: '${l.send} $valueText · @${to.handle}');
    if (pin == null || !mounted) return;
    setState(() => _busy = true);
    final r = await repo.sendP2p(handle: to.handle, asset: _asset, amount: _value, pinToken: pin, note: note);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (tx) {
        ref.read(lastP2pProvider.notifier).set((
          name: to.name,
          handle: to.handle,
          value: valueText,
          request: false,
          tx: tx,
        ));
        context.pushReplacementNamed(AppRoute.p2pdone.name);
      },
      err: (f) => setState(
        () => _error = switch (f) {
          InsufficientFundsFailure() => l.notEnoughBalance,
          UserNotFoundFailure() => l.errUserNotFound,
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
    final me = ref.watch(profileProvider).value;
    final catalog = ref.watch(catalogProvider).value?.values.toList() ?? const <AssetInfo>[];
    final balances = ref.watch(balancesProvider).value;
    final quotes = ref.watch(quotesProvider).value;
    final people = (ref.watch(recipientsProvider).value ?? const <Recipient>[]).where((r) => r.handle != null);
    final request = _mode == _Mode.request;

    final asset = request || _asset == 'NGN' ? null : catalog.where((a) => a.id == _asset).firstOrNull;
    final unit = asset?.unit ?? Currency.ngn;
    final available = asset == null
        ? balances?.fiatOf(Currency.ngn).amount ?? Decimal.zero
        : balances?.qtyOf(asset.id) ?? Decimal.zero;
    final value = _value;
    final over = !request && value > available;
    final money = Money(value, unit);
    final valueText = asset?.isStock ?? false ? '$value ${l.shares2} ${asset!.id}' : MoneyFormat.format(money);
    final ngnValue = asset == null
        ? money
        : Money(value * (quotes?[asset.id]?.price ?? Decimal.zero), Currency.ngn).rounded();
    final found = _found;
    final ready = found != null && value > Decimal.zero && !over && !_busy;

    void setPct(double p) {
      final raw = available * Decimal.parse(p.toStringAsFixed(4));
      final v = raw.floor(scale: unit.decimals);
      setState(() {
        _amount.text = v == Decimal.zero ? '' : v.toString();
        _error = null;
      });
    }

    final held = [
      for (final a in catalog)
        if ((balances?.qtyOf(a.id) ?? Decimal.zero) > Decimal.zero) a,
    ];

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.sendToJarinaUser),
      body: GestureDetector(
        // Dismisses the keyboard; not a control, so hidden from screen readers.
        excludeFromSemantics: true,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 24),
          children: [
            JBrandCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonAvatar(name: me?.fullName ?? '', color: 0xFFF4F1EA, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.jarinaP2p, style: t.title.copyWith(color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(
                              l.p2pHeaderSub(me?.username ?? ''),
                              style: t.caption.copyWith(color: Colors.white70, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(label: l.free2, color: c.up),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DarkTag(icon: JIcon.bolt, label: l.instant),
                      _DarkTag(icon: JIcon.shield, label: l.zeroFees),
                      _DarkTag(icon: JIcon.globe, label: l.countriesCount('6')),
                      _DarkTag(icon: JIcon.crypto, label: l.cashCryptoStocks),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            JSegmented<_Mode>(
              segments: {_Mode.send: l.send, _Mode.request: l.request},
              value: _mode,
              onChanged: (m) => setState(() {
                _mode = m;
                _error = null;
              }),
            ),
            const SizedBox(height: 14),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardLabel(left: request ? l.requestFrom : l.sendTo, right: l.jarinaUsername),
                  const SizedBox(height: 10),
                  JTextField(
                    controller: _user,
                    hint: l.username,
                    large: true,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    onChanged: _onUser,
                    errorText: _notFound ? l.errUserNotFound : null,
                    helperText: found == null
                        ? (_looking ? l.lookingUp(UsernameRules.normalize(_user.text)) : null)
                        : l.userFound(found.name, found.handle),
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      child: Text('@', style: t.h2.copyWith(color: c.goldDeep)),
                    ),
                  ),
                  if (people.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 84,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        children: [
                          for (final p in people)
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _pick(p.handle!),
                              child: SizedBox(
                                width: 76,
                                child: Column(
                                  children: [
                                    PersonAvatar(name: p.name, color: p.avatarColor),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.firstName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.caption.copyWith(fontWeight: FontWeight.w700, color: c.ink),
                                    ),
                                    Text(
                                      '@${p.handle}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.caption.copyWith(color: c.muted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardLabel(
                    left: request ? l.youRequest : l.youSend,
                    right: request ? null : l.balanceOf(_format(l, asset, available)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _AssetPill(
                        asset: asset,
                        sub: l.walletLabel,
                        onTap: request
                            ? null
                            : () async {
                                final pick = await _pickAsset(context, held);
                                if (pick != null) {
                                  setState(() {
                                    _asset = pick;
                                    _amount.clear();
                                    _error = null;
                                  });
                                }
                              },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amount,
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.numberWithOptions(decimal: unit.decimals > 0),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(unit.decimals == 0 ? r'^\d{0,9}' : '^\\d{0,12}\\.?\\d{0,${unit.decimals}}'),
                            ),
                          ],
                          style: t.amountL.copyWith(fontSize: 34),
                          decoration: bareAmountDecoration(t.amountL.copyWith(fontSize: 34), c.muted),
                          onChanged: (_) => setState(() => _error = null),
                        ),
                      ),
                    ],
                  ),
                  if (!request) ...[
                    const SizedBox(height: 6),
                    JPercentSlider(
                      value: available > Decimal.zero ? (value / available).toDouble() : 0,
                      maxLabel: l.max,
                      onChanged: setPct,
                    ),
                  ],
                  if (over) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.notEnoughBalance,
                      style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            if (!request) ...[
              const SizedBox(height: 14),
              JCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _CardLabel(left: l.theyReceive)),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: c.up, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l.instant,
                          style: t.caption.copyWith(color: c.up, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _AssetPill(asset: asset, sub: l.sameAsset),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerRight,
                            fit: BoxFit.scaleDown,
                            child: Text('$value', style: t.amountL.copyWith(fontSize: 34)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '≈ ${MoneyFormat.format(ngnValue, decimals: 0)} · ${l.free2}',
                      style: t.caption.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardLabel(left: l.addANoteOptional),
                  const SizedBox(height: 10),
                  JTextField(
                    controller: _note,
                    hint: l.whatSItFor,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  NoteChips(controller: _note, onChanged: () => setState(() {})),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 14),
            JNote(text: l.p2pNote),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JSlideToConfirm(
          label: request ? l.slideToRequestAmount(valueText) : l.slideToSendAmount(valueText),
          disabledLabel: found == null ? l.chooseJarinaUser : null,
          onConfirm: ready ? () => unawaited(_submit(found, valueText)) : null,
        ),
      ),
    );
  }

  String _format(AppLocalizations l, AssetInfo? a, Decimal qty) => a == null
      ? MoneyFormat.format(Money(qty, Currency.ngn), decimals: 0)
      : a.isStock
      ? '$qty ${l.shares2}'
      : MoneyFormat.format(Money(qty, a.unit));

  Future<String?> _pickAsset(BuildContext context, List<AssetInfo> held) => showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: context.colors.bg,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      final t = ctx.text;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 16, SpacingTokens.screenGutter, 24),
          children: [
            Text(l.youSend, style: t.title),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const _NairaBadge(),
              title: Text(l.naira, style: t.body.copyWith(fontWeight: FontWeight.w700)),
              onTap: () => Navigator.of(ctx).pop('NGN'),
            ),
            for (final a in held)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AssetBadge(a),
                title: Text(a.name, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(a.id),
                onTap: () => Navigator.of(ctx).pop(a.id),
              ),
          ],
        ),
      );
    },
  );
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({required this.left, this.right});

  final String left;
  final String? right;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Row(
      children: [
        Expanded(
          child: Text(
            left.toUpperCase(),
            style: t.caption.copyWith(color: c.muted, letterSpacing: 1.1, fontWeight: FontWeight.w700),
          ),
        ),
        if (right != null)
          Flexible(
            child: Text(
              right!,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.caption.copyWith(color: c.muted),
            ),
          ),
      ],
    );
  }
}

class _DarkTag extends StatelessWidget {
  const _DarkTag({required this.icon, required this.label});

  final JIcon icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          JarinaIcon(icon, size: 14, color: c.gold),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _NairaBadge extends StatelessWidget {
  const _NairaBadge();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.black, borderRadius: BorderRadius.circular(12)),
      child: Text(
        '₦',
        style: t.body.copyWith(color: c.gold, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _AssetPill extends StatelessWidget {
  const _AssetPill({required this.asset, required this.sub, this.onTap});

  final AssetInfo? asset;
  final String sub;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final a = asset;
    return Material(
      color: c.fill,
      shape: StadiumBorder(side: BorderSide(color: c.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (a == null) const _NairaBadge() else AssetBadge(a),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      a?.id ?? l.naira,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(sub, style: t.caption.copyWith(color: c.muted, fontSize: 11)),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                JarinaIcon(JIcon.down, size: 14, color: c.ink2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

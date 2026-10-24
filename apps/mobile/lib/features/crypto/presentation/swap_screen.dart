import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Instant swap between NGN and any coin (or coin ↔ coin), 15-second quotes.
class SwapScreen extends ConsumerStatefulWidget {
  const SwapScreen({super.key, this.from = 'USDT', this.to = 'BTC'});

  final String from;
  final String to;

  @override
  ConsumerState<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends ConsumerState<SwapScreen> {
  late String _from = widget.from;
  late String _to = widget.to == widget.from ? (widget.from == 'USDT' ? 'BTC' : 'USDT') : widget.to;
  final _amount = TextEditingController();
  double _pct = 0;
  SwapQuote? _quote;
  String? _error;
  bool _quoting = false;
  bool _busy = false;
  Timer? _debounce;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Re-render the countdown and re-quote when it runs out.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final q = _quote;
      if (q != null && !ref.read(clockProvider)().isBefore(q.expiresAt)) {
        _requote();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tick?.cancel();
    _amount.dispose();
    super.dispose();
  }

  Currency _unit(String code) =>
      code == 'NGN' ? Currency.ngn : Currency.crypto(code, decimals: code == 'USDT' || code == 'USDC' ? 2 : 8);

  Decimal get _input => Decimal.tryParse(_amount.text) ?? Decimal.zero;

  Money _balance(String code) {
    final b = ref.read(balancesProvider).value;
    if (b == null) return Money.zero(_unit(code));
    return code == 'NGN' ? b.fiatOf(Currency.ngn) : Money(b.qtyOf(code), _unit(code));
  }

  void _changed() {
    _debounce?.cancel();
    setState(() {
      _quote = null;
      _error = null;
    });
    if (_input <= Decimal.zero) return;
    _debounce = Timer(const Duration(milliseconds: 350), _requote);
  }

  Future<void> _requote() async {
    if (_input <= Decimal.zero) return;
    final l = AppLocalizations.of(context);
    setState(() => _quoting = true);
    final r = await ref.read(cryptoRepositoryProvider).quoteSwap(Money(_input, _unit(_from)), _to);
    if (!mounted) return;
    setState(() {
      _quoting = false;
      _quote = r.valueOrNull;
      _error = r.when(
        ok: (_) => null,
        err: (f) => switch (f) {
          InsufficientFundsFailure() => l.notEnoughBalance,
          BelowMinimumFailure() => l.errTooShort,
          _ => l.failure(f),
        },
      );
    });
  }

  void _setPct(double p) {
    final bal = _balance(_from);
    final v = (bal.amount * Decimal.parse(p.toStringAsFixed(4))).floor(scale: bal.currency.decimals);
    _amount.text = v.toString();
    _pct = p;
    _changed();
  }

  void _flip() {
    setState(() {
      final f = _from;
      _from = _to;
      _to = f;
      _amount.clear();
      _pct = 0;
    });
    _changed();
  }

  Future<void> _pick({required bool pay}) async {
    final catalog = ref.read(catalogProvider).value;
    if (catalog == null) return;
    final coins = ['NGN', ...catalog.values.where((a) => !a.isStock).map((a) => a.id)];
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final code in coins)
              ListTile(
                leading: code == 'NGN'
                    ? JAssetBadge(
                        label: '₦',
                        color: context.colors.black,
                        ring: context.colors.fill,
                        ink: Colors.white,
                        round: true,
                        size: 32,
                      )
                    : AssetBadge(catalog[code]!, size: 32),
                title: Text(code, style: context.text.body.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(code == 'NGN' ? 'Naira' : catalog[code]!.name),
                trailing: MoneyText(_balance(code), style: context.text.caption),
                onTap: () => Navigator.of(context).pop(code),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      if (pay) {
        if (picked == _to) _to = _from;
        _from = picked;
        _amount.clear();
        _pct = 0;
      } else {
        if (picked == _from) _from = _to;
        _to = picked;
      }
    });
    _changed();
  }

  Future<void> _swap(SwapQuote q) async {
    final l = AppLocalizations.of(context);
    final token = await confirmWithPin(
      context,
      action: '${MoneyFormat.format(q.pay)} → ${MoneyFormat.format(q.receive)}',
    );
    if (!mounted || token == null) return;
    setState(() => _busy = true);
    final r = await ref.read(cryptoRepositoryProvider).swap(q, pinToken: token);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (tx) => context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id}),
      err: (f) {
        if (f is QuoteExpiredFailure) unawaited(_requote());
        setState(() => _error = f is QuoteExpiredFailure ? l.priceUpdated : l.failure(f));
      },
    );
  }

  Widget _badge(String code, Map<String, AssetInfo>? catalog, double size) => code == 'NGN' || catalog?[code] == null
      ? JAssetBadge(
          label: '₦',
          color: context.colors.black,
          ring: context.colors.fill,
          ink: Colors.white,
          round: true,
          size: size,
        )
      : AssetBadge(catalog![code]!, size: size);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final quotes = ref.watch(quotesProvider).value;
    ref.watch(balancesProvider);
    final now = ref.watch(clockProvider)();
    final recent = (ref.watch(activityProvider).value ?? const <Transaction>[])
        .where((x) => x.title.startsWith('Swapped'))
        .take(4)
        .toList();
    final q = _quote;
    final secondsLeft = q == null ? 0 : q.expiresAt.difference(now).inSeconds.clamp(0, 15);
    final priceFrom = _from == 'NGN' ? 1.0 : quotes?[_from]?.price.toDouble() ?? 0;
    final priceTo = _to == 'NGN' ? 1.0 : quotes?[_to]?.price.toDouble() ?? 1;
    final indicativeRate = priceTo == 0 ? 0.0 : priceFrom * 0.975 / priceTo;
    final chartCode = _to == 'NGN' ? _from : _to;
    final chart = quotes?[chartCode]?.intraday;

    Widget assetPill(String code, {required bool pay}) => JTapTarget(
      onTap: () => _pick(pay: pay),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _badge(code, catalog, 26),
            const SizedBox(width: 6),
            Text(code, style: t.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(width: 2),
            Transform.rotate(angle: -1.5708, child: JarinaIcon(JIcon.back, size: 14, color: c.muted)),
          ],
        ),
      ),
    );

    return JFlowScaffold(
      onBack: () => context.pop(),
      backLabel: l.back,
      trailing: Text(l.instantSwap, style: t.h2),
      bottom: _busy
          ? const SizedBox(height: 58, child: Center(child: CircularProgressIndicator()))
          : JSlideToConfirm(
              label: l.slideToSwap,
              disabledLabel: l.enterAnAmount,
              onConfirm: q != null && _error == null ? () => _swap(q) : null,
            ),
      children: [
        JBrandCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _badge(_from, catalog, 26),
                  Transform.translate(offset: const Offset(-8, 0), child: _badge(_to, catalog, 26)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_from → $_to',
                          style: t.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '1 $_from = ${indicativeRate.toStringAsFixed(indicativeRate < 1 ? 8 : 2)} $_to',
                          style: t.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (chart != null) ...[
                const SizedBox(height: 6),
                JAreaChart(values: chart, color: BrandColors.gold, height: 40, stroke: 1.6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    l.youPay.toUpperCase(),
                    style: t.caption.copyWith(
                      color: c.muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      l.balanceOf(MoneyFormat.format(_balance(_from))),
                      overflow: TextOverflow.ellipsis,
                      style: t.caption.copyWith(color: c.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  assetPill(_from, pay: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amount,
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
                        LengthLimitingTextInputFormatter(16),
                      ],
                      onChanged: (_) {
                        _pct = 0;
                        _changed();
                      },
                      style: t.amountL.copyWith(fontSize: 26),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: t.amountL.copyWith(fontSize: 26, color: c.muted.withValues(alpha: 0.6)),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        constraints: const BoxConstraints(minHeight: 48),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              JPercentSlider(value: _pct, maxLabel: l.max, onChanged: _setPct),
            ],
          ),
        ),
        Center(
          child: IconButton.filled(
            tooltip: l.switchLabel,
            style: IconButton.styleFrom(backgroundColor: c.black, fixedSize: const Size(44, 44)),
            onPressed: _flip,
            icon: const JarinaIcon(JIcon.swap, size: 20, color: Colors.white),
          ),
        ),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    l.youReceive.toUpperCase(),
                    style: t.caption.copyWith(
                      color: c.muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      l.balanceOf(MoneyFormat.format(_balance(_to))),
                      overflow: TextOverflow.ellipsis,
                      style: t.caption.copyWith(color: c.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  assetPill(_to, pay: false),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: _quoting
                          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              q == null
                                  ? '0'
                                  : MoneyFormat.format(q.receive).replaceAll(' $_to', '').replaceAll('₦', ''),
                              style: t.amountL.copyWith(fontSize: 26),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      q == null ? '≈ ₦0' : '${l.fee} ${MoneyFormat.format(q.fee)}',
                      style: t.caption.copyWith(color: c.muted),
                    ),
                  ),
                  if (q != null) ...[
                    SizedBox.square(
                      dimension: 30,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: secondsLeft / 15,
                            strokeWidth: 2.5,
                            color: c.goldDeep,
                            backgroundColor: c.line,
                          ),
                          Text(
                            '${secondsLeft}s',
                            style: t.caption.copyWith(fontSize: 9, fontWeight: FontWeight.w700, color: c.goldDeep),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l.priceUpdated,
                      onPressed: _requote,
                      icon: Icon(Icons.refresh_rounded, color: c.ink, size: 20),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        if (q != null) ...[
          const SizedBox(height: 12),
          SummaryCard(
            rows: [SummaryRow(l.rate, '1 $_from = ${q.rate.round(scale: q.rate < Decimal.one ? 8 : 2)} $_to')],
          ),
        ],
        JSectionHeader(title: l.popularPairs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (a, b) in const [
              ('USDT', 'BTC'),
              ('NGN', 'USDT'),
              ('BTC', 'USDT'),
              ('NGN', 'BTC'),
              ('USDT', 'ETH'),
            ])
              JChip(
                label: '$a → $b',
                selected: _from == a && _to == b,
                onTap: () {
                  setState(() {
                    _from = a;
                    _to = b;
                    _amount.clear();
                    _pct = 0;
                  });
                  _changed();
                },
              ),
          ],
        ),
        if (recent.isNotEmpty) ...[
          JSectionHeader(title: l.recentSwaps),
          RowsCard(children: [for (final tx in recent) ActivityRow(tx: tx)]),
        ],
        const SizedBox(height: 12),
        JNote(text: l.swapNote),
      ],
    );
  }
}

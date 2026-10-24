import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/automation/presentation/automation_text.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/trading/application/trading_state.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Create an Autopilot rule for one asset: trigger, amount, repeat, expiry.
class RuleScreen extends ConsumerStatefulWidget {
  const RuleScreen({required this.assetId, super.key});

  final String assetId;

  @override
  ConsumerState<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends ConsumerState<RuleScreen> {
  RuleSide _side = RuleSide.buy;
  RuleCondition _condition = RuleCondition.range;
  RuleAmountUnit _unit = RuleAmountUnit.ngn;
  RuleRepeat _repeat = RuleRepeat.once;
  RuleExpiry _expiry = RuleExpiry.thirtyDays;
  final _low = TextEditingController();
  final _high = TextEditingController();
  final _amount = TextEditingController();
  bool _seeded = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_low, _high, _amount]) {
      c.dispose();
    }
    super.dispose();
  }

  static Decimal? _parse(TextEditingController c) => Decimal.tryParse(c.text.replaceAll(',', ''));

  /// Whole naira from ₦1,000, kobo below.
  static String _fmtPrice(Decimal ref, double v) =>
      ref >= Decimal.fromInt(1000) ? v.round().toString() : v.toStringAsFixed(2);

  void _seed(AssetInfo a, Decimal price) {
    final p = price.toDouble();
    _low.text = _fmtPrice(price, p * 0.9);
    _high.text = _fmtPrice(price, p * 0.99);
    _amount.text = a.isStock ? '100000' : '50000';
    _seeded = true;
  }

  void _flip(AssetInfo a, Decimal price) {
    final p = price.toDouble();
    setState(() {
      if (_side == RuleSide.buy) {
        _side = RuleSide.sell;
        _condition = RuleCondition.above;
        _unit = RuleAmountUnit.quantity;
        _low.text = _fmtPrice(price, p * 1.1);
        _amount.text = a.isStock ? '20' : '0.001';
      } else {
        _side = RuleSide.buy;
        _condition = RuleCondition.range;
        _unit = RuleAmountUnit.ngn;
        _low.text = _fmtPrice(price, p * 0.9);
        _high.text = _fmtPrice(price, p * 0.99);
        _amount.text = a.isStock ? '100000' : '50000';
      }
    });
  }

  RuleDraft? _draft() {
    final low = _parse(_low);
    final amount = _parse(_amount);
    if (low == null || amount == null) return null;
    return (
      assetId: widget.assetId,
      side: _side,
      condition: _condition,
      trigger: low,
      upper: _condition == RuleCondition.range ? _parse(_high) : null,
      amount: amount,
      unit: _unit,
      repeat: _repeat,
      expiry: _expiry,
    );
  }

  AutopilotRule? _preview(RuleDraft? d) => d == null
      ? null
      : AutopilotRule(
          id: 'draft',
          assetId: d.assetId,
          side: d.side,
          condition: d.condition,
          trigger: d.trigger,
          upper: d.upper,
          amount: d.amount,
          unit: d.unit,
          repeat: d.repeat,
          expiry: d.expiry,
          createdAt: DateTime(2000),
        );

  Future<void> _save(RuleDraft d, AssetInfo a) async {
    final l = AppLocalizations.of(context);
    final pin = await confirmWithPin(context, action: l.authoriseAutopilot);
    if (pin == null || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(automationRepositoryProvider).saveRule(d, pinToken: pin);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (_) {
        showToast(context, l.autopilotRuleIsLive);
        context.pushReplacementNamed(AppRoute.autopilot.name, queryParameters: {'type': a.kind.name});
      },
      err: (f) => showToast(context, l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final asset = ref.watch(catalogProvider).value?[widget.assetId];
    final price = ref.watch(quotesProvider).value?[widget.assetId]?.price;
    if (asset == null || price == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: jarinaAppBar(context, l.autopilotRule),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_seeded) _seed(asset, price);

    final buy = _side == RuleSide.buy;
    final stock = asset.isStock;
    final unitWord = stock ? l.shares2 : asset.id;
    final balances = ref.watch(balancesProvider).value;
    final cash = balances?.fiatOf(Currency.ngn).amount ?? Decimal.zero;
    final held = balances?.qtyOf(asset.id) ?? Decimal.zero;
    final feeRate = ref.watch(tradingRepositoryProvider).feeRate;
    final draft = _draft();
    final rule = _preview(draft);
    final valid = rule?.isValid ?? false;
    final low = _parse(_low);
    final high = _parse(_high);
    final amount = _parse(_amount) ?? Decimal.zero;

    // Price the estimate at the trigger (the middle of a range).
    final px = switch ((_condition, low, high)) {
      (RuleCondition.range, final lo?, final hi?) => ((lo + hi) / Decimal.fromInt(2)).toDecimal(
        scaleOnInfinitePrecision: 4,
      ),
      (_, final lo?, _) => lo,
      _ => price,
    };
    final max = switch ((_side, _unit)) {
      (RuleSide.buy, RuleAmountUnit.ngn) => cash,
      (RuleSide.buy, _) =>
        px > Decimal.zero
            ? (cash / px).toDecimal(scaleOnInfinitePrecision: 8).floor(scale: stock ? 0 : 6)
            : Decimal.zero,
      (RuleSide.sell, RuleAmountUnit.percent) => Decimal.fromInt(100),
      _ => held,
    };
    final over = amount > max && max >= Decimal.zero && amount > Decimal.zero;
    final one = Decimal.one;
    final estimate = switch ((_side, _unit)) {
      (RuleSide.buy, RuleAmountUnit.ngn) =>
        '≈ ${MoneyFormat.number((amount * (one - feeRate) / px).toDecimal(scaleOnInfinitePrecision: 8), decimals: stock ? 1 : 6)} $unitWord',
      (RuleSide.buy, _) =>
        '≈ ${MoneyFormat.format(Money(amount * px * (one + feeRate), Currency.ngn).rounded(), decimals: 0)}',
      (RuleSide.sell, final u) => () {
        final q = u == RuleAmountUnit.percent
            ? (held * amount / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 8)
            : amount;
        return '≈ ${MoneyFormat.format(Money(q * px * (one - feeRate), Currency.ngn).rounded(), decimals: 0)}';
      }(),
    };

    String vsNow(Decimal? v) {
      if (v == null) return '';
      final pct = ((v - price) / price).toDecimal(scaleOnInfinitePrecision: 6).shift(2).round();
      return l.vsNow('${pct >= Decimal.zero ? '+' : ''}$pct%');
    }

    final conds = buy
        ? {RuleCondition.range: l.fallsIntoARange, RuleCondition.below: l.fallsBelow}
        : {RuleCondition.above: l.risesAbove, RuleCondition.below: l.fallsBelowStopLoss};
    final units = buy
        ? {RuleAmountUnit.ngn: l.amount2, RuleAmountUnit.quantity: stock ? l.shares : l.units}
        : {RuleAmountUnit.quantity: stock ? l.shares : l.units, RuleAmountUnit.percent: l.ofHolding};
    final quick = buy ? const [-5, -10, -15, -20] : const [5, 10, 20, -10];
    final lowPct = low == null ? 0.0 : ((low.toDouble() / price.toDouble()) - 1) * 100;

    Widget label(String s, {String? right}) => Row(
      children: [
        Expanded(
          child: Text(
            s.toUpperCase(),
            style: t.caption.copyWith(color: c.muted, letterSpacing: 1.1, fontWeight: FontWeight.w700),
          ),
        ),
        if (right != null)
          Flexible(
            child: Text(
              right,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.caption.copyWith(color: c.muted),
            ),
          ),
      ],
    );

    Widget chips<T>(Map<T, String> options, T value, ValueChanged<T> onChanged) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in options.entries) JChip(label: e.value, selected: e.key == value, onTap: () => onChanged(e.key)),
      ],
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.autopilotRule),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 24),
          children: [
            _RuleChartCard(asset: asset, price: price, low: low, high: _condition == RuleCondition.range ? high : null),
            const SizedBox(height: 14),
            JSegmented<RuleSide>(
              segments: {RuleSide.buy: l.autoBuy, RuleSide.sell: l.autoSell},
              value: _side,
              onChanged: (s) {
                if (s != _side) _flip(asset, price);
              },
            ),
            const SizedBox(height: 14),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(l.whenThePrice, right: l.nowPrice(priceText(price))),
                  const SizedBox(height: 10),
                  chips(conds, _condition, (v) => setState(() => _condition = v)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TriggerField(
                          label: _condition == RuleCondition.range
                              ? l.from
                              : (_condition == RuleCondition.above ? l.risesAbove : l.fallsBelow),
                          controller: _low,
                          hint: vsNow(low),
                          up: (low ?? price) >= price,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      if (_condition == RuleCondition.range) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TriggerField(
                            label: l.to,
                            controller: _high,
                            hint: vsNow(high),
                            up: (high ?? price) >= price,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Slider(
                    value: lowPct.clamp(-40, 40),
                    min: -40,
                    max: 40,
                    divisions: 80,
                    semanticFormatterCallback: (v) => '${v.round()}%',
                    onChanged: (v) => setState(() {
                      final p = price.toDouble();
                      _low.text = _fmtPrice(price, p * (1 + v / 100));
                      if (_condition == RuleCondition.range) _high.text = _fmtPrice(price, p * (1 + (v + 9) / 100));
                    }),
                  ),
                  Row(
                    children: [
                      for (final (i, q) in quick.indexed) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: JChip(
                            label: '${q > 0 ? '+' : ''}$q%',
                            onTap: () => setState(() {
                              final p = price.toDouble();
                              _low.text = _fmtPrice(price, p * (1 + q / 100));
                              if (_condition == RuleCondition.range) {
                                _high.text = _fmtPrice(price, p * (1 + (q + 4) / 100));
                              }
                            }),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: IconButton.filled(
                  tooltip: l.switchBuySell,
                  style: IconButton.styleFrom(backgroundColor: c.black, foregroundColor: c.gold),
                  onPressed: () => _flip(asset, price),
                  icon: JarinaIcon(JIcon.swap, size: 20, color: c.gold),
                ),
              ),
            ),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(
                    buy ? l.thenBuyWith : l.thenSell,
                    right: buy
                        ? l.balanceOf(MoneyFormat.format(Money(cash, Currency.ngn), decimals: 0))
                        : l.youHold('${MoneyFormat.number(held, decimals: stock ? 0 : 6)} $unitWord'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _WalletPill(
                        badge: buy ? null : asset,
                        title: buy ? l.naira : asset.id,
                        sub: buy ? l.walletLabel : (stock ? l.yourShares : l.walletLabel),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _amount,
                          textAlign: TextAlign.end,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}\.?\d{0,8}'))],
                          style: t.amountL.copyWith(fontSize: 30, color: over ? c.down : null),
                          decoration: InputDecoration(
                            filled: false,
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '0',
                            hintStyle: t.amountL.copyWith(fontSize: 30, color: c.muted),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  if (over) ...[
                    const SizedBox(height: 6),
                    Text(l.moreThanYouHaveRule, style: t.caption.copyWith(color: c.down)),
                  ],
                  const SizedBox(height: 10),
                  chips(units, _unit, (v) => setState(() => _unit = v)),
                  const SizedBox(height: 4),
                  JPercentSlider(
                    value: max > Decimal.zero ? (amount / max).toDouble() : 0,
                    maxLabel: l.max,
                    onChanged: (p) => setState(() {
                      final v = max * Decimal.parse(p.toStringAsFixed(4));
                      final scale = _unit == RuleAmountUnit.ngn || _unit == RuleAmountUnit.percent || stock ? 0 : 6;
                      final r = v.floor(scale: scale);
                      _amount.text = r == Decimal.zero ? '' : r.toString();
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(
                    buy ? l.youGetEstimated : l.proceedsGoTo,
                    right: buy
                        ? l.youHold('${MoneyFormat.number(held, decimals: stock ? 0 : 6)} $unitWord')
                        : l.balanceOf(MoneyFormat.format(Money(cash, Currency.ngn), decimals: 0)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _WalletPill(
                        badge: buy ? asset : null,
                        title: buy ? asset.id : l.naira,
                        sub: buy ? (stock ? l.yourShares : l.walletLabel) : l.walletLabel,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerRight,
                          fit: BoxFit.scaleDown,
                          child: Text(estimate, style: t.title.copyWith(fontSize: 22)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.atTriggerFeeIncluded(MoneyFormat.percent(feeRate * Decimal.fromInt(100), decimals: 1)),
                          style: t.caption.copyWith(color: c.muted),
                        ),
                      ),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: c.up, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l.watching,
                        style: t.caption.copyWith(color: c.up, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.repeat,
                    style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  chips(
                    {RuleRepeat.once: l.runOnce, RuleRepeat.everyTime: l.everyTime},
                    _repeat,
                    (v) => setState(() => _repeat = v),
                  ),
                  const Divider(height: 24),
                  Text(
                    l.expires,
                    style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  chips(
                    {RuleExpiry.sevenDays: l.s7Days, RuleExpiry.thirtyDays: l.s30Days, RuleExpiry.never: l.never},
                    _expiry,
                    (v) => setState(() => _expiry = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            JCard(
              color: c.gold.withValues(alpha: 0.12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.summary,
                    style: t.caption.copyWith(color: c.goldDeep, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      valid ? ruleText(l, rule!, asset) : l.enterTriggerAndAmount,
                      style: t.body.copyWith(fontWeight: FontWeight.w700, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${buy ? l.fundsComeFromYourNairaWallet : l.proceedsGoToNaira} '
                    '${stock ? l.stockRulesRunOnlyDuringNgx : l.cryptoRulesRun247}',
                    style: t.caption.copyWith(color: c.ink2, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JSlideToConfirm(
          label: buy ? l.slideToSaveBuyRule : l.slideToSaveSellRule,
          disabledLabel: l.enterPriceAndAmount,
          onConfirm: valid && !_busy ? () => unawaited(_save(draft!, asset)) : null,
        ),
      ),
    );
  }
}

class _TriggerField extends StatelessWidget {
  const _TriggerField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.up,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool up;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.caption.copyWith(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Text('₦', style: t.title),
              const SizedBox(width: 2),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}\.?\d{0,2}'))],
                  style: t.title.copyWith(fontSize: 22),
                  decoration: const InputDecoration(
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.caption.copyWith(color: up ? c.up : c.down, fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.title, required this.sub, this.badge});

  final AssetInfo? badge;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final b = badge;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: ShapeDecoration(
        color: c.fill,
        shape: StadiumBorder(side: BorderSide(color: c.line)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (b != null)
            AssetBadge(b, size: 32)
          else
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.black, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '₦',
                style: t.body.copyWith(color: c.gold, fontWeight: FontWeight.w800),
              ),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.body.copyWith(fontWeight: FontWeight.w700)),
              Text(sub, style: t.caption.copyWith(color: c.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dark header: price, 7-day chart and the trigger price (or range).
class _RuleChartCard extends ConsumerWidget {
  const _RuleChartCard({required this.asset, required this.price, required this.low, required this.high});

  final AssetInfo asset;
  final Decimal price;
  final Decimal? low;
  final Decimal? high;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final history = ref.watch(assetHistoryProvider(asset.id, ChartRange.week)).value ?? const <double>[];
    final values = history.isEmpty ? <double>[] : [...history.take(history.length - 1), price.toDouble()];
    final change = values.length < 2 ? 0.0 : (values.last / values.first - 1) * 100;
    final up = change >= 0;
    return JBrandCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AssetBadge(asset, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.caption.copyWith(color: Colors.white60),
                    ),
                    Text(priceText(price), style: t.title.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  JChangePill(percent: change),
                  const SizedBox(height: 4),
                  Text(l.s7Days, style: t.caption.copyWith(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: values.length < 2
                ? null
                : CustomPaint(
                    size: Size.infinite,
                    painter: _TriggerChartPainter(
                      values: values,
                      low: low?.toDouble(),
                      high: high?.toDouble(),
                      line: up ? c.up : c.down,
                      trigger: c.gold,
                      label: t.caption.copyWith(color: c.gold, fontSize: 10, fontWeight: FontWeight.w700),
                      format: (v) => priceText(Decimal.parse(v.toStringAsFixed(2)), scale: high ?? low),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 14, height: 2, color: c.gold),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  high == null ? l.yourTriggerPrice : l.yourTriggerPriceRange,
                  style: t.caption.copyWith(color: Colors.white60, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TriggerChartPainter extends CustomPainter {
  _TriggerChartPainter({
    required this.values,
    required this.low,
    required this.high,
    required this.line,
    required this.trigger,
    required this.label,
    required this.format,
  });

  final List<double> values;
  final double? low;
  final double? high;
  final Color line;
  final Color trigger;
  final TextStyle label;
  final String Function(double) format;

  @override
  void paint(Canvas canvas, Size size) {
    final levels = [?low, ?high].where((v) => v > 0);
    final lo = [...values, ...levels].reduce(math.min) * 0.995;
    final hi = [...values, ...levels].reduce(math.max) * 1.005;
    double y(double v) => 4 + (hi - v) / (hi - lo) * (size.height - 8);
    double x(int i) => i / (values.length - 1) * size.width;

    if (low != null && high != null && high! > low!) {
      canvas.drawRect(
        Rect.fromLTRB(0, y(high!), size.width, y(low!)),
        Paint()..color = trigger.withValues(alpha: 0.14),
      );
    }
    final path = Path()..moveTo(0, y(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [line.withValues(alpha: 0.25), line.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );

    final dash = Paint()
      ..color = trigger
      ..strokeWidth = 1.5;
    for (final v in levels) {
      final yy = y(v);
      for (var dx = 0.0; dx < size.width; dx += 8) {
        canvas.drawLine(Offset(dx, yy), Offset(math.min(dx + 4, size.width), yy), dash);
      }
      final tp = TextPainter(
        text: TextSpan(text: format(v), style: label),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 2, yy - tp.height - 1));
    }
  }

  @override
  bool shouldRepaint(_TriggerChartPainter old) =>
      old.values != values || old.low != low || old.high != high || old.line != line;
}

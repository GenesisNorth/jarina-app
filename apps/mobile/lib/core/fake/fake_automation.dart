import 'dart:async';

import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina_core/jarina_core.dart';

/// Autopilot rules and price alerts, evaluated against the fake ledger's live
/// prices. In production this runs on the server (and sends push/SMS/email);
/// the app only manages the rules.
class FakeAutomation implements AutomationRepository {
  FakeAutomation(this._ledger, {this.latency = const Duration(milliseconds: 250), this.watchPrices = true}) {
    final now = _ledger.now();
    Decimal d(String v) => Decimal.parse(v);
    _rules = [
      AutopilotRule(
        id: 'r1',
        assetId: 'DANGCEM',
        side: RuleSide.buy,
        condition: RuleCondition.range,
        trigger: d('960'),
        upper: d('1040'),
        amount: d('100000'),
        unit: RuleAmountUnit.ngn,
        repeat: RuleRepeat.once,
        expiry: RuleExpiry.thirtyDays,
        createdAt: now,
      ),
      AutopilotRule(
        id: 'r2',
        assetId: 'DANGCEM',
        side: RuleSide.sell,
        condition: RuleCondition.above,
        trigger: d('1200'),
        amount: d('20'),
        unit: RuleAmountUnit.quantity,
        repeat: RuleRepeat.once,
        expiry: RuleExpiry.never,
        createdAt: now,
      ),
      AutopilotRule(
        id: 'r3',
        assetId: 'BTC',
        side: RuleSide.buy,
        condition: RuleCondition.below,
        trigger: d('92000000'),
        amount: d('50000'),
        unit: RuleAmountUnit.ngn,
        repeat: RuleRepeat.everyTime,
        expiry: RuleExpiry.never,
        createdAt: now,
      ),
      AutopilotRule(
        id: 'r4',
        assetId: 'MTNN',
        side: RuleSide.sell,
        condition: RuleCondition.below,
        trigger: d('780'),
        amount: d('50'),
        unit: RuleAmountUnit.percent,
        repeat: RuleRepeat.once,
        expiry: RuleExpiry.never,
        createdAt: now,
        enabled: false,
      ),
    ];
    _alerts = [
      PriceAlert(
        id: 'a1',
        assetId: 'MTNN',
        direction: AlertDirection.above,
        target: d('900'),
        channels: const {AlertChannel.push},
      ),
      PriceAlert(
        id: 'a2',
        assetId: 'BTC',
        direction: AlertDirection.below,
        target: d('95000000'),
        channels: const {AlertChannel.push, AlertChannel.sms},
      ),
      PriceAlert(
        id: 'a3',
        assetId: 'DANGCEM',
        direction: AlertDirection.below,
        target: d('1000'),
        channels: const {AlertChannel.push},
      ),
    ];
    _events = [
      AutomationEvent(
        kind: AutomationEventKind.alertFired,
        assetId: 'MTNN',
        at: now.subtract(const Duration(hours: 2)),
        price: d('850'),
        direction: AlertDirection.above,
      ),
      AutomationEvent(
        kind: AutomationEventKind.ruleFilled,
        assetId: 'DANGCEM',
        at: now.subtract(const Duration(days: 30)),
        price: d('1000'),
        side: RuleSide.buy,
        quantity: d('25'),
      ),
    ];
  }

  final FakeLedger _ledger;
  final Duration latency;

  /// Off in unit tests, which drive [evaluate] with their own prices.
  final bool watchPrices;

  late List<AutopilotRule> _rules;
  late List<PriceAlert> _alerts;
  late List<AutomationEvent> _events;
  final _rulesC = StreamController<List<AutopilotRule>>.broadcast();
  final _alertsC = StreamController<List<PriceAlert>>.broadcast();
  final _eventsC = StreamController<List<AutomationEvent>>.broadcast();
  StreamSubscription<Object?>? _prices;
  final _running = <String>{};
  var _seq = 10;

  Future<void> _wait() async {
    await _ledger.ready;
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  /// Starts watching prices the first time anything here is observed.
  void _ensureWatching() {
    if (!watchPrices) return;
    _prices ??= _ledger.watchQuotes().listen(
      (quotes) => unawaited(evaluate({for (final e in quotes.entries) e.key: e.value.price})),
    );
  }

  Stream<List<T>> _watch<T>(StreamController<List<T>> c, List<T> Function() current) {
    _ensureWatching();
    return Stream.multi((out) {
      final sub = c.stream.listen(out.add, onError: out.addError);
      out
        ..add(current())
        ..onCancel = sub.cancel;
    });
  }

  void _emitRules() => _rulesC.add(List.unmodifiable(_rules));
  void _emitAlerts() => _alertsC.add(List.unmodifiable(_alerts));
  void _emitEvents() => _eventsC.add(List.unmodifiable(_events));

  void _event(AutomationEvent e) {
    _events = [e, ..._events];
    _emitEvents();
  }

  /// Runs rules and alerts against [prices]. Public so tests can drive it.
  Future<void> evaluate(Map<String, Decimal> prices) async {
    final now = _ledger.now();

    // Alerts fire once per crossing and re-arm when the price moves back.
    var alertsChanged = false;
    _alerts = [
      for (final a in _alerts)
        if (prices[a.assetId] case final price?)
          () {
            if (a.shouldFire(price)) {
              alertsChanged = true;
              _event(
                AutomationEvent(
                  kind: AutomationEventKind.alertFired,
                  assetId: a.assetId,
                  at: now,
                  price: price,
                  direction: a.direction,
                ),
              );
              return a.copyWith(armed: false);
            }
            if (!a.armed && !a.matches(price)) {
              alertsChanged = true;
              return a.copyWith(armed: true);
            }
            return a;
          }()
        else
          a,
    ];
    if (alertsChanged) _emitAlerts();

    final catalog = await _ledger.catalog();
    for (final r in List.of(_rules)) {
      final price = prices[r.assetId];
      final asset = catalog.where((a) => a.id == r.assetId).firstOrNull;
      if (price == null || asset == null || _running.contains(r.id)) continue;
      if (r.isExpired(now) && r.enabled) {
        _replace(r.copyWith(enabled: false));
        continue;
      }
      final open = !asset.isStock || NgxSchedule.isOpen(now);
      if (!r.armed && !r.matches(price)) {
        _replace(r.copyWith(armed: true));
        continue;
      }
      if (!r.shouldFire(price, now, marketOpen: open)) continue;
      _running.add(r.id);
      try {
        await _execute(r, price, isStock: asset.isStock);
      } finally {
        _running.remove(r.id);
      }
    }
  }

  Future<void> _execute(AutopilotRule r, Decimal price, {required bool isStock}) async {
    final Result<TradeQuote> quote;
    if (r.side == RuleSide.buy) {
      final spend = r.unit == RuleAmountUnit.ngn ? r.amount : r.amount * price;
      quote = await _ledger.quoteBuy(r.assetId, Money(spend, Currency.ngn).rounded());
    } else {
      final held = (await _ledger.watchBalances().first).qtyOf(r.assetId);
      final want = r.unit == RuleAmountUnit.percent
          ? (held * r.amount / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 12)
          : r.amount;
      // "If you hold fewer than set, we sell what you have."
      final qty = (want > held ? held : want).floor(scale: isStock ? 0 : 8);
      quote = qty > Decimal.zero ? await _ledger.quoteSell(r.assetId, qty) : const Err(InsufficientFundsFailure());
    }
    final now = _ledger.now();
    final placed = switch (quote) {
      Ok(:final value) => await _ledger.placeOrder(value, pinToken: 'autopilot:${r.id}'),
      Err(:final failure) => Err<Transaction>(failure),
    };
    final current = _rules.where((x) => x.id == r.id).firstOrNull;
    if (current == null) return;
    switch (placed) {
      case Ok(:final value):
        _event(
          AutomationEvent(
            kind: AutomationEventKind.ruleFilled,
            assetId: r.assetId,
            at: now,
            price: price,
            side: r.side,
            quantity: quote.valueOrNull?.quantity,
            txId: value.id,
          ),
        );
      case Err():
        _event(
          AutomationEvent(
            kind: AutomationEventKind.ruleSkipped,
            assetId: r.assetId,
            at: now,
            price: price,
            side: r.side,
          ),
        );
    }
    // A "run once" rule is done after one attempt; "every time" waits for the
    // price to leave the condition before it can fire again.
    _replace(r.repeat == RuleRepeat.once ? current.copyWith(enabled: false) : current.copyWith(armed: false));
  }

  void _replace(AutopilotRule r) {
    _rules = [
      for (final x in _rules)
        if (x.id == r.id) r else x,
    ];
    _emitRules();
  }

  @override
  Stream<List<AutopilotRule>> watchRules() => _watch(_rulesC, () => _rules);

  @override
  Future<Result<AutopilotRule>> saveRule(RuleDraft d, {required String pinToken}) async {
    await _wait();
    final rule = AutopilotRule(
      id: 'r${++_seq}',
      assetId: d.assetId,
      side: d.side,
      condition: d.condition,
      trigger: d.trigger,
      upper: d.condition == RuleCondition.range ? d.upper : null,
      amount: d.amount,
      unit: d.unit,
      repeat: d.repeat,
      expiry: d.expiry,
      createdAt: _ledger.now(),
    );
    if (!rule.isValid) return const Err(InvalidRuleFailure());
    // A rule created while its condition already holds waits for the next
    // crossing, so saving never trades instantly by surprise.
    final price = _ledger.priceOf(d.assetId);
    final saved = rule.matches(price) ? rule.copyWith(armed: false) : rule;
    _rules = [saved, ..._rules];
    _emitRules();
    return Ok(saved);
  }

  @override
  Future<Result<void>> setRuleEnabled(String id, {required bool enabled}) async {
    await _wait();
    final r = _rules.where((x) => x.id == id).firstOrNull;
    if (r == null) return const Err(ValidationFailure('Rule not found'));
    _replace(r.copyWith(enabled: enabled, armed: enabled ? !r.matches(_ledger.priceOf(r.assetId)) : r.armed));
    return const Ok(null);
  }

  @override
  Future<Result<void>> deleteRule(String id) async {
    await _wait();
    _rules = [..._rules.where((x) => x.id != id)];
    _emitRules();
    return const Ok(null);
  }

  @override
  Stream<List<PriceAlert>> watchAlerts() => _watch(_alertsC, () => _alerts);

  @override
  Future<Result<PriceAlert>> saveAlert({
    required String assetId,
    required AlertDirection direction,
    required Decimal target,
    required Set<AlertChannel> channels,
  }) async {
    await _wait();
    if (target <= Decimal.zero) return const Err(ValidationFailure('Enter a price'));
    if (channels.isEmpty) return const Err(ValidationFailure('Pick at least one channel'));
    final a = PriceAlert(
      id: 'a${++_seq}',
      assetId: assetId,
      direction: direction,
      target: target,
      channels: channels,
    );
    final saved = a.matches(_ledger.priceOf(assetId)) ? a.copyWith(armed: false) : a;
    _alerts = [saved, ..._alerts];
    _emitAlerts();
    return Ok(saved);
  }

  @override
  Future<Result<void>> setAlertEnabled(String id, {required bool enabled}) async {
    await _wait();
    _alerts = [
      for (final a in _alerts)
        if (a.id == id) a.copyWith(enabled: enabled) else a,
    ];
    _emitAlerts();
    return const Ok(null);
  }

  @override
  Future<Result<void>> deleteAlert(String id) async {
    await _wait();
    _alerts = [..._alerts.where((a) => a.id != id)];
    _emitAlerts();
    return const Ok(null);
  }

  @override
  Stream<List<AutomationEvent>> watchEvents() => _watch(_eventsC, () => _events);

  void dispose() {
    unawaited(_prices?.cancel());
    unawaited(_rulesC.close());
    unawaited(_alertsC.close());
    unawaited(_eventsC.close());
  }
}

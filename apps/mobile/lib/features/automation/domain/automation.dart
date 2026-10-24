import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

enum RuleSide { buy, sell }

/// When a rule fires. Buy rules use [range] or [below]; sell rules use
/// [above] (take profit) or [below] (stop-loss).
enum RuleCondition { range, below, above }

/// What [AutopilotRule.amount] means: Naira to spend, a quantity (shares or
/// coins), or a percentage of the holding (sell only).
enum RuleAmountUnit { ngn, quantity, percent }

enum RuleRepeat { once, everyTime }

enum RuleExpiry {
  sevenDays(Duration(days: 7)),
  thirtyDays(Duration(days: 30)),
  never(null);

  const RuleExpiry(this.duration);
  final Duration? duration;
}

/// An Autopilot rule: "When DANGCEM trades between ₦960 and ₦1,040, buy
/// ₦100,000 worth." Funds come from (and proceeds go to) the Naira wallet.
///
/// Rules are evaluated on the server; stock rules only while NGX is open.
@immutable
class AutopilotRule {
  const AutopilotRule({
    required this.id,
    required this.assetId,
    required this.side,
    required this.condition,
    required this.trigger,
    required this.amount,
    required this.unit,
    required this.repeat,
    required this.expiry,
    required this.createdAt,
    this.upper,
    this.enabled = true,
    this.armed = true,
  });

  final String id;
  final String assetId;
  final RuleSide side;
  final RuleCondition condition;

  /// The price that fires the rule; the lower bound for [RuleCondition.range].
  final Decimal trigger;

  /// Upper bound for [RuleCondition.range].
  final Decimal? upper;
  final Decimal amount;
  final RuleAmountUnit unit;
  final RuleRepeat repeat;
  final RuleExpiry expiry;
  final DateTime createdAt;
  final bool enabled;

  /// "Every time" rules re-arm only after the price leaves the condition,
  /// so a price sitting inside a range doesn't fire on every tick.
  final bool armed;

  DateTime? get expiresAt => expiry.duration == null ? null : createdAt.add(expiry.duration!);

  bool isExpired(DateTime now) => expiresAt != null && !now.isBefore(expiresAt!);

  /// Whether [price] satisfies the condition (ignores enabled/armed/expiry).
  bool matches(Decimal price) => switch (condition) {
    RuleCondition.range => price >= trigger && price <= (upper ?? trigger),
    RuleCondition.below => price < trigger,
    RuleCondition.above => price > trigger,
  };

  /// Whether the rule should fire now.
  bool shouldFire(Decimal price, DateTime now, {required bool marketOpen}) =>
      enabled && armed && marketOpen && !isExpired(now) && matches(price);

  /// Distance from [price] to the nearest trigger, as a fraction of [price].
  /// Zero when the condition is already met.
  Decimal distance(Decimal price) {
    if (matches(price) || price == Decimal.zero) return Decimal.zero;
    final target = condition == RuleCondition.range && price > (upper ?? trigger) ? upper! : trigger;
    return ((price - target).abs() / price).toDecimal(scaleOnInfinitePrecision: 6);
  }

  /// A valid draft: positive trigger and amount, a proper range, at most 100%.
  bool get isValid =>
      trigger > Decimal.zero &&
      amount > Decimal.zero &&
      (condition != RuleCondition.range || (upper != null && upper! > trigger)) &&
      (unit != RuleAmountUnit.percent || amount <= Decimal.fromInt(100)) &&
      (side == RuleSide.sell || unit != RuleAmountUnit.percent) &&
      (side == RuleSide.sell || condition != RuleCondition.above) &&
      (side == RuleSide.buy || condition != RuleCondition.range);

  AutopilotRule copyWith({bool? enabled, bool? armed}) => AutopilotRule(
    id: id,
    assetId: assetId,
    side: side,
    condition: condition,
    trigger: trigger,
    upper: upper,
    amount: amount,
    unit: unit,
    repeat: repeat,
    expiry: expiry,
    createdAt: createdAt,
    enabled: enabled ?? this.enabled,
    armed: armed ?? this.armed,
  );
}

enum AlertDirection { above, below }

enum AlertChannel { push, sms, email }

@immutable
class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.assetId,
    required this.direction,
    required this.target,
    required this.channels,
    this.enabled = true,
    this.armed = true,
  });

  final String id;
  final String assetId;
  final AlertDirection direction;
  final Decimal target;
  final Set<AlertChannel> channels;
  final bool enabled;

  /// Fires once per crossing: re-arms when the price moves back.
  final bool armed;

  bool matches(Decimal price) => direction == AlertDirection.above ? price > target : price < target;

  bool shouldFire(Decimal price) => enabled && armed && matches(price);

  PriceAlert copyWith({bool? enabled, bool? armed}) => PriceAlert(
    id: id,
    assetId: assetId,
    direction: direction,
    target: target,
    channels: channels,
    enabled: enabled ?? this.enabled,
    armed: armed ?? this.armed,
  );
}

enum AutomationEventKind { alertFired, ruleFilled, ruleSkipped }

/// Something Autopilot or an alert did, shown under "Recent notifications".
@immutable
class AutomationEvent {
  const AutomationEvent({
    required this.kind,
    required this.assetId,
    required this.at,
    required this.price,
    this.direction,
    this.side,
    this.quantity,
    this.txId,
  });

  final AutomationEventKind kind;
  final String assetId;
  final DateTime at;
  final Decimal price;
  final AlertDirection? direction;
  final RuleSide? side;
  final Decimal? quantity;
  final String? txId;
}

/// A rule being drafted on the rule screen (no id yet).
typedef RuleDraft = ({
  String assetId,
  RuleSide side,
  RuleCondition condition,
  Decimal trigger,
  Decimal? upper,
  Decimal amount,
  RuleAmountUnit unit,
  RuleRepeat repeat,
  RuleExpiry expiry,
});

final class InvalidRuleFailure extends Failure {
  const InvalidRuleFailure() : super('Check the trigger price and amount');
}

abstract interface class AutomationRepository {
  Stream<List<AutopilotRule>> watchRules();

  /// Saving a rule authorises Jarina to trade for the user, so it needs the PIN.
  Future<Result<AutopilotRule>> saveRule(RuleDraft draft, {required String pinToken});

  Future<Result<void>> setRuleEnabled(String id, {required bool enabled});

  Future<Result<void>> deleteRule(String id);

  Stream<List<PriceAlert>> watchAlerts();

  Future<Result<PriceAlert>> saveAlert({
    required String assetId,
    required AlertDirection direction,
    required Decimal target,
    required Set<AlertChannel> channels,
  });

  Future<Result<void>> setAlertEnabled(String id, {required bool enabled});

  Future<Result<void>> deleteAlert(String id);

  /// Newest first.
  Stream<List<AutomationEvent>> watchEvents();
}

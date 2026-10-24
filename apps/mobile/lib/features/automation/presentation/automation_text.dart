import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';

/// Naira price with the precision traders expect: whole naira from ₦1,000,
/// kobo below (MTNN ₦861.90, DANGCEM ₦1,067).
/// [scale] decides the precision when several prices are shown together
/// (a range uses its upper bound, so both ends match).
String priceText(Decimal price, {Decimal? scale}) =>
    MoneyFormat.format(Money(price, Currency.ngn), decimals: (scale ?? price) >= Decimal.fromInt(1000) ? 0 : 2);

/// "When DANGCEM trades between ₦960 and ₦1,040, buy ₦100,000 worth."
String ruleText(AppLocalizations l, AutopilotRule r, AssetInfo? asset) {
  final when = switch (r.condition) {
    RuleCondition.range => l.ruleWhenRange(
      r.assetId,
      priceText(r.trigger, scale: r.upper),
      priceText(r.upper ?? r.trigger),
    ),
    RuleCondition.below => l.ruleWhenBelow(r.assetId, priceText(r.trigger)),
    RuleCondition.above => l.ruleWhenAbove(r.assetId, priceText(r.trigger)),
  };
  final isStock = asset?.isStock ?? true;
  final unitWord = isStock ? l.shares2 : r.assetId;
  final amount = switch (r.unit) {
    RuleAmountUnit.ngn => l.amountWorth(MoneyFormat.format(Money(r.amount, Currency.ngn), decimals: 0)),
    RuleAmountUnit.percent => l.percentOfMy('${r.amount}', unitWord),
    RuleAmountUnit.quantity =>
      '${MoneyFormat.number(r.amount, decimals: isStock ? 0 : _decimalsOf(r.amount))} $unitWord',
  };
  return r.side == RuleSide.buy ? l.ruleSentenceBuy(when, amount) : l.ruleSentenceSell(when, amount);
}

int _decimalsOf(Decimal d) => d.scale.clamp(0, 8);

/// "Runs once · Expires in 30 days".
String ruleSchedule(AppLocalizations l, AutopilotRule r) => [
  if (r.repeat == RuleRepeat.once) l.runsOnce else l.repeatsEveryTime,
  switch (r.expiry) {
    RuleExpiry.sevenDays => l.expiresIn(l.s7Days),
    RuleExpiry.thirtyDays => l.expiresIn(l.s30Days),
    RuleExpiry.never => l.untilCancelled,
  },
].join(' · ');

/// Status pill: Paused, Condition met, or how far the price is.
enum RuleStatusKind { paused, met, away }

(RuleStatusKind, String) ruleStatus(AppLocalizations l, AutopilotRule r, Decimal? price) {
  if (!r.enabled) return (RuleStatusKind.paused, l.paused);
  if (price == null) return (RuleStatusKind.away, l.watching);
  if (r.matches(price)) return (RuleStatusKind.met, l.conditionMet);
  final pct = (r.distance(price) * Decimal.fromInt(100)).round(scale: 1);
  return (RuleStatusKind.away, l.percentAway('$pct'));
}

String alertTitle(AppLocalizations l, PriceAlert a) => a.direction == AlertDirection.above
    ? l.alertTitleAbove(a.assetId, priceText(a.target))
    : l.alertTitleBelow(a.assetId, priceText(a.target));

String channelLabel(AppLocalizations l, AlertChannel c) => switch (c) {
  AlertChannel.push => l.push,
  AlertChannel.sms => l.sms,
  AlertChannel.email => l.email,
};

String channelsText(AppLocalizations l, Set<AlertChannel> channels) => [
  for (final c in AlertChannel.values)
    if (channels.contains(c)) channelLabel(l, c),
].join(', ');

String eventText(AppLocalizations l, AutomationEvent e, AssetInfo? asset) {
  final price = priceText(e.price);
  final qty = e.quantity == null ? '' : MoneyFormat.number(e.quantity!, decimals: asset?.isStock ?? true ? 0 : 6);
  return switch (e.kind) {
    AutomationEventKind.alertFired =>
      e.direction == AlertDirection.above ? l.eventRoseAbove(e.assetId, price) : l.eventFellBelow(e.assetId, price),
    AutomationEventKind.ruleFilled =>
      e.side == RuleSide.sell
          ? l.eventAutopilotSold(qty, e.assetId, price)
          : l.eventAutopilotBought(qty, e.assetId, price),
    AutomationEventKind.ruleSkipped => l.eventAutopilotSkipped(e.assetId),
  };
}

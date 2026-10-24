import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/core/fake/fake_automation.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina_core/jarina_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Monday 11:00 WAT (NGX open) and Saturday (closed).
  final open = DateTime.utc(2026, 10, 19, 10);
  final weekend = DateTime.utc(2026, 10, 24, 10);
  Decimal d(String v) => Decimal.parse(v);

  late FakeLedger ledger;
  late FakeAutomation auto;
  var made = false;
  void setUpAt(DateTime now) {
    ledger = FakeLedger(latency: Duration.zero, tick: Duration.zero, clock: () => now);
    auto = FakeAutomation(ledger, latency: Duration.zero, watchPrices: false);
    made = true;
  }

  tearDown(() {
    if (!made) return;
    auto.dispose();
    ledger.dispose();
    made = false;
  });

  Future<List<AutopilotRule>> rules() => auto.watchRules().first;
  Future<List<AutomationEvent>> events() => auto.watchEvents().first;
  Future<Decimal> cash() async => (await ledger.watchBalances().first).fiatOf(Currency.ngn).amount;

  RuleDraft draft({
    String asset = 'DANGCEM',
    RuleSide side = RuleSide.buy,
    RuleCondition condition = RuleCondition.below,
    String trigger = '900',
    String? upper,
    String amount = '10000',
    RuleAmountUnit unit = RuleAmountUnit.ngn,
    RuleRepeat repeat = RuleRepeat.once,
  }) => (
    assetId: asset,
    side: side,
    condition: condition,
    trigger: d(trigger),
    upper: upper == null ? null : d(upper),
    amount: d(amount),
    unit: unit,
    repeat: repeat,
    expiry: RuleExpiry.thirtyDays,
  );

  group('rule maths', () {
    final r = AutopilotRule(
      id: 'x',
      assetId: 'DANGCEM',
      side: RuleSide.buy,
      condition: RuleCondition.range,
      trigger: d('960'),
      upper: d('1040'),
      amount: d('100000'),
      unit: RuleAmountUnit.ngn,
      repeat: RuleRepeat.once,
      expiry: RuleExpiry.sevenDays,
      createdAt: open,
    );

    test('range matches inclusively and measures distance to the nearer edge', () {
      expect(r.matches(d('960')), isTrue);
      expect(r.matches(d('1040')), isTrue);
      expect(r.matches(d('1041')), isFalse);
      expect(r.distance(d('1066.67')).toDouble(), closeTo(0.025, 0.001));
      expect(r.distance(d('1000')), Decimal.zero);
    });

    test('expires after its window', () {
      expect(r.isExpired(open.add(const Duration(days: 6))), isFalse);
      expect(r.isExpired(open.add(const Duration(days: 7))), isTrue);
      expect(r.shouldFire(d('1000'), open.add(const Duration(days: 8)), marketOpen: true), isFalse);
    });

    test('validation rejects inverted ranges, >100% and buy-by-percent', () {
      expect(r.isValid, isTrue);
      AutopilotRule with_({RuleCondition? c, String? up, RuleAmountUnit? u, String amt = '10', RuleSide? s}) =>
          AutopilotRule(
            id: 'y',
            assetId: 'DANGCEM',
            side: s ?? RuleSide.buy,
            condition: c ?? RuleCondition.range,
            trigger: d('960'),
            upper: up == null ? null : d(up),
            amount: d(amt),
            unit: u ?? RuleAmountUnit.ngn,
            repeat: RuleRepeat.once,
            expiry: RuleExpiry.never,
            createdAt: open,
          );
      expect(with_(up: '900').isValid, isFalse);
      expect(with_(c: RuleCondition.below, u: RuleAmountUnit.percent).isValid, isFalse);
      expect(with_(c: RuleCondition.above, s: RuleSide.sell, u: RuleAmountUnit.percent, amt: '120').isValid, isFalse);
      expect(with_(c: RuleCondition.above).isValid, isFalse, reason: 'buy-above is not offered');
    });
  });

  test('a stock buy rule fires once while NGX is open, then turns off', () async {
    setUpAt(open);
    final before = await cash();
    final saved = (await auto.saveRule(draft(), pinToken: 'p')).valueOrNull!;
    await auto.evaluate({'DANGCEM': d('890')});
    final r = (await rules()).firstWhere((x) => x.id == saved.id);
    expect(r.enabled, isFalse, reason: 'run once');
    expect((await events()).first.kind, AutomationEventKind.ruleFilled);
    expect(await cash(), lessThan(before));

    await auto.evaluate({'DANGCEM': d('880')});
    expect((await events()).where((e) => e.kind == AutomationEventKind.ruleFilled).length, 2, reason: 'seed + 1');
  });

  test('stock rules wait for market hours; crypto rules run 24/7', () async {
    setUpAt(weekend);
    final stock = (await auto.saveRule(draft(), pinToken: 'p')).valueOrNull!;
    final coin = (await auto.saveRule(
      draft(asset: 'BTC', trigger: '200000000'),
      pinToken: 'p',
    )).valueOrNull!;
    expect(coin.armed, isFalse, reason: 'condition already true when saved: waits for the next crossing');
    await auto.evaluate({'DANGCEM': d('890'), 'BTC': d('250000000')});
    await auto.evaluate({'BTC': d('190000000')});
    final rs = await rules();
    expect(rs.firstWhere((r) => r.id == stock.id).enabled, isTrue, reason: 'NGX closed');
    expect(rs.firstWhere((r) => r.id == coin.id).enabled, isFalse, reason: 'crypto filled');
  });

  test('"every time" rules re-arm only after the price leaves the condition', () async {
    setUpAt(open);
    final r = (await auto.saveRule(
      draft(asset: 'BTC', trigger: '200000000', repeat: RuleRepeat.everyTime),
      pinToken: 'p',
    )).valueOrNull!;
    Future<int> fills() async => (await events()).where((e) => e.assetId == 'BTC').length;
    await auto.evaluate({'BTC': d('250000000')}); // re-arm
    await auto.evaluate({'BTC': d('190000000')}); // fill
    await auto.evaluate({'BTC': d('180000000')}); // still below: no fill
    expect(await fills(), 1);
    await auto.evaluate({'BTC': d('210000000')}); // leaves: re-arms
    await auto.evaluate({'BTC': d('190000000')}); // fill again
    expect(await fills(), 2);
    expect((await rules()).firstWhere((x) => x.id == r.id).enabled, isTrue);
  });

  test('sell by percent sells whole shares of what is held', () async {
    setUpAt(open);
    final held = (await ledger.watchBalances().first).qtyOf('DANGCEM');
    expect(held, greaterThan(Decimal.zero));
    await auto.saveRule(
      draft(
        side: RuleSide.sell,
        condition: RuleCondition.above,
        trigger: '1100',
        amount: '50',
        unit: RuleAmountUnit.percent,
      ),
      pinToken: 'p',
    );
    await auto.evaluate({'DANGCEM': d('1200')});
    final left = (await ledger.watchBalances().first).qtyOf('DANGCEM');
    expect(left, held - (held / Decimal.fromInt(2)).toDecimal(scaleOnInfinitePrecision: 4).floor());
  });

  test('a rule without enough cash is skipped and reported', () async {
    setUpAt(open);
    await auto.saveRule(draft(amount: '99000000'), pinToken: 'p');
    await auto.evaluate({'DANGCEM': d('890')});
    expect((await events()).first.kind, AutomationEventKind.ruleSkipped);
  });

  test('alerts fire once per crossing', () async {
    setUpAt(open);
    await auto.setAlertEnabled('a1', enabled: false); // the seeded "MTNN above ₦900"
    final a = (await auto.saveAlert(
      assetId: 'MTNN',
      direction: AlertDirection.above,
      target: d('2000'),
      channels: const {AlertChannel.push},
    )).valueOrNull!;
    Future<int> fired() async => (await events()).where((e) => e.assetId == 'MTNN' && e.price > d('2000')).length;
    await auto.evaluate({'MTNN': d('2100')});
    await auto.evaluate({'MTNN': d('2200')});
    expect(await fired(), 1);
    await auto.evaluate({'MTNN': d('1900')});
    await auto.evaluate({'MTNN': d('2050')});
    expect(await fired(), 2);
    await auto.setAlertEnabled(a.id, enabled: false);
    await auto.evaluate({'MTNN': d('1900')});
    await auto.evaluate({'MTNN': d('2300')});
    expect(await fired(), 2, reason: 'disabled');
    expect(
      (await auto.saveAlert(
        assetId: 'MTNN',
        direction: AlertDirection.below,
        target: d('1'),
        channels: const {},
      )).valueOrNull,
      isNull,
      reason: 'needs a channel',
    );
  });
}

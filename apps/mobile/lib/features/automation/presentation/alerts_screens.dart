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
import 'package:jarina/features/automation/application/automation_state.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/automation/presentation/automation_text.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Active price alerts and what Autopilot and alerts did recently.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value ?? const <String, AssetInfo>{};
    final quotes = ref.watch(quotesProvider).value;
    final alerts = ref.watch(priceAlertsProvider).value ?? const <PriceAlert>[];
    final events = ref.watch(automationEventsProvider).value ?? const <AutomationEvent>[];
    final now = ref.watch(clockProvider)();
    void newAlert() => context.pushNamed(AppRoute.picker.name, queryParameters: {'for': 'alert'});

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(
        context,
        l.priceAlerts,
        actions: [
          TextButton.icon(
            onPressed: newAlert,
            icon: const JarinaIcon(JIcon.plus, size: 18),
            label: Text(l.newLabel),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          JSectionHeader(title: l.activeAlerts),
          const SizedBox(height: 10),
          if (alerts.isEmpty)
            JCard(
              child: Text(l.noAlertsYet, style: t.body.copyWith(color: c.muted)),
            )
          else
            RowsCard(
              children: [
                for (final a in alerts)
                  _AlertRow(alert: a, asset: catalog[a.assetId], price: quotes?[a.assetId]?.price),
              ],
            ),
          const SizedBox(height: 14),
          JButton(label: l.newPriceAlert, icon: JIcon.bell, variant: JButtonVariant.soft, onPressed: newAlert),
          const SizedBox(height: 22),
          JSectionHeader(title: l.recentNotifications),
          const SizedBox(height: 10),
          if (events.isEmpty)
            JCard(
              child: Text(l.noNotificationsYet, style: t.body.copyWith(color: c.muted)),
            )
          else
            RowsCard(
              children: [
                for (final e in events.take(20))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(10)),
                          child: JarinaIcon(
                            e.kind == AutomationEventKind.alertFired ? JIcon.bell : JIcon.auto,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(eventText(l, e, catalog[e.assetId]), style: t.body.copyWith(height: 1.35)),
                              const SizedBox(height: 2),
                              Text(
                                activityDate(l, e.at, now: now),
                                style: t.caption.copyWith(color: c.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AlertRow extends ConsumerWidget {
  const _AlertRow({required this.alert, required this.asset, required this.price});

  final PriceAlert alert;
  final AssetInfo? asset;
  final Decimal? price;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final a = asset;
    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        color: c.down.withValues(alpha: 0.12),
        child: JarinaIcon(JIcon.trash, size: 18, color: c.down),
      ),
      onDismissed: (_) async {
        await ref.read(automationRepositoryProvider).deleteAlert(alert.id);
        if (context.mounted) showToast(context, l.alertDeleted);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (a != null) AssetBadge(a) else const SizedBox(width: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alertTitle(l, alert), style: t.body.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    [if (price != null) l.nowPrice(priceText(price!)), channelsText(l, alert.channels)].join(' · '),
                    style: t.caption.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            Semantics(
              label: l.alertOn,
              child: Switch(
                value: alert.enabled,
                onChanged: (v) =>
                    unawaited(ref.read(automationRepositoryProvider).setAlertEnabled(alert.id, enabled: v)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Create a price alert for one asset.
class AlertScreen extends ConsumerStatefulWidget {
  const AlertScreen({required this.assetId, super.key});

  final String assetId;

  @override
  ConsumerState<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends ConsumerState<AlertScreen> {
  final _price = TextEditingController();
  AlertDirection _direction = AlertDirection.above;
  final _channels = <AlertChannel>{AlertChannel.push};
  bool _seeded = false;
  bool _busy = false;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  static String _fmt(Decimal ref, double v) =>
      ref >= Decimal.fromInt(1000) ? v.round().toString() : v.toStringAsFixed(2);

  Future<void> _save(Decimal target) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref
        .read(automationRepositoryProvider)
        .saveAlert(assetId: widget.assetId, direction: _direction, target: target, channels: {..._channels});
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (_) {
        showToast(context, l.alertSet);
        context.pop();
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
    final now = ref.watch(quotesProvider).value?[widget.assetId]?.price;
    if (asset == null || now == null) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: jarinaAppBar(context, l.createAnAlert),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_seeded) {
      _price.text = _fmt(now, now.toDouble() * 1.05);
      _seeded = true;
    }
    final target = Decimal.tryParse(_price.text);
    final p = now.toDouble();
    final diff = target == null || target == Decimal.zero ? null : (target.toDouble() / p - 1) * 100;
    final ok = target != null && target > Decimal.zero && _channels.isNotEmpty;
    final channels = channelsText(l, _channels);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.createAnAlert),
      body: GestureDetector(
        // Dismisses the keyboard; not a control, so hidden from screen readers.
        excludeFromSemantics: true,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 24),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: c.black, shape: BoxShape.circle),
                child: JarinaIcon(JIcon.bell, size: 30, color: c.gold),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.createAnAlertPrice, textAlign: TextAlign.center, style: t.title),
            const SizedBox(height: 4),
            Text(
              l.alertNotifyBody(asset.id),
              textAlign: TextAlign.center,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Text(
                target == null ? '—' : priceText(target),
                textAlign: TextAlign.center,
                style: t.amountL.copyWith(fontSize: 32),
              ),
            ),
            Slider(
              value: (target?.toDouble() ?? p).clamp(p * 0.5, p * 1.5),
              min: p * 0.5,
              max: p * 1.5,
              semanticFormatterCallback: (v) => priceText(Decimal.parse(v.toStringAsFixed(2))),
              onChanged: (v) => setState(() {
                _price.text = _fmt(now, v);
                _direction = v >= p ? AlertDirection.above : AlertDirection.below;
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AssetBadge(asset, size: 44),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.id, style: t.title),
                    Text(l.nowPrice(priceText(now)), style: t.caption.copyWith(color: c.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l.alertMeWhenThePrice,
              style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
            ),
            const SizedBox(height: 8),
            JSegmented<AlertDirection>(
              segments: {AlertDirection.above: l.goesAbove, AlertDirection.below: l.goesBelow},
              value: _direction,
              onChanged: (d) => setState(() => _direction = d),
            ),
            const SizedBox(height: 18),
            JTextField(
              label: l.targetPrice,
              controller: _price,
              large: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}\.?\d{0,2}'))],
              helperText: diff == null
                  ? null
                  : l.fromCurrentPrice('${diff >= 0 ? '+' : '−'}${diff.abs().toStringAsFixed(1)}%'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in const [-10, -5, 5, 10])
                  JChip(
                    label: '${q > 0 ? '+' : '−'}${q.abs()}%',
                    onTap: () => setState(() {
                      _price.text = _fmt(now, p * (1 + q / 100));
                      _direction = q > 0 ? AlertDirection.above : AlertDirection.below;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l.notifyMeBy,
              style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ch in AlertChannel.values)
                  JChip(
                    label: channelLabel(l, ch),
                    selected: _channels.contains(ch),
                    onTap: () => setState(() => _channels.contains(ch) ? _channels.remove(ch) : _channels.add(ch)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            JCard(
              color: c.fill,
              child: Text(
                !ok
                    ? l.pickPriceAndChannel
                    : _direction == AlertDirection.above
                    ? l.alertSummaryAbove(channels, asset.id, priceText(target))
                    : l.alertSummaryBelow(channels, asset.id, priceText(target)),
                style: t.body.copyWith(height: 1.45, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              icon: const JarinaIcon(JIcon.auto, size: 18),
              label: Text(l.wantJarinaToTradeAutomaticallyInstead, textAlign: TextAlign.start),
              onPressed: () => context.pushReplacementNamed(AppRoute.rule.name, queryParameters: {'asset': asset.id}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JButton(label: l.setAlert, loading: _busy, onPressed: ok ? () => unawaited(_save(target)) : null),
      ),
    );
  }
}

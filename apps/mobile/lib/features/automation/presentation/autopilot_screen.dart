import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/automation/application/automation_state.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/automation/presentation/automation_text.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Stock or crypto Autopilot: the user's rules, with pause and delete.
class AutopilotScreen extends ConsumerWidget {
  const AutopilotScreen({super.key, this.kind = AssetKind.stock});

  final AssetKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final stock = kind == AssetKind.stock;
    final catalog = ref.watch(catalogProvider).value ?? const <String, AssetInfo>{};
    final quotes = ref.watch(quotesProvider).value;
    final all = ref.watch(autopilotRulesProvider);
    final rules = (all.value ?? const <AutopilotRule>[]).where((r) => catalog[r.assetId]?.kind == kind).toList();
    void newRule() =>
        context.pushNamed(AppRoute.picker.name, queryParameters: {'for': 'rule', 'kind': stock ? 'stocks' : 'crypto'});

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(
        context,
        stock ? l.stockAutopilot : l.cryptoAutopilot,
        actions: [
          TextButton.icon(
            onPressed: newRule,
            icon: const JarinaIcon(JIcon.plus, size: 18),
            label: Text(l.newLabel),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          JBrandCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    JarinaIcon(JIcon.auto, size: 22, color: c.gold),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        stock ? l.stockAutopilot : l.cryptoAutopilot,
                        style: t.title.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stock ? l.setYourPriceForNgxShares : l.setYourPriceForCryptoJarina,
                  style: t.body.copyWith(color: Colors.white70, fontWeight: FontWeight.w400, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          JSectionHeader(
            title: stock ? l.yourStockRules : l.yourCryptoRules,
            trailing: l.activeCount('${rules.where((r) => r.enabled).length}'),
          ),
          const SizedBox(height: 10),
          if (all.isLoading && !all.hasValue)
            const Center(child: CircularProgressIndicator())
          else if (rules.isEmpty)
            JCard(
              child: Text(
                l.noRulesYetTapNewTo,
                style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
              ),
            )
          else
            RowsCard(
              children: [
                for (final r in rules) RuleRow(rule: r, asset: catalog[r.assetId], price: quotes?[r.assetId]?.price),
              ],
            ),
          const SizedBox(height: 14),
          JButton(
            label: stock ? l.newStockRule : l.newCryptoRule,
            icon: JIcon.plus,
            variant: JButtonVariant.soft,
            onPressed: newRule,
          ),
          const SizedBox(height: 14),
          Text(
            l.autopilotPlacesOrdersAtMarketConditions,
            style: t.caption.copyWith(color: c.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class RuleRow extends ConsumerWidget {
  const RuleRow({required this.rule, required this.asset, required this.price, super.key});

  final AutopilotRule rule;
  final AssetInfo? asset;
  final Decimal? price;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteRule),
        content: Text(ruleText(l, rule, asset)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(automationRepositoryProvider).deleteRule(rule.id);
    if (context.mounted) showToast(context, l.ruleDeleted);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final r = rule;
    final buy = r.side == RuleSide.buy;
    final (statusKind, statusText) = ruleStatus(l, r, price);
    final a = asset;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a != null) AssetBadge(a, size: 42) else const SizedBox(width: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Badge(text: buy ? l.autoBuy : l.autoSell, fg: buy ? c.up : c.down),
                    _Badge(
                      text: statusText,
                      fg: switch (statusKind) {
                        RuleStatusKind.paused => c.muted,
                        RuleStatusKind.met => c.up,
                        RuleStatusKind.away => c.ink2,
                      },
                      neutral: statusKind != RuleStatusKind.met,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(ruleText(l, r, a), style: t.body.copyWith(height: 1.4)),
                const SizedBox(height: 4),
                Text(
                  [ruleSchedule(l, r), if (price != null) l.nowPrice(priceText(price!))].join(' · '),
                  style: t.caption.copyWith(color: c.muted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    JarinaIcon(JIcon.wallet, size: 13, color: c.goldDeep),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        buy ? l.fromNairaWallet : l.toNairaWallet,
                        style: t.caption.copyWith(color: c.goldDeep, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Semantics(
                label: l.ruleOn,
                child: Switch(
                  value: r.enabled,
                  onChanged: (v) async {
                    await ref.read(automationRepositoryProvider).setRuleEnabled(r.id, enabled: v);
                    if (context.mounted) showToast(context, v ? l.ruleResumed : l.rulePaused);
                  },
                ),
              ),
              IconButton(
                tooltip: l.deleteRule,
                onPressed: () => unawaited(_delete(context, ref)),
                icon: JarinaIcon(JIcon.trash, size: 18, color: c.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.fg, this.neutral = false});

  final String text;
  final Color fg;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: neutral ? c.fill : fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: t.caption.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/home/presentation/app_drawer.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// All transactions with category filters.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  TxCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final all = ref.watch(activityProvider);
    final filters = <TxCategory?, String>{
      null: l.all,
      TxCategory.stocks: l.stocks,
      TxCategory.crypto: l.crypto,
      TxCategory.transfers: l.transfers,
      TxCategory.bills: l.bills,
    };

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(header: true, child: Text(l.activity, style: t.largeTitle)),
                ),
                JIconButton(icon: JIcon.menu, semanticLabel: l.menu, onPressed: () => showAppDrawer(context)),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final e in filters.entries) ...[
                    JChip(label: e.value, selected: _filter == e.key, onTap: () => setState(() => _filter = e.key)),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            switch (all) {
              AsyncData(:final value) => () {
                final list = value.where((tx) => _filter == null || tx.category == _filter).toList();
                return list.isEmpty
                    ? JCard(
                        child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
                      )
                    : RowsCard(children: [for (final tx in list) ActivityRow(tx: tx)]);
              }(),
              AsyncError() => JCard(child: Text(l.errGeneric)),
              _ => const Center(
                child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

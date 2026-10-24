import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Formats [money] and masks it when "hide balances" is on.
class MoneyText extends ConsumerWidget {
  const MoneyText(this.money, {super.key, this.style, this.decimals, this.signed = false, this.alwaysShow = false});

  final Money money;
  final TextStyle? style;
  final int? decimals;
  final bool signed;

  /// Amounts the user is entering or confirming are never masked.
  final bool alwaysShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = !alwaysShow && ref.watch(hideBalancesProvider);
    final text = hidden ? '••••••' : MoneyFormat.format(money, decimals: decimals, signed: signed);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (style ?? context.text.num).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}

/// Whole-naira display for large portfolio figures (₦2,198,676).
int? wholeFor(Money m) => m.currency.isFiat && m.amount.abs() >= Decimal.fromInt(1000) ? 0 : null;

/// "Today · 10:24", "Yesterday · 18:02", "27 Sep · 09:15".
String activityDate(AppLocalizations l, DateTime t, {DateTime? now, bool withTime = true}) {
  final n = now ?? DateTime.now();
  final day = DateTime(t.year, t.month, t.day);
  final today = DateTime(n.year, n.month, n.day);
  final diff = today.difference(day).inDays;
  final locale = Intl.canonicalizedLocale(l.localeName);
  final safeLocale = DateFormat.localeExists(locale) ? locale : 'en';
  final d = switch (diff) {
    0 => l.today2,
    1 => l.yesterday,
    _ => DateFormat(t.year == n.year ? 'd MMM' : 'd MMM y', safeLocale).format(t),
  };
  return withTime ? '$d · ${DateFormat.Hm(safeLocale).format(t)}' : d;
}

/// One activity row: direction arrow, title, date · detail, signed amount.
class ActivityRow extends StatelessWidget {
  const ActivityRow({required this.tx, super.key});

  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final credit = tx.isCredit;
    return InkWell(
      onTap: () => context.pushNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id}),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Transform.rotate(
                angle: credit ? 3.1416 * 0.75 : -3.1416 * 0.25,
                child: JarinaIcon(JIcon.arrowRight, size: 20, color: credit ? c.muted : c.down),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${activityDate(l, tx.createdAt, withTime: false)} · ${tx.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.caption.copyWith(color: c.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            RowAmount(
              child: MoneyText(
                tx.amount,
                signed: true,
                decimals: wholeFor(tx.amount),
                style: t.num.copyWith(fontSize: 15, color: credit ? c.up : c.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card holding a list of rows separated by hairlines.
class RowsCard extends StatelessWidget {
  const RowsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return JCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Right-hand amount column in a list row. Takes up to 40% of the row and
/// scales down rather than overflowing (long balances, large text, narrow
/// phones); pair it with an `Expanded(flex: 3)` title.
class RowAmount extends StatelessWidget {
  const RowAmount({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Flexible(
    flex: 2,
    child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: child),
  );
}

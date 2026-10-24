import 'package:flutter/material.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

String rangeLabel(AppLocalizations l, ChartRange r) => switch (r) {
  ChartRange.day => l.rangeDay,
  ChartRange.week => l.rangeWeek,
  ChartRange.month => l.rangeMonth,
  ChartRange.year => l.rangeYear,
  ChartRange.all => l.rangeAll,
};

/// 1D · 1W · 1M · 1Y · All selector under charts.
class RangeSelector extends StatelessWidget {
  const RangeSelector({required this.value, required this.onChanged, super.key});

  final ChartRange value;
  final ValueChanged<ChartRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final r in ChartRange.values)
          Semantics(
            selected: r == value,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(r),
              child: Container(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: r == value ? c.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rangeLabel(l, r),
                  style: t.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: r == value ? Colors.white : c.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

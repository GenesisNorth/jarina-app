import 'package:flutter/material.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';
import 'package:jarina_ui/src/widgets/jarina_icon.dart';

class JarinaTabItem {
  const JarinaTabItem({required this.icon, required this.label});

  final JIcon icon;
  final String label;
}

/// Floating 5-tab bar (`.tabbar` in the prototype): white rounded card,
/// gold icon + underline on the active tab.
class JarinaTabBar extends StatelessWidget {
  const JarinaTabBar({required this.items, required this.currentIndex, required this.onTap, super.key});

  final List<JarinaTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(RadiusTokens.card + 4),
          border: Border.all(color: c.line),
          boxShadow: const [BoxShadow(color: Color(0x1417181C), blurRadius: 24, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _Tab(item: items[i], selected: i == currentIndex, onTap: () => onTap(i)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final JarinaTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.goldDeep : c.muted;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.tile),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              JarinaIcon(item.icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: context.text.caption.copyWith(
                  fontSize: 11,
                  color: selected ? c.ink : c.muted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 14 : 0,
                height: 3,
                decoration: BoxDecoration(color: c.gold, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

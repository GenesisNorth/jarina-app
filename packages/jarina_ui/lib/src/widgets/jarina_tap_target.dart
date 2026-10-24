import 'package:flutter/material.dart';

/// Gives a small control a [minSize] square touch and screen-reader target
/// (48 by default, Android's minimum) without changing how it looks.
///
/// The child's own ink should set `excludeFromSemantics: true`; this widget
/// owns the tap action and merges the child's text into one button label.
class JTapTarget extends StatelessWidget {
  const JTapTarget({
    required this.onTap,
    required this.child,
    super.key,
    this.label,
    this.selected,
    this.minSize = 48,
  });

  final VoidCallback? onTap;
  final Widget child;
  final String? label;
  final bool? selected;
  final double minSize;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      button: true,
      enabled: onTap != null,
      selected: selected,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    ),
  );
}

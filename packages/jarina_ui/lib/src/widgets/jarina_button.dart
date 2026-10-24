import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';
import 'package:jarina_ui/src/widgets/jarina_icon.dart';
import 'package:jarina_ui/src/widgets/jarina_tap_target.dart';

enum JButtonVariant {
  /// Black (light) / gold (dark) — the main call to action.
  primary,

  /// Filled with the neutral `fill` colour.
  soft,

  /// Card background with a hairline border.
  outline,

  /// Text only.
  ghost,
}

/// The app's button. 56pt tall, 18pt radius, bold label (prototype `.btn`).
///
/// Pass `onPressed: null` to disable. Set [loading] while an async action runs:
/// the button keeps its size, shows a spinner and ignores taps, which prevents
/// double submits on slow networks.
class JButton extends StatelessWidget {
  const JButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = JButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.trailingArrow = false,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final JButtonVariant variant;
  final bool loading;
  final JIcon? icon;
  final bool trailingArrow;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !loading;

    final (Color bg, Color fg, BorderSide side) = switch (variant) {
      JButtonVariant.primary =>
        enabled || loading
            ? (dark ? c.gold : c.black, dark ? c.black : Colors.white, BorderSide.none)
            : (c.muted.withValues(alpha: 0.45), Colors.white, BorderSide.none),
      JButtonVariant.soft => (c.fill, c.ink, BorderSide.none),
      JButtonVariant.outline => (c.card, c.ink, BorderSide(color: c.line, width: 1.5)),
      JButtonVariant.ghost => (Colors.transparent, c.ink, BorderSide.none),
    };

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.body.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: fg, letterSpacing: -0.1),
    );

    final content = loading
        ? SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[JarinaIcon(icon!, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(child: text),
              if (trailingArrow) ...[
                const SizedBox(width: 8),
                JarinaIcon(JIcon.arrowRight, size: 20, color: fg),
              ],
            ],
          );

    final elevated = variant == JButtonVariant.primary && enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label, loading' : null,
      excludeSemantics: loading,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: expand ? double.infinity : null,
        constraints: BoxConstraints(minHeight: height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: elevated
              ? [BoxShadow(color: c.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))]
              : null,
        ),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: side),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    unawaited(HapticFeedback.lightImpact());
                    onPressed!();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Center(widthFactor: expand ? null : 1, heightFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round 40pt button used for back / close in top bars (prototype `.navback`).
class JCircleButton extends StatelessWidget {
  const JCircleButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
    this.size = 40,
  });

  final JIcon icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      // 48pt hit area around a 40pt visual (accessibility minimum is 44pt).
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Material(
            color: c.card,
            shape: const CircleBorder(),
            shadowColor: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: c.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: JarinaIcon(icon, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill button, e.g. "Help" in KYC top bars.
class JPillButton extends StatelessWidget {
  const JPillButton({required this.label, required this.onPressed, super.key, this.icon, this.leading});

  final String label;
  final VoidCallback? onPressed;
  final JIcon? icon;

  /// Custom leading widget (e.g. a flag), used instead of [icon].
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return JTapTarget(
      onTap: onPressed,
      child: Material(
        color: c.card,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          excludeFromSemantics: true,
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: c.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 6)],
                if (icon != null) ...[JarinaIcon(icon!, size: 16), const SizedBox(width: 6)],
                Text(
                  label,
                  style: context.text.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

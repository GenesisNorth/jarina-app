import 'package:flutter/material.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';
import 'package:jarina_ui/src/widgets/jarina_icon.dart';
import 'package:jarina_ui/src/widgets/jarina_pattern.dart';

/// Round white action with a label underneath (Add money, Send, Transfer…).
class JActionButton extends StatelessWidget {
  const JActionButton({required this.icon, required this.label, required this.onTap, super.key});

  final JIcon icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.line.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(color: c.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(child: JarinaIcon(icon, size: 22)),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Your assets ............ See all"
class JSectionHeader extends StatelessWidget {
  const JSectionHeader({required this.title, super.key, this.action, this.onAction, this.trailing});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  /// Small muted text on the right instead of an action (e.g. a count).
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: context.text.h2.copyWith(fontSize: 19))),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: c.ink, padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text(action!, style: context.text.body.copyWith(fontSize: 15)),
            ),
          if (trailing != null) Text(trailing!, style: context.text.caption.copyWith(color: c.muted)),
        ],
      ),
    );
  }
}

enum JCardTone { black, gold, white }

/// Brand card with the African pattern: balance headers and wallet tiles.
class JBrandCard extends StatelessWidget {
  const JBrandCard({
    required this.child,
    super.key,
    this.tone = JCardTone.black,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = RadiusTokens.card,
  });

  final Widget child;
  final JCardTone tone;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  /// Text colour that reads on this tone.
  static Color inkOn(JCardTone tone) => tone == JCardTone.white ? BrandColors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    final (bg, ink, opacity) = switch (tone) {
      JCardTone.black => (BrandColors.black, PatternInk.gold, 0.12),
      JCardTone.gold => (BrandColors.goldDeep, PatternInk.black, 0.12),
      JCardTone.white => (Colors.white, PatternInk.gold, 0.1),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: BrandColors.black.withValues(alpha: tone == JCardTone.white ? 0.06 : 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: bg,
          child: InkWell(
            onTap: onTap,
            child: JPattern(
              ink: ink,
              opacity: opacity,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular icon button for app bars (bell, menu, share).
class JIconButton extends StatelessWidget {
  const JIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
    this.badge = false,
  });

  final JIcon icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  /// Small red dot (unread notifications).
  final bool badge;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: semanticLabel,
    onPressed: onPressed,
    icon: Stack(
      clipBehavior: Clip.none,
      children: [
        JarinaIcon(icon),
        if (badge)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: context.colors.down,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.bg, width: 1.5),
              ),
            ),
          ),
      ],
    ),
  );
}

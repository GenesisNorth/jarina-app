import 'package:flutter/material.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';
import 'package:jarina_ui/src/widgets/jarina_button.dart';
import 'package:jarina_ui/src/widgets/jarina_icon.dart';

/// Layout for every full-screen step (onboarding, KYC, confirm flows).
///
/// ```text
/// [back]                 [trailing]
/// ┌ scrollable content ───────────┐
/// │ header, body…                 │
/// └───────────────────────────────┘
/// [ bottom: CTA or keypad ]   ← stays above the keyboard and home indicator
/// ```
/// The body scrolls on short phones and with large text instead of
/// overflowing; tapping empty space dismisses the keyboard.
class JFlowScaffold extends StatelessWidget {
  const JFlowScaffold({
    required this.children,
    super.key,
    this.onBack,
    this.backLabel = 'Back',
    this.trailing,
    this.bottom,
    this.bottomPadded = true,
    this.centerBody = false,
  });

  final List<Widget> children;

  /// Shows the back button when non-null.
  final VoidCallback? onBack;
  final String backLabel;
  final Widget? trailing;

  /// Pinned under the scroll area: a CTA button, or a keypad.
  final Widget? bottom;

  /// False for edge-to-edge bottoms like the keypad.
  final bool bottomPadded;

  /// Vertically centre short content (e.g. "Account disabled").
  final bool centerBody;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const gutter = SpacingTokens.screenGutter;
    // System back (Android gesture / button) does what the on-screen back does.
    return PopScope(
      canPop: onBack == null && Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack?.call();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: gutter - 4),
                    child: Row(
                      children: [
                        if (onBack != null)
                          JCircleButton(icon: JIcon.arrowLeft, onPressed: onBack, semanticLabel: backLabel),
                        const SizedBox(width: 12),
                        // Scales down rather than overflowing with long titles or large text.
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: centerBody ? box.maxHeight - 32 : 0),
                        child: Column(
                          mainAxisAlignment: centerBody ? MainAxisAlignment.center : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                  ),
                ),
                if (bottom != null)
                  SafeArea(
                    top: false,
                    minimum: EdgeInsets.only(bottom: bottomPadded ? 16 : 8),
                    child: Padding(
                      padding: bottomPadded ? const EdgeInsets.fromLTRB(gutter, 8, gutter, 0) : EdgeInsets.zero,
                      child: bottom,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "STEP 5 OF 12 · VERIFICATION", progress bar, title and subtitle.
class JStepHeader extends StatelessWidget {
  const JStepHeader({required this.title, super.key, this.eyebrow, this.progress, this.subtitle, this.leading});

  final String? eyebrow;

  /// 0..1; hidden when null.
  final double? progress;
  final String title;
  final String? subtitle;

  /// Optional widget above the eyebrow row (e.g. a country flag).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null)
          Semantics(
            header: true,
            child: Text(
              eyebrow!.toUpperCase(),
              style: t.caption.copyWith(color: c.goldDeep, fontWeight: FontWeight.w700, letterSpacing: 1.4),
            ),
          ),
        if (progress != null) ...[
          const SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: c.line,
                valueColor: AlwaysStoppedAnimation(c.gold),
              ),
            ),
          ),
        ],
        if (leading != null) ...[const SizedBox(height: 12), leading!],
        const SizedBox(height: 14),
        Semantics(
          header: true,
          child: Text(title, style: t.largeTitle.copyWith(fontSize: 28, height: 1.12, letterSpacing: -0.8)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
          ),
        ],
      ],
    );
  }
}

enum JStepState { done, current, todo }

class JTrackerItem {
  const JTrackerItem({required this.number, required this.label, required this.state});

  /// Shown in the circle for current/todo items, e.g. `5` or `10–11`.
  final String number;
  final String label;
  final JStepState state;
}

/// The mini step tracker under onboarding titles (prototype `obStep` chips).
class JStepTracker extends StatelessWidget {
  const JStepTracker({required this.items, super.key});

  final List<JTrackerItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              switch (item.state) {
                JStepState.done => Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: c.gold, shape: BoxShape.circle),
                  child: const Center(child: JarinaIcon(JIcon.check, size: 12, color: BrandColors.black)),
                ),
                JStepState.current => Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: c.goldDeep, width: 1.3),
                  ),
                  child: Center(
                    child: Text(
                      item.number,
                      style: t.caption.copyWith(fontSize: 10, color: c.goldDeep, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                JStepState.todo => Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(9)),
                  child: Center(
                    child: Text(
                      item.number,
                      style: t.caption.copyWith(fontSize: 10, color: c.muted, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              },
              const SizedBox(width: 5),
              Text(
                item.label,
                style: t.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: switch (item.state) {
                    JStepState.done => c.ink,
                    JStepState.current => c.goldDeep,
                    JStepState.todo => c.muted,
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// White rounded card (prototype `.card`).
class JCard extends StatelessWidget {
  const JCard({required this.child, super.key, this.padding = const EdgeInsets.all(18), this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.card,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(color: c.line.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: c.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: c.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

/// Small muted line with an icon, e.g. the encryption note under KYC forms.
class JNote extends StatelessWidget {
  const JNote({required this.text, super.key, this.icon = JIcon.lock});

  final String text;
  final JIcon icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: JarinaIcon(icon, size: 14, color: c.muted),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: context.text.caption.copyWith(color: c.muted, height: 1.5)),
        ),
      ],
    );
  }
}

/// Cream callout box (gold tint) for important notices.
class JCallout extends StatelessWidget {
  const JCallout({required this.text, super.key, this.icon = JIcon.shield});

  final String text;
  final JIcon icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JarinaIcon(icon, size: 18, color: c.ink),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.text.body.copyWith(fontSize: 14, height: 1.45))),
        ],
      ),
    );
  }
}

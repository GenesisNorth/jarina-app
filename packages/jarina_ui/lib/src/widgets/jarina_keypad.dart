import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';

/// On-screen number pad for OTP, PIN, 2FA and amounts.
///
/// Using our own keypad (not the system keyboard) for codes keeps the layout
/// stable, avoids third-party keyboards capturing PINs, and matches the design.
class JKeypad extends StatelessWidget {
  const JKeypad({
    required this.onDigit,
    required this.onBackspace,
    super.key,
    this.onClear,
    this.extraKey,
    this.onExtra,
    this.enabled = true,
    this.backspaceLabel = 'Delete',
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Long-press on backspace.
  final VoidCallback? onClear;

  /// Bottom-left key label, e.g. `000` on amount pads. Empty when null.
  final String? extraKey;
  final VoidCallback? onExtra;
  final bool enabled;
  final String backspaceLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Shrink keys on short phones (iPhone SE: 667pt) so the content above fits.
    final h = (MediaQuery.sizeOf(context).height * 0.068).clamp(46.0, 60.0);
    Widget row(List<Widget> keys) => SizedBox(
      height: h,
      child: Row(children: [for (final k in keys) Expanded(child: k)]),
    );
    Widget digit(String d) => _Key(
      label: d,
      enabled: enabled,
      onTap: () => onDigit(d),
      child: Text(d, style: context.text.title.copyWith(fontSize: 24, fontWeight: FontWeight.w500)),
    );
    final divider = Divider(height: 1, thickness: 1, color: c.line);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row([digit('1'), digit('2'), digit('3')]),
          divider,
          row([digit('4'), digit('5'), digit('6')]),
          divider,
          row([digit('7'), digit('8'), digit('9')]),
          divider,
          row([
            if (extraKey != null)
              _Key(
                label: extraKey!,
                enabled: enabled,
                onTap: onExtra ?? () {},
                child: Text(extraKey!, style: context.text.h2.copyWith(fontWeight: FontWeight.w600)),
              )
            else
              const SizedBox.shrink(),
            digit('0'),
            _Key(
              label: backspaceLabel,
              enabled: enabled,
              onTap: onBackspace,
              onLongPress: onClear,
              child: Icon(Icons.backspace_outlined, size: 24, color: c.ink),
            ),
          ]),
          divider,
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, required this.child, required this.enabled, this.onLongPress});

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkWell(
      onTap: enabled
          ? () {
              unawaited(HapticFeedback.selectionClick());
              onTap();
            }
          : null,
      onLongPress: enabled ? onLongPress : null,
      child: Center(child: child),
    ),
  );
}

/// Six boxes showing entered OTP digits (prototype `vOtp`).
class JCodeBoxes extends StatelessWidget {
  const JCodeBoxes({required this.value, super.key, this.length = 6, this.error = false});

  final String value;
  final int length;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Code, ${value.length} of $length digits entered',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.92,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: error
                          ? c.down
                          : i == value.length
                          ? c.goldDeep
                          : c.line,
                      width: i == value.length || error ? 2 : 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    i < value.length ? value[i] : '',
                    style: context.text.title.copyWith(
                      fontSize: 24,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Six PIN dots; filled dots are gold. Never shows the digits.
class JPinDots extends StatelessWidget {
  const JPinDots({required this.filled, super.key, this.length = 6, this.error = false});

  final int filled;
  final int length;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$filled of $length digits entered',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.symmetric(horizontal: 7),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? (error ? c.down : c.gold) : Colors.transparent,
                border: Border.all(
                  color: error ? c.down : (i < filled ? c.gold : c.muted.withValues(alpha: 0.5)),
                  width: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

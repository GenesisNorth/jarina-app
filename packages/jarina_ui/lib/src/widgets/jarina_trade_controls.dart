import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';
import 'package:jarina_ui/src/widgets/jarina_icon.dart';

/// Slide-to-confirm (prototype `.swslide`): drag the gold thumb to the end to
/// confirm. A deliberate gesture for money-moving actions; screen-reader users
/// get a plain button action instead of having to drag.
class JSlideToConfirm extends StatefulWidget {
  const JSlideToConfirm({required this.label, required this.onConfirm, super.key, this.disabledLabel});

  final String label;

  /// Null disables the control and shows [disabledLabel].
  final VoidCallback? onConfirm;
  final String? disabledLabel;

  @override
  State<JSlideToConfirm> createState() => _JSlideToConfirmState();
}

class _JSlideToConfirmState extends State<JSlideToConfirm> with SingleTickerProviderStateMixin {
  static const _height = 58.0;
  static const _thumb = 48.0;
  static const _threshold = 0.92;

  late final AnimationController _reset = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))
    ..addListener(() => setState(() => _drag = _resetFrom * (1 - _reset.value)));
  double _drag = 0;
  double _resetFrom = 0;
  Timer? _snapBack;

  @override
  void dispose() {
    _snapBack?.cancel();
    _reset.dispose();
    super.dispose();
  }

  void _end(double travel) {
    if (travel > 0 && _drag / travel >= _threshold) {
      unawaited(HapticFeedback.mediumImpact());
      setState(() => _drag = travel);
      widget.onConfirm?.call();
      // Snap back after the action so the control is reusable if it fails.
      _snapBack = Timer(const Duration(milliseconds: 600), () {
        if (mounted) _animateBack();
      });
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    _resetFrom = _drag;
    unawaited(_reset.forward(from: 0));
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onConfirm != null;
    final t = context.text;
    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? widget.label : (widget.disabledLabel ?? widget.label),
      onTap: enabled ? widget.onConfirm : null,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, box) {
          final travel = box.maxWidth - _thumb - 10;
          final progress = travel <= 0 ? 0.0 : (_drag / travel).clamp(0.0, 1.0);
          return Container(
            height: _height,
            decoration: BoxDecoration(
              color: enabled ? BrandColors.black : context.colors.muted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(_height / 2),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: BrandColors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Gold fill follows the thumb.
                Container(
                  width: _thumb + 10 + _drag,
                  decoration: BoxDecoration(
                    color: BrandColors.gold.withValues(alpha: 0.25 + 0.5 * progress),
                    borderRadius: BorderRadius.circular(_height / 2),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: _thumb),
                    child: Opacity(
                      opacity: 1 - progress,
                      child: Text(
                        enabled ? widget.label : (widget.disabledLabel ?? widget.label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 5 + _drag,
                  child: GestureDetector(
                    onHorizontalDragUpdate: enabled
                        ? (d) => setState(() => _drag = (_drag + d.delta.dx).clamp(0, travel))
                        : null,
                    onHorizontalDragEnd: enabled ? (_) => _end(travel) : null,
                    child: Container(
                      width: _thumb,
                      height: _thumb,
                      decoration: BoxDecoration(
                        color: enabled ? BrandColors.gold : Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: JarinaIcon(JIcon.arrowRight, size: 22, color: BrandColors.black)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Percent-of-balance slider with 25 / 50 / 75 / Max shortcuts.
class JPercentSlider extends StatelessWidget {
  const JPercentSlider({required this.value, required this.onChanged, super.key, this.maxLabel = 'Max'});

  /// 0..1
  final double value;
  final ValueChanged<double> onChanged;
  final String maxLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: c.gold,
            inactiveTrackColor: c.line,
            thumbColor: Colors.white,
            overlayColor: c.gold.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(),
          ),
          child: Slider(
            value: value.clamp(0, 1),
            onChanged: onChanged,
            semanticFormatterCallback: (v) => '${(v * 100).round()}%',
          ),
        ),
        Row(
          children: [
            for (final (i, p) in [0.25, 0.5, 0.75, 1.0].indexed) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Material(
                  color: (value - p).abs() < 0.001 ? c.black : c.fill,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      unawaited(HapticFeedback.selectionClick());
                      onChanged(p);
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 36),
                      alignment: Alignment.center,
                      child: Text(
                        p == 1 ? maxLabel : '${(p * 100).round()}%',
                        style: t.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: (value - p).abs() < 0.001 ? Colors.white : c.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

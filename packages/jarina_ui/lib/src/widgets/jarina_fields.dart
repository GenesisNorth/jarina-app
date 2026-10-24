import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarina_ui/src/theme/jarina_theme.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';
import 'package:jarina_ui/src/widgets/jarina_icon.dart';
import 'package:jarina_ui/src/widgets/jarina_tap_target.dart';

/// Labelled text field (prototype `.field` + `.input`): 54pt, 16pt radius,
/// hairline border that turns gold on focus and red on error.
class JTextField extends StatelessWidget {
  const JTextField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.large = false,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;

  /// Shown under the field in red; also turns the border red.
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final int? maxLength;

  /// Bigger text for single hero inputs (username, phone).
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
    final style = t.body.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: large ? 20 : 16,
      color: c.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label!,
              style: t.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2),
            ),
          ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: [...?inputFormatters, if (maxLength != null) LengthLimitingTextInputFormatter(maxLength)],
          autofillHints: autofillHints,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: style,
          cursorColor: c.goldDeep,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: c.bg,
            hintText: hint,
            hintStyle: style.copyWith(color: c.muted.withValues(alpha: 0.75), fontWeight: FontWeight.w500),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: large ? 18 : 17),
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(),
            enabledBorder: border(errorText != null ? c.down : c.line, 1.5),
            focusedBorder: border(errorText != null ? c.down : c.gold, 2),
            disabledBorder: border(c.line, 1.5),
            border: border(c.line, 1.5),
            counterText: '',
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.topCenter,
          child: errorText != null || helperText != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4, top: 6),
                  child: Text(
                    errorText ?? helperText!,
                    style: t.caption.copyWith(color: errorText != null ? c.down : c.muted, height: 1.4),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// A field-looking button that opens a searchable bottom-sheet list.
/// Used for country/state pickers (37 Nigerian states won't fit a menu).
class JSelect<T> extends StatelessWidget {
  const JSelect({
    required this.items,
    required this.labelOf,
    required this.onChanged,
    super.key,
    this.value,
    this.label,
    this.hint,
    this.sheetTitle,
    this.searchHint,
    this.errorText,
  });

  final List<T> items;
  final T? value;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? hint;
  final String? sheetTitle;

  /// Shows a search box in the sheet when non-null.
  final String? searchHint;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final has = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label!,
              style: t.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2),
            ),
          ),
        Semantics(
          button: true,
          label: label,
          value: has ? labelOf(value as T) : hint,
          onTap: () => _open(context),
          excludeSemantics: true,
          child: Material(
            color: c.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: errorText != null ? c.down : c.line, width: 1.5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _open(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        has ? labelOf(value as T) : (hint ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.body.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: has ? c.ink : c.muted),
                      ),
                    ),
                    Transform.rotate(angle: -1.5708, child: JarinaIcon(JIcon.back, size: 18, color: c.muted)),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(errorText!, style: t.caption.copyWith(color: c.down)),
          ),
      ],
    );
  }

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SelectSheet<T>(
        items: items,
        value: value,
        labelOf: labelOf,
        title: sheetTitle ?? label ?? '',
        searchHint: searchHint,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _SelectSheet<T> extends StatefulWidget {
  const _SelectSheet({required this.items, required this.labelOf, required this.title, this.value, this.searchHint});

  final List<T> items;
  final T? value;
  final String Function(T) labelOf;
  final String title;
  final String? searchHint;

  @override
  State<_SelectSheet<T>> createState() => _SelectSheetState<T>();
}

class _SelectSheetState<T> extends State<_SelectSheet<T>> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final q = _q.toLowerCase();
    final list = widget.items.where((i) => widget.labelOf(i).toLowerCase().contains(q)).toList();
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Text(widget.title, style: t.h2),
            ),
            if (widget.searchHint != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                child: JTextField(
                  hint: widget.searchHint,
                  onChanged: (v) => setState(() => _q = v),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: JarinaIcon(JIcon.search, size: 18, color: c.muted),
                  ),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final item = list[i];
                  final selected = item == widget.value;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 22),
                    minTileHeight: 52,
                    title: Text(
                      widget.labelOf(item),
                      style: t.body.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                    ),
                    trailing: selected ? JarinaIcon(JIcon.check, size: 20, color: c.goldDeep) : null,
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill segmented control (prototype `.seg`): fill track, white selected pill.
class JSegmented<T> extends StatelessWidget {
  const JSegmented({required this.segments, required this.value, required this.onChanged, super.key});

  final Map<T, String> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    // The track's vertical padding sits inside each segment's tap area, so every
    // segment is a full 48pt target while the pill stays 40pt.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final e in segments.entries)
            Expanded(
              child: Semantics(
                selected: e.key == value,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (e.key != value) {
                      unawaited(HapticFeedback.selectionClick());
                      onChanged(e.key);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      constraints: const BoxConstraints(minHeight: 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: e.key == value ? c.card : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: e.key == value
                            ? [
                                BoxShadow(
                                  color: c.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        e.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: e.key == value ? c.ink : c.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selectable chip (prototype `.chip`): 36pt, 12pt radius; gold when on.
class JChip extends StatelessWidget {
  const JChip({required this.label, required this.onTap, super.key, this.selected = false, this.outlined = true});

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // 40pt chip, 48pt touch target.
    return JTapTarget(
      selected: selected,
      onTap: onTap,
      child: Material(
        color: selected ? c.gold : c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: outlined && !selected ? BorderSide(color: c.line) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          excludeFromSemantics: true,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.text.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? BrandColors.black : c.ink2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

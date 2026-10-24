import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Initials on the person's colour, with a country flag for cross-border.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({required this.name, required this.color, super.key, this.size = 44, this.countryIso});

  final String name;
  final int color;
  final double size;
  final String? countryIso;

  String get _initials =>
      name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w.characters.first).join().toUpperCase();

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final flag = countryIso == null || countryIso == 'NG' ? null : JFlag.fromIso(countryIso!);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
              child: Text(
                _initials,
                style: t.body.copyWith(
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF17181B),
                ),
              ),
            ),
            if (flag != null)
              Positioned(
                right: -2,
                bottom: -2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: JarinaFlag(flag, width: size * 0.38),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `Jarina user · @zainab`, `Bank account ••4821`, `Maradi, Niger · Mobile money`.
String recipientSubtitle(AppLocalizations l, Recipient r) => switch (r.kind) {
  RecipientKind.jarina => l.jarinaUserTag(r.handle ?? ''),
  RecipientKind.bank => '${r.bank} · ${l.bankAccountMasked(r.accountNumber?.substring(6) ?? '')}',
  RecipientKind.crossBorder => '${r.place} · ${r.channel}',
};

/// Quick notes under "What's it for?". Tapping fills the note field.
class NoteChips extends StatelessWidget {
  const NoteChips({required this.controller, required this.onChanged, super.key});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final n in [l.family, l.food, l.rent, l.schoolFees, l.business, l.gift])
          JChip(
            label: n,
            selected: controller.text == n,
            onTap: () {
              controller.text = n;
              onChanged();
            },
          ),
      ],
    );
  }
}

/// A tappable card row (icon, title, subtitle, chevron) with its own ink.
class LinkCard extends StatelessWidget {
  const LinkCard({required this.leading, required this.title, required this.subtitle, required this.onTap, super.key});

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(RadiusTokens.card),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: leading,
        title: Text(title, style: t.body.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: t.caption.copyWith(color: c.muted)),
        trailing: JarinaIcon(JIcon.chev, size: 14, color: c.muted),
        onTap: onTap,
      ),
    );
  }
}

/// Whole-naira input shown with thousands separators (`25,000`).
class GroupedDigitsFormatter extends TextInputFormatter {
  const GroupedDigitsFormatter({this.maxDigits = 9});

  final int maxDigits;

  static String group(String digits) => digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0+'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    final text = group(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// A bare, centred or end-aligned amount field: no box, just the number.
InputDecoration bareAmountDecoration(TextStyle style, Color hintColor, {String? prefix}) => InputDecoration(
  filled: false,
  isDense: true,
  contentPadding: EdgeInsets.zero,
  constraints: const BoxConstraints(minHeight: 48),
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  prefixText: prefix,
  prefixStyle: style,
  hintText: prefix == null ? '0' : '${prefix}0',
  hintStyle: style.copyWith(color: hintColor),
);

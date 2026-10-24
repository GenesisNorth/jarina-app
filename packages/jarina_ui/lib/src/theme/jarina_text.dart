import 'package:flutter/material.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';

/// Type scale from `design/tokens.json` (Poppins). Colours are applied by the
/// theme; use `.copyWith(color: …)` for muted/up/down variants.
@immutable
class JarinaText extends ThemeExtension<JarinaText> {
  const JarinaText({
    required this.largeTitle,
    required this.title,
    required this.h2,
    required this.body,
    required this.caption,
    required this.amountXl,
    required this.amountL,
  });

  factory JarinaText.forColor(Color ink) {
    TextStyle s(double size, FontWeight weight, double spacing, {bool tabular = false}) => TextStyle(
      fontFamily: TypeTokens.family,
      // Poppins has no ₦, ₵ or Hausa hooked letters (ɓ ɗ ƙ ƴ); this bundled Noto
      // subset supplies them so they look the same on every phone.
      fontFamilyFallback: fallbackFamilies,
      package: 'jarina_ui',
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: ink,
      height: 1.25,
      // Money must use tabular figures so digits don't jitter as prices tick.
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
    return JarinaText(
      largeTitle: s(TypeTokens.largeTitleSize, TypeTokens.largeTitleWeight, TypeTokens.largeTitleLetterSpacing),
      title: s(TypeTokens.titleSize, TypeTokens.titleWeight, TypeTokens.titleLetterSpacing),
      h2: s(TypeTokens.h2Size, TypeTokens.h2Weight, TypeTokens.h2LetterSpacing),
      body: s(TypeTokens.bodySize, TypeTokens.bodyWeight, TypeTokens.bodyLetterSpacing),
      caption: s(TypeTokens.captionSize, TypeTokens.captionWeight, TypeTokens.captionLetterSpacing),
      amountXl: s(TypeTokens.amountXlSize, TypeTokens.amountXlWeight, TypeTokens.amountXlLetterSpacing, tabular: true),
      amountL: s(TypeTokens.amountLSize, TypeTokens.amountLWeight, TypeTokens.amountLLetterSpacing, tabular: true),
    );
  }

  /// Bundled glyph fallbacks (Noto subsets, see `fonts/NotoSans-OFL.txt`):
  /// currency and Hausa letters, then UI symbols (▲ ▼ ✓ ◎ …).
  static const fallbackFamilies = ['JarinaFallback', 'JarinaSymbols'];

  final TextStyle largeTitle;
  final TextStyle title;
  final TextStyle h2;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle amountXl;
  final TextStyle amountL;

  /// Body-sized tabular figures for amounts in list rows.
  TextStyle get num => body.copyWith(fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()]);

  @override
  JarinaText copyWith({
    TextStyle? largeTitle,
    TextStyle? title,
    TextStyle? h2,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? amountXl,
    TextStyle? amountL,
  }) => JarinaText(
    largeTitle: largeTitle ?? this.largeTitle,
    title: title ?? this.title,
    h2: h2 ?? this.h2,
    body: body ?? this.body,
    caption: caption ?? this.caption,
    amountXl: amountXl ?? this.amountXl,
    amountL: amountL ?? this.amountL,
  );

  @override
  JarinaText lerp(JarinaText? other, double t) {
    if (other == null) return this;
    return JarinaText(
      largeTitle: TextStyle.lerp(largeTitle, other.largeTitle, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      amountXl: TextStyle.lerp(amountXl, other.amountXl, t)!,
      amountL: TextStyle.lerp(amountL, other.amountL, t)!,
    );
  }
}

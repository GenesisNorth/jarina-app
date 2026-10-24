import 'package:flutter/material.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';

/// Semantic colours from `design/tokens.json`, switched by brightness.
///
/// Read with `context.colors` (see `JarinaThemeX`). Material's ColorScheme is
/// also populated, but Jarina screens should prefer these names because they
/// match the design files 1:1.
@immutable
class JarinaColors extends ThemeExtension<JarinaColors> {
  const JarinaColors({
    required this.bg,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.line,
    required this.fill,
    required this.up,
    required this.down,
    required this.gold,
    required this.goldDeep,
    required this.goldInk,
    required this.black,
  });

  static const light = JarinaColors(
    bg: LightColors.bg,
    card: LightColors.card,
    ink: LightColors.ink,
    ink2: LightColors.ink2,
    muted: LightColors.muted,
    line: LightColors.line,
    fill: LightColors.fill,
    up: LightColors.green,
    down: LightColors.red,
    gold: BrandColors.gold,
    goldDeep: BrandColors.goldDeep,
    goldInk: BrandColors.goldInk,
    black: BrandColors.black,
  );

  static const dark = JarinaColors(
    bg: DarkColors.bg,
    card: DarkColors.card,
    ink: DarkColors.ink,
    ink2: DarkColors.ink2,
    muted: DarkColors.muted,
    line: DarkColors.line,
    fill: DarkColors.fill,
    up: DarkColors.green,
    down: DarkColors.red,
    gold: BrandColors.gold,
    goldDeep: BrandColors.goldDeep,
    goldInk: BrandColors.goldInk,
    black: BrandColors.black,
  );

  final Color bg;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color muted;
  final Color line;
  final Color fill;

  /// Price up / positive amounts. Always pair with ▲ — never colour alone.
  final Color up;

  /// Price down / negative amounts. Always pair with ▼.
  final Color down;
  final Color gold;
  final Color goldDeep;
  final Color goldInk;

  /// Brand black used for header cards in both themes.
  final Color black;

  @override
  JarinaColors copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? ink2,
    Color? muted,
    Color? line,
    Color? fill,
    Color? up,
    Color? down,
    Color? gold,
    Color? goldDeep,
    Color? goldInk,
    Color? black,
  }) => JarinaColors(
    bg: bg ?? this.bg,
    card: card ?? this.card,
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    muted: muted ?? this.muted,
    line: line ?? this.line,
    fill: fill ?? this.fill,
    up: up ?? this.up,
    down: down ?? this.down,
    gold: gold ?? this.gold,
    goldDeep: goldDeep ?? this.goldDeep,
    goldInk: goldInk ?? this.goldInk,
    black: black ?? this.black,
  );

  @override
  JarinaColors lerp(JarinaColors? other, double t) {
    if (other == null) return this;
    return JarinaColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldDeep: Color.lerp(goldDeep, other.goldDeep, t)!,
      goldInk: Color.lerp(goldInk, other.goldInk, t)!,
      black: Color.lerp(black, other.black, t)!,
    );
  }
}

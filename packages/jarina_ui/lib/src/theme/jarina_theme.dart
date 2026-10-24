import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarina_ui/src/theme/jarina_colors.dart';
import 'package:jarina_ui/src/theme/jarina_text.dart';
import 'package:jarina_ui/src/tokens/jarina_tokens.g.dart';

abstract final class JarinaTheme {
  static ThemeData light() => _build(Brightness.light, JarinaColors.light);
  static ThemeData dark() => _build(Brightness.dark, JarinaColors.dark);

  static ThemeData _build(Brightness brightness, JarinaColors c) {
    final text = JarinaText.forColor(c.ink);
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? c.gold : c.black,
      onPrimary: isDark ? c.black : Colors.white,
      secondary: c.gold,
      onSecondary: c.black,
      error: c.down,
      onError: Colors.white,
      surface: c.card,
      onSurface: c.ink,
      surfaceContainerHighest: c.fill,
      outline: c.line,
      outlineVariant: c.line,
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.button));
    final buttonText = text.body.copyWith(fontWeight: FontWeight.w600);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: TypeTokens.family,
      package: 'jarina_ui',
      extensions: [c, text],
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displaySmall: text.largeTitle,
        headlineSmall: text.title,
        titleMedium: text.h2,
        bodyLarge: text.body,
        bodyMedium: text.body,
        bodySmall: text.caption.copyWith(color: c.muted),
        labelLarge: buttonText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.body.copyWith(fontWeight: FontWeight.w700, fontSize: 17),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? c.gold : c.black,
          foregroundColor: isDark ? c.black : Colors.white,
          disabledBackgroundColor: c.muted.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.fill,
          foregroundColor: c.ink,
          side: BorderSide.none,
          minimumSize: const Size.fromHeight(54),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.fill.withValues(alpha: isDark ? 1 : 0.6),
        hintStyle: text.body.copyWith(color: c.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.input),
          borderSide: BorderSide(color: c.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.input),
          borderSide: BorderSide(color: c.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.input),
          borderSide: BorderSide(color: c.gold, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.card)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.goldDeep : c.line),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.black,
        contentTextStyle: text.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.tile)),
      ),
    );
  }
}

extension JarinaThemeX on BuildContext {
  JarinaColors get colors => Theme.of(this).extension<JarinaColors>()!;
  JarinaText get text => Theme.of(this).extension<JarinaText>()!;
}

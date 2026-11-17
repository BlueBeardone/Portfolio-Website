import 'package:flutter/material.dart';

import '../models/site_theme.dart';

const String headingFontFamily = 'SpaceGrotesk';
const String bodyFontFamily = 'Inter';

ThemeData buildThemeData(SiteTheme theme) {
  final colors = theme.colors;
  final type = theme.type;

  final base = ColorScheme.fromSeed(
    seedColor: colors.accent,
    brightness: Brightness.dark,
    surface: colors.background,
    primary: colors.accent,
    secondary: colors.accentSecondary,
    onSurface: colors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: base,
    scaffoldBackgroundColor: colors.background,
    fontFamily: bodyFontFamily,
    splashFactory: NoSplash.splashFactory,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: type.heroDesktop,
        letterSpacing: type.nameTracking,
        height: 0.95,
        fontWeight: FontWeight.w700,
        color: colors.text,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colors.text,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: type.bodySize,
        height: 1.6,
        color: colors.text,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: type.bodySize,
        height: 1.6,
        color: colors.text,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: type.smallSize,
        height: 1.5,
        color: colors.muted,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: type.smallSize,
        letterSpacing: 1.6,
        color: colors.muted,
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.hairline, thickness: 1, space: 1),
  );
}

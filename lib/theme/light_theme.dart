 import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/theme/custom_theme_color.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFFF6B09),
  primaryColorDark: const Color(0xFFB64901),
  disabledColor: const Color(0xFFFFFFFF),
  scaffoldBackgroundColor: const Color(0xFFFF6B09),
  shadowColor: Colors.black.withValues(alpha:0.03),
  textTheme:  const TextTheme(
    bodyMedium: TextStyle(color: Color(0xff0c0c0c)),
    bodySmall: TextStyle(color: Color(0xff0a0b0b)),
    bodyLarge: TextStyle(color: Color(0xff0c0e0e)),
    titleMedium: TextStyle(color: Color(0xff0e0e0e)),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFEEEEEE)
  ),

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),

  brightness: Brightness.light,
  hintColor: const Color(0xFF050505),
  cardColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF6B09),
    secondary: Color(0xFFFF6B09),
    error: Color(0xFF8C0311),
    surface: Color(0xFFF3F3F3),
    tertiary: Color(0xFAE1B495),
    tertiaryContainer: Color(0xFFC98B3E),
    secondaryContainer: Color(0xFFEE6464),
    onTertiary: Color(0xFFD9D9D9),
    onSecondary: Color(0xFAB57043),
    onSecondaryContainer: Color(0xFAC1AD9F),
    onTertiaryContainer: Color(0xFF425956),
    outline: Color(0xFF8CFFF1),
    onPrimaryContainer: Color(0xFFDEFFFB),
    primaryContainer: Color(0xFF0B0B0A),
    onErrorContainer: Color(0xFFFFE6AD),
    onPrimary: Color(0xFF14B19E),
    surfaceTint: Color(0xFF0B9722),
    errorContainer: Color(0xFFF6F6F6),
    inverseSurface: Color(0xFF0148AF),
    surfaceContainer: Color(0xFF0094FF),
    secondaryFixedDim: Color(0xff252525),
  ),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF14B19E))),

  extensions: <ThemeExtension<CustomThemeColors>>[
    CustomThemeColors.light(),
  ],
);

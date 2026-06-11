import 'package:flutter/material.dart';

class AppColors {
  // LIGHT PALETTE
  static const Color lightPrimary = Color(0xFF249BB3);
  static const Color lightInk = Color(0xFF29373E);
  static const Color lightBackground = Color(0xFFF7FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceTintA = Color(0xFF8AC6C8);
  static const Color lightSurfaceTintB = Color(0xFF84B9DB);
  static const Color lightValueGreen = Color(0xFF2E7D32);
  static const Color lightValueGreenSoft = Color(0xFFE8F5E9);
  static const Color lightDanger = Color(0xFFC62828);
  static const Color lightWarning = Color(0xFFF9A825);

  // DARK PALETTE
  static const Color darkPrimary = Color(0xFF3FB8D0);
  static const Color darkInk = Color(0xFFE4EBEE);
  static const Color darkBackground = Color(0xFF121A1E);
  static const Color darkSurface = Color(0xFF1C262C);
  static const Color darkSurfaceTintA = Color(0x1F8AC6C8);
  static const Color darkSurfaceTintB = Color(0x1F84B9DB);
  static const Color darkValueGreen = Color(0xFF4CAF50);
  static const Color darkValueGreenSoft = Color(0x264CAF50);
  static const Color darkDanger = Color(0xFFEF5350);
  static const Color darkWarning = Color(0xFFF9A825);

  // DEPRECATED ALIASES (mapping to light tokens to prevent breakage until restyled)
  @Deprecated('Use theme instead')
  static const Color primary = lightPrimary;
  @Deprecated('Use theme instead')
  static const Color secondary = lightSurfaceTintA;
  @Deprecated('Use theme instead')
  static const Color background = lightBackground;
  @Deprecated('Use theme instead')
  static const Color surface = lightSurface;
  @Deprecated('Use theme instead')
  static const Color error = lightDanger;
  @Deprecated('Use theme instead')
  static const Color textPrimary = lightInk;
  @Deprecated('Use theme instead')
  static const Color textSecondary = lightSurfaceTintB;
  @Deprecated('Use theme instead')
  static const Color divider = Color(0xFFBDBDBD);
  @Deprecated('Use theme instead')
  static const Color agentPrice = Color(0xFF1976D2);
  @Deprecated('Use theme instead')
  static const Color companyPrice = Color(0xFF388E3C);
  @Deprecated('Use theme instead')
  static const Color marketPrice = Color(0xFFFBC02D);
  @Deprecated('Use theme instead')
  static const Color primaryLight = lightSurfaceTintA;
  @Deprecated('Use theme instead')
  static const Color accent = lightWarning;
  @Deprecated('Use theme instead')
  static const Color danger = lightDanger;
  @Deprecated('Use theme instead')
  static const Color cardBackground = lightSurface;
  @Deprecated('Use theme instead')
  static const Color textOnPrimary = lightSurface;
  @Deprecated('Use theme instead')
  static const Color priceGreen = lightValueGreen;
  @Deprecated('Use theme instead')
  static const Color priceRed = lightDanger;
}

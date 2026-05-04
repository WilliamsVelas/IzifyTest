import 'dart:ui';

import 'package:flutter/material.dart';

import 'Colors.dart';

class AppTextTheme {
  static const Color _defaultColor = AppColors.base900;

  static const String _fontFamily = 'Poppins';

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),

      headlineLarge: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),

      titleLarge: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      labelLarge: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: _defaultColor,
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// Centralized color palette for Casa de las Joyas application
/// Refined elegant color scheme: Champagne Gold, Deep Purple, and Premium Neutrals
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============= PRIMARY COLORS (REFINED GOLD) =============
  /// Primary gold color - Champagne gold for sophistication
  static const Color goldPrimary = Color(0xFFC9A961);

  /// Light gold - Soft elegant gold for highlights
  static const Color goldLight = Color(0xFFE8D5B7);

  /// Dark gold - Bronze gold for depth
  static const Color goldDark = Color(0xFF8B7355);

  /// Accent gold - Cream gold for subtle accents
  static const Color goldAccent = Color(0xFFF4E8D0);

  /// Metallic gold - For premium elements
  static const Color goldMetallic = Color(0xFFD4AF37);

  // ============= SECONDARY COLORS (DEEP PURPLE/INDIGO) =============
  /// Primary purple - Deep luxurious purple
  static const Color violetPrimary = Color(0xFF4A148C);

  /// Light purple - Medium rich purple
  static const Color violetLight = Color(0xFF7B1FA2);

  /// Dark purple - Almost black purple for depth
  static const Color violetDark = Color(0xFF1A0037);

  /// Accent purple - Rich vibrant purple
  static const Color violetAccent = Color(0xFF6A1B9A);

  /// Soft purple - For backgrounds
  static const Color violetSoft = Color(0xFFE1BEE7);

  // ============= NEUTRAL COLORS (PREMIUM WHITES & GRAYS) =============
  /// Pure white for backgrounds
  static const Color white = Color(0xFFFFFFFF);

  /// Almost white for subtle backgrounds
  static const Color almostWhite = Color(0xFFFAFAFA);

  /// Off-white for contrast
  static const Color offWhite = Color(0xFFF5F5F5);

  /// Light gray for borders and dividers
  static const Color lightGray = Color(0xFFE0E0E0);

  /// Medium gray for secondary text
  static const Color mediumGray = Color(0xFF9E9E9E);

  /// Dark gray for primary text (softer than pure black)
  static const Color darkGray = Color(0xFF212121);

  /// Charcoal - For deep text
  static const Color charcoal = Color(0xFF424242);

  // ============= SEMANTIC COLORS =============
  /// Success color - Elegant green
  static const Color success = Color(0xFF2E7D32);

  /// Error color - Sophisticated red
  static const Color error = Color(0xFFC62828);

  /// Warning color - Refined amber
  static const Color warning = Color(0xFFF57C00);

  /// Info color - Professional blue
  static const Color info = Color(0xFF1976D2);

  // ============= GRADIENTS =============
  /// Premium gold gradient for luxury elements
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, goldPrimary, goldDark],
  );

  /// Deep purple gradient for backgrounds
  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violetDark, violetPrimary, violetAccent],
  );

  /// Elegant combined gradient for hero sections
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violetDark, violetPrimary, goldPrimary],
    stops: [0.0, 0.6, 1.0],
  );

  /// Soft background gradient
  static const LinearGradient softBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [almostWhite, white],
  );
}

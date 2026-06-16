import 'package:flutter/material.dart';

class AppColors {
  // ──────────────────────────────────────────────
  // Dark Theme Palette (ليلي - Eye-friendly)
  // ──────────────────────────────────────────────
  static const navy        = Color(0xFF0F1C3A);
  static const navyLight   = Color(0xFF1A2C4E);
  static const gold        = Color(0xFFC9A84C);
  static const goldLight   = Color(0xFFE8C97A);
  static const goldMuted   = Color(0x26C9A84C);

  // Neutrals
  static const white       = Color(0xFFFFFFFF);
  static const offWhite    = Color(0xFFF8F6F0);
  static const surface     = Color(0xFFF2EDE4);

  // Semantics
  static const success     = Color(0xFF2E7D32);
  static const warning     = Color(0xFFE65100);
  static const error       = Color(0xFFC62828);

  // Text
  static const textPrimary    = Color(0xFF1A1A1A);
  static const textSecondary  = Color(0xFF6B6B6B);
  static const textOnDark     = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0x99FFFFFF);

  // ──────────────────────────────────────────────
  // Comprehensive Dark Palette (Eye-optimized)
  // ──────────────────────────────────────────────
  static const Dark = _DarkPalette();
  static const Light = _LightPalette();
}

class _DarkPalette {
  const _DarkPalette();

  // Backgrounds — warm dark blue-grays (no pure black)
  Color get background     => const Color(0xFF0D1117);
  Color get backgroundAlt  => const Color(0xFF131822);
  Color get surface        => const Color(0xFF1C2536);
  Color get surfaceHover   => const Color(0xFF263041);
  Color get surfaceNav     => const Color(0xFF101828);
  Color get surfaceCard    => const Color(0xFF1E293B);

  // Primary — warm Islamic gold
  Color get primary        => const Color(0xFFD4AF37);
  Color get primaryLight   => const Color(0xFFE8C97A);
  Color get primaryMuted   => const Color(0x33D4AF37);
  Color get primaryDark    => const Color(0xFFB8952E);

  // Secondary — calming emerald
  Color get secondary      => const Color(0xFF2D8A5E);
  Color get secondaryLight => const Color(0xFF3DAA78);
  Color get secondaryMuted => const Color(0x332D8A5E);

  // Accents
  Color get accentTeal     => const Color(0xFF3A9D8C);
  Color get accentAmber    => const Color(0xFFC9A84C);
  Color get accentRose     => const Color(0xFFC47272);

  // Text
  Color get textPrimary    => const Color(0xFFE6EDF3);
  Color get textSecondary  => const Color(0xFF8B949E);
  Color get textMuted      => const Color(0xFF5C6773);
  Color get textInverse    => const Color(0xFF1F2937);

  // Borders & Dividers
  Color get border         => const Color(0xFF2D3748);
  Color get borderLight    => const Color(0xFF3D4A5C);
  Color get divider        => const Color(0xFF1E2A3A);

  // Shadows
  Color get shadow         => const Color(0x40000000);

  // Semantic
  Color get success        => const Color(0xFF2EA043);
  Color get warning        => const Color(0xFFD29922);
  Color get error          => const Color(0xFFF85149);
  Color get info           => const Color(0xFF58A6FF);
}

class _LightPalette {
  const _LightPalette();

  // Backgrounds — warm cream / parchment
  Color get background     => const Color(0xFFF7F5F0);
  Color get backgroundAlt  => const Color(0xFFF0EDE5);
  Color get surface        => const Color(0xFFFFFDF7);
  Color get surfaceHover   => const Color(0xFFEDE9DF);
  Color get surfaceNav     => const Color(0xFFF0EDE5);
  Color get surfaceCard    => const Color(0xFFFFFDF5);

  // Primary — deep navy with warmth
  Color get primary        => const Color(0xFF1B2A4A);
  Color get primaryLight   => const Color(0xFF2C4068);
  Color get primaryMuted   => const Color(0x331B2A4A);
  Color get primaryDark    => const Color(0xFF0F1C3A);

  // Secondary — warm gold
  Color get secondary      => const Color(0xFFB8953A);
  Color get secondaryLight => const Color(0xFFD4B85C);
  Color get secondaryMuted => const Color(0x33B8953A);

  // Accents
  Color get accentTeal     => const Color(0xFF2B7A6B);
  Color get accentAmber    => const Color(0xFFC9A84C);
  Color get accentRose     => const Color(0xFFB86565);

  // Text
  Color get textPrimary    => const Color(0xFF1F2937);
  Color get textSecondary  => const Color(0xFF6B7280);
  Color get textMuted      => const Color(0xFF9CA3AF);
  Color get textInverse    => const Color(0xFFE6EDF3);

  // Borders & Dividers
  Color get border         => const Color(0xFFE5E1D8);
  Color get borderLight    => const Color(0xFFD4CFC4);
  Color get divider        => const Color(0xFFE8E4DB);

  // Shadows
  Color get shadow         => const Color(0x1A000000);

  // Semantic
  Color get success        => const Color(0xFF2E7D32);
  Color get warning        => const Color(0xFFE65100);
  Color get error          => const Color(0xFFDC2626);
  Color get info           => const Color(0xFF2563EB);
}

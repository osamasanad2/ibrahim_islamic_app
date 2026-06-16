import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceHover;
  final Color surfaceNav;
  final Color surfaceCard;

  final Color primary;
  final Color primaryLight;
  final Color primaryMuted;
  final Color primaryDark;

  final Color secondary;
  final Color secondaryLight;
  final Color secondaryMuted;

  final Color accentTeal;
  final Color accentAmber;
  final Color accentRose;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;

  final Color border;
  final Color borderLight;
  final Color divider;

  final Color shadow;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const ThemeColors({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceNav,
    required this.surfaceCard,
    required this.primary,
    required this.primaryLight,
    required this.primaryMuted,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryMuted,
    required this.accentTeal,
    required this.accentAmber,
    required this.accentRose,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.shadow,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const dark = ThemeColors(
    background: Color(0xFF0D1117),
    backgroundAlt: Color(0xFF131822),
    surface: Color(0xFF1C2536),
    surfaceHover: Color(0xFF263041),
    surfaceNav: Color(0xFF101828),
    surfaceCard: Color(0xFF1E293B),
    primary: Color(0xFFD4AF37),
    primaryLight: Color(0xFFE8C97A),
    primaryMuted: Color(0x33D4AF37),
    primaryDark: Color(0xFFB8952E),
    secondary: Color(0xFF2D8A5E),
    secondaryLight: Color(0xFF3DAA78),
    secondaryMuted: Color(0x332D8A5E),
    accentTeal: Color(0xFF3A9D8C),
    accentAmber: Color(0xFFC9A84C),
    accentRose: Color(0xFFC47272),
    textPrimary: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF8B949E),
    textMuted: Color(0xFF5C6773),
    textInverse: Color(0xFF1F2937),
    border: Color(0xFF2D3748),
    borderLight: Color(0xFF3D4A5C),
    divider: Color(0xFF1E2A3A),
    shadow: Color(0x40000000),
    success: Color(0xFF2EA043),
    warning: Color(0xFFD29922),
    error: Color(0xFFF85149),
    info: Color(0xFF58A6FF),
  );

  static const light = ThemeColors(
    background: Color(0xFFF7F5F0),
    backgroundAlt: Color(0xFFF0EDE5),
    surface: Color(0xFFFFFDF7),
    surfaceHover: Color(0xFFEDE9DF),
    surfaceNav: Color(0xFFF0EDE5),
    surfaceCard: Color(0xFFFFFDF5),
    primary: Color(0xFF1B2A4A),
    primaryLight: Color(0xFF2C4068),
    primaryMuted: Color(0x331B2A4A),
    primaryDark: Color(0xFF0F1C3A),
    secondary: Color(0xFFB8953A),
    secondaryLight: Color(0xFFD4B85C),
    secondaryMuted: Color(0x33B8953A),
    accentTeal: Color(0xFF2B7A6B),
    accentAmber: Color(0xFFC9A84C),
    accentRose: Color(0xFFB86565),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    textInverse: Color(0xFFE6EDF3),
    border: Color(0xFFE5E1D8),
    borderLight: Color(0xFFD4CFC4),
    divider: Color(0xFFE8E4DB),
    shadow: Color(0x1A000000),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFE65100),
    error: Color(0xFFDC2626),
    info: Color(0xFF2563EB),
  );

  @override
  ThemeExtension<ThemeColors> copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceHover,
    Color? surfaceNav,
    Color? surfaceCard,
    Color? primary,
    Color? primaryLight,
    Color? primaryMuted,
    Color? primaryDark,
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryMuted,
    Color? accentTeal,
    Color? accentAmber,
    Color? accentRose,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? border,
    Color? borderLight,
    Color? divider,
    Color? shadow,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return ThemeColors(
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceNav: surfaceNav ?? this.surfaceNav,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryMuted: secondaryMuted ?? this.secondaryMuted,
      accentTeal: accentTeal ?? this.accentTeal,
      accentAmber: accentAmber ?? this.accentAmber,
      accentRose: accentRose ?? this.accentRose,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceNav: Color.lerp(surfaceNav, other.surfaceNav, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryMuted: Color.lerp(secondaryMuted, other.secondaryMuted, t)!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      accentRose: Color.lerp(accentRose, other.accentRose, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension ThemeColorsX on BuildContext {
  ThemeColors get themeColors => Theme.of(this).extension<ThemeColors>()!;
  Brightness get brightness => Theme.of(this).brightness;
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}

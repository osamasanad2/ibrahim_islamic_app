import 'package:flutter/material.dart';
import 'theme_colors.dart';

class AppTheme {
  // ── Dark Theme (ليلي) ──────────────────────────
  static ThemeData get darkTheme {
    final c = ThemeColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,

      colorScheme: ColorScheme.dark(
        primary: c.primary,
        onPrimary: c.textInverse,
        primaryContainer: c.primary.withValues(alpha: 0.15),
        onPrimaryContainer: c.primaryLight,
        secondary: c.secondary,
        onSecondary: c.textInverse,
        secondaryContainer: c.secondary.withValues(alpha: 0.15),
        onSecondaryContainer: c.secondaryLight,
        tertiary: c.accentTeal,
        surface: c.surface,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.surfaceNav,
        error: c.error,
        onError: c.textInverse,
        outline: c.border,
        outlineVariant: c.borderLight,
        shadow: c.shadow,
      ),

      extensions: const <ThemeExtension<dynamic>>[
        ThemeColors.dark,
      ],

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: c.backgroundAlt,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        iconTheme: IconThemeData(color: c.primary),
        titleTextStyle: TextStyle(
          color: c.primary,
          fontFamily: 'Amiri',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surfaceNav,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textMuted),
        prefixIconColor: c.textMuted,
        suffixIconColor: c.textMuted,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.textInverse,
          disabledBackgroundColor: c.textMuted.withValues(alpha: 0.3),
          disabledForegroundColor: c.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Icon Button ──
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.textPrimary,
        ),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(color: c.textPrimary, fontFamily: 'Amiri'),
        secondaryLabelStyle: TextStyle(color: c.textSecondary),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceNav,
        contentTextStyle: TextStyle(color: c.textPrimary, fontFamily: 'Amiri'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Progress Indicator ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.border,
        thumbColor: c.primary,
        overlayColor: c.primary.withValues(alpha: 0.12),
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.primary.withValues(alpha: 0.5);
          }
          return c.border;
        }),
      ),

      // ── Text Theme ──
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 28, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 24, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w400,
          color: c.textPrimary, height: 2.0,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400,
          color: c.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400,
          color: c.textMuted,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
          color: c.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500,
          color: c.textMuted,
        ),
      ),
    );
  }

  // ── Light Theme (نهاري) ────────────────────────
  static ThemeData get lightTheme {
    final c = ThemeColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,

      colorScheme: ColorScheme.light(
        primary: c.primary,
        onPrimary: c.textInverse,
        primaryContainer: c.primary.withValues(alpha: 0.12),
        onPrimaryContainer: c.primaryLight,
        secondary: c.secondary,
        onSecondary: c.textInverse,
        secondaryContainer: c.secondary.withValues(alpha: 0.12),
        onSecondaryContainer: c.secondaryLight,
        tertiary: c.accentTeal,
        surface: c.surface,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.surfaceNav,
        error: c.error,
        onError: c.textInverse,
        outline: c.border,
        outlineVariant: c.borderLight,
        shadow: c.shadow,
      ),

      extensions: const <ThemeExtension<dynamic>>[
        ThemeColors.light,
      ],

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        iconTheme: IconThemeData(color: c.primary),
        titleTextStyle: TextStyle(
          color: c.primary,
          fontFamily: 'Amiri',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surfaceNav,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textMuted),
        prefixIconColor: c.textMuted,
        suffixIconColor: c.textMuted,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.textInverse,
          disabledBackgroundColor: c.textMuted.withValues(alpha: 0.3),
          disabledForegroundColor: c.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Icon Button ──
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.textPrimary,
        ),
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: c.textPrimary, fontFamily: 'Amiri'),
        secondaryLabelStyle: TextStyle(color: c.textSecondary),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceNav,
        contentTextStyle: TextStyle(color: c.textPrimary, fontFamily: 'Amiri'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Progress Indicator ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.border,
        thumbColor: c.primary,
        overlayColor: c.primary.withValues(alpha: 0.12),
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.primary.withValues(alpha: 0.5);
          }
          return c.border;
        }),
      ),

      // ── Text Theme ──
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 28, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 24, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w400,
          color: c.textPrimary, height: 2.0,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400,
          color: c.textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400,
          color: c.textMuted,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
          color: c.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500,
          color: c.textMuted,
        ),
      ),
    );
  }
}

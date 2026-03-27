import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens following the user's typography & spacing guidelines:
/// - Single font family (Inter default, Lexend for dyslexia)
/// - Typographic scale: 32 / 24 / 20 / 16 / 14 / 12 (never below 12)
/// - Weight hierarchy: 400 body, 500-600 buttons/nav, 700 headers
/// - Line height: 140-150% body, 110-120% headers
/// - Text colors: #1A1A1A primary, #666666 secondary (never pure black)
/// - Minimum touch target: 44x44 (48x48 when largeTouchTargets enabled)
class AppTheme {
  // ─── Color Tokens ────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF1E88E5);
  static const Color brandPrimaryDark = Color(0xFF1565C0);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color surfaceBg = Color(0xFFF8F9FA);
  static const Color surfaceCard = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF2E7D32);

  // ─── Typographic Scale ───────────────────────────────────
  static const double fontDisplay = 32.0;
  static const double fontH1 = 24.0;
  static const double fontH2 = 20.0;
  static const double fontBody = 16.0;
  static const double fontCaption = 14.0;
  static const double fontTiny = 12.0;

  // ─── Spacing (8-point grid) ──────────────────────────────
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // ─── Gradients ────────────────────────────────────────────
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientCard = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientSubtle = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Animation Tokens ─────────────────────────────────────
  static const Duration animDuration = Duration(milliseconds: 300);
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Curve animCurve = Curves.easeInOutCubic;

  // ─── Shape Tokens ─────────────────────────────────────────
  static const double cardRadius = 16.0;
  static const double cardRadiusLg = 24.0;
  static const double inputRadius = 14.0;

  static ThemeData getTheme({
    required bool isHighContrast,
    required bool isDyslexiaFont,
    required double textScale,
    double lineSpacing = 1.5,
    double letterSpacing = 0.0,
    bool focusIndicators = true,
    bool largeTouchTargets = false,
  }) {
    // ─── Color Scheme ────────────────────────────────────
    ColorScheme colorScheme;
    if (isHighContrast) {
      colorScheme = const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.black,
        onPrimary: Colors.yellow,
        secondary: Colors.yellow,
        onSecondary: Colors.black,
        error: Color(0xFFB00020),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      );
    } else {
      colorScheme = ColorScheme.fromSeed(
        seedColor: brandPrimary,
        brightness: Brightness.light,
        primary: brandPrimary,
        onPrimary: Colors.white,
        error: errorColor,
        surface: surfaceCard,
        onSurface: textPrimary,
      );
    }

    // ─── Typography ──────────────────────────────────────

    TextTheme baseTextTheme = isDyslexiaFont
        ? GoogleFonts.lexendTextTheme()
        : GoogleFonts.interTextTheme();

    final Color onSurface = colorScheme.onSurface;
    final double ls = letterSpacing;

    TextTheme scaledTextTheme = baseTextTheme.copyWith(
      // Display — 32px, bold 700, tight line height 1.15
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: fontDisplay * textScale,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: ls,
        color: onSurface,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: (fontDisplay * 0.85) * textScale,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: ls,
        color: onSurface,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: fontH1 * textScale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: ls,
        color: onSurface,
      ),
      // Headlines — 24/20px, bold 700, line height 1.2
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: fontH1 * textScale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: ls,
        color: onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: fontH2 * textScale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: ls,
        color: onSurface,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: (fontH2 * 0.9) * textScale,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: ls,
        color: onSurface,
      ),
      // Titles — 16-20px, semi-bold 600
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: fontH2 * textScale,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: ls,
        color: onSurface,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: fontBody * textScale,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: ls,
        color: onSurface,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: fontCaption * textScale,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: ls,
        color: onSurface,
      ),
      // Body — 16/14px, regular 400, generous line height
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: fontBody * textScale,
        fontWeight: FontWeight.w400,
        height: lineSpacing,
        letterSpacing: ls,
        color: onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: fontCaption * textScale,
        fontWeight: FontWeight.w400,
        height: lineSpacing,
        letterSpacing: ls,
        color: onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: fontTiny * textScale,
        fontWeight: FontWeight.w400,
        height: lineSpacing,
        letterSpacing: ls,
        color: isHighContrast ? onSurface : textSecondary,
      ),
      // Labels — 14/12px, medium 500 (buttons, nav)
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: fontCaption * textScale,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: ls + 0.1,
        color: onSurface,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: fontTiny * textScale,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: ls + 0.5,
        color: isHighContrast ? onSurface : textSecondary,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: fontTiny * textScale,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: ls + 0.5,
        color: isHighContrast ? onSurface : textTertiary,
      ),
    );

    // ─── Touch target sizing ─────────────────────────────
    final double minButtonHeight = largeTouchTargets ? 52.0 : 44.0;
    final MaterialTapTargetSize tapSize =
        largeTouchTargets ? MaterialTapTargetSize.padded : MaterialTapTargetSize.shrinkWrap;

    // ─── Focus styling ───────────────────────────────────
    final Color focusColor = isHighContrast
        ? Colors.yellow
        : brandPrimary.withValues(alpha: 0.4);

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: scaledTextTheme,
      useMaterial3: true,
      scaffoldBackgroundColor: isHighContrast ? Colors.white : surfaceBg,
      materialTapTargetSize: tapSize,

      // Focus & highlight
      focusColor: focusIndicators ? focusColor : Colors.transparent,
      highlightColor: brandPrimary.withValues(alpha: 0.08),
      splashColor: brandPrimary.withValues(alpha: 0.12),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isHighContrast ? Colors.black : Colors.white,
        foregroundColor: isHighContrast ? Colors.yellow : textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isHighContrast ? Colors.yellow : textPrimary,
          size: 24,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isHighContrast ? Colors.white : surfaceCard,
        elevation: isHighContrast ? 0 : 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHighContrast
              ? const BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
        ),
      ),

      // Elevated buttons — min 44px height
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isHighContrast ? Colors.black : brandPrimary,
          foregroundColor: isHighContrast ? Colors.yellow : Colors.white,
          minimumSize: Size(88, minButtonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontCaption * textScale,
            letterSpacing: ls + 0.1,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isHighContrast ? Colors.black : brandPrimary,
          minimumSize: Size(88, minButtonHeight),
          side: BorderSide(
            color: isHighContrast ? Colors.black : brandPrimary,
            width: isHighContrast ? 2 : 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontCaption * textScale,
            letterSpacing: ls + 0.1,
          ),
        ),
      ),

      // Icon buttons — minimum touch target
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size(largeTouchTargets ? 48 : 44, largeTouchTargets ? 48 : 44),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isHighContrast ? Colors.yellow : brandPrimary;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isHighContrast
                ? Colors.yellow.withValues(alpha: 0.5)
                : brandPrimary.withValues(alpha: 0.3);
          }
          return Colors.grey.shade300;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: isHighContrast ? Colors.black : brandPrimary,
        thumbColor: isHighContrast ? Colors.yellow : brandPrimary,
        inactiveTrackColor: Colors.grey.shade300,
        overlayColor: brandPrimary.withValues(alpha: 0.12),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isHighContrast ? Colors.black : Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }
}

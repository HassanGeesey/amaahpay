import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoTheme {
  NeoTheme._();

  // --- Primary Navy ---
  static const Color primaryNavy = Color(0xFF0F2A44);
  static const Color secondaryNavy = Color(0xFF1B3B5A);
  static const Color primaryTeal = Color(0xFF2EC4A6);
  static const Color tealGradientStart = Color(0xFF34D1BF);
  static const Color tealGradientEnd = Color(0xFF1FAF95);

  // --- Light Theme Colors ---
  static const Color bgPrimary = Color(0xFFF4F7F9);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE3E8EE);
  static const Color textDark = Color(0xFF0F2A44);
  static const Color textMuted = Color(0xFF6B7C8F);
  static const Color textInverse = Color(0xFFFFFFFF);

  // --- Dark Theme Colors ---
  static const Color bgDark = Color(0xFF0D1117);
  static const Color cardDark = Color(0xFF161B22);
  static const Color cardDarkElevated = Color(0xFF21262D);
  static const Color textDarkMode = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textMutedDark = Color(0xFF6E7681);
  static const Color borderDark = Color(0xFF30363D);

  // --- Semantic Colors ---
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFF59E0B);

  // --- Gradients ---
  static const List<Color> tealGradient = [tealGradientStart, tealGradientEnd];
  static const List<Color> primaryGradient = [primaryNavy, secondaryNavy];

  static Color bg(bool isDark) => isDark ? bgDark : bgPrimary;
  static Color card(bool isDark) => isDark ? cardDark : bgCard;
  static Color cardElevated(bool isDark) => isDark ? cardDarkElevated : bgCard;
  static Color txt(bool isDark) => isDark ? textDarkMode : textDark;
  static Color sub(bool isDark) => isDark ? textSecondaryDark : textMuted;
  static Color muted(bool isDark) => isDark ? textMutedDark : textMuted;
  static Color bdr(bool isDark) => isDark ? borderDark : borderLight;

  static BoxDecoration get darkCard => BoxDecoration(
    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [secondaryNavy, primaryNavy]),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderDark, width: 1),
  );

  static BoxDecoration cardDecoration({bool isDark = false}) => BoxDecoration(
    color: card(isDark),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: bdr(isDark)),
    boxShadow: isDark ? null : [BoxShadow(color: primaryNavy.withAlpha(15), blurRadius: 24, offset: const Offset(0, 8))],
  );

  static BoxDecoration soft({bool isDark = false}) => BoxDecoration(
    color: isDark ? cardDarkElevated : const Color(0xFFF4F7F9),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: bdr(isDark)),
    boxShadow: isDark ? null : [BoxShadow(color: primaryNavy.withAlpha(12), blurRadius: 16, offset: const Offset(0, 4))],
  );

  static ThemeData get light => _buildTheme(false);
  static ThemeData get dark => _buildTheme(true);

  static ThemeData _buildTheme(bool isDark) {
    final bgColor = isDark ? bgDark : bgPrimary;
    final surface = isDark ? cardDark : bgCard;
    final txtP = isDark ? textDarkMode : textDark;
    final txtS = isDark ? textSecondaryDark : textMuted;
    final border = isDark ? borderDark : borderLight;
    final primary = primaryTeal;
    final onPrimary = isDark ? primaryNavy : textInverse;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              onPrimary: onPrimary,
              secondary: primaryTeal,
              onSecondary: textInverse,
              surface: surface,
              onSurface: txtP,
              outline: border,
              error: error,
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: onPrimary,
              secondary: primaryTeal,
              onSecondary: textInverse,
              surface: surface,
              onSurface: txtP,
              outline: border,
              error: error,
            ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: txtP, height: 1.2),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: txtP, height: 1.25),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: txtP, height: 1.3),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: txtP),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: txtP),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: txtP),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: txtP),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: txtP),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: txtP),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: txtP),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: txtP),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: txtS),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: txtP),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: txtS),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: txtS, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: txtP,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: txtP),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: border)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: primaryNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txtP,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? cardDark : bgCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: txtS),
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: txtS),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: isDark ? primaryTeal.withAlpha(30) : primaryTeal.withAlpha(20),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: primaryTeal);
          }
          return GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: txtS);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12)))),
      dialogTheme: DialogThemeData(backgroundColor: surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: txtS, size: 22),
    );
  }
}

// Color shortcuts
class C {
  C._();
  static const Color primaryNavy = NeoTheme.primaryNavy;
  static const Color secondaryNavy = NeoTheme.secondaryNavy;
  static const Color primaryTeal = NeoTheme.primaryTeal;
  static const Color tealGradientStart = NeoTheme.tealGradientStart;
  static const Color tealGradientEnd = NeoTheme.tealGradientEnd;
  static const Color bgPrimary = NeoTheme.bgPrimary;
  static const Color bgCard = NeoTheme.bgCard;
  static const Color border = NeoTheme.borderLight;
  static const Color textPrimary = NeoTheme.textDark;
  static const Color textMuted = NeoTheme.textMuted;
  static const Color textSecondary = NeoTheme.textMuted;
  static const Color textInverse = NeoTheme.textInverse;
  static const Color success = NeoTheme.success;
  static const Color error = NeoTheme.error;
  static const Color warning = NeoTheme.warning;
  static const Color accent = NeoTheme.primaryTeal;
  static Color accentColor(bool isDark) => isDark ? primaryTeal : primaryTeal;
  static const Color bgDark = NeoTheme.bgDark;
  static const Color cardDark = NeoTheme.cardDark;
  static const Color textDark = NeoTheme.textDarkMode;
  static const Color textMutedDark = NeoTheme.textMutedDark;
  static const Color borderDark = NeoTheme.borderDark;

  static Color bg(bool isDark) => NeoTheme.bg(isDark);
  static Color card(bool isDark) => NeoTheme.card(isDark);
  static Color cardElevated(bool isDark) => NeoTheme.cardElevated(isDark);
  static Color txt(bool isDark) => NeoTheme.txt(isDark);
  static Color sub(bool isDark) => NeoTheme.sub(isDark);
  static Color muted(bool isDark) => NeoTheme.muted(isDark);
  static Color bdr(bool isDark) => NeoTheme.bdr(isDark);

  static List<Color> get tealGradient => NeoTheme.tealGradient;
}

// Spacing
class S {
  S._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

// Radius
class R {
  R._();
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}

// Typography shortcuts
class T {
  T._();
  static TextStyle get displayLarge => GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle get displayMedium => GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle get sectionHeader => GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle get title => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle get body => GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white);
  static TextStyle get bodyLarge => GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white);
  static TextStyle get label => GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF));
  static TextStyle get caption => GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF));
  static TextStyle get upperLabel => GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF), letterSpacing: 0.5);
  static TextStyle get button => GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);
}

// Decorations
class D {
  D._();
  static BoxDecoration get darkCard => NeoTheme.darkCard;
  static BoxDecoration card({bool isDark = false}) => NeoTheme.cardDecoration(isDark: isDark);
  static BoxDecoration soft({bool isDark = false}) => NeoTheme.soft(isDark: isDark);
}

// App aliases
class AppColors {
  static const Color primaryBlue = NeoTheme.primaryNavy;
  static const Color secondaryBlue = NeoTheme.secondaryNavy;
  static const Color primaryTeal = NeoTheme.primaryTeal;
  static const Color tealGradientStart = NeoTheme.tealGradientStart;
  static const Color tealGradientEnd = NeoTheme.tealGradientEnd;
  static const Color successGreen = NeoTheme.success;
  static const Color errorRed = NeoTheme.error;
  static const Color warningAmber = NeoTheme.warning;
  static const Color light = NeoTheme.bgPrimary;
  static const Color white = NeoTheme.bgCard;
  static const Color neutral900 = NeoTheme.textDark;
  static const Color neutral800 = NeoTheme.secondaryNavy;
  static const Color neutral700 = NeoTheme.primaryNavy;
  static const Color neutral500 = NeoTheme.textMuted;
  static const Color neutral400 = NeoTheme.textMuted;
  static const Color neutral200 = NeoTheme.borderLight;
  static const Color neutral100 = Color(0xFFF8FAFC);
  static const List<Color> primaryGradient = NeoTheme.primaryGradient;
  static const List<Color> tealGradient = NeoTheme.tealGradient;
  static Color background(bool isDark) => NeoTheme.bg(isDark);
  static Color surface(bool isDark) => NeoTheme.card(isDark);
  static Color surfaceElevated(bool isDark) => isDark ? NeoTheme.cardDarkElevated : NeoTheme.bgCard;
  static Color textPrimary(bool isDark) => NeoTheme.txt(isDark);
  static Color textSecondary(bool isDark) => NeoTheme.sub(isDark);
  static Color border(bool isDark) => NeoTheme.bdr(isDark);
  static Color divider(bool isDark) => NeoTheme.bdr(isDark);
  static Color accent(bool isDark) => NeoTheme.primaryTeal;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadius {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 100;
}

class AppTheme {
  AppTheme._();
  static ThemeData get light => NeoTheme.light;
  static ThemeData get dark => NeoTheme.dark;
}
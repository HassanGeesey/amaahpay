import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoTheme {
  NeoTheme._();

  // --- Colors (Light theme - clean professional) ---
  static const Color bgPrimary = Color(0xFFFAFAFA);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgElevated = Color(0xFFF5F5F5);
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF1A1A1A);
  static const Color accentDark = Color(0xFFFFFFFF);
  static const List<Color> cardGradient = [Color(0xFF1A1A1A), Color(0xFF262626)];
  static const List<Color> cardGradientLight = [Color(0xFF171717), Color(0xFF2D2D2D)];

  // --- Dark theme colors (professional high contrast) ---
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardDarkElevated = Color(0xFF242424);
  static const Color textDark = Color(0xFFFEFEFE);
  static const Color textSecondaryDark = Color(0xFFB4B4B4);
  static const Color textMutedDark = Color(0xFF6B7280);
  static const Color borderDark = Color(0xFF2E2E2E);

  static Color bg(bool isDark) => isDark ? bgDark : bgPrimary;
  static Color card(bool isDark) => isDark ? cardDark : bgCard;
  static Color cardElevated(bool isDark) => isDark ? cardDarkElevated : bgElevated;
  static Color txt(bool isDark) => isDark ? textDark : textPrimary;
  static Color sub(bool isDark) => isDark ? textSecondaryDark : textSecondary;
  static Color muted(bool isDark) => isDark ? textMutedDark : textMuted;
  static Color bdr(bool isDark) => isDark ? borderDark : borderLight;
  static Color accentColor(bool isDark) => isDark ? textDark : accent;

  static BoxDecoration get darkCard => BoxDecoration(
    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1F1F1F), Color(0xFF141414)]),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: borderDark, width: 1),
  );

  static BoxDecoration cardDecoration({bool isDark = false}) => BoxDecoration(
    color: card(isDark),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: bdr(isDark)),
    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20, offset: const Offset(0, 4))],
  );

  static BoxDecoration soft({bool isDark = false}) => BoxDecoration(
    color: isDark ? const Color(0xFF242424) : bgElevated,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: bdr(isDark)),
    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))],
  );

  static ThemeData get light => _buildTheme(false);
  static ThemeData get dark => _buildTheme(true);
  
  static ThemeData _buildTheme(bool isDark) {
    final bgColor = isDark ? bgDark : bgPrimary;
    final surface = isDark ? cardDark : bgCard;
    final txtP = isDark ? textDark : textPrimary;
    final txtS = isDark ? textSecondaryDark : textSecondary;
    final border = isDark ? borderDark : borderLight;
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.light(brightness: isDark ? Brightness.dark : Brightness.light, primary: accent, onPrimary: textInverse, surface: surface, onSurface: txtP, outline: border),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: txtP),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: txtP),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: txtP),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: txtP),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: txtS),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor, foregroundColor: txtP, elevation: 0, centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: txtP),
      ),
      cardTheme: CardThemeData(color: surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: border))),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: textInverse, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(foregroundColor: txtP, side: BorderSide(color: border), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: isDark ? const Color(0xFF1F1F1F) : bgCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accent, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface, indicatorColor: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6),
        elevation: 0, height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: txtP);
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: txtS);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: const Radius.circular(24)))),
      dialogTheme: DialogThemeData(backgroundColor: surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
    );
  }
}

// Simple shortcuts
class C {
  C._();
  static const Color bgPrimary = NeoTheme.bgPrimary;
  static const Color bgCard = NeoTheme.bgCard;
  static const Color textPrimary = NeoTheme.textPrimary;
  static const Color textSecondary = NeoTheme.textSecondary;
  static const Color textMuted = NeoTheme.textMuted;
  static const Color textInverse = NeoTheme.textInverse;
  static const Color border = NeoTheme.borderLight;
  static const Color accent = NeoTheme.accent;
  static const Color bgDark = NeoTheme.bgDark;
  static const Color cardDark = NeoTheme.cardDark;
  static const Color textDark = NeoTheme.textDark;
  static const Color textMutedDark = NeoTheme.textMutedDark;
  static Color bg(bool isDark) => NeoTheme.bg(isDark);
  static Color card(bool isDark) => NeoTheme.card(isDark);
  static Color cardElevated(bool isDark) => NeoTheme.cardElevated(isDark);
  static Color txt(bool isDark) => NeoTheme.txt(isDark);
  static Color sub(bool isDark) => NeoTheme.sub(isDark);
  static Color muted(bool isDark) => NeoTheme.muted(isDark);
  static Color bdr(bool isDark) => NeoTheme.bdr(isDark);
  static Color accentColor(bool isDark) => NeoTheme.accentColor(isDark);
}

class S {
  S._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class R {
  R._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}

class T {
  T._();
  static TextStyle get sectionHeader => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: NeoTheme.textPrimary);
  static TextStyle get body => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: NeoTheme.textPrimary);
  static TextStyle get label => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: NeoTheme.textSecondary);
  static TextStyle get caption => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: NeoTheme.textSecondary);
  static TextStyle get upperLabel => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: NeoTheme.textSecondary, letterSpacing: 0.5);
}

class D {
  D._();
  static BoxDecoration get darkCard => NeoTheme.darkCard;
  static BoxDecoration card({bool isDark = false}) => NeoTheme.cardDecoration(isDark: isDark);
  static BoxDecoration soft({bool isDark = false}) => NeoTheme.soft(isDark: isDark);
}

// Compatibility aliases
class AppColors {
  static const Color primaryBlue = NeoTheme.accent;
  static const Color successGreen = NeoTheme.textPrimary;
  static const Color errorRed = NeoTheme.textPrimary;
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color light = Color(0xFFF9FAFB);
  static const Color neutral900 = NeoTheme.textPrimary;
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral500 = NeoTheme.textSecondary;
  static const Color neutral400 = NeoTheme.textMuted;
  static const Color neutral200 = NeoTheme.borderLight;
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color white = NeoTheme.textInverse;
  static const List<Color> primaryGradient = NeoTheme.cardGradient;
  static Color background(bool isDark) => NeoTheme.bg(isDark);
  static Color surface(bool isDark) => NeoTheme.card(isDark);
  static Color surfaceElevated(bool isDark) => isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF9FAFB);
  static Color textPrimary(bool isDark) => NeoTheme.txt(isDark);
  static Color textSecondary(bool isDark) => NeoTheme.sub(isDark);
  static Color border(bool isDark) => NeoTheme.bdr(isDark);
  static Color divider(bool isDark) => NeoTheme.bdr(isDark);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}

class AppTheme {
  AppTheme._();
  static ThemeData get light => NeoTheme.light;
  static ThemeData get dark => NeoTheme.dark;
}
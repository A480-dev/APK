import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales
  static const Color primaryBackground = Color(0xFF0F0F23);
  static const Color secondaryBackground = Color(0xFF1A1A3E);
  static const Color surfaceColor = Color(0xFF252550);
  static const Color primaryAccent = Color(0xFF7C4DFF);
  static const Color secondaryAccent = Color(0xFF00E5FF);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0BEC5);
  static const Color successColor = Color(0xFF69F0AE);
  static const Color dangerColor = Color(0xFFFF5252);
  
  // Colores de bloques
  static const List<Color> blockColors = [
    Color(0xFFFF4757), // Rojo
    Color(0xFF2196F3), // Azul
    Color(0xFF4CAF50), // Verde
    Color(0xFFFFD700), // Amarillo
    Color(0xFF9C27B0), // Morado
    Color(0xFFFF9800), // Naranja
    Color(0xFF00BCD4), // Cyan
  ];
  
  // Gradiente para botones principales
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryAccent, secondaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente para fondo
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryBackground, secondaryBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Tema claro (no se usa mucho pero es bueno tenerlo)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.purple,
      fontFamily: 'Poppins',
    );
  }
  
  // Tema oscuro (el principal del juego)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBackground,
      fontFamily: 'Poppins',
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Títulos del juego
        displayLarge: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: primaryText,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        // Puntuación
        headlineLarge: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: primaryText,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: primaryText,
        ),
        // Botones
        labelLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
        // Texto del cuerpo
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: primaryText,
          elevation: 8,
          shadowColor: primaryAccent.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryText,
        size: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: primaryText,
        ),
      ),
    );
  }
  
  // Estilo para botones con gradiente
  static ButtonStyle get primaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: primaryText,
      elevation: 8,
      shadowColor: primaryAccent.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.zero,
    );
  }
  
  // Decoración para celdas del tablero
  static BoxDecoration get cellDecoration {
    return BoxDecoration(
      color: surfaceColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: secondaryText.withOpacity(0.2),
        width: 1,
      ),
    );
  }
  
  // Decoración para bloques colocados
  static BoxDecoration getBlockDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.5),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // Decoración para ghost preview
  static BoxDecoration getGhostDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: color.withOpacity(0.6),
        width: 2,
        style: BorderStyle.solid,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores principal
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkBg = Color(0xFF12141C);
  static const Color cardBg = Color(0xFF1E2230);
  static const Color surfaceBg = Color(0xFF252A3C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EABB8);
  static const Color accentGold = Color(0xFFFFCB05);
  static const Color accentBlue = Color(0xFF3B4CCA);

  // Colores por tipo de Pokémon
  static Color getTypeColor(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'fire':
      case 'fuego':
        return const Color(0xFFFA5643);
      case 'water':
      case 'agua':
        return const Color(0xFF569CFA);
      case 'grass':
      case 'planta':
      case 'hierba':
        return const Color(0xFF49D0B0);
      case 'electric':
      case 'eléctrico':
      case 'electrico':
        return const Color(0xFFFFCE4B);
      case 'psychic':
      case 'psíquico':
      case 'psiquico':
        return const Color(0xFFFF6584);
      case 'ice':
      case 'hielo':
        return const Color(0xFF70D7F5);
      case 'dragon':
      case 'dragón':
        return const Color(0xFF8B5CF6);
      case 'dark':
      case 'siniestro':
      case 'oscuro':
        return const Color(0xFF5A5366);
      case 'fairy':
      case 'hada':
        return const Color(0xFFFF85B5);
      case 'normal':
        return const Color(0xFFA0A29F);
      case 'fighting':
      case 'lucha':
        return const Color(0xFFD3425F);
      case 'flying':
      case 'volador':
        return const Color(0xFF8294F5);
      case 'poison':
      case 'veneno':
        return const Color(0xFFA43E9E);
      case 'ground':
      case 'tierra':
        return const Color(0xFFD97746);
      case 'rock':
      case 'roca':
        return const Color(0xFFC5B78C);
      case 'bug':
      case 'bicho':
        return const Color(0xFF92BD2D);
      case 'ghost':
      case 'fantasma':
        return const Color(0xFF70559B);
      case 'steel':
      case 'acero':
        return const Color(0xFF5E8EA5);
      default:
        return const Color(0xFF757575);
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: accentGold,
        surface: cardBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: cardBg,
    );
  }
}

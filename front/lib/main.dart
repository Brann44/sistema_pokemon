import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Pokémon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

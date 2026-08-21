import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../theme/app_theme.dart';
import '../screens/pokemon_detail_screen.dart';

class PokemonCard extends StatelessWidget {
  final PokemonModel pokemon;
  final VoidCallback? onFavoriteToggle;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppTheme.getTypeColor(pokemon.mainType);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PokemonDetailScreen(
              pokemon: pokemon,
              onFavoriteToggle: onFavoriteToggle,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.85),
              cardColor.withOpacity(0.45),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Marca de agua Pokébola decorativa de fondo
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID y Botón Favorito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pokemon.formattedId,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              pokemon.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: pokemon.isFavorite
                                  ? Colors.redAccent
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Nombre del Pokémon
                  Text(
                    pokemon.capitalizedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Badges de Tipos
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: pokemon.types.take(2).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // Imagen del Pokémon
                  Center(
                    child: Hero(
                      tag: 'pokemon-img-${pokemon.id}',
                      child: Image.network(
                        pokemon.imageUrl,
                        height: 90,
                        width: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 50, color: Colors.white54),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 90,
                            width: 90,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

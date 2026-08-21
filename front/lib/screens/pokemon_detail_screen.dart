import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../theme/app_theme.dart';

class PokemonDetailScreen extends StatefulWidget {
  final PokemonModel pokemon;
  final VoidCallback? onFavoriteToggle;

  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
    this.onFavoriteToggle,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final themeColor = AppTheme.getTypeColor(widget.pokemon.mainType);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.onFavoriteToggle != null)
            IconButton(
              icon: Icon(
                widget.pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.pokemon.isFavorite ? Colors.redAccent : Colors.white,
                size: 28,
              ),
              onPressed: () {
                widget.onFavoriteToggle!();
                setState(() {});
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Encabezado con Nombre, ID y Tipos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.pokemon.capitalizedName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.pokemon.formattedId,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.pokemon.types.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Tarjeta Inferior con Detalles
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.90,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 24, right: 24, bottom: 20),
                decoration: const BoxDecoration(
                  color: AppTheme.darkBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Datos Físicos (Peso y Altura)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPhysicalStatCard(
                          icon: Icons.height,
                          title: 'ALTURA',
                          value: '${widget.pokemon.height} m',
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white12,
                        ),
                        _buildPhysicalStatCard(
                          icon: Icons.monitor_weight_outlined,
                          title: 'PESO',
                          value: '${widget.pokemon.weight} kg',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Sección Habilidades
                    const Text(
                      'Habilidades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.pokemon.abilities.map((ability) {
                        return Chip(
                          backgroundColor: AppTheme.cardBg,
                          avatar: CircleAvatar(
                            backgroundColor: themeColor,
                            radius: 6,
                          ),
                          label: Text(
                            ability.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // Estadísticas Base
                    if (widget.pokemon.stats.isNotEmpty) ...[
                      const Text(
                        'Estadísticas Base',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...widget.pokemon.stats.entries.map((entry) {
                        return _buildStatRow(
                          name: _formatStatName(entry.key),
                          value: entry.value,
                          color: themeColor,
                        );
                      }),
                    ],
                  ],
                ),
              );
            },
          ),

          // Imagen Flotante del Pokémon
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'pokemon-img-${widget.pokemon.id}',
                child: Image.network(
                  widget.pokemon.imageUrl,
                  height: 180,
                  width: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 80, color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required String name,
    required int value,
    required Color color,
  }) {
    final percentage = (value / 255.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              name,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  value > 80 ? Colors.greenAccent : (value > 50 ? color : Colors.orangeAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatName(String raw) {
    switch (raw) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Ataque';
      case 'defense':
        return 'Defensa';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Velocidad';
      default:
        return raw;
    }
  }
}

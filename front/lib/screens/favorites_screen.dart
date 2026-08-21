import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/backend_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pokemon_card.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onFavoritesChanged;

  const FavoritesScreen({super.key, this.onFavoritesChanged});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<PokemonModel> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await BackendApiService.consultarPokemon();
      setState(() {
        _favorites = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los favoritos desde el servidor.';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(PokemonModel pokemon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Eliminar de Favoritos', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${pokemon.capitalizedName} de tus favoritos?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await BackendApiService.eliminarPokemon(pokemon.id);
      if (success) {
        setState(() {
          _favorites.removeWhere((p) => p.id == pokemon.id);
        });
        widget.onFavoritesChanged?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pokemon.capitalizedName} eliminado de favoritos'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar de favoritos'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: AppTheme.primaryRed,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Favoritos ❤️',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Guardados en PostgreSQL',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.5)),
                      ),
                      child: Text(
                        '${_favorites.length} Pokémon',
                        style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryRed),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadFavorites,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_favorites.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cardBg,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 60,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Aún no tienes favoritos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explora la PokéAPI y toca el corazón para guardar Pokémon en tu base de datos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final pokemon = _favorites[index];
                      return PokemonCard(
                        pokemon: pokemon,
                        onFavoriteToggle: () => _removeFavorite(pokemon),
                      );
                    },
                    childCount: _favorites.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

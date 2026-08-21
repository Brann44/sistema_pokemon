import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/poke_api_service.dart';
import '../services/backend_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pokemon_card.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  List<PokemonModel> _allPokemons = [];
  List<PokemonModel> _filteredPokemons = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedType = 'Todos';

  final List<String> _types = [
    'Todos',
    'grass',
    'fire',
    'water',
    'electric',
    'poison',
    'bug',
    'normal',
    'flying',
    'psychic',
    'rock',
    'ground',
    'ghost',
    'dragon',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Cargar favoritos desde PostgreSQL para marcar los estados
      await _syncFavoritesFromBackend();

      // 2. Cargar Pokémon desde PokeAPI
      final pokemons = await PokeApiService.getPokemons(limit: 100);

      // 3. Cruzar estados de favoritos
      for (final p in pokemons) {
        p.isFavorite = _favoriteIds.contains(p.id);
      }

      setState(() {
        _allPokemons = pokemons;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _syncFavoritesFromBackend() async {
    try {
      final favorites = await BackendApiService.consultarPokemon();
      setState(() {
        _favoriteIds = favorites.map((f) => f.id).toSet();
        for (final p in _allPokemons) {
          p.isFavorite = _favoriteIds.contains(p.id);
        }
      });
    } catch (_) {}
  }

  void _applyFilters() {
    setState(() {
      _filteredPokemons = _allPokemons.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.id.toString() == _searchQuery.trim();
        final matchesType = _selectedType == 'Todos' ||
            p.types.any((t) => t.toLowerCase() == _selectedType.toLowerCase());
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  Future<void> _toggleFavorite(PokemonModel pokemon) async {
    final willBeFavorite = !pokemon.isFavorite;

    // Optimistic UI update
    setState(() {
      pokemon.isFavorite = willBeFavorite;
      if (willBeFavorite) {
        _favoriteIds.add(pokemon.id);
      } else {
        _favoriteIds.remove(pokemon.id);
      }
    });

    if (willBeFavorite) {
      final success = await BackendApiService.guardarPokemon(pokemon);
      if (!success) {
        // Revertir si falló
        setState(() {
          pokemon.isFavorite = false;
          _favoriteIds.remove(pokemon.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo guardar en el servidor PostgreSQL'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡${pokemon.capitalizedName} agregado a favoritos! ❤️'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      final success = await BackendApiService.eliminarPokemon(pokemon.id);
      if (!success) {
        // Revertir si falló
        setState(() {
          pokemon.isFavorite = true;
          _favoriteIds.add(pokemon.id);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pokemon.capitalizedName} eliminado de favoritos'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
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
      body: _currentTabIndex == 0 ? _buildPokedexTab() : FavoritesScreen(onFavoritesChanged: _syncFavoritesFromBackend),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() => _currentTabIndex = index);
            if (index == 0) {
              _syncFavoritesFromBackend();
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: AppTheme.textSecondary,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.catching_pokemon),
              label: 'Pokédex',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('${_favoriteIds.length}'),
                isLabelVisible: _favoriteIds.isNotEmpty,
                child: const Icon(Icons.favorite),
              ),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokedexTab() {
    return CustomScrollView(
      slivers: [
        // App Bar con Título y Pokébola decorativa
        SliverAppBar(
          floating: true,
          pinned: false,
          backgroundColor: AppTheme.darkBg,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.catching_pokemon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pokédex',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Barra de Búsqueda
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon por nombre o ID...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),

        // Filtro por Categorías / Tipos
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected = _selectedType.toLowerCase() == type.toLowerCase();
                final typeColor = type == 'Todos' ? AppTheme.primaryRed : AppTheme.getTypeColor(type);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: typeColor,
                    backgroundColor: AppTheme.cardBg,
                    side: BorderSide(
                      color: isSelected ? typeColor : Colors.white10,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // Contenido Principal (Grid de Pokémon)
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryRed),
                  SizedBox(height: 16),
                  Text('Cargando Pokédex...', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          )
        else if (_errorMessage != null)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Error: $_errorMessage', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (_filteredPokemons.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'No se encontraron Pokémon con ese criterio',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pokemon = _filteredPokemons[index];
                  return PokemonCard(
                    pokemon: pokemon,
                    onFavoriteToggle: () => _toggleFavorite(pokemon),
                  );
                },
                childCount: _filteredPokemons.length,
              ),
            ),
          ),
      ],
    );
  }
}

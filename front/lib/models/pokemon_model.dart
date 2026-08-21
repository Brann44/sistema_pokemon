class PokemonModel {
  final int id;
  final String name;
  final double height;
  final double weight;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  bool isFavorite;

  PokemonModel({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
    required this.abilities,
    required this.stats,
    this.isFavorite = false,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  String get capitalizedName =>
      name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : '';

  String get mainType => types.isNotEmpty ? types.first : 'normal';

  // Factory para crear desde la respuesta oficial de PokeAPI (/pokemon/{id})
  factory PokemonModel.fromPokeApi(Map<String, dynamic> json) {
    final typesList = (json['types'] as List? ?? [])
        .map((t) => t['type']['name'].toString())
        .toList();

    final abilitiesList = (json['abilities'] as List? ?? [])
        .map((a) => a['ability']['name'].toString())
        .toList();

    final statsMap = <String, int>{};
    for (final s in (json['stats'] as List? ?? [])) {
      final statName = s['stat']['name'] as String;
      final baseStat = s['base_stat'] as int;
      statsMap[statName] = baseStat;
    }

    // Imagen oficial de alta calidad (artwork)
    final otherSprites = json['sprites']?['other'];
    final officialArtwork =
        otherSprites?['official-artwork']?['front_default'];
    final defaultSprite = json['sprites']?['front_default'];
    final fallbackUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${json['id']}.png';

    final finalImageUrl =
        officialArtwork ?? defaultSprite ?? fallbackUrl;

    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      height: ((json['height'] as num?)?.toDouble() ?? 0) / 10.0, // decímetros a metros
      weight: ((json['weight'] as num?)?.toDouble() ?? 0) / 10.0, // hectogramos a kg
      imageUrl: finalImageUrl.toString(),
      types: typesList,
      abilities: abilitiesList,
      stats: statsMap,
      isFavorite: false,
    );
  }

  // Factory para crear desde la respuesta de nuestro Backend Laravel (/api/consultar_pokemon)
  factory PokemonModel.fromBackendJson(Map<String, dynamic> json) {
    final habilidadesList = (json['habilidades'] as List? ?? [])
        .map((h) => h.toString())
        .toList();

    final categoria = json['categoria']?.toString() ?? 'normal';

    return PokemonModel(
      id: json['poke_id'] is int ? json['poke_id'] : int.parse(json['poke_id'].toString()),
      name: json['nombre']?.toString() ?? '',
      height: (json['altura'] as num?)?.toDouble() ?? 0,
      weight: (json['peso'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imagen_url']?.toString() ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${json['poke_id']}.png',
      types: [categoria],
      abilities: habilidadesList,
      stats: {},
      isFavorite: true,
    );
  }

  // Convertir a JSON para enviar a nuestro endpoint POST /api/guardar_pokemon
  Map<String, dynamic> toBackendJson() {
    return {
      'poke_id': id,
      'nombre': name,
      'categoria': mainType,
      'altura': height,
      'peso': weight,
      'imagen_url': imageUrl,
      'habilidades': abilities,
    };
  }
}

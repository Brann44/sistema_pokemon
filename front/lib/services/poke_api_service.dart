import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// Obtiene la lista de Pokémon con su información detallada.
  /// [limit] cantidad de Pokémon a consultar (por defecto los primeros 150).
  /// [offset] desplazamiento para paginación.
  static Future<List<PokemonModel>> getPokemons({int limit = 100, int offset = 0}) async {
    try {
      final url = Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Error al conectar con PokéAPI: Código ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List results = data['results'] as List;

      // Obtener detalles completos de cada Pokémon en paralelo
      final futures = results.map((item) async {
        try {
          final detailResponse = await http.get(Uri.parse(item['url']));
          if (detailResponse.statusCode == 200) {
            final detailJson = json.decode(detailResponse.body);
            return PokemonModel.fromPokeApi(detailJson);
          }
        } catch (_) {}
        return null;
      }).toList();

      final pokemons = await Future.wait(futures);
      return pokemons.whereType<PokemonModel>().toList();
    } catch (e) {
      throw Exception('Fallo al obtener Pokémon de PokéAPI: $e');
    }
  }

  /// Obtiene un Pokémon específico por su ID o Nombre
  static Future<PokemonModel> getPokemonDetail(dynamic idOrName) async {
    try {
      final url = Uri.parse('$_baseUrl/pokemon/$idOrName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final detailJson = json.decode(response.body);
        return PokemonModel.fromPokeApi(detailJson);
      } else {
        throw Exception('Pokémon no encontrado');
      }
    } catch (e) {
      throw Exception('Error al obtener detalle del Pokémon: $e');
    }
  }
}

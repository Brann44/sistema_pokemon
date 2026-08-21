import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class BackendApiService {
  // Configuración de la URL base según la plataforma
  static String get baseUrl {
    // Si corre en Android emulador, localhost es 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    // Web, Windows Desktop, Linux, macOS o dispositivo con red local
    return 'http://localhost:8000/api';
  }

  /// 1. POST api/guardar_pokemon
  /// Guarda el Pokémon en la base de datos PostgreSQL y lo agrega a favoritos
  static Future<bool> guardarPokemon(PokemonModel pokemon) async {
    try {
      final url = Uri.parse('$baseUrl/guardar_pokemon');
      final bodyData = json.encode(pokemon.toBackendJson());

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: bodyData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Error al guardar: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Excepción al conectar con el backend: $e');
      return false;
    }
  }

  /// 2. GET api/consultar_pokemon
  /// Obtiene todos los Pokémon guardados en favoritos desde PostgreSQL
  static Future<List<PokemonModel>> consultarPokemon() async {
    try {
      final url = Uri.parse('$baseUrl/consultar_pokemon');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final List list = data['data'];
          return list.map((item) => PokemonModel.fromBackendJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Excepción al consultar favoritos: $e');
      return [];
    }
  }

  /// 3. DELETE api/eliminar_pokemon/{id}
  /// Elimina un Pokémon de la lista de favoritos en PostgreSQL
  static Future<bool> eliminarPokemon(int pokeId) async {
    try {
      final url = Uri.parse('$baseUrl/eliminar_pokemon/$pokeId');
      final response = await http.delete(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Error al eliminar: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Excepción al eliminar favorito: $e');
      return false;
    }
  }
}

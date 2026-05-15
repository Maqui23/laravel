import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  
  // --- CARGA MASIVA EN PARALELO (Para el scroll infinito) ---
  Future<List<Pokemon>> getPokemonList({int limit = 40, int offset = 0}) async {
    final response = await http.get(
      Uri.parse("https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset")
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      
      // Preparamos todas las peticiones al mismo tiempo
      List<Future<http.Response>> peticiones = results.map<Future<http.Response>>((p) {
        return http.get(Uri.parse(p['url']));
      }).toList();

      // Disparamos en paralelo y esperamos resultados
      List<http.Response> respuestas = await Future.wait(peticiones);

      List<Pokemon> pokemonCompletos = [];
      for (var detalleRes in respuestas) {
        if (detalleRes.statusCode == 200) {
          pokemonCompletos.add(Pokemon.fromJson(jsonDecode(detalleRes.body)));
        }
      }
      
      return pokemonCompletos;
    } else {
      throw Exception('Error al conectar con la PokéAPI');
    }
  }

  // --- BÚSQUEDA REMOTA (Encontrar un Pokémon por nombre o ID) ---
  Future<Pokemon?> buscarPokemonPorNombre(String nombre) async {
    try {
      String nombreBuscado = nombre.toLowerCase().trim();
      final response = await http.get(Uri.parse("https://pokeapi.co/api/v2/pokemon/$nombreBuscado"));

      if (response.statusCode == 200) {
        return Pokemon.fromJson(jsonDecode(response.body));
      }
      return null; 
    } catch (e) {
      return null;
    }
  }

  // --- BUSCAR VARIANTES (Megas, Regionales, Gigantamax) ---
  // Esta función busca las "variedades" de una especie Pokémon
  Future<List<Pokemon>> getVariantes(int id) async {
    try {
      // Primero consultamos la especie para ver qué variedades tiene
      final response = await http.get(Uri.parse("https://pokeapi.co/api/v2/pokemon-species/$id"));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> variedades = data['varieties'];
        
        // Filtramos para no repetir el Pokémon base que ya estamos viendo
        var soloVariantes = variedades.where((v) => v['is_default'] == false).toList();
        
        if (soloVariantes.isEmpty) return [];

        // Pedimos los datos detallados de cada variante en paralelo
        List<Future<http.Response>> peticiones = soloVariantes.map((v) {
          return http.get(Uri.parse(v['pokemon']['url']));
        }).toList();

        List<http.Response> respuestas = await Future.wait(peticiones);

        return respuestas
            .where((r) => r.statusCode == 200)
            .map((r) => Pokemon.fromJson(jsonDecode(r.body)))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error al obtener variantes: $e");
      return [];
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/pokemon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      home: const PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => PokemonPageState();
}

class PokemonPageState extends State<PokemonPage> {
  List<Pokemon> pokemones = [];
  List<Pokemon> pokemonesFiltrados = [];
  bool estaCargando = true;

  @override
  void initState() {
    super.initState();
    obtenerPokemones();
  }

  Future<void> obtenerPokemones() async {
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1025');
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        final resultados = data['results'] as List;

        setState(() {
          pokemones = resultados
              .map((pokemon) => Pokemon.fromJson(pokemon))
              .toList();
          pokemonesFiltrados = pokemones;
          estaCargando = false;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filtrarBusqueda(String texto) {
    setState(() {
      pokemonesFiltrados = pokemones
          .where((pokemon) =>
              pokemon.name.toLowerCase().contains(texto.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pokémon'),
        backgroundColor: Colors.redAccent,
      ),
      body: estaCargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    onChanged: filtrarBusqueda,
                    decoration: InputDecoration(
                      labelText: 'Buscar Pokémon',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: pokemonesFiltrados.length,
                    itemBuilder: (context, index) {
                      final pokemon = pokemonesFiltrados[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            pokemon.imageUrl,
                            width: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.help_outline),
                          ),
                          title: Text(pokemon.name.toUpperCase()),
                          subtitle: Text('ID: ${pokemon.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
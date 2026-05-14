import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
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
  String mensajeError = '';

  // Instancia del reproductor de audio
  final AudioPlayer _reproductorAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    obtenerPokemones();
  }

  // Liberar recursos de audio cuando se cierre la pantalla
  @override
  void dispose() {
    _reproductorAudio.dispose();
    super.dispose();
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
      } else {
        setState(() {
          mensajeError = 'Error de servidor. Código: ${respuesta.statusCode}';
          estaCargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = 'Error de conexión.\nDetalle: $e';
        estaCargando = false;
      });
    }
  }

  void filtrarBusqueda(String texto) {
    setState(() {
      if (texto.isEmpty) {
        pokemonesFiltrados = pokemones;
      } else {
        pokemonesFiltrados = pokemones
            .where((pokemon) =>
                pokemon.name.toLowerCase().contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex Interactiva'),
        backgroundColor: Colors.redAccent,
      ),
      body: estaCargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : mensajeError.isNotEmpty
              ? Center(
                  child: Text(
                    mensajeError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // Barra de búsqueda
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        onChanged: filtrarBusqueda,
                        decoration: InputDecoration(
                          labelText: 'Buscar Pokémon',
                          hintText: 'Ej. Pikachu, Charizard...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                    // Lista de Pokémon
                    Expanded(
                      child: pokemonesFiltrados.isEmpty
                          ? const Center(
                              child: Text('No se encontró ningún Pokémon.'),
                            )
                          : ListView.builder(
                              itemCount: pokemonesFiltrados.length,
                              itemBuilder: (context, index) {
                                final pokemon = pokemonesFiltrados[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    // Reproducir audio al tocar
                                    onTap: () async {
                                      try {
                                        await _reproductorAudio.play(
                                            UrlSource(pokemon.soundUrl));
                                      } catch (e) {
                                        // Si el audio falla (por ej. un Pokémon muy nuevo que no tiene sonido aún)
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al reproducir el sonido de ${pokemon.name}'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    leading: Image.network(
                                      pokemon.imageUrl,
                                      width: 60,
                                      height: 60,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 60),
                                    ),
                                    title: Text(
                                      pokemon.name.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('ID: ${pokemon.id}'),
                                    trailing: const Icon(Icons.volume_up, color: Colors.blueGrey),
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
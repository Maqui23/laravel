import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const PokedexApp());

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laravel Pokedex',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: const PokemonListScreen(),
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List pokemons = [];
  bool cargando = true;
  String mensajeError = '';

  @override
  void initState() {
    super.initState();
    obtenerPokemons();
  }

  Future<void> obtenerPokemons() async {
    // Usamos tu IP de PC para la conexión vía Wi-Fi
    final url = Uri.parse('http://10.55.29.30/api/pokemons');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        setState(() {
          pokemons = json.decode(response.body);
          cargando = false;
        });
      } else {
        setState(() {
          mensajeError = "Error del servidor: ${response.statusCode}";
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = "No se pudo conectar con Laravel. Revisa la IP y el Firewall.";
        cargando = false;
      });
      print("Error: $e");
    }
  }

  // Función para darle color a las etiquetas de tipo
  Color obtenerColorTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'fuego': return Colors.orange;
      case 'agua': return Colors.blue;
      case 'planta': return Colors.green;
      case 'eléctrico': return Colors.yellow.shade700;
      case 'veneno': return Colors.purple;
      case 'hielo': return Colors.cyan;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex Nacional (Laravel + Flutter)', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: cargando 
        ? const Center(child: CircularProgressIndicator())
        : mensajeError.isNotEmpty
          ? Center(child: Text(mensajeError))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final poke = pokemons[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "#${poke['pokedex_number']}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      Expanded(
                        child: Image.network(
                          poke['imagen_url'],
                          fit: BoxFit.contain,
                          // Si la imagen falla, muestra una pokebola o icono
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.catching_pokemon, size: 50, color: Colors.grey),
                        ),
                      ),
                      Text(
                        poke['nombre'].toString().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: obtenerColorTipo(poke['tipo_1']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          poke['tipo_1'],
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
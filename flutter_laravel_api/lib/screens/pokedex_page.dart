import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import 'pokemon_detail_page.dart';

class PokedexPage extends StatefulWidget {
  @override
  _PokedexPageState createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  final PokemonService pokemonService = PokemonService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Pokemon> pokemonList = [];
  List<Pokemon> filteredPokemonList = [];
  
  bool isLoading = false;
  int offset = 0;
  final int limit = 40; // Ajustado a 40 para un scroll más fluido
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _cargarMasPokemon();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoading) {
        if (searchQuery.isEmpty) {
          _cargarMasPokemon();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarMasPokemon() async {
    if (offset >= 1025) return;

    setState(() => isLoading = true);
    try {
      final nuevosPokemon = await pokemonService.getPokemonList(limit: limit, offset: offset);
      setState(() {
        pokemonList.addAll(nuevosPokemon);
        _filtrarPokemonLocales(searchQuery);
        offset += limit;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  // --- FILTRO LOCAL (Mientras escribes) ---
  void _filtrarPokemonLocales(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredPokemonList = List.from(pokemonList);
      } else {
        filteredPokemonList = pokemonList.where((pokemon) {
          return pokemon.nombre.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // --- BÚSQUEDA REMOTA (Al presionar Lupa o Enter) ---
  Future<void> _buscarEnLaAPI(String query) async {
    if (query.isEmpty) return;
    
    setState(() => isLoading = true);
    FocusScope.of(context).unfocus(); 

    final pokemonEncontrado = await pokemonService.buscarPokemonPorNombre(query);
    
    setState(() {
      if (pokemonEncontrado != null) {
        filteredPokemonList = [pokemonEncontrado];
      } else {
        filteredPokemonList = [];
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Pokédex: ${pokemonList.length} / 1025'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA PROFESIONAL ---
          Container(
            color: Colors.redAccent,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarPokemonLocales,
              onSubmitted: _buscarEnLaAPI,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Nombre o número (Enter para buscar)',
                // Botón de lupa a la izquierda para búsqueda remota
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.redAccent),
                  onPressed: () => _buscarEnLaAPI(_searchController.text),
                ),
                // Botón de X a la derecha para limpiar
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filtrarPokemonLocales('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredPokemonList.isEmpty && isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : filteredPokemonList.isEmpty && !isLoading
                    ? const Center(
                        child: Text("No se encontró ningún Pokémon", 
                        style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredPokemonList.length,
                        itemBuilder: (context, index) {
                          return _buildPokemonCard(filteredPokemonList[index]);
                        },
                      ),
          ),
          // Solo muestra el cargador de abajo si estamos haciendo scroll normal
          if (isLoading && searchQuery.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.red),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DISEÑO DE LA TARJETA CON NAVEGACIÓN
  // ---------------------------------------------------------
  Widget _buildPokemonCard(Pokemon pokemon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PokemonDetailPage(pokemon: pokemon)),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("#${pokemon.id.toString().padLeft(3, '0')}", 
                 style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            Expanded(
              child: Image.network(
                pokemon.imagenUrl, 
                fit: BoxFit.contain,
                // Placeholder por si la imagen tarda en cargar
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            Text(pokemon.nombre.toUpperCase(), 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pokemon.tipos.map((tipo) => _buildTipoBadge(tipo)).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _traducirTipo(String tipoEn) {
    const traducciones = {
      'normal': 'Normal', 'fire': 'Fuego', 'water': 'Agua', 'grass': 'Planta',
      'electric': 'Eléctrico', 'ice': 'Hielo', 'fighting': 'Lucha', 'poison': 'Veneno',
      'ground': 'Tierra', 'flying': 'Volador', 'psychic': 'Psíquico', 'bug': 'Bicho',
      'rock': 'Roca', 'ghost': 'Fantasma', 'dragon': 'Dragón', 'dark': 'Siniestro',
      'steel': 'Acero', 'fairy': 'Hada',
    };
    return traducciones[tipoEn] ?? tipoEn; 
  }

  Widget _buildTipoBadge(String tipo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getColorTipo(tipo),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _traducirTipo(tipo), 
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'fire': return Colors.orange; case 'water': return Colors.blue;
      case 'grass': return Colors.green; case 'poison': return Colors.purple;
      case 'electric': return Colors.yellow[700]!; case 'bug': return Colors.lightGreen;
      case 'normal': return Colors.grey; case 'flying': return Colors.lightBlueAccent;
      case 'ground': return Colors.brown[300]!; case 'fighting': return Colors.red[900]!;
      case 'psychic': return Colors.pink; case 'rock': return Colors.brown;
      case 'ghost': return Colors.deepPurple; case 'ice': return Colors.cyanAccent;
      case 'dragon': return Colors.indigo; case 'dark': return Colors.black87;
      case 'steel': return Colors.blueGrey; case 'fairy': return Colors.pinkAccent;
      default: return Colors.grey;
    }
  }
}
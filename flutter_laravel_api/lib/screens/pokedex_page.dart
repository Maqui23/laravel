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
  final int limit = 40; 
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
      debugPrint("Error: $e");
    }
  }

  // --- FILTRO LOCAL ---
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

  // --- BÚSQUEDA REMOTA ---
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
      backgroundColor: const Color(0xFFF0F2F5), // Fondo gris moderno
      appBar: AppBar(
        title: Text('Pokédex (${pokemonList.length}/1025)', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        backgroundColor: const Color(0xFFE53935), // Rojo vibrante Pokémon
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- CABECERA CURVA CON BUSCADOR PREMIUM ---
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filtrarPokemonLocales,
                onSubmitted: _buscarEnLaAPI,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Buscar nombre o número...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search_rounded, color: Color(0xFFE53935)),
                    onPressed: () => _buscarEnLaAPI(_searchController.text),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarPokemonLocales('');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // --- CONTENIDO PRINCIPAL ---
          Expanded(
            child: filteredPokemonList.isEmpty && isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
                : filteredPokemonList.isEmpty && !isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.catching_pokemon, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text("No se encontró ningún Pokémon", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // Ajustado para dar más espacio vertical
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredPokemonList.length,
                        itemBuilder: (context, index) {
                          return _buildPokemonCard(filteredPokemonList[index]);
                        },
                      ),
          ),
          
          // Cargador inferior para el scroll infinito
          if (isLoading && searchQuery.isEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.transparent,
              child: const CircularProgressIndicator(color: Color(0xFFE53935)),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // TARJETA PREMIUM DINÁMICA
  // ---------------------------------------------------------
  Widget _buildPokemonCard(Pokemon pokemon) {
    // Extraemos el color principal basado en el primer tipo del Pokémon
    final Color mainColor = pokemon.tipos.isNotEmpty ? _getColorTipo(pokemon.tipos.first) : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.2), // Sombra dinámica según el tipo
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PokemonDetailPage(pokemon: pokemon)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Etiqueta del ID
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "#${pokemon.id.toString().padLeft(3, '0')}", 
                    style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                ),
                
                // Imagen con fondo circular dinámico
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: mainColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Image.network(
                        pokemon.imagenUrl, 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.catching_pokemon, size: 50, color: Colors.grey.shade300),
                      ),
                    ],
                  ),
                ),
                
                // Nombre
                const SizedBox(height: 8),
                Text(
                  pokemon.nombre.toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF2C3E50)),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Tipos (Píldoras)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: pokemon.tipos.map((tipo) => _buildTipoBadge(tipo)).toList(),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorTipo(tipo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _traducirTipo(tipo).toUpperCase(), 
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)
      ),
    );
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'fire': return const Color(0xFFF42D2D); 
      case 'water': return const Color(0xFF3B9BF1);
      case 'grass': return const Color(0xFF48D0B0); 
      case 'poison': return const Color(0xFF9F5BBA);
      case 'electric': return const Color(0xFFFAC000); 
      case 'bug': return const Color(0xFF98D142);
      case 'normal': return const Color(0xFFA0A29F); 
      case 'flying': return const Color(0xFF79A4FF);
      case 'ground': return const Color(0xFFE19854); 
      case 'fighting': return const Color(0xFFD6425E);
      case 'psychic': return const Color(0xFFF85888); 
      case 'rock': return const Color(0xFFCEC18C);
      case 'ghost': return const Color(0xFF6970C5); 
      case 'ice': return const Color(0xFF61CEC0);
      case 'dragon': return const Color(0xFF0773C7); 
      case 'dark': return const Color(0xFF595761);
      case 'steel': return const Color(0xFF5596A4); 
      case 'fairy': return const Color(0xFFEA1369);
      default: return Colors.grey;
    }
  }
}
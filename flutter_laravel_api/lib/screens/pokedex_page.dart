import 'dart:ui'; // Necesario para el efecto Glassmorphism
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
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027), // Fondo oscuro base
      appBar: AppBar(
        title: Text(
          'POKEDEX NACIONAL (${pokemonList.length}/1025)',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white, fontSize: 18)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFF5252)), // Acento rojo Pokédex
      ),
      body: Stack(
        children: [
          // --- FONDO TECNOLÓGICO Y CÍRCULOS DE NEÓN ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          // Círculo rojo difuso (Pokédex vibe)
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE53935).withOpacity(0.15)),
            ),
          ),
          // Círculo azul difuso
          Positioned(
            bottom: 100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00BCD4).withOpacity(0.1)),
            ),
          ),

          // --- CONTENIDO PRINCIPAL ---
          SafeArea(
            child: Column(
              children: [
                // --- BUSCADOR GLASSMORPHISM ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filtrarPokemonLocales,
                          onSubmitted: _buscarEnLaAPI,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o ID (Ej: Pikachu o 25)',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.radar_rounded, color: Color(0xFFFF5252)),
                              onPressed: () => _buscarEnLaAPI(_searchController.text),
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.cancel_rounded, color: Colors.white54),
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
                  ),
                ),

                // --- GRILLA DE RESULTADOS ---
                Expanded(
                  child: filteredPokemonList.isEmpty && isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)))
                      : filteredPokemonList.isEmpty && !isLoading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.troubleshoot_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  const Text("Entidad no encontrada en la DB", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : GridView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
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
                    child: const CircularProgressIndicator(color: Color(0xFFFF5252)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // TARJETA DE CRISTAL CON RESPLANDOR HOLOGRÁFICO
  // ---------------------------------------------------------
  Widget _buildPokemonCard(Pokemon pokemon) {
    final Color mainColor = pokemon.tipos.isNotEmpty ? _getColorTipo(pokemon.tipos.first) : Colors.cyanAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: mainColor.withOpacity(0.4), width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
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
                        "ID: ${pokemon.id.toString().padLeft(3, '0')}",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)
                      ),
                    ),

                    // Imagen con resplandor (Glow effect)
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base brillante
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withOpacity(0.5),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          Image.network(
                            pokemon.imagenUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.catching_pokemon, size: 50, color: Colors.white.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),

                    // Nombre
                    const SizedBox(height: 12),
                    Text(
                      pokemon.nombre.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 1),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Tipos (Píldoras neón)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: pokemon.tipos.map((tipo) => _buildTipoBadge(tipo)).toList(),
                    ),
                  ],
                ),
              ),
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
    final colorTipo = _getColorTipo(tipo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorTipo.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorTipo.withOpacity(0.6)),
      ),
      child: Text(
        _traducirTipo(tipo).toUpperCase(),
        style: TextStyle(color: colorTipo, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)
      ),
    );
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'fire': return const Color(0xFFFF5252);
      case 'water': return const Color(0xFF40C4FF);
      case 'grass': return const Color(0xFF69F0AE);
      case 'poison': return const Color(0xFFE040FB);
      case 'electric': return const Color(0xFFFFE57F);
      case 'bug': return const Color(0xFFB2FF59);
      case 'normal': return const Color(0xFFB0BEC5);
      case 'flying': return const Color(0xFF8C9EFF);
      case 'ground': return const Color(0xFFFFAB40);
      case 'fighting': return const Color(0xFFFF5252);
      case 'psychic': return const Color(0xFFFF4081);
      case 'rock': return const Color(0xFFD7CCC8);
      case 'ghost': return const Color(0xFF7C4DFF);
      case 'ice': return const Color(0xFF84FFFF);
      case 'dragon': return const Color(0xFF448AFF);
      case 'dark': return const Color(0xFF607D8B);
      case 'steel': return const Color(0xFF90A4AE);
      case 'fairy': return const Color(0xFFFF80AB);
      default: return Colors.cyanAccent;
    }
  }
}

import 'dart:ui'; // Requerido para el Glassmorphism
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonDetailPage extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Pokemon currentPokemon;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    currentPokemon = widget.pokemon;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPokemonCry() async {
    try {
      String urlSonido = 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/${currentPokemon.id}.ogg';
      await _audioPlayer.play(UrlSource(urlSonido));
    } catch (e) {
      debugPrint('Error al reproducir la frecuencia de audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el color neón principal basado en el tipo
    final Color mainColor = currentPokemon.tipos.isNotEmpty ? _getColorTipo(currentPokemon.tipos.first) : Colors.cyanAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Fondo oscuro base
      body: Stack(
        children: [
          // --- FONDO TECNOLÓGICO Y NEÓN DINÁMICO ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor.withOpacity(0.15)),
            ),
          ),
          Positioned(
            bottom: 50, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent.withOpacity(0.05)),
            ),
          ),

          // --- CONTENIDO SCROLL ---
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: Colors.transparent, // Barra transparente para efecto cristal
                elevation: 0,
                expandedHeight: 300,
                floating: false,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      // NÚCLEO HOLOGRÁFICO (GLOW)
                      Positioned(
                        top: 80,
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 60, spreadRadius: 20),
                            ],
                          ),
                        ),
                      ),

                      // Círculos de "Escaneo"
                      Positioned(
                        top: 80,
                        child: Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: mainColor.withOpacity(0.3), width: 2),
                          ),
                        ),
                      ),

                      // IMAGEN DEL POKÉMON
                      Positioned(
                        top: 90,
                        child: Hero(
                          tag: currentPokemon.id, // ¡Misma etiqueta que en el Pokedex Explorer!
                          child: currentPokemon.animacionUrl.isNotEmpty
                              ? Image.network(currentPokemon.animacionUrl, height: 180, fit: BoxFit.contain)
                              : Image.network(currentPokemon.imagenUrl, height: 180, fit: BoxFit.contain),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: Container(
              color: Colors.transparent,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CABECERA DE INFORMACIÓN ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NÚMERO: #${currentPokemon.id.toString().padLeft(3, '0')}",
                                style: TextStyle(fontSize: 14, color: mainColor, fontWeight: FontWeight.bold, letterSpacing: 2)
                              ),
                              const SizedBox(height: 5),
                              Text(
                                currentPokemon.nombre.toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // BOTÓN DE AUDIO NEÓN
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: mainColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: mainColor.withOpacity(0.5)),
                              ),
                              child: IconButton(
                                onPressed: _playPokemonCry,
                                icon: Icon(Icons.graphic_eq_rounded, color: mainColor),
                                iconSize: 28,
                                tooltip: 'Analizar Frecuencia',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- TIPOS (Píldoras de sistema) ---
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: currentPokemon.tipos.map((t) => _buildTipoIcono(t)).toList(),
                    ),

                    const SizedBox(height: 30),

                    // --- TARJETA DE DATOS FÍSICOS ---
                    _buildPhysicalInfo(),
                    const SizedBox(height: 25),

                    // --- ESTADÍSTICAS DEL SISTEMA ---
                    _buildSectionCard(
                      title: "Características Base",
                      titleColor: mainColor,
                      child: _buildStatsSection(),
                    ),
                    const SizedBox(height: 20),

                    // --- HABILIDADES DE COMBATE ---
                    _buildSectionCard(
                      title: "Habilidades",
                      child: _buildHabilidadesSection(),
                    ),
                    const SizedBox(height: 20),

                    // --- OTRAS FORMAS (VARIANTES) ---
                    _buildSeccionVariantes(),
                    const SizedBox(height: 20),

                    // --- FORMA VARIOCOLOR (HOLOGRÁFICA) ---
                    _buildSectionCard(
                      title: "Forma Variocolor (Shiny)",
                      titleColor: Colors.amberAccent,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.amberAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                                  ]
                                ),
                              ),
                              Image.network(
                                currentPokemon.animacionShinyUrl,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.hide_image_rounded, size: 50, color: Colors.white.withOpacity(0.2)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTENEDOR GLASSMORPHISM PARA SECCIONES ---
  Widget _buildSectionCard({required String title, required Widget child, Color? titleColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: titleColor ?? Colors.white, letterSpacing: 1.5)
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  // --- ICONOS DE TIPOS NEÓN ---
  Widget _buildTipoIcono(String tipoEn) {
    Color colorTipo = _getColorTipo(tipoEn);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorTipo.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorTipo.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: colorTipo.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: colorTipo.withOpacity(0.3), shape: BoxShape.circle),
            child: _getTipoSymbol(tipoEn, colorTipo),
          ),
          const SizedBox(width: 8),
          Text(
            _traducirTipo(tipoEn),
            style: TextStyle(color: colorTipo, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)
          ),
        ],
      ),
    );
  }

  Widget _getTipoSymbol(String t, Color color) {
    IconData icon;
    switch (t) {
      case 'normal': icon = Icons.circle_outlined; break;
      case 'fighting': icon = Icons.front_hand; break;
      case 'flying': icon = Icons.air; break;
      case 'poison': icon = Icons.science; break;
      case 'ground': icon = Icons.landscape; break;
      case 'rock': icon = Icons.terrain; break;
      case 'bug': icon = Icons.bug_report; break;
      case 'ghost': icon = Icons.auto_fix_high; break;
      case 'steel': icon = Icons.settings_suggest; break;
      case 'fire': icon = Icons.local_fire_department_rounded; break;
      case 'water': icon = Icons.water_drop; break;
      case 'grass': icon = Icons.eco; break;
      case 'electric': icon = Icons.bolt; break;
      case 'psychic': icon = Icons.psychology; break;
      case 'ice': icon = Icons.ac_unit; break;
      case 'dragon': icon = Icons.local_fire_department; break;
      case 'dark': icon = Icons.nightlight_round; break;
      case 'fairy': icon = Icons.auto_awesome; break;
      default: icon = Icons.adjust_rounded;
    }
    return Icon(icon, color: color, size: 16);
  }

  // --- INFO FÍSICA (CRISTAL) ---
  Widget _buildPhysicalInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoCard("${currentPokemon.peso} kg", "PESO", Icons.monitor_weight_outlined),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
              _infoCard("${currentPokemon.altura} m", "ALTURA", Icons.height_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyanAccent.withOpacity(0.8)),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }

  // --- ESTADÍSTICAS BARRAS DE NEÓN ---
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statBar("PS", currentPokemon.hp, Colors.greenAccent),
        _statBar("Ataque", currentPokemon.ataque, Colors.redAccent),
        _statBar("Defensa", currentPokemon.defensa, Colors.blueAccent),
        _statBar("Ataque Especial", currentPokemon.atkEsp, Colors.purpleAccent),
        _statBar("Defensa Especial", currentPokemon.defEsp, Colors.tealAccent),
        _statBar("Velocidad", currentPokemon.velocidad, Colors.amberAccent),
      ],
    );
  }

  Widget _statBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white.withOpacity(0.7))),
              Text(value.toString(), style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value / 255,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HABILIDADES ---
  Widget _buildHabilidadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...currentPokemon.habilidadesNormales.map((h) => _buildHabItem(h, false)).toList(),
        if (currentPokemon.habilidadOculta != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withOpacity(0.15)),
          ),
          _buildHabItem(currentPokemon.habilidadOculta!, true),
        ]
      ],
    );
  }

  Widget _buildHabItem(String habEn, bool isOculta) {
    Color habColor = isOculta ? Colors.purpleAccent : Colors.cyanAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: habColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: habColor.withOpacity(0.5))
            ),
            child: Icon(isOculta ? Icons.memory_rounded : Icons.bolt_rounded, color: habColor, size: 18),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _traducirHabilidad(habEn),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              if (isOculta)
                Text("HABILIDAD OCULTA", style: TextStyle(fontSize: 10, color: Colors.purpleAccent.shade100, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  String _traducirHabilidad(String habEn) {
    const d = {
      'overgrow': 'Espesura', 'blaze': 'Mar Llamas', 'torrent': 'Torrente', 'pressure': 'Presión',
      'levitate': 'Levitación', 'multitype': 'Multitipo', 'telepathy': 'Telepatía', 'static': 'Electricidad Estática',
      'sturdy': 'Robustez', 'inner-focus': 'Foco Interno', 'intimidate': 'Intimidación', 'keen-eye': 'Vista Lince',
      'guts': 'Agallas', 'synchronize': 'Sincronía', 'chlorophyll': 'Clorofila', 'swift-swim': 'Nado Rápido',
      'beast-boost': 'Ultraimpulso', 'full-metal-body': 'Cuerpo Metal Puro', 'prism-armor': 'Armadura Prisma',
      'shadow-shield': 'Guardia Espectro', 'teravolt': 'Terravoltaje', 'turboblaze': 'Turbollama'
    };
    if (d.containsKey(habEn)) return d[habEn]!;
    return habEn.replaceAll('-', ' ').toUpperCase();
  }

  String _traducirTipo(String t) {
    const d = {'fire':'Fuego','water':'Agua','grass':'Planta','electric':'Eléctrico','poison':'Veneno','ice':'Hielo','ground':'Tierra','flying':'Volador','psychic':'Psíquico','bug':'Bicho','rock':'Roca','ghost':'Fantasma','dragon':'Dragón','dark':'Siniestro','steel':'Acero','fairy':'Hada','fighting':'Lucha','normal':'Normal'};
    return d[t] ?? t.toUpperCase();
  }

  // --- VARIANTES HOLOGRÁFICAS ---
  Widget _buildSeccionVariantes() {
    return FutureBuilder<List<Pokemon>>(
      future: PokemonService().getVariantes(widget.pokemon.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 15),
              child: Text("VARIANTES REGISTRADAS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white54, letterSpacing: 1.5)),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                  var v = snapshot.data![i];
                  bool isSelected = currentPokemon.nombre == v.nombre;

                  return GestureDetector(
                    onTap: () => setState(() => currentPokemon = v),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.cyanAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white.withOpacity(0.1), width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                v.imagenUrl,
                                height: 55,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.catching_pokemon, size: 30, color: Colors.white.withOpacity(0.2)),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  v.nombre.split('-').last.toUpperCase(),
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.cyanAccent : Colors.white70, letterSpacing: 1),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getColorTipo(String t) {
    switch(t){
      case 'fire': return const Color(0xFFFF5252);
      case 'water': return const Color(0xFF40C4FF);
      case 'grass': return const Color(0xFF69F0AE);
      case 'electric': return const Color(0xFFFFE57F);
      case 'poison': return const Color(0xFFE040FB);
      case 'dragon': return const Color(0xFF448AFF);
      case 'psychic': return const Color(0xFFFF4081);
      case 'ghost': return const Color(0xFF7C4DFF);
      case 'steel': return const Color(0xFF90A4AE);
      case 'dark': return const Color(0xFF607D8B);
      case 'fairy': return const Color(0xFFFF80AB);
      case 'fighting': return const Color(0xFFFF5252);
      case 'ground': return const Color(0xFFFFAB40);
      case 'ice': return const Color(0xFF84FFFF);
      case 'flying': return const Color(0xFF8C9EFF);
      case 'rock': return const Color(0xFFD7CCC8);
      case 'bug': return const Color(0xFFB2FF59);
      case 'normal': return const Color(0xFFB0BEC5);
      default: return Colors.cyanAccent;
    }
  }
}

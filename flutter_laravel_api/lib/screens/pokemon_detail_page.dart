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
      debugPrint('Error al reproducir el sonido: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el color principal basado en el tipo
    final Color mainColor = currentPokemon.tipos.isNotEmpty ? _getColorTipo(currentPokemon.tipos.first) : Colors.grey;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Fondo gris moderno
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: mainColor,
            elevation: 0,
            expandedHeight: 280,
            floating: false,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [mainColor, mainColor.withOpacity(0.6)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo decorativo de fondo
                    Positioned(
                      bottom: -20,
                      child: Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Hero(
                      tag: currentPokemon.id,
                      child: currentPokemon.animacionUrl.isNotEmpty
                          ? Image.network(currentPokemon.animacionUrl, height: 190, fit: BoxFit.contain)
                          : Image.network(currentPokemon.imagenUrl, height: 190, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F2F5),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABECERA DE INFORMACIÓN (Nombre, ID, Audio) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "#${currentPokemon.id.toString().padLeft(3, '0')}", 
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold)
                          ),
                          Text(
                            currentPokemon.nombre.toUpperCase(), 
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), letterSpacing: 0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // BOTÓN DE AUDIO PREMIUM
                    Container(
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _playPokemonCry,
                        icon: Icon(Icons.volume_up_rounded, color: mainColor),
                        iconSize: 28,
                        tooltip: 'Reproducir sonido',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- TIPOS (Píldoras) ---
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: currentPokemon.tipos.map((t) => _buildTipoIcono(t)).toList(),
                ),
                
                const SizedBox(height: 25),
                _buildPhysicalInfo(),
                const SizedBox(height: 25),

                // --- ESTADÍSTICAS EN TARJETA ---
                _buildSectionCard(
                  title: "Estadísticas Base",
                  child: _buildStatsSection(),
                ),
                const SizedBox(height: 20),

                // --- HABILIDADES EN TARJETA ---
                _buildSectionCard(
                  title: "Habilidades",
                  child: _buildHabilidadesSection(),
                ),
                const SizedBox(height: 20),

                // --- OTRAS FORMAS ---
                _buildSeccionVariantes(),
                const SizedBox(height: 20),
                
                // --- FORMA VARIOCOLOR (SHINY) ---
                _buildSectionCard(
                  title: "Forma Variocolor",
                  titleColor: Colors.amber.shade700,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.network(
                        currentPokemon.animacionShinyUrl, 
                        height: 120,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.catching_pokemon, size: 50, color: Colors.grey.shade300),
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
    );
  }

  // --- CONTENEDOR TARJETA PARA SECCIONES ---
  Widget _buildSectionCard({required String title, required Widget child, Color? titleColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: titleColor ?? const Color(0xFF2C3E50))
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  // --- ICONOS DE TIPOS PREMIUM ---
  Widget _buildTipoIcono(String tipoEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColorTipo(tipoEn),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: _getColorTipo(tipoEn).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
            child: _getTipoSymbol(tipoEn),
          ),
          const SizedBox(width: 8),
          Text(
            _traducirTipo(tipoEn), 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }

  Widget _getTipoSymbol(String t) {
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
      case 'fire': icon = Icons.whatshot; break;
      case 'water': icon = Icons.water_drop; break;
      case 'grass': icon = Icons.eco; break;
      case 'electric': icon = Icons.bolt; break;
      case 'psychic': icon = Icons.psychology; break;
      case 'ice': icon = Icons.ac_unit; break;
      case 'dragon': icon = Icons.auto_awesome_motion; break;
      case 'dark': icon = Icons.nightlight_round; break;
      case 'fairy': icon = Icons.auto_awesome; break;
      default: icon = Icons.help_outline;
    }
    return Icon(icon, color: Colors.white, size: 14);
  }

  Widget _buildPhysicalInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _infoCard("${currentPokemon.peso} kg", "PESO", Icons.monitor_weight_outlined),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _infoCard("${currentPokemon.altura} m", "ALTURA", Icons.height_rounded),
        ],
      ),
    );
  }

  Widget _infoCard(String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade500),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C3E50))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statBar("PS", currentPokemon.hp, Colors.green),
        _statBar("Ataque", currentPokemon.ataque, Colors.redAccent),
        _statBar("Defensa", currentPokemon.defensa, Colors.blueAccent),
        _statBar("Atk. Esp.", currentPokemon.atkEsp, Colors.purpleAccent),
        _statBar("Def. Esp.", currentPokemon.defEsp, Colors.teal),
        _statBar("Velocidad", currentPokemon.velocidad, Colors.orangeAccent),
      ],
    );
  }

  Widget _statBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
              Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 255, 
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabilidadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...currentPokemon.habilidadesNormales.map((h) => _buildHabItem(h, false)).toList(),
        if (currentPokemon.habilidadOculta != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          _buildHabItem(currentPokemon.habilidadOculta!, true),
        ]
      ],
    );
  }

  Widget _buildHabItem(String habEn, bool isOculta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isOculta ? Colors.deepPurple.withOpacity(0.1) : Colors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(isOculta ? Icons.stars_rounded : Icons.bolt_rounded, 
              color: isOculta ? Colors.deepPurple : Colors.amber.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_traducirHabilidad(habEn), 
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isOculta ? Colors.deepPurple : const Color(0xFF2C3E50))),
              if (isOculta)
                const Text("Habilidad Oculta", style: TextStyle(fontSize: 11, color: Colors.grey)),
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

  Widget _buildSeccionVariantes() {
    return FutureBuilder<List<Pokemon>>(
      future: PokemonService().getVariantes(widget.pokemon.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text("OTRAS FORMAS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2C3E50))),
            ),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                  var v = snapshot.data![i];
                  bool isSelected = currentPokemon.nombre == v.nombre;
                  
                  return GestureDetector(
                    onTap: () => setState(() => currentPokemon = v),
                    child: Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.redAccent : Colors.transparent, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            v.imagenUrl, 
                            height: 65,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.catching_pokemon, size: 30, color: Colors.grey.shade300),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              v.nombre.split('-').last.toUpperCase(), 
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.redAccent : Colors.grey.shade700),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
      case 'fire': return const Color(0xFFF42D2D); 
      case 'water': return const Color(0xFF3B9BF1);
      case 'grass': return const Color(0xFF48D0B0); 
      case 'electric': return const Color(0xFFFAC000); 
      case 'poison': return const Color(0xFF9F5BBA); 
      case 'dragon': return const Color(0xFF0773C7); 
      case 'psychic': return const Color(0xFFF85888); 
      case 'ghost': return const Color(0xFF6970C5); 
      case 'steel': return const Color(0xFF5596A4); 
      case 'dark': return const Color(0xFF595761); 
      case 'fairy': return const Color(0xFFEA1369); 
      case 'fighting': return const Color(0xFFD6425E); 
      case 'ground': return const Color(0xFFE19854); 
      case 'ice': return const Color(0xFF61CEC0); 
      case 'flying': return const Color(0xFF79A4FF); 
      case 'rock': return const Color(0xFFCEC18C);
      case 'bug': return const Color(0xFF98D142);
      case 'normal': return const Color(0xFFA0A29F); 
      default: return Colors.grey;
    }
  }
}
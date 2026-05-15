import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    currentPokemon = widget.pokemon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_getColorTipo(currentPokemon.tipos[0]), Colors.white],
            stops: const [0.0, 0.4],
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 250,
              floating: false,
              pinned: true,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Hero(
                    tag: currentPokemon.id,
                    child: currentPokemon.animacionUrl.isNotEmpty
                        ? Image.network(currentPokemon.animacionUrl, height: 180)
                        : Image.network(currentPokemon.imagenUrl, height: 180),
                  ),
                ),
              ),
            ),
          ],
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currentPokemon.nombre.toUpperCase(), 
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      Text("#${currentPokemon.id.toString().padLeft(4, '0')}", 
                        style: TextStyle(fontSize: 20, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // TIPOS CON ICONOS Y BORDE DORADO
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: currentPokemon.tipos.map((t) => _buildTipoIcono(t)).toList(),
                  ),
                  
                  const SizedBox(height: 30),
                  _buildPhysicalInfo(),
                  const SizedBox(height: 35),
                  _buildStatsSection(),
                  const SizedBox(height: 35),
                  _buildHabilidadesSection(),
                  const SizedBox(height: 35),
                  _buildSeccionVariantes(),
                  const SizedBox(height: 40),
                  
                  const Text("FORMA VARIOCOLOR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                  const SizedBox(height: 10),
                  Image.network(currentPokemon.animacionShinyUrl, height: 110),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- ICONOS DE TIPOS (ESTILO CIRCULAR CON BORDE DORADO) ---
  Widget _buildTipoIcono(String tipoEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getColorTipo(tipoEn),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.5), // Borde Dorado
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: _getTipoSymbol(tipoEn),
          ),
          const SizedBox(width: 8),
          Text(_traducirTipo(tipoEn), 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
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

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ESTADÍSTICAS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 15),
        _statBar("PS", currentPokemon.hp, Colors.green),
        _statBar("Ataque", currentPokemon.ataque, Colors.redAccent),
        _statBar("Defensa", currentPokemon.defensa, Colors.blueAccent),
        _statBar("At. Esp.", currentPokemon.atkEsp, Colors.purpleAccent),
        _statBar("Def. Esp.", currentPokemon.defEsp, Colors.teal),
        _statBar("Veloc.", currentPokemon.velocidad, Colors.orangeAccent),
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
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 200,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabilidadesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HABILIDADES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const Divider(),
          ...currentPokemon.habilidadesNormales.map((h) => _buildHabItem(h, false)).toList(),
          if (currentPokemon.habilidadOculta != null)
            _buildHabItem(currentPokemon.habilidadOculta!, true),
        ],
      ),
    );
  }

  Widget _buildHabItem(String habEn, bool isOculta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(isOculta ? Icons.stars : Icons.bolt, 
            color: isOculta ? Colors.deepPurple : Colors.amber, size: 18),
          const SizedBox(width: 10),
          Text(_traducirHabilidad(habEn), 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, 
              color: isOculta ? Colors.deepPurple : Colors.black87)),
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
            const Text("OTRAS FORMAS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 15),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                  var v = snapshot.data![i];
                  return GestureDetector(
                    onTap: () => setState(() => currentPokemon = v),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: currentPokemon.nombre == v.nombre ? Colors.red[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: currentPokemon.nombre == v.nombre ? Colors.red : Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(v.imagenUrl, height: 60),
                          Text(v.nombre.split('-').last.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
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

  Widget _buildPhysicalInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _infoCard("${currentPokemon.peso} kg", "PESO", Icons.monitor_weight_outlined),
        _infoCard("${currentPokemon.altura} m", "ALTURA", Icons.height),
      ],
    );
  }

  Widget _infoCard(String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 5),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Color _getColorTipo(String t) {
    switch(t){
      case 'fire': return Colors.orange; case 'water': return Colors.blue;
      case 'grass': return Colors.green; case 'electric': return Colors.yellow[800]!;
      case 'poison': return Colors.purple; case 'dragon': return Colors.indigo;
      case 'psychic': return Colors.pinkAccent; case 'ghost': return Colors.deepPurple;
      case 'steel': return Colors.blueGrey; case 'dark': return Colors.black87;
      case 'fairy': return Colors.pink[200]!; case 'fighting': return Colors.red[900]!;
      case 'ground': return Colors.brown; case 'ice': return Colors.cyan[300]!;
      case 'flying': return Colors.indigo[200]!; case 'normal': return Colors.blueGrey[200]!;
      default: return Colors.grey;
    }
  }
}
class Pokemon {
  final int id;
  final String nombre;
  final String imagenUrl;
  final String shinyUrl;
  final String animacionUrl;
  final String animacionShinyUrl;
  final List<String> tipos;
  final double peso;
  final double altura;
  final int hp, ataque, defensa, atkEsp, defEsp, velocidad; // Estadísticas completas
  final List<String> habilidadesNormales;
  final String? habilidadOculta;

  Pokemon({
    required this.id, required this.nombre, required this.imagenUrl,
    required this.shinyUrl, required this.animacionUrl, required this.animacionShinyUrl,
    required this.tipos, required this.peso, required this.altura,
    required this.hp, required this.ataque, required this.defensa,
    required this.atkEsp, required this.defEsp, required this.velocidad,
    required this.habilidadesNormales, this.habilidadOculta,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    var tiposList = json['types'] as List;
    List<String> tiposNombres = tiposList.map((t) => t['type']['name'].toString()).toList();

    int getStat(String name) {
      return json['stats'].firstWhere((s) => s['stat']['name'] == name)['base_stat'];
    }

    List<String> normales = [];
    String? oculta;
    var abilitiesList = json['abilities'] as List;
    for (var a in abilitiesList) {
      if (a['is_hidden'] == true) oculta = a['ability']['name'];
      else normales.add(a['ability']['name']);
    }

    var showdown = json['sprites']['other']['showdown'];
    String urlAnim = showdown['front_default'] ?? json['sprites']['other']['official-artwork']['front_default'] ?? "";
    String urlAnimShiny = showdown['front_shiny'] ?? json['sprites']['other']['official-artwork']['front_shiny'] ?? "";

    return Pokemon(
      id: json['id'],
      nombre: json['name'],
      imagenUrl: json['sprites']['other']['official-artwork']['front_default'] ?? "",
      shinyUrl: json['sprites']['other']['official-artwork']['front_shiny'] ?? "",
      animacionUrl: urlAnim,
      animacionShinyUrl: urlAnimShiny,
      tipos: tiposNombres,
      peso: json['weight'] / 10.0,
      altura: json['height'] / 10.0,
      hp: getStat('hp'),
      ataque: getStat('attack'),
      defensa: getStat('defense'),
      atkEsp: getStat('special-attack'), // NUEVO
      defEsp: getStat('special-defense'), // NUEVO
      velocidad: getStat('speed'),
      habilidadesNormales: normales,
      habilidadOculta: oculta,
    );
  }
}
class Pokemon {
  final String name;
  final String url;

  Pokemon({
    required this.name,
    required this.url,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
    );
  }

  // Esto es necesario para mostrar el ID en la lista
  int get id {
    final partes = url.split('/');
    return int.parse(partes[partes.length - 2]);
  }

  // Esto es necesario para mostrar la imagen en la lista
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }
}
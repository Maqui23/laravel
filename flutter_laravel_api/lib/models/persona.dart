class Persona {
  final int id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String? email;
  final String? telefono;
  final String? fotoUrl;
  final String? direccion;
  final bool esFavorito;
  final String? categoria;

  Persona( {
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    this.email,
    this.telefono,
    this.fotoUrl,
    this.direccion,
    this.esFavorito = false,
    this.categoria,
  });

  // Esto convierte el JSON que manda Laravel a un objeto de Dart
  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      dni: json['dni'],
      email: json['email'],
      telefono: json['telefono'],
      fotoUrl: json['foto_url'],
      direccion: json['direccion'],
      esFavorito: json['es_favorito'] == 1,
      categoria: json['categoria'],
    );
  }
}
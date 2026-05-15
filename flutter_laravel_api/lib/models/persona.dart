class Persona {
  final int id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String? email;
  final String? telefono;
  final String? fotoUrl;

  Persona({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    this.email,
    this.telefono,
    this.fotoUrl,
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
    );
  }
}
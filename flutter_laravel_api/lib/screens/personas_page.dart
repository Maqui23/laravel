import 'dart:convert';
import 'dart:ui'; // Necesario para el efecto Glassmorphism
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/persona.dart';
import '../services/persona_service.dart';
import 'crear_persona_page.dart';

class PersonasPage extends StatefulWidget {
  @override
  _PersonasPageState createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  final PersonaService personaService = PersonaService();
  late Future<List<Persona>> futurePersonas;

  @override
  void initState() {
    super.initState();
    _cargarPersonas();
  }

  void _cargarPersonas() {
    setState(() {
      futurePersonas = personaService.getPersonas();
    });
  }

  // --- MODAL DE ELIMINACIÓN TEMA OSCURO ---
  Future<bool?> _confirmarEliminacion(BuildContext context, Persona persona) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F2027),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5)
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('¿Eliminar registro?', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar a ${persona.nombres} del directorio global?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.cyanAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- COLORES NEÓN PARA CATEGORÍAS ---
  Color _getColorCategoria(String? categoria) {
    switch (categoria) {
      case 'Familia': return const Color(0xFFFF8A65); // Naranja Neón
      case 'Trabajo': return const Color(0xFF00E5FF); // Cyan Neón
      case 'Universidad': return const Color(0xFFB388FF); // Púrpura Neón
      case 'Amigos': return const Color(0xFFB2FF59); // Verde Neón
      default: return Colors.white70; // Neutro
    }
  }

  Future<LatLng?> _obtenerCoordenadasGoogle(String direccion) async {
    const String apiKey = 'AIzaSyCj6i9bsnUf3SIBD--tEbiGtLJCeR_5tb4';
    final String query = Uri.encodeComponent('$direccion, Puno, Perú');
    final String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  // --- MAPA MODAL TEMA OSCURO ---
  void _mostrarMapaInApp(BuildContext context, Persona persona) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF1E2A32),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            border: Border(top: BorderSide(color: Colors.cyanAccent, width: 2)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.satellite_alt_rounded, color: Colors.cyanAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Señal de ${persona.nombres}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context)
                    )
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  dense: true,
                  tileColor: Colors.amber.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.amber.withOpacity(0.3))
                  ),
                  leading: const Icon(Icons.radar_rounded, color: Colors.amberAccent),
                  title: const Text('¿Requiere más precisión?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amberAccent)),
                  subtitle: const Text('Abrir enlace directo con satélite (Maps)', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () async {
                      final String query = Uri.encodeComponent('${persona.direccion}, Puno, Perú');
                      final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) debugPrint('Error al abrir maps');
                    },
                    child: const Text('ABRIR APP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: FutureBuilder<LatLng?>(
                  future: _obtenerCoordenadasGoogle(persona.direccion!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.cyanAccent),
                            SizedBox(height: 16),
                            Text('Rastreando coordenadas...', style: TextStyle(color: Colors.cyanAccent)),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off, size: 60, color: Colors.white24),
                            const SizedBox(height: 16),
                            const Text('No se pudo establecer conexión satelital.', style: TextStyle(fontSize: 14, color: Colors.white54)),
                          ],
                        ),
                      );
                    }

                    final LatLng posicionExacta = snapshot.data!;
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: posicionExacta, zoom: 17.5),
                        markers: {
                          Marker(
                            markerId: MarkerId('marcador_${persona.id}'),
                            position: posicionExacta,
                            infoWindow: InfoWindow(title: persona.direccion, snippet: persona.nombres),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan), // Marcador Cyan
                          ),
                        },
                        mapType: MapType.normal, // Podrías poner MapType.hybrid para un look más "espía"
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BOTONES DE ACCIÓN PREMIUM ---
  Widget _buildBotonAccion({required IconData icono, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icono, color: color, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text('Directorio Global', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.cyanAccent), // Flecha de retroceso Cyan
      ),
      body: Stack(
        children: [
          // --- FONDO TECNOLÓGICO CON CÍRCULOS DE NEÓN ---
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
            top: 100, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00BCD4).withOpacity(0.15)),
            ),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3F51B5).withOpacity(0.2)),
            ),
          ),

          // --- LISTA DE PERSONAS ---
          SafeArea(
            child: FutureBuilder<List<Persona>>(
              future: futurePersonas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error de conexión al cargar datos.', style: TextStyle(color: Colors.redAccent)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 15),
                        const Text('Base de datos vacía', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('Inicia el registro de tu primer contacto.', style: TextStyle(color: Colors.white54)),
                      ],
                    )
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Persona persona = snapshot.data![index];
                    Color colorCategoria = _getColorCategoria(persona.categoria);

                    return Dismissible(
                      key: Key(persona.id.toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _confirmarEliminacion(context, persona),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
                      ),
                      onDismissed: (direction) async {
                        await personaService.deletePersona(persona.id);
                        if(mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${persona.nombres} purgado del sistema', style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },

                      // --- TARJETA GLASSMORPHISM ---
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () async {
                                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CrearPersonaPage(persona: persona)));
                                    if (result == true) _cargarPersonas();
                                  },
                                  onLongPress: () {
                                    Share.share('👤 ${persona.nombres} ${persona.apellidos}\n📱 ${persona.telefono ?? '-'}\n📍 ${persona.direccion ?? '-'}', subject: 'Contacto Seguro');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // AVATAR
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: colorCategoria.withOpacity(0.8), width: 2),
                                                boxShadow: [
                                                  BoxShadow(color: colorCategoria.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                                                ]
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor: const Color(0xFF1E2A32),
                                                radius: 30,
                                                backgroundImage: persona.fotoUrl != null ? NetworkImage(persona.fotoUrl!) : null,
                                                child: persona.fotoUrl == null
                                                    ? Text(persona.nombres[0].toUpperCase(), style: TextStyle(color: colorCategoria, fontWeight: FontWeight.bold, fontSize: 24))
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // INFORMACIÓN CENTRAL
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${persona.nombres} ${persona.apellidos}',
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (persona.esFavorito) const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 22),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),

                                                  // CHIP DE CATEGORÍA
                                                  if (persona.categoria != null && persona.categoria!.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: colorCategoria.withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: colorCategoria.withOpacity(0.4)),
                                                      ),
                                                      child: Text(
                                                        persona.categoria!.toUpperCase(),
                                                        style: TextStyle(fontSize: 10, color: colorCategoria, fontWeight: FontWeight.bold, letterSpacing: 1),
                                                      ),
                                                    ),
                                                  const SizedBox(height: 8),

                                                  // DATOS
                                                  if (persona.telefono != null && persona.telefono!.isNotEmpty)
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.phone_android, size: 14, color: Colors.cyanAccent),
                                                        const SizedBox(width: 6),
                                                        Text(persona.telefono!, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                                                      ],
                                                    ),
                                                  const SizedBox(height: 4),
                                                  if (persona.direccion != null && persona.direccion!.isNotEmpty)
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(top: 2),
                                                          child: Icon(Icons.location_on_outlined, size: 14, color: Colors.cyanAccent),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Expanded(child: Text(persona.direccion!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)))),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // LÍNEA DIVISORIA Y BOTONES
                                        if ((persona.telefono?.isNotEmpty ?? false) || (persona.direccion?.isNotEmpty ?? false)) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Divider(height: 1, color: Colors.white.withOpacity(0.15)),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (persona.telefono != null && persona.telefono!.isNotEmpty)
                                                _buildBotonAccion(
                                                  icono: Icons.call,
                                                  color: Colors.greenAccent,
                                                  onPressed: () => launchUrl(Uri.parse('tel:${persona.telefono}'))
                                                ),
                                              if (persona.telefono != null && persona.telefono!.isNotEmpty)
                                                _buildBotonAccion(
                                                  icono: Icons.message_rounded,
                                                  color: const Color(0xFF25D366), // WhatsApp Neón
                                                  onPressed: (){
                                                    // 1. Creamos el mensaje dinámico usando el nombre del contacto
                                                   final String mensajePredeterminado = "Hola ${persona.nombres}, te escribo desde mi sistema AlexCore. ¿Qué tal?";
                                                   final String mensajeCodificado = Uri.encodeComponent(mensajePredeterminado);
                                                   final String urlFinal = 'https://wa.me/51${persona.telefono}?text=$mensajeCodificado';
                                                   
                                                   launchUrl(Uri.parse(urlFinal), mode: LaunchMode.externalApplication);
                                                  }
                                                ),
                                              if (persona.direccion != null && persona.direccion!.isNotEmpty)
                                                _buildBotonAccion(
                                                  icono: Icons.map_rounded,
                                                  color: const Color(0xFFFF5252), // Google Maps Oscuro/Rojo
                                                  onPressed: () => _mostrarMapaInApp(context, persona)
                                                ),
                                            ],
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black87, // Icono oscuro para contraste
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CrearPersonaPage()));
          if (result == true) _cargarPersonas();
        },
        child: const Icon(Icons.person_add_alt_1_rounded, size: 28),
      ),
    );
  }
}

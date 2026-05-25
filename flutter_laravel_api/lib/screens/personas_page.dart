import 'dart:convert';
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

  Future<bool?> _confirmarEliminacion(BuildContext context, Persona persona) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar registro?'),
        content: Text('¿Estás seguro de eliminar a ${persona.nombres}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FUNCIÓN PARA COLORES DINÁMICOS SEGÚN CATEGORÍA ---
  Color _getColorCategoria(String? categoria) {
    switch (categoria) {
      case 'Familia': return const Color(0xFFFF8A65); // Naranja coral
      case 'Trabajo': return const Color(0xFF4FC3F7); // Azul claro
      case 'Universidad': return const Color(0xFF9575CD); // Púrpura
      case 'Amigos': return const Color(0xFFAED581); // Verde suave
      default: return const Color(0xFFBDBDBD); // Gris neutro
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

  void _mostrarMapaInApp(BuildContext context, Persona persona) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Color(0xFF3F51B5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ubicación de ${persona.nombres}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  dense: true,
                  tileColor: Colors.amber.withOpacity(0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  leading: const Icon(Icons.navigation, color: Colors.amber),
                  title: const Text('¿El mapa interno no es exacto?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: const Text('Usa el buscador de la App oficial', style: TextStyle(fontSize: 11)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () async {
                      final String query = Uri.encodeComponent('${persona.direccion}, Puno, Perú');
                      final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) debugPrint('Error al abrir maps');
                    },
                    child: const Text('ABRIR APP', style: TextStyle(fontSize: 11, color: Colors.white)),
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
                            CircularProgressIndicator(color: Color(0xFF3F51B5)),
                            SizedBox(height: 16),
                            Text('Trazando coordenadas...', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('No pudimos trazar esta dirección.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                          ),
                        },
                        mapType: MapType.normal,
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

  // --- WIDGET PREMIUM PARA LOS BOTONES DE ACCIÓN ---
  Widget _buildBotonAccion({required IconData icono, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), // Fondo suave translúcido
          borderRadius: BorderRadius.circular(12), // Borde cuadrado redondeado
        ),
        child: Icon(icono, color: color, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Un gris más claro y moderno para el fondo
      appBar: AppBar(
        title: const Text('Directorio', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Persona>>(
        future: futurePersonas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error de conexión al cargar datos.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contact_phone_outlined, size: 80, color: Colors.grey[350]),
                  const SizedBox(height: 15),
                  const Text('Tu directorio está vacío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const Text('Toca el botón + para agregar personas', style: TextStyle(color: Colors.grey)),
                ],
              )
            );
          }

          return ListView.builder(
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
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                ),
                onDismissed: (direction) async {
                  await personaService.deletePersona(persona.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${persona.nombres} eliminado')));
                },
                
                // --- REDISEÑO PREMIUM DE LA TARJETA ---
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Bordes más redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04), // Sombra muy sutil
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CrearPersonaPage(persona: persona)));
                        if (result == true) _cargarPersonas();
                      },
                      onLongPress: () {
                        Share.share('👤 ${persona.nombres} ${persona.apellidos}\n📱 ${persona.telefono ?? '-'}\n📍 ${persona.direccion ?? '-'}', subject: 'Contacto');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // AVATAR MEJORADO
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: colorCategoria.withOpacity(0.5), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: colorCategoria.withOpacity(0.15),
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
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2C3E50)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (persona.esFavorito) const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // CHIP DE CATEGORÍA DINÁMICO
                                      if (persona.categoria != null && persona.categoria!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colorCategoria.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            persona.categoria!,
                                            style: TextStyle(fontSize: 11, color: colorCategoria, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      
                                      // DATOS CON ICONOS PEQUEÑOS
                                      if (persona.telefono != null && persona.telefono!.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_android, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(persona.telefono!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                          ],
                                        ),
                                      const SizedBox(height: 3),
                                      if (persona.direccion != null && persona.direccion!.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(child: Text(persona.direccion!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54))),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // LÍNEA DIVISORIA Y BOTONES DE ACCIÓN
                            if ((persona.telefono?.isNotEmpty ?? false) || (persona.direccion?.isNotEmpty ?? false)) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: Colors.grey[200]),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (persona.telefono != null && persona.telefono!.isNotEmpty)
                                    _buildBotonAccion(
                                      icono: Icons.call, 
                                      color: Colors.green, 
                                      onPressed: () => launchUrl(Uri.parse('tel:${persona.telefono}'))
                                    ),
                                  if (persona.telefono != null && persona.telefono!.isNotEmpty)
                                    _buildBotonAccion(
                                      icono: Icons.message_rounded, 
                                      color: const Color(0xFF25D366), // Color WhatsApp
                                      onPressed: () => launchUrl(Uri.parse('https://wa.me/51${persona.telefono}'), mode: LaunchMode.externalApplication)
                                    ),
                                  if (persona.direccion != null && persona.direccion!.isNotEmpty)
                                    _buildBotonAccion(
                                      icono: Icons.map_rounded, 
                                      color: const Color(0xFFEA4335), // Color Google Maps
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CrearPersonaPage()));
          if (result == true) _cargarPersonas();
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
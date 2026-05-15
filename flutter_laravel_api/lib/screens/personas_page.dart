import 'package:flutter/material.dart';
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

  // --- CUADRO DE DIÁLOGO DE CONFIRMACIÓN ---
  Future<bool?> _confirmarEliminacion(BuildContext context, Persona persona) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('¿Estás seguro de eliminar a ${persona.nombres}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Directorio de Personas'),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Persona>>(
        future: futurePersonas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error de conexión al cargar datos.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No hay personas registradas aún.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Persona persona = snapshot.data![index];
              return Dismissible(
                key: Key(persona.id.toString()),
                direction: DismissDirection.endToStart,
                // --- SE AGREGA LA CONFIRMACIÓN AQUÍ ---
                confirmDismiss: (direction) => _confirmarEliminacion(context, persona),
                // --------------------------------------
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                ),
                onDismissed: (direction) async {
                  await personaService.deletePersona(persona.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${persona.nombres} eliminado')),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CrearPersonaPage(persona: persona),
                        ),
                      );
                      if (result == true) _cargarPersonas();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF3F51B5).withOpacity(0.1),
                      radius: 25,
                      backgroundImage: persona.fotoUrl != null 
                          ? NetworkImage(persona.fotoUrl!) 
                          : null,
                      child: persona.fotoUrl == null
                          ? Text(
                              persona.nombres[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Color(0xFF3F51B5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            )
                          : null,
                    ),
                    title: Text('${persona.nombres} ${persona.apellidos}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DNI: ${persona.dni}'),
                          if (persona.telefono != null && persona.telefono!.isNotEmpty)
                            Text('Tel: ${persona.telefono}'),
                        ],
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
        backgroundColor: const Color(0xFFFF5252),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CrearPersonaPage()),
          );
          if (result == true) {
            _cargarPersonas();
          }
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
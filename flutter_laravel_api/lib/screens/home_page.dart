import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final data = await ApiService.getUser();
    setState(() {
      user = data;
    });
  }

  Future<void> logout() async {
    await ApiService.logout();
    
    if (!mounted) return; 

    // MODIFICACIÓN: Usamos pushReplacementNamed para limpiar la pila de navegación
    // y redirigir al login de forma segura.
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Cabecera con diseño curvo
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 30, top: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: const NetworkImage('https://pbs.twimg.com/media/G3Ea7cvXEAAHU0H?format=jpg&name=4096x4096'),
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint('Error al cargar la imagen de perfil');
                          },
                          child: user!['name'] == null 
                            ? const Icon(Icons.person, size: 50, color: Colors.indigo)
                            : null, 
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '¡Hola, ${user!['name']}!',
                          style: const TextStyle(
                            fontSize: 24, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Información del usuario
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Colors.indigo, size: 30),
                        title: const Text('Correo Electrónico', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        subtitle: Text(
                          user!['email'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // SECCIÓN DE ACCIONES (Punto 2: CRUD)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestión de Datos (CRUD)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        
                        // Botón para ir al Listado de Personas (Punto 2 del PDF)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Aquí navegaremos a la pantalla de lista de personas
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cargando lista desde AWS...')),
                            );
                          },
                          icon: const Icon(Icons.people_alt_rounded),
                          label: const Text('Ver Personas Registradas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                        
                        const SizedBox(height: 15),

                        // Tu botón de Pokédex
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cargando Pokédex...')),
                            );
                          },
                          icon: const Icon(Icons.catching_pokemon, size: 28),
                          label: const Text('Explorar Pokédex', style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
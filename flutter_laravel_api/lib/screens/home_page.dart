import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'personas_page.dart';
import 'pokedex_page.dart';

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
    
    if (!mounted) return;

    if (data != null) {
      setState(() {
        user = data;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login'); 
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    if (!mounted) return; 
    Navigator.pushReplacementNamed(context, '/login');
  }

  // --- WIDGET PERSONALIZADO PARA LOS BOTONES DEL MENÚ ---
  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Fondo gris moderno
      appBar: AppBar(
        title: const Text('Mi Panel', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        backgroundColor: const Color(0xFF283593), // Azul oscuro
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF283593)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- CABECERA PREMIUM CON GRADIENTE ---
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF283593), Color(0xFF3F51B5)], // Gradiente azul
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    child: Column(
                      children: [
                        // Contenedor del Avatar con borde
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: const NetworkImage('https://pbs.twimg.com/media/G3Ea7cvXEAAHU0H?format=jpg&name=4096x4096'),
                            onBackgroundImageError: (exception, stackTrace) => debugPrint('Error al cargar imagen'),
                            child: user!['name'] == null || user!['name'].toString().isEmpty
                                ? const Icon(Icons.person_rounded, size: 50, color: Color(0xFF3F51B5))
                                : null, 
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Hola, ${user!['name'] ?? 'Usuario'}!',
                          style: const TextStyle(
                            fontSize: 26, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_rounded, color: Colors.white70, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                user!['email'] ?? 'Sin correo',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // --- SECCIÓN DE MÓDULOS (Dashboard) ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Qué deseas hacer hoy?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                        ),
                        const SizedBox(height: 20),
                        
                        // Tarjeta 1: Directorio de Personas
                        _buildMenuCard(
                          context: context,
                          title: 'Directorio de Personas',
                          subtitle: 'Gestiona contactos, direcciones y ubicaciones GPS.',
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF3F51B5), // Azul Índigo
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => PersonasPage()),
                            );
                          },
                        ),
                        
                        // Tarjeta 2: Pokédex API
                        _buildMenuCard(
                          context: context,
                          title: 'Pokédex Explorer',
                          subtitle: 'Consulta información detallada y estadísticas.',
                          icon: Icons.catching_pokemon,
                          color: const Color(0xFFE53935), // Rojo Pokémon
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PokedexPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
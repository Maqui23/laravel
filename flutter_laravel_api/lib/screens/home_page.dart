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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
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
                  // Cabecera con la imagen de perfil de la URL proporcionada
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
                          // URL de imagen de X (Twitter) integrada
                          backgroundImage: const NetworkImage('https://pbs.twimg.com/media/G3Ea7cvXEAAHU0H?format=jpg&name=4096x4096'),
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint('Error al cargar la imagen de perfil');
                          },
                          // Respaldo: si la imagen de la URL no carga, muestra la inicial
                          child: user!['name'] == null 
                            ? const Icon(Icons.person, size: 50, color: Colors.indigo)
                            : null, // Si la imagen carga, el child no se ve
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
                  
                  // Tarjeta de información del usuario
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Colors.indigo, size: 30),
                        title: const Text(
                          'Correo Electrónico',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        subtitle: Text(
                          user!['email'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Sección de acciones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Acciones rápidas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cargando Pokédex...')),
                            );
                          },
                          icon: const Icon(Icons.catching_pokemon, size: 28),
                          label: const Text(
                            'Explorar Pokédex',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                          ),
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
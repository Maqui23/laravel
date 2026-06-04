import 'dart:math';
import 'dart:async';
import 'dart:ui'; // Necesario para el efecto cristal (Blur)
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
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

  // --- Variables para el Sensor de Movimiento ---
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
    _iniciarSensorDeMovimiento();
  }

  // --- LÓGICA DEL SENSOR (ACELERÓMETRO) ---
  void _iniciarSensorDeMovimiento() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      double gX = event.x / 9.80665;
      double gY = event.y / 9.80665;
      double gZ = event.z / 9.80665;
      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > 2.5) {
        final now = DateTime.now();
        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
          _lastShakeTime = now;
          _mostrarEasterEgg();
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> cargarUsuario() async {
    final data = await ApiService.getUser();
    if (!mounted) return;

    if (data != null) {
      setState(() => user = data);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // --- MODAL PARA CAMBIAR LA CONTRASEÑA (ESTILO DARK/NEÓN) ---
  void _mostrarModalCambioPassword() {
    final TextEditingController passController = TextEditingController();
    bool isLoading = false;
    bool isObscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Para usar nuestro propio diseño
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 30,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E2A32), // Fondo oscuro para el modal
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(top: BorderSide(color: Colors.cyanAccent, width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Actualizar Contraseña", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("Ingresa tu nueva clave de acceso de forma segura.", style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 25),

                  // Campo de texto estilo Neón
                  TextField(
                    controller: passController,
                    obscureText: isObscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Nueva Contraseña",
                      labelStyle: TextStyle(color: Colors.cyanAccent.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.cyanAccent),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: Colors.white54,
                        ),
                        onPressed: () => setModalState(() => isObscure = !isObscure),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Botón de Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.cyanAccent.withOpacity(0.4),
                      ),
                      onPressed: isLoading ? null : () async {
                        if (passController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debe tener al menos 6 caracteres'), backgroundColor: Colors.redAccent)
                          );
                          return;
                        }
                        setModalState(() => isLoading = true);
                        bool exito = await ApiService.updatePassword(passController.text);
                        setModalState(() => isLoading = false);

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(exito ? 'Contraseña actualizada con éxito' : 'Error al actualizar', style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: exito ? Colors.green.shade600 : Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            behavior: SnackBarBehavior.floating,
                          )
                        );
                      },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black87)
                          : const Text("GUARDAR CLAVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        );
      }
    );
  }

  // --- EASTER EGG (ESTILO TERMINAL) ---
  void _mostrarEasterEgg() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F2027),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.cyanAccent, width: 1.5)
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.cyanAccent, size: 30),
            SizedBox(width: 10),
            Text("HARDWARE DETECTADO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          "El acelerómetro de tu dispositivo ha registrado una fuerza G inusual.\n\nSistemas de monitoreo activados en tiempo real.",
          style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ENTENDIDO", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
          )
        ],
      ),
    );
  }

  // --- WIDGET PERSONALIZADO GLASSMORPHISM PARA EL MENÚ ---
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor.withOpacity(0.5)),
                        ),
                        child: Icon(icon, color: accentColor, size: 30),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Permite que el gradiente suba hasta la barra de estado
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text('ALEXCORE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.cyanAccent),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- FONDO TECNOLÓGICO Y CÍRCULOS DE NEÓN ---
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
            top: -50, left: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3F51B5).withOpacity(0.3)),
            ),
          ),
          Positioned(
            bottom: 100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00BCD4).withOpacity(0.2)),
            ),
          ),

          // --- CONTENIDO DEL DASHBOARD ---
          user == null
            ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // --- CABECERA DE USUARIO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color(0xFF203A43),
                                backgroundImage: const NetworkImage('https://pbs.twimg.com/media/G3Ea7cvXEAAHU0H?format=jpg&name=4096x4096'),
                                onBackgroundImageError: (e, s) => debugPrint('Error al cargar imagen'),
                                child: user!['name'] == null || user!['name'].toString().isEmpty
                                    ? const Icon(Icons.person_rounded, size: 50, color: Colors.cyanAccent)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '¡Hola, ${user!['name'] ?? 'Usuario'}!',
                              style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.email_outlined, color: Colors.cyanAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Text(user!['email'] ?? 'Sin correo', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botón de Contraseña estilo "Glass"
                            OutlinedButton.icon(
                              onPressed: _mostrarModalCambioPassword,
                              icon: const Icon(Icons.security_rounded, size: 18),
                              label: const Text("Cambiar Contraseña", style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.05),
                                side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- SECCIÓN DE MÓDULOS ---
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Módulos Activos',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 2),
                            ),
                            const SizedBox(height: 16),

                            // Módulo 1: Personas
                            _buildMenuCard(
                              title: 'Directorio de Personas',
                              subtitle: 'Gestión de contactos, ubicaciones GPS y datos de sistema.',
                              icon: Icons.hub_outlined,
                              accentColor: Colors.cyanAccent,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PersonasPage()));
                              },
                            ),

                            // Módulo 2: Pokédex
                            _buildMenuCard(
                              title: 'Pokédex Nacional',
                              subtitle: 'API Explorer para consulta de entidades y estadísticas.',
                              icon: Icons.data_exploration_outlined,
                              accentColor: const Color(0xFFFF5252), // Un toque rojo para contrastar
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PokedexPage()));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

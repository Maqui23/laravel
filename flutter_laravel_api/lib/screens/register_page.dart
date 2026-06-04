import 'dart:ui'; // Necesario para el efecto Glassmorphism
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> handleRegister() async {
    // 1. Validación de campos
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showSnackBar('Datos incompletos. Se requieren todos los campos.');
      return;
    }

    setState(() => loading = true);

    // 2. Llamada a la API en AWS
    final ok = await ApiService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (ok) {
      // 3. Navegación al éxito
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage())
      );
    } else {
      _showSnackBar('Fallo de registro. La credencial ya existe en el sistema.');
    }
  }

  // --- ALERTA DEL SISTEMA MODERNA ---
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("NUEVO ACCESO", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
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
            top: 50, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3F51B5).withOpacity(0.2)),
            ),
          ),
          Positioned(
            bottom: -100, left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00BCD4).withOpacity(0.15)),
            ),
          ),

          // --- CONTENIDO PRINCIPAL ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- ICONO CENTRAL CON GLOW ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                        ]
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 60,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      "CREAR UNA CUENTA",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Registra tus datos. El sistema validará que el correo no exista previamente.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 35),

                    // --- TARJETA GLASSMORPHISM ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(nameController, 'Nombres y Apellidos', Icons.badge_outlined),
                              const SizedBox(height: 20),

                              _buildTextField(emailController, 'Correo Electrónico', Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 20),

                              _buildTextField(passwordController, 'Contraseña', Icons.lock_outline, isObscure: true),
                              const SizedBox(height: 30),

                              // --- BOTÓN DE REGISTRO NEÓN ---
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: loading ? null : handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black87,
                                    elevation: 8,
                                    shadowColor: Colors.cyanAccent.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 25, width: 25,
                                          child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 3),
                                        )
                                      : const Text(
                                          'REGISTRARSE',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- ENLACE AL LOGIN ---
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: '¿El usuario ya existe? ',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          children: const [
                            TextSpan(
                              text: 'Inicia Sesión',
                              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PERSONALIZADO PARA CAMPOS GLASSMORPHISM ---
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
      ),
    );
  }
}

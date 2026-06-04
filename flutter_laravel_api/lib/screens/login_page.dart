import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import 'recovery_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    _googleSignIn.initialize();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LOGIN NORMAL ---
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar('Por favor, completa todos los campos');
      return;
    }

    setState(() => loading = true);

    final ok = await ApiService.login(
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar('Credenciales incorrectas. Intenta de nuevo.');
    }
  }

  // --- LÓGICA DE LOGIN CON GOOGLE ---
  Future<void> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        return; // El usuario canceló
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null) {
        if (!mounted) return;
        _showSnackBar('Conectando con el servidor...');

        bool success = await ApiService.loginWithGoogle(googleAuth.idToken!);

        if (!mounted) return;
        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showSnackBar('Error al autorizar con el servidor.');
        }
      }
    } catch (error) {
      debugPrint("Error de Google Sign-In: $error");
      if (mounted) {
        _showSnackBar('Error al conectar con Google. Revisa tu SHA-1.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evita que el teclado empuje el fondo de manera extraña
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- FONDO TECNOLÓGICO PROFUNDO ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Negro azulado profundo
                  Color(0xFF203A43), // Azul oscuro
                  Color(0xFF2C5364), // Gris azulado
                ],
              ),
            ),
          ),

          // --- CÍRCULOS DECORATIVOS DIFUMINADOS ---
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3F51B5).withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00BCD4).withOpacity(0.2),
              ),
            ),
          ),

          // --- CONTENIDO PRINCIPAL ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO ALEXCORE CON TU IMAGEN
                    Container(
                      padding: const EdgeInsets.all(8), // Padding reducido para destacar el logo
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ALEXCORE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Panel de Control Centralizado',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 40),

                    // --- TARJETA GLASSMORPHISM ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // El efecto cristal
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), // Translúcido
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Inputs
                              _buildTextField(emailController, 'Correo electrónico', Icons.email_outlined),
                              const SizedBox(height: 16),
                              _buildTextField(passwordController, 'Contraseña', Icons.lock_outline, isObscure: true),

                              // Recuperar Contraseña
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RecoveryPage()),
                                    );
                                  },
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600)
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // BOTÓN DE LOGIN PRINCIPAL
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: loading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 5,
                                    shadowColor: Colors.cyanAccent.withOpacity(0.5),
                                  ),
                                  child: loading
                                    ? const CircularProgressIndicator(color: Colors.black87)
                                    : const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                                ),
                              ),

                              // SEPARADOR VISUAL
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text("O ingresa con", style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                                  ],
                                ),
                              ),

                              // BOTÓN DE GOOGLE REDISEÑADO
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton.icon(
                                  onPressed: handleGoogleSignIn,
                                  icon: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    height: 24
                                  ),
                                  label: const Text('Continuar con Google', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // --- NAVEGACIÓN AL REGISTRO ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("¿No tienes cuenta?", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Regístrate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.cyanAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PERSONALIZADO PARA LOS TEXTFIELDS DE CRISTAL ---
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05), // Muy transparente
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}

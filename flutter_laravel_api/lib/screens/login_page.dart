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
        _showSnackBar('Conectando con el servidor de AWS...');
        
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
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Fondo gris muy claro
      body: Stack(
        children: [
          // --- FONDO SUPERIOR CON GRADIENTE ---
          Container(
            height: size.height * 0.4,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF283593), Color(0xFF3F51B5)], // Colores Índigo
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
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
                    const SizedBox(height: 20),
                    
                    // ICONO Y TEXTOS DE CABECERA
                    const Icon(Icons.lock_person_rounded, size: 70, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Ingresa para continuar',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),

                    // --- TARJETA BLANCA FLOTANTE ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
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
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w600)),
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
                                backgroundColor: const Color(0xFF3F51B5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                              ),
                              child: loading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                            ),
                          ),
                          
                          // SEPARADOR VISUAL
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text("O ingresa con", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                ),
                                Expanded(child: Divider()),
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
                              label: const Text('Continuar con Google', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 35),

                    // --- NAVEGACIÓN AL REGISTRO ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿No tienes cuenta?", style: TextStyle(color: Colors.black54, fontSize: 15)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Regístrate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF283593))),
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

  // --- WIDGET PERSONALIZADO PARA LOS TEXTFIELDS ---
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        filled: true,
        fillColor: Colors.grey[50], // Fondo ligerísimamente gris para contraste
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
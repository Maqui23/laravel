import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importación necesaria para Google
import '../services/api_service.dart';
import 'recovery_page.dart'; // Importamos la página de recuperación

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
    _googleSignIn.initialize(); // Requerido a partir de google_sign_in v7.0.0+
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
      Navigator.pushReplacementNamed(context, '/home'); // Usando rutas limpias
    } else {
      _showSnackBar('Credenciales incorrectas. Intenta de nuevo.');
    }
  }

  // --- LÓGICA DE LOGIN CON GOOGLE (Punto 1.4) ---
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
      print("Error de Google Sign-In: $error");
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono decorativo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 80, color: Colors.indigo),
                ),
                const SizedBox(height: 30),
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Inputs
                _buildTextField(emailController, 'Correo electrónico', Icons.email_outlined),
                const SizedBox(height: 20),
                _buildTextField(passwordController, 'Contraseña', Icons.lock_outline, isObscure: true),
                
                // --- RECUPERACIÓN (Punto 1.3) ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecoveryPage()),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.indigo)),
                  ),
                ),
                const SizedBox(height: 20),

                // --- BOTÓN PRINCIPAL DE LOGIN ---
                ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: loading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("O ingresa con")),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // --- BOTÓN DE GOOGLE (Punto 1.4) ---
                ElevatedButton.icon(
                  onPressed: handleGoogleSignIn,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', 
                    height: 24
                  ),
                  label: const Text('Continuar con Google', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 1,
                  ),
                ),

                const SizedBox(height: 30),

                // --- NAVEGACIÓN A REGISTRO (Punto 1.2) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes cuenta?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text("Regístrate", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
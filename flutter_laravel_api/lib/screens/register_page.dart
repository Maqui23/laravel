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
    // 1. Validación de campos (Punto 1.2 del proyecto)
    if (nameController.text.isEmpty || 
        emailController.text.isEmpty || 
        passwordController.text.isEmpty) {
      _showSnackBar('Por favor, completa todos los campos.');
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
      // 3. Navegación al éxito (Punto 89: Flujo de pantallas)
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const HomePage())
      );
    } else {
      _showSnackBar('Error al registrar. El correo podría ya estar en uso.');
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
      backgroundColor: Colors.grey[100], // Mismo fondo que tu login
      appBar: AppBar(
        title: const Text("Crear Cuenta"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Icono para mantener la coherencia visual
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Campo de Nombre
                _buildTextField(nameController, 'Nombre completo', Icons.person_outline),
                const SizedBox(height: 20),

                // Campo de Correo
                _buildTextField(emailController, 'Correo electrónico', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),

                // Campo de Contraseña
                _buildTextField(passwordController, 'Contraseña', Icons.lock_outline, isObscure: true),
                
                const SizedBox(height: 40),

                // Botón de Registro (Mismo estilo que el login)
                ElevatedButton(
                  onPressed: loading ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 25, width: 25,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'REGISTRARSE',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                ),
                
                // Botón para volver al login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("¿Ya tienes cuenta? Inicia sesión", style: TextStyle(color: Colors.indigo)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los inputs (Mismo que el login)
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
}
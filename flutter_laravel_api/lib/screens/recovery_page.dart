import 'dart:ui'; // Requerido para el efecto Glassmorphism
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final emailController = TextEditingController();
  bool loading = false;

  void handleRecovery() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa tu correo institucional', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
      return;
    }

    setState(() => loading = true);
    // Llamamos al método que ya tienes configurado en el backend
    final message = await ApiService.recoverPassword(emailController.text);
    setState(() => loading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E2A32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.cyanAccent, width: 1.5)
          ),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, color: Colors.cyanAccent),
              SizedBox(width: 10),
              Text("ESTADO DEL SISTEMA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          content: Text(
            message ?? "Hubo un error de conexión con los servidores de AWS.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                if (message != null && message.contains('temporal')) {
                   Navigator.pop(context); // Vuelve al login si tuvo éxito
                }
              },
              child: const Text("ENTENDIDO", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("RECUPERAR ACCESO", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 18)),
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
            top: 100, right: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00BCD4).withOpacity(0.2)),
            ),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3F51B5).withOpacity(0.15)),
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
                    // --- ICONO FLOTANTE ---
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
                      child: const Icon(Icons.mark_email_read_rounded, size: 70, color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "PROTOCOLO DE SEGURIDAD",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Ingresa la dirección vinculada a tu cuenta. El sistema emitirá una clave temporal para restablecer tu acceso.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.5),
                    ),
                    const SizedBox(height: 40),

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
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.cyanAccent),
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
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: loading ? null : handleRecovery,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black87,
                                    elevation: 5,
                                    shadowColor: Colors.cyanAccent.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: loading
                                      ? const CircularProgressIndicator(color: Colors.black87)
                                      : const Text("SOLICITAR CLAVE TEMPORAL", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}

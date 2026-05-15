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
        const SnackBar(content: Text('Por favor, ingresa tu correo')),
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
          title: const Text("Recuperación"),
          content: Text(message ?? "Hubo un error de conexión con AWS."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                if (message != null && message.contains('temporal')) {
                   Navigator.pop(context); // Vuelve al login si tuvo éxito
                }
              },
              child: const Text("Entendido"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar Contraseña"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              "Ingresa el correo con el que te registraste. Te daremos una clave temporal.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email, color: Colors.indigo),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : handleRecovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: loading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SOLICITAR CLAVE TEMPORAL", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
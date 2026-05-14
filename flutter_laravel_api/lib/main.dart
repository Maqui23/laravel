import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/register_page.dart'; // Importamos registro para las rutas

void main() async {
  // 1. Asegura que los servicios de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Revisa si existe un token guardado en el celular (Persistencia Punto 1.1)
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 3. Lanza la app pasando el resultado del token
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Portafolio - Auth Laravel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      
      // LÓGICA DE AUTO-LOGIN: 
      // Si el token no es nulo, va directo al Home. Si es nulo, al Login.
      home: token != null ? const HomePage() : const LoginPage(),

      // AÑADIMOS ESTO: Definición de rutas para navegación y Logout
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IP pública de tu instancia de AWS
  static const String baseUrl = 'http://3.137.136.104/api';

  // 1. AUTENTICACIÓN: LOGIN [cite: 6, 12]
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        // Guardamos el token de Sanctum para persistir la sesión [cite: 5-6]
        await prefs.setString('token', data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print("Error en login: $e");
      return false;
    }
  }

  // 1.5 REGISTRO DE USUARIO
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Accept': 'application/json'},
        body: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('token')) {
          await prefs.setString('token', data['token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Error en registro: $e");
      return false;
    }
  }

  // 2. CRUD: LISTAR PERSONAS [cite: 13, 24, 91]
  static Future<List<dynamic>> getPersonas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personas'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Autorización con el token guardado
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error al obtener personas: $e");
      return [];
    }
  }

  // 3. CRUD: CREAR CON IMAGEN (Cámara/Galería) [cite: 23, 27, 30-33]
  static Future<bool> createPersona(String nombre, String detalle, String? imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      // Usamos MultipartRequest para poder enviar archivos (fotos) [cite: 27]
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/personas'));
      
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Campos de texto para la base de datos MySQL [cite: 85]
      request.fields['nombre'] = nombre;
      request.fields['detalle'] = detalle;

      // Si se capturó una foto, la adjuntamos al envío [cite: 30-31]
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('foto', imagePath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201; // 201 Created
    } catch (e) {
      print("Error al crear persona: $e");
      return false;
    }
  }

  // 4. CRUD: ELIMINAR PERSONA [cite: 26]
  static Future<bool> deletePersona(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/personas/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error al eliminar: $e");
      return false;
    }
  }

static Future<bool> loginWithGoogle(String idToken) async {
  final response = await http.post(
    Uri.parse('$baseUrl/google-login'),
    body: {'token': idToken},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    return true;
  }
  return false;
}
  // 5. OBTENER PERFIL DE USUARIO
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 6. LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Limpiamos el almacenamiento local
  }
}
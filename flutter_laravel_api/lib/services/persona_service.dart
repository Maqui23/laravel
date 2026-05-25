import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/persona.dart';

class PersonaService {
 final String baseUrl = 'http://3.137.136.104:8000/api';
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. OBTENER TODAS LAS PERSONAS (Read)
  Future<List<Persona>> getPersonas() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/personas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Persona.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las personas');
    }
  }

  // 2. CREAR UNA PERSONA (Create)
  Future<bool> createPersona(Map<String, String> personaData, {File? imageFile}) async {
    final String? token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/personas'));

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll(personaData);

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      return true;
    } else {
      var responseData = await response.stream.bytesToString();
      print('DETALLE ERROR CREAR: $responseData');
      return false;
    }
  }

  // 3. ACTUALIZAR UNA PERSONA (Update) 
  Future<bool> updatePersona(int id, Map<String, String> personaData, {File? imageFile}) async {
    final String? token = await _getToken();
    
    // IMPORTANTE: Se envía por POST para que PHP/Laravel procese el archivo 'foto'
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/personas/$id'));

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Esta es la parte mágica para que Laravel entienda que es un UPDATE (PUT)
    request.fields['_method'] = 'PUT'; 
    request.fields.addAll(personaData);

    // Solo adjuntamos la foto si el usuario seleccionó una nueva
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      var responseData = await response.stream.bytesToString();
      print('====================================');
      print('ERROR AL ACTUALIZAR (Servidor): ${response.statusCode}');
      print('RESPUESTA: $responseData');
      print('====================================');
      return false;
    }
  }

  // 4. ELIMINAR UNA PERSONA (Delete)
  Future<bool> deletePersona(int id) async {
    final String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/personas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
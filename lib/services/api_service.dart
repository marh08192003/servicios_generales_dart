import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_constants.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      authorizationHeader: 'Bearer $token', // Usando constante de header
      contentTypeHeader: contentTypeJson, // Usando constante de header
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Decodifica la respuesta JSON
    } else if (response.statusCode == 401) {
      print("Token expired. Please log in again.");
      await _authService.logout();
      throw Exception("Unauthorized");
    } else {
      print("Error: ${response.statusCode}, Body: ${response.body}");
      throw Exception("Error: ${response.statusCode}");
    }
  }

  // Método PUT (sin cambios)
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'), // Usando constante baseUrl
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      print("Token expired. Please log in again.");
      await _authService.logout();
      throw Exception("Unauthorized");
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_constants.dart';

class ApiService {
  final AuthService _authService = AuthService();

  AuthService get authService =>
      _authService; // Getter para acceder a AuthService

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      authorizationHeader: 'Bearer $token',
      contentTypeHeader: contentTypeJson,
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // Decodifica UTF-8
    } else if (response.statusCode == 401) {
      print("Token expired. Please log in again.");
      await _authService.logout();
      throw Exception("Unauthorized");
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
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

  Future<void> delete(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      print("Token expired. Please log in again.");
      await _authService.logout();
      throw Exception("Unauthorized");
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: utf8.encode(jsonEncode(body)), // Codificar datos en UTF-8
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(
          utf8.decode(response.bodyBytes)); // Decodifica respuesta UTF-8
    } else if (response.statusCode == 401) {
      print("Token expired. Please log in again.");
      await _authService.logout();
      throw Exception("Unauthorized");
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }
}

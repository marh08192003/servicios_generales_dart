import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_constants.dart';

class ApiService {
  final AuthService _authService = AuthService();

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

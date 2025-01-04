import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';
import '../config/api_constants.dart';

class AuthService {
  final _secureStorage = SecureStorageService();

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {'Content-Type': contentTypeJson},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 202) {
        // Decodificar respuesta en UTF-8
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Guardar token y datos relevantes del usuario
        if (data['jwt'] == null) {
          print("Error: 'jwt' is missing from the response.");
          return false;
        }

        await _secureStorage.write('jwt', data['jwt']);
        await _secureStorage.write('id', data['id'].toString());
        await _secureStorage.write('firstName', data['firstName']);
        await _secureStorage.write('email', data['email']);

        return true;
      } else {
        print("Login error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Login exception: $e");
      return false;
    }
  }

  // Registrar usuario
  Future<bool> register(Map<String, dynamic> user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: {'Content-Type': contentTypeJson},
        body: jsonEncode(user),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Register error: ${utf8.decode(response.bodyBytes)}");
        return false;
      }
    } catch (e) {
      print("Register exception: $e");
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _secureStorage.clear();
  }

  // Obtener token JWT
  Future<String?> getToken() async {
    return await _secureStorage.read('jwt');
  }

  // Obtener información del usuario almacenada
  Future<Map<String, String>> getUserInfo() async {
    final id = await _secureStorage.read('id') ?? '';
    final firstName = await _secureStorage.read('firstName') ?? '';
    final email = await _secureStorage.read('email') ?? '';

    return {
      'id': id,
      'firstName': firstName,
      'email': email,
    };
  }
}

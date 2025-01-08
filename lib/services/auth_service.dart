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

        // Verificar que los datos existan y asignar valores predeterminados si no
        final jwt = data['jwt'] ?? '';
        final id = data['id']?.toString() ?? '';
        final firstName = data['firstName'] ?? 'User';
        final email = data['email'] ?? '';
        final userType = data['userType'] ?? 'user'; // Cambiar 'userType' a 'userType'

        // Validar que 'jwt' no sea nulo o vacío
        if (jwt.isEmpty) {
          print("Error: 'jwt' is missing from the response.");
          return false;
        }

        // Guardar datos relevantes en almacenamiento seguro
        await _secureStorage.write('jwt', jwt);
        await _secureStorage.write('id', id);
        await _secureStorage.write('firstName', firstName);
        await _secureStorage.write('email', email);
        await _secureStorage.write('userType', userType);

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
    final userType = await _secureStorage.read('userType') ?? '';

    return {
      'id': id,
      'firstName': firstName,
      'email': email,
      'userType': userType,
    };
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'edit_user_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  late Future<Map<String, String>> _userInfo;

  @override
  void initState() {
    super.initState();
    _reloadUserInfo();
  }

  void _reloadUserInfo() {
    setState(() {
      _userInfo = _authService.getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _userInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading user info"));
          } else {
            final userInfo = snapshot.data!;
            final userId =
                int.parse(userInfo['id']!); // Convierte el ID a entero
            final userType =
                userInfo['userType'] ?? 'user'; // Valor por defecto

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${userInfo['firstName']}!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text("Email: ${userInfo['email']}"),
                  Text("Role: $userType"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Navegar a la vista de edición con el userId actual
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserScreen(userId: userId),
                        ),
                      );

                      if (result == true) {
                        _reloadUserInfo(); // Recargar información si hubo cambios
                      }
                    },
                    child: Text("Edit Profile"),
                  ),
                  if (userType.toLowerCase() ==
                      "administrador") // Valida "admin"
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/list-users');
                      },
                      child: Text("Manage Users"),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

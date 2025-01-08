import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

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
        future: _authService.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading user info"));
          } else {
            final userInfo = snapshot.data!;
            final userType = userInfo['userType'] ?? 'user'; // Valor por defecto

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
                  Text("userType: $userType"),
                  SizedBox(height: 20),
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

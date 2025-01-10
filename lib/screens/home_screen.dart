import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'create_incident_screen.dart';
import 'edit_user_screen.dart';
import 'list_physical_areas_screen.dart';
import 'register_screen.dart';
import 'create_physical_area_screen.dart'; // Importar la pantalla para crear áreas físicas

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
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading user info"));
          } else {
            final userInfo = snapshot.data!;
            final userId = int.parse(userInfo['id']!);
            final userType = userInfo['userType'] ?? 'user';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${userInfo['firstName']}!",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Email: ${userInfo['email']}"),
                  Text("Role: $userType"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserScreen(userId: userId),
                        ),
                      );
                      if (result == true) {
                        _reloadUserInfo();
                      }
                    },
                    child: const Text("Edit Profile"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListPhysicalAreasScreen(),
                        ),
                      );
                    },
                    child: const Text("View Physical Areas"),
                  ),
                  if (userType.toLowerCase() == "administrador") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/list-users');
                      },
                      child: const Text("Manage Users"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User registered successfully!")),
                          );
                        }
                      },
                      child: const Text("Create User"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePhysicalAreaScreen(),
                          ),
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Physical area created successfully!")),
                          );
                        }
                      },
                      child: const Text("Create Physical Area"),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateIncidentScreen(),
                        ),
                      );
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Incident created successfully!")),
                        );
                      }
                    },
                    child: const Text("Report Incident"),
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

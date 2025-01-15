import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import 'maintenances/list_assigned_maintenances_screen.dart';
import '../services/auth_service.dart';
import 'incidents/create_incident_screen.dart';
import 'users/edit_user_screen.dart';
import 'incidents/list_all_incidents_screen.dart';
import 'incidents/list_my_incidents_screen.dart';
import 'physical_areas/list_physical_areas_screen.dart';
import 'physical_areas/create_physical_area_screen.dart';
import 'maintenances/list_maintenances_screen.dart';
import 'maintenances/create_maintenance_screen.dart';
import 'maintenances/assign_users_to_maintenance_screen.dart';

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

  Future<void> _deleteAccount(int userId) async {
    try {
      await _authService.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
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
            final userType = userInfo['userType']?.toLowerCase() ?? 'user';

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
                  if (userType == "administrador") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/list-users');
                      },
                      child: const Text("Manage Users"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes
                              .register, // Uso de la ruta definida en AppRoutes
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListMaintenancesScreen(),
                          ),
                        );
                      },
                      child: const Text("Manage Maintenances"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateMaintenanceScreen(),
                          ),
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Maintenance created successfully!")),
                          );
                        }
                      },
                      child: const Text("Create Maintenance"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AssignUsersToMaintenanceScreen(),
                          ),
                        );
                      },
                      child: const Text("Assign Users to Maintenance"),
                    ),
                  ],
                  if (userType == "servicios_generales") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListAssignedMaintenancesScreen(), // Nueva pantalla
                          ),
                        );
                      },
                      child: const Text("View Assigned Maintenances"),
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListMyIncidentsScreen(),
                        ),
                      );
                    },
                    child: const Text("View My Incidents"),
                  ),
                  if (userType == "administrador" ||
                      userType == "servicios_generales") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListAllIncidentsScreen(),
                          ),
                        );
                      },
                      child: const Text("View All Incidents"),
                    ),
                  ],
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Account Deletion"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  "To confirm account deletion, type \"eliminar cuenta\"."),
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    // Add your state handling if necessary
                                  });
                                },
                                decoration: const InputDecoration(
                                    hintText: "Type \"eliminar cuenta\" here"),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text("Confirm"),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _deleteAccount(userId);
                      }
                    },
                    child: const Text("Delete Account"),
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

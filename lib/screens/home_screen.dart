import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../services/auth_service.dart';
import 'users/edit_user_screen.dart';

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
                      Navigator.pushNamed(context, AppRoutes.listPhysicalAreas);
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
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.createPhysicalArea,
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Physical area created successfully!"),
                            ),
                          );
                        }
                      },
                      child: const Text("Create Physical Area"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRoutes.listMaintenances);
                      },
                      child: const Text("Manage Maintenances"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.createMaintenance,
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
                        Navigator.pushNamed(
                            context, AppRoutes.assignUsersToMaintenance);
                      },
                      child: const Text("Assign Users to Maintenance"),
                    ),
                  ],
                  if (userType == "servicios_generales") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRoutes.listAssignedMaintenances);
                      },
                      child: const Text("View Assigned Maintenances"),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppRoutes.createIncident,
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
                      Navigator.pushNamed(context, AppRoutes.listMyIncidents);
                    },
                    child: const Text("View My Incidents"),
                  ),
                  if (userType == "administrador" ||
                      userType == "servicios_generales") ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRoutes.listAllIncidents);
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

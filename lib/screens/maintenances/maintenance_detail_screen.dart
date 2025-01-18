import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final int maintenanceId;

  const MaintenanceDetailScreen({Key? key, required this.maintenanceId})
      : super(key: key);

  @override
  _MaintenanceDetailScreenState createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _maintenanceDetails;
  late Future<List<dynamic>> _assignedUsers;

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceDetails();
    _fetchAssignedUsers();
  }

  void _fetchMaintenanceDetails() {
    setState(() {
      _maintenanceDetails = _apiService
          .get(
        getMaintenanceByIdEndpoint.replaceAll(
          "{id}",
          widget.maintenanceId.toString(),
        ),
      )
          .then((data) async {
        // Fetch the name of the physical area
        final physicalArea = await _apiService.get(
          getPhysicalAreaByIdEndpoint.replaceAll(
            "{id}",
            data['physicalAreaId'].toString(),
          ),
        );
        data['physicalAreaName'] = physicalArea['name'];
        return data;
      });
    });
  }

  void _fetchAssignedUsers() {
    setState(() {
      _assignedUsers = _apiService.get(listMaintenanceAssignmentsEndpoint).then(
        (data) async {
          List<dynamic> details = [];
          for (var assignment in (data as List<dynamic>).where((assignment) =>
              assignment['maintenanceId'] == widget.maintenanceId)) {
            // Fetch user details for each assigned user
            final user = await _apiService.get(
              getUserByIdEndpoint.replaceAll(
                "{id}",
                assignment['userId'].toString(),
              ),
            );
            details.add({
              "userId": user['id'],
              "userName": "${user['firstName']} ${user['lastName']}",
              "completed": assignment['completed'],
            });
          }
          return details;
        },
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Mantenimiento"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _maintenanceDetails,
        builder: (context, maintenanceSnapshot) {
          if (maintenanceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (maintenanceSnapshot.hasError) {
            return Center(
              child: Text(
                  "Error al cargar detalles: ${maintenanceSnapshot.error}"),
            );
          } else if (!maintenanceSnapshot.hasData) {
            return const Center(child: Text("Mantenimiento no encontrado."));
          } else {
            final maintenance = maintenanceSnapshot.data!;
            return FutureBuilder<List<dynamic>>(
              future: _assignedUsers,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return Center(
                    child: Text(
                        "Error al cargar usuarios asignados: ${userSnapshot.error}"),
                  );
                } else {
                  final assignedUsers = userSnapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card para detalles del mantenimiento
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Detalles del Mantenimiento",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  _buildDetailRow(
                                      "ID", maintenance['id'].toString()),
                                  _buildDetailRow(
                                      "Tipo", maintenance['maintenanceType']),
                                  _buildDetailRow("Área Física",
                                      maintenance['physicalAreaName']),
                                  _buildDetailRow(
                                      "Prioridad", maintenance['priority']),
                                  _buildDetailRow("Inicio",
                                      maintenance['startDate'].toString()),
                                  _buildDetailRow("Duración",
                                      "${maintenance['duration']} horas"),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Descripción:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(maintenance['description']),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Card para usuarios asignados
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Usuarios Asignados",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(),
                                  assignedUsers.isEmpty
                                      ? const Text(
                                          "No hay usuarios asignados a este mantenimiento.",
                                        )
                                      : Column(
                                          children: assignedUsers.map((user) {
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(
                                                "ID: ${user['userId']}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "Nombre: ${user['userName']}\nCompletado: ${user['completed'] ? "Sí" : "No"}"),
                                              leading: const Icon(
                                                Icons.person,
                                                color: Colors.green,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}

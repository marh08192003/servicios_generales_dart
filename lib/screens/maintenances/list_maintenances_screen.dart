import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import 'create_maintenance_screen.dart';

class ListMaintenancesScreen extends StatefulWidget {
  @override
  _ListMaintenancesScreenState createState() => _ListMaintenancesScreenState();
}

class _ListMaintenancesScreenState extends State<ListMaintenancesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _maintenances;

  @override
  void initState() {
    super.initState();
    _fetchMaintenances();
  }

  void _fetchMaintenances() {
    setState(() {
      _maintenances = _apiService
          .get(listMaintenancesEndpoint)
          .then((data) => data as List<dynamic>);
    });
  }

  Future<void> _deleteMaintenance(int id) async {
    try {
      await _apiService
          .delete(deleteMaintenanceEndpoint.replaceAll("{id}", id.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maintenance deleted successfully")),
      );
      _fetchMaintenances(); // Refresca el listado tras eliminar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting maintenance: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenances"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateMaintenanceScreen()),
              ).then((_) => _fetchMaintenances());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _maintenances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading maintenances: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No maintenances found."),
            );
          } else {
            final maintenances = snapshot.data!;
            return ListView.builder(
              itemCount: maintenances.length,
              itemBuilder: (context, index) {
                final maintenance = maintenances[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      "Maintenance ID: ${maintenance['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type: ${maintenance['maintenanceType']}"),
                        Text("Area: ${maintenance['physicalAreaId']}"),
                        Text("Priority: ${maintenance['priority']}"),
                        Text("Start: ${maintenance['startDate']}"),
                        Text("Duration: ${maintenance['duration']} hours"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editMaintenance,
                              arguments: maintenance['id'],
                            ).then((_) => _fetchMaintenances());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                    "Are you sure you want to delete this maintenance?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await _deleteMaintenance(maintenance['id']);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.maintenanceDetails,
                        arguments: maintenance['id'],
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

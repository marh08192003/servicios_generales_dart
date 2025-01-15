import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class ListAllIncidentsScreen extends StatefulWidget {
  @override
  _ListAllIncidentsScreenState createState() => _ListAllIncidentsScreenState();
}

class _ListAllIncidentsScreenState extends State<ListAllIncidentsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _incidents;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  void _fetchIncidents() {
    setState(() {
      _incidents = _apiService
          .get(listAllIncidentsEndpoint)
          .then((data) => data as List<dynamic>)
          .catchError((error) {
        if (error.toString().contains('403')) {
          throw Exception("Access denied: insufficient permissions");
        }
        throw error;
      });
    });
  }

  Future<void> _deleteIncident(int incidentId) async {
    try {
      await _apiService.delete(
        deleteIncidentEndpoint.replaceAll("{id}", incidentId.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incident deleted successfully!")),
      );
      _fetchIncidents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting incident: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Incidents"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _incidents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading incidents: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No incidents found."),
            );
          } else {
            final incidents = snapshot.data!;
            return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      "Incident ID: ${incident['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reported by User ID: ${incident['userId']}"),
                        Text("Physical Area ID: ${incident['physicalAreaId']}"),
                        Text("Description: ${incident['description']}"),
                        Text("Status: ${incident['status']}"),
                        Text(
                            "Reported on: ${incident['reportDate'] ?? 'Unknown'}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.incidentDetails,
                        arguments: incident[
                            'id'], // Pasa el ID del incidente como argumento
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editIncident,
                              arguments:
                                  incident['id'], // Pasa el ID del incidente
                            );
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
                                    "Are you sure you want to delete this incident?"),
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
                              await _deleteIncident(incident['id']);
                            }
                          },
                        ),
                      ],
                    ),
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

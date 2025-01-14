import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import 'edit_incident_screen.dart';
import 'incident_detail_screen.dart';

class ListMyIncidentsScreen extends StatefulWidget {
  @override
  _ListMyIncidentsScreenState createState() => _ListMyIncidentsScreenState();
}

class _ListMyIncidentsScreenState extends State<ListMyIncidentsScreen> {
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
          .get(listMyIncidentsEndpoint)
          .then((data) => data as List<dynamic>)
          .catchError((error) {
        if (error.toString().contains('404')) {
          return [];
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
        title: const Text("My Incidents"),
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
              child: Text("You have not reported any incidents."),
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
                        Text("Description: ${incident['description']}"),
                        Text("Status: ${incident['status']}"),
                        Text(
                            "Reported on: ${incident['reportDate'] ?? 'Unknown'}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncidentDetailScreen(
                            incidentId: incident['id'],
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditIncidentScreen(
                                  incidentId: incident['id'],
                                ),
                              ),
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

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class AssignedMaintenancesScreen extends StatefulWidget {
  @override
  _AssignedMaintenancesScreenState createState() =>
      _AssignedMaintenancesScreenState();
}

class _AssignedMaintenancesScreenState
    extends State<AssignedMaintenancesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _assignedMaintenances;

  @override
  void initState() {
    super.initState();
    _fetchAssignedMaintenances();
  }

  void _fetchAssignedMaintenances() {
    setState(() {
      _assignedMaintenances = _apiService
          .get(listAssignedMaintenancesEndpoint)
          .then((assignments) async {
        List<dynamic> details = [];
        for (var assignment in assignments) {
          final maintenanceDetails = await _apiService.get(
            getMaintenanceByIdEndpoint.replaceAll(
              "{id}",
              assignment['maintenanceId'].toString(),
            ),
          );

          // Fetch Physical Area Name
          final physicalAreaDetails = await _apiService.get(
            getPhysicalAreaByIdEndpoint.replaceAll(
              "{id}",
              maintenanceDetails['physicalAreaId'].toString(),
            ),
          );

          details.add({
            "assignmentId": assignment['id'],
            "completed": assignment['completed'],
            "physicalAreaName": physicalAreaDetails['name'],
            ...maintenanceDetails,
          });
        }
        return details;
      });
    });
  }

  Future<void> _markAsComplete(int assignmentId) async {
    try {
      await _apiService.put(
        editMaintenanceAssignmentEndpoint.replaceAll(
            "{id}", assignmentId.toString()),
        {"completed": true},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maintenance marked as complete.")),
      );
      _fetchAssignedMaintenances(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error marking maintenance as complete: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Maintenances"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _assignedMaintenances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading maintenances: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No assigned maintenances found."),
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
                      "Maintenance: ${maintenance['maintenanceType']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description: ${maintenance['description']}"),
                        Text(
                            "Physical Area: ${maintenance['physicalAreaName']}"),
                        Text("Start Date: ${maintenance['startDate']}"),
                        Text("Duration: ${maintenance['duration']} hours"),
                        Text("Priority: ${maintenance['priority']}"),
                        Text("Assignment ID: ${maintenance['assignmentId']}"),
                      ],
                    ),
                    trailing: maintenance['completed']
                        ? const Icon(Icons.check, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.check_box_outline_blank),
                            color: Colors.blue,
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Mark as Complete"),
                                  content: const Text(
                                      "Are you sure you want to mark this maintenance as complete?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await _markAsComplete(
                                    maintenance['assignmentId']);
                              }
                            },
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

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

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
          .then((data) => data as Map<String, dynamic>);
    });
  }

  void _fetchAssignedUsers() {
    setState(() {
      _assignedUsers = _apiService.get(listMaintenanceAssignmentsEndpoint).then(
        (data) {
          return (data as List<dynamic>)
              .where((assignment) =>
                  assignment['maintenanceId'] == widget.maintenanceId)
              .toList();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _maintenanceDetails,
        builder: (context, maintenanceSnapshot) {
          if (maintenanceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (maintenanceSnapshot.hasError) {
            return Center(
              child:
                  Text("Error loading details: ${maintenanceSnapshot.error}"),
            );
          } else if (!maintenanceSnapshot.hasData) {
            return const Center(child: Text("Maintenance not found."));
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
                        "Error loading assigned users: ${userSnapshot.error}"),
                  );
                } else {
                  final assignedUsers = userSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        Text(
                          "Maintenance ID: ${maintenance['id']}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text("Type: ${maintenance['maintenanceType']}"),
                        Text("Area: ${maintenance['physicalAreaId']}"),
                        Text("Priority: ${maintenance['priority']}"),
                        Text("Start: ${maintenance['startDate']}"),
                        Text("Duration: ${maintenance['duration']} hours"),
                        const SizedBox(height: 20),
                        Text(
                          "Description:",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(maintenance['description']),
                        const SizedBox(height: 20),
                        const Text(
                          "Assigned Users:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        assignedUsers.isEmpty
                            ? const Text(
                                "No users assigned to this maintenance.",
                              )
                            : Column(
                                children: assignedUsers.map((user) {
                                  return Card(
                                    child: ListTile(
                                      title: Text("User ID: ${user['userId']}"),
                                      subtitle: Text(
                                          "Completed: ${user['completed'] ? "Yes" : "No"}"),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
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

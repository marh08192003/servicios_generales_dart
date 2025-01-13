import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class AssignUsersToMaintenanceScreen extends StatefulWidget {
  @override
  _AssignUsersToMaintenanceScreenState createState() =>
      _AssignUsersToMaintenanceScreenState();
}

class _AssignUsersToMaintenanceScreenState
    extends State<AssignUsersToMaintenanceScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _maintenances = [];
  List<dynamic> _users = [];
  int? _selectedMaintenanceId;
  List<int> _selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final maintenances = await _apiService.get(listMaintenancesEndpoint);
      final users = await _apiService.get(listUsersEndpoint);

      setState(() {
        _maintenances = maintenances;
        _users = users
            .where((user) => user['userType'] == 'servicios_generales')
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    }
  }

  Future<void> _assignUsers() async {
    if (_selectedMaintenanceId == null || _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a maintenance and users.")),
      );
      return;
    }

    try {
      for (var userId in _selectedUserIds) {
        await _apiService.post(createMaintenanceAssignmentEndpoint, {
          'maintenanceId': _selectedMaintenanceId,
          'userId': userId,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Users assigned successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error assigning users: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Users to Maintenance"),
      ),
      body: _maintenances.isEmpty || _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Maintenance:"),
                  DropdownButton<int>(
                    value: _selectedMaintenanceId,
                    isExpanded: true,
                    items: _maintenances.map((maintenance) {
                      return DropdownMenuItem<int>(
                        value: maintenance['id'],
                        child: Text(
                          "${maintenance['maintenanceType']} - ${maintenance['description']}",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaintenanceId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Select Users:"),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return CheckboxListTile(
                          title:
                              Text("${user['firstName']} (ID: ${user['id']})"),
                          value: _selectedUserIds.contains(user['id']),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _selectedUserIds.add(user['id']);
                              } else {
                                _selectedUserIds.remove(user['id']);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _assignUsers,
                    child: const Text("Assign Users"),
                  ),
                ],
              ),
            ),
    );
  }
}

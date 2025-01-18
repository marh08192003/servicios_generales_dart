import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

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

  bool _isLoading = false;

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
        SnackBar(content: Text("Error al cargar los datos: $e")),
      );
    }
  }

  Future<void> _assignUsers() async {
    if (_selectedMaintenanceId == null || _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Seleccione un mantenimiento y usuarios.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (var userId in _selectedUserIds) {
        await _apiService.post(createMaintenanceAssignmentEndpoint, {
          'maintenanceId': _selectedMaintenanceId,
          'userId': userId,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuarios asignados exitosamente.")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (e.toString().contains("409")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error: Uno o más usuarios ya están asignados a este mantenimiento.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al asignar usuarios: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asignar Usuarios a Mantenimiento"),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _maintenances.isEmpty || _users.isEmpty
              ? const Center(child: Text("No hay datos disponibles."))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Seleccionar Mantenimiento:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
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
                          decoration: InputDecoration(
                            labelText: "Mantenimiento",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Seleccionar Usuarios:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          itemCount: _users.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: CheckboxListTile(
                                title: Text(
                                  "${user['firstName']} ${user['lastName']} (ID: ${user['id']})",
                                ),
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
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _assignUsers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Asignar Usuarios",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

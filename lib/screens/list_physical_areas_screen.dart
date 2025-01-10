import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';
import 'edit_physical_area_screen.dart';
import 'physical_area_detail_screen.dart';
import '../services/auth_service.dart';

class ListPhysicalAreasScreen extends StatefulWidget {
  @override
  _ListPhysicalAreasScreenState createState() =>
      _ListPhysicalAreasScreenState();
}

class _ListPhysicalAreasScreenState extends State<ListPhysicalAreasScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late Future<List<dynamic>> _physicalAreas;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _fetchPhysicalAreas();
    _loadUserType();
  }

  void _fetchPhysicalAreas() {
    setState(() {
      _physicalAreas = _apiService
          .get(listPhysicalAreasEndpoint)
          .then((data) => data as List<dynamic>);
    });
  }

  Future<void> _loadUserType() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      _userType = userInfo['userType']?.toLowerCase();
    });
  }

  Future<void> _deletePhysicalArea(int physicalAreaId) async {
    try {
      await _apiService.delete(
        deletePhysicalAreaEndpoint.replaceAll(
            "{id}", physicalAreaId.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Physical area deleted successfully")),
      );
      _fetchPhysicalAreas(); // Refrescar lista tras eliminar el área física
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting physical area: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Physical Areas"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _physicalAreas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading physical areas: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No physical areas found"),
            );
          } else {
            final areas = snapshot.data!;
            return ListView.builder(
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      area['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Location: ${area['location']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhysicalAreaDetailScreen(
                              physicalAreaId: area['id']),
                        ),
                      );
                    },
                    trailing: (_userType == 'administrador')
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditPhysicalAreaScreen(
                                              physicalAreaId: area['id']),
                                    ),
                                  );

                                  if (result == true) {
                                    _fetchPhysicalAreas(); // Refrescar lista tras editar
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Confirm Deletion"),
                                      content: const Text(
                                          "Are you sure you want to delete this physical area?"),
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
                                    await _deletePhysicalArea(area['id']);
                                  }
                                },
                              ),
                            ],
                          )
                        : null, // No mostrar acciones si no es administrador
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

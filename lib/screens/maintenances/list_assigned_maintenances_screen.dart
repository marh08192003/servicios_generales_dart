import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class ListAssignedMaintenancesScreen extends StatefulWidget {
  @override
  _ListAssignedMaintenancesScreenState createState() =>
      _ListAssignedMaintenancesScreenState();
}

class _ListAssignedMaintenancesScreenState
    extends State<ListAssignedMaintenancesScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _assignedMaintenances = [];
  int _currentPage = 0;
  final int _pageSize = 4;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedMaintenances();
  }

  Future<void> _fetchAssignedMaintenances({int page = 0}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.get(
        "$listAssignedMaintenancesEndpoint?page=$page&size=$_pageSize",
      );

      final fetchedAssignments = response as List<dynamic>;

      List<dynamic> details = [];
      for (var assignment in fetchedAssignments) {
        final maintenanceDetails = await _apiService.get(
          getMaintenanceByIdEndpoint.replaceAll(
            "{id}",
            assignment['maintenanceId'].toString(),
          ),
        );

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

      setState(() {
        _assignedMaintenances = details;
        _isLoading = false;
        _hasMore = details.length == _pageSize;
        _currentPage = page;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar asignaciones: $e")),
      );
    }
  }

  Future<void> _markAsComplete(int assignmentId) async {
    try {
      await _apiService.put(
        editMaintenanceAssignmentEndpoint.replaceAll(
            "{id}", assignmentId.toString()),
        {"completed": true},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mantenimiento marcado como completado.")),
      );
      _fetchAssignedMaintenances(page: _currentPage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al marcar como completado: $e")),
      );
    }
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0 && !_isLoading
                ? () {
                    _fetchAssignedMaintenances(page: _currentPage - 1);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Anterior"),
          ),
          ElevatedButton(
            onPressed: _hasMore && !_isLoading
                ? () {
                    _fetchAssignedMaintenances(page: _currentPage + 1);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Siguiente"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mantenimientos Asignados"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _assignedMaintenances.length,
                    itemBuilder: (context, index) {
                      final maintenance = _assignedMaintenances[index];
                      return GestureDetector(
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ID: ${maintenance['assignmentId']} || Tipo: ${maintenance['maintenanceType']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          "Área: ${maintenance['physicalAreaName']}"),
                                      Text(
                                          "Prioridad: ${maintenance['priority']}"),
                                      Text(
                                          "Inicio: ${maintenance['startDate']}"),
                                      Text(
                                          "Duración: ${maintenance['duration']} horas"),
                                    ],
                                  ),
                                ),
                                maintenance['completed']
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : IconButton(
                                        icon: const Icon(
                                            Icons.check_box_outline_blank,
                                            color: Colors.blue),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  "Marcar como completado"),
                                              content: const Text(
                                                  "¿Está seguro de marcar este mantenimiento como completado?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text("Cancelar"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text("Confirmar"),
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }
}

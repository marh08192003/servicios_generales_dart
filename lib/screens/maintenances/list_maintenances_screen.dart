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

  List<dynamic> _maintenances = [];
  int _currentPage = 0;
  final int _pageSize = 4;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMaintenances();
  }

  Future<void> _fetchMaintenances({int page = 0}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService
          .get("$listMaintenancesEndpoint?page=$page&size=$_pageSize");
      final fetchedMaintenances = response as List<dynamic>;

      setState(() {
        _maintenances = fetchedMaintenances;
        _isLoading = false;
        _hasMore = fetchedMaintenances.length == _pageSize;
        _currentPage = page;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar mantenimientos: $e")),
      );
    }
  }

  Future<void> _deleteMaintenance(int id) async {
    try {
      await _apiService.delete(
        deleteMaintenanceEndpoint.replaceAll("{id}", id.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mantenimiento eliminado exitosamente.")),
      );
      _fetchMaintenances(page: _currentPage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar el mantenimiento: $e")),
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
                    _fetchMaintenances(page: _currentPage - 1);
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
                    _fetchMaintenances(page: _currentPage + 1);
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
        title: const Text("Mantenimientos"),
        backgroundColor: Colors.green,
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
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _maintenances.length,
                    itemBuilder: (context, index) {
                      final maintenance = _maintenances[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.maintenanceDetails,
                            arguments: maintenance['id'],
                          );
                        },
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
                                        "ID: ${maintenance['id']} || Tipo: ${maintenance['maintenanceType']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          "Área: ${maintenance['physicalAreaId']}"),
                                      Text(
                                          "Prioridad: ${maintenance['priority']}"),
                                      Text(
                                          "Inicio: ${maintenance['startDate']}"),
                                      Text(
                                          "Duración estimada: ${maintenance['duration']} horas"),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final result =
                                            await Navigator.pushNamed(
                                          context,
                                          AppRoutes.editMaintenance,
                                          arguments: maintenance['id'],
                                        );
                                        if (result == true) {
                                          _fetchMaintenances(
                                              page: _currentPage);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                "Confirmar eliminación"),
                                            content: const Text(
                                                "¿Está seguro de eliminar este mantenimiento?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("Eliminar"),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await _deleteMaintenance(
                                              maintenance['id']);
                                        }
                                      },
                                    ),
                                  ],
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

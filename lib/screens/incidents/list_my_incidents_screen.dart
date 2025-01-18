import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class ListMyIncidentsScreen extends StatefulWidget {
  @override
  _ListMyIncidentsScreenState createState() => _ListMyIncidentsScreenState();
}

class _ListMyIncidentsScreenState extends State<ListMyIncidentsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _incidents = [];
  int _currentPage = 0;
  final int _pageSize = 4;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents({int page = 0}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService
          .get("$listMyIncidentsEndpoint?page=$page&size=$_pageSize");
      final fetchedIncidents = response as List<dynamic>;

      setState(() {
        if (page == 0) {
          _incidents = fetchedIncidents;
        } else {
          _incidents.addAll(fetchedIncidents);
        }
        _hasMore = fetchedIncidents.length == _pageSize;
        _currentPage = page;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar tus incidencias: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteIncident(int incidentId) async {
    try {
      await _apiService.delete(
        deleteIncidentEndpoint.replaceAll("{id}", incidentId.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incidencia eliminada con éxito.")),
      );
      _fetchIncidents(page: _currentPage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar la incidencia: $e")),
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
                ? () => _fetchIncidents(page: _currentPage - 1)
                : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Anterior"),
          ),
          ElevatedButton(
            onPressed: _hasMore && !_isLoading
                ? () => _fetchIncidents(page: _currentPage + 1)
                : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
        title: const Text("Mis Incidencias"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _currentPage == 0
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _incidents.length,
                    itemBuilder: (context, index) {
                      final incident = _incidents[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            "Incidencia #${incident['id']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Descripción: ${incident['description']}"),
                              Text("Estado: ${incident['status']}"),
                              Text(
                                  "Fecha: ${incident['reportDate'] ?? 'Desconocida'}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.editIncident,
                                    arguments: incident['id'],
                                  ).then((_) => _fetchIncidents());
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text("Confirmar Eliminación"),
                                      content: const Text(
                                          "¿Está seguro de que desea eliminar esta incidencia?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Eliminar"),
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
                  ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }
}

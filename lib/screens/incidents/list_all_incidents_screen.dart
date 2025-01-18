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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.get(
          "$listAllIncidentsEndpoint?page=$page&size=$_pageSize");
      final fetchedIncidents = response as List<dynamic>;

      setState(() {
        _incidents = fetchedIncidents; // Sobrescribe la lista actual
        _hasMore = fetchedIncidents.length == _pageSize; // Comprueba si hay más
        _currentPage = page; // Actualiza la página actual
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar incidencias: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text("Todas las Incidencias"),
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
                              Text("Usuario: ${incident['userId']}"),
                              Text(
                                  "Área Física: ${incident['physicalAreaId']}"),
                              Text("Descripción: ${incident['description']}"),
                              Text("Estado: ${incident['status']}"),
                              Text(
                                  "Fecha: ${incident['reportDate'] ?? 'Desconocida'}"),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.incidentDetails,
                              arguments: incident['id'],
                            );
                          },
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

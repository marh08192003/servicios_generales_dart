import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class ListPhysicalAreasScreen extends StatefulWidget {
  @override
  _ListPhysicalAreasScreenState createState() =>
      _ListPhysicalAreasScreenState();
}

class _ListPhysicalAreasScreenState extends State<ListPhysicalAreasScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _physicalAreas =
      []; // Lista de áreas físicas de la página actual
  int _currentPage = 0; // Página actual
  final int _pageSize = 4; // Tamaño de la página
  bool _isLoading = false; // Si está cargando datos
  bool _hasMore = true; // Si hay más datos disponibles

  @override
  void initState() {
    super.initState();
    _fetchPhysicalAreas();
  }

  Future<void> _fetchPhysicalAreas({int page = 0}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService
          .get("$listPhysicalAreasEndpoint?page=$page&size=$_pageSize");
      final fetchedAreas = response as List<dynamic>;

      setState(() {
        _physicalAreas = fetchedAreas;
        _isLoading = false;
        _hasMore = fetchedAreas.length ==
            _pageSize; // Si la página está completa, hay más datos
        _currentPage = page;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar las áreas físicas: $e")),
      );
    }
  }

  Future<void> _deletePhysicalArea(int physicalAreaId) async {
    try {
      await _apiService.delete(
        deletePhysicalAreaEndpoint.replaceAll(
            "{id}", physicalAreaId.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Área física eliminada exitosamente.")),
      );
      _fetchPhysicalAreas(page: _currentPage); // Refrescar la página actual
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar el área física: $e")),
      );
    }
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de "Anterior"
          ElevatedButton(
            onPressed: _currentPage > 0 && !_isLoading
                ? () {
                    _fetchPhysicalAreas(page: _currentPage - 1);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Anterior"),
          ),

          // Botón de "Siguiente"
          ElevatedButton(
            onPressed: _hasMore && !_isLoading
                ? () {
                    _fetchPhysicalAreas(page: _currentPage + 1);
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
        title: const Text("Áreas Físicas"),
        backgroundColor: Colors.green,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _physicalAreas.length,
                    itemBuilder: (context, index) {
                      final area = _physicalAreas[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.physicalAreaDetails,
                            arguments: area['id'],
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
                                        "ID: ${area['id']} || ${area['name']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Ubicación: ${area['location']}"),
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
                                          AppRoutes.editPhysicalArea,
                                          arguments: area['id'],
                                        );
                                        if (result == true) {
                                          _fetchPhysicalAreas(
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
                                                "¿Está seguro de eliminar esta área física?"),
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
                                          await _deletePhysicalArea(area['id']);
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
          _buildPaginationControls(), // Controles de paginación
        ],
      ),
    );
  }
}

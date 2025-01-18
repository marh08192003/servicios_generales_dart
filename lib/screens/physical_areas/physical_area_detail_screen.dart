import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class PhysicalAreaDetailScreen extends StatefulWidget {
  final int physicalAreaId;

  const PhysicalAreaDetailScreen({Key? key, required this.physicalAreaId})
      : super(key: key);

  @override
  _PhysicalAreaDetailScreenState createState() =>
      _PhysicalAreaDetailScreenState();
}

class _PhysicalAreaDetailScreenState extends State<PhysicalAreaDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _physicalAreaDetails;

  @override
  void initState() {
    super.initState();
    _physicalAreaDetails = _fetchPhysicalAreaDetails();
  }

  Future<Map<String, dynamic>> _fetchPhysicalAreaDetails() async {
    try {
      final response = await _apiService.get(
        getPhysicalAreaByIdEndpoint.replaceAll(
          "{id}",
          widget.physicalAreaId.toString(),
        ),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching physical area details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Área Física"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _physicalAreaDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar los detalles del área: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final area = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header del área física
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_city,
                              size: 80,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              area['name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "ID: ${area['id']}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detalles adicionales
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow("Ubicación:", area['location']),
                            const Divider(),
                            _buildDetailRow(
                                "Descripción:", area['description']),
                            const Divider(),
                            _buildDetailRow(
                              "Incidencias:",
                              area['incidentCount'].toString(),
                            ),
                            const Divider(),
                            _buildDetailRow(
                              "Estado:",
                              area['active'] == true ? "Activo" : "Inactivo",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón para regresar
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      child: const Text(
                        "Regresar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

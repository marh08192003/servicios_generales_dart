import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class IncidentDetailScreen extends StatefulWidget {
  final int incidentId;

  const IncidentDetailScreen({Key? key, required this.incidentId})
      : super(key: key);

  @override
  _IncidentDetailScreenState createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _incidentDetails;

  @override
  void initState() {
    super.initState();
    _fetchIncidentDetails();
  }

  void _fetchIncidentDetails() {
    setState(() {
      _incidentDetails = _apiService
          .get(
        getIncidentByIdEndpoint.replaceAll(
            "{id}", widget.incidentId.toString()),
      )
          .then((data) async {
        final incident = data as Map<String, dynamic>;
        final physicalAreaResponse = await _apiService.get(
          getPhysicalAreaByIdEndpoint.replaceAll(
              "{id}", incident['physicalAreaId'].toString()),
        );
        incident['physicalAreaName'] = physicalAreaResponse['name'];
        return incident;
      });
    });
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Incidencia"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _incidentDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar los detalles de la incidencia: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("No se encontró la incidencia."),
            );
          } else {
            final incident = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Incidencia #${incident['id']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      _buildDetailRow(
                        label: "Usuario",
                        value: "ID: ${incident['userId']}",
                      ),
                      _buildDetailRow(
                        label: "Área Física",
                        value: incident['physicalAreaName'],
                      ),
                      _buildDetailRow(
                        label: "Descripción",
                        value: incident['description'],
                      ),
                      _buildDetailRow(
                        label: "Estado",
                        value: incident['status'].toUpperCase(),
                      ),
                      _buildDetailRow(
                        label: "Fecha de Reporte",
                        value: incident['reportDate'],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

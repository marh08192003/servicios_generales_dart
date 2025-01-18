import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_constants.dart';

class CreateIncidentScreen extends StatefulWidget {
  @override
  _CreateIncidentScreenState createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedPhysicalAreaId;
  List<dynamic> _physicalAreas = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchPhysicalAreas();
  }

  Future<void> _loadUserId() async {
    final userInfo = await _authService.getUserInfo();
    setState(() {
      userIdController.text = userInfo['id']!;
    });
  }

  Future<void> _fetchPhysicalAreas() async {
    setState(() {
      isLoading = true;
    });
    try {
      final areas = await _apiService.get(listPhysicalAreasEndpoint);
      setState(() {
        _physicalAreas = areas as List<dynamic>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar las áreas físicas: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createIncident() async {
    if (selectedPhysicalAreaId == null || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, complete todos los campos.")),
      );
      return;
    }

    final incident = {
      'userId': int.parse(userIdController.text),
      'physicalAreaId': int.parse(selectedPhysicalAreaId!),
      'description': descriptionController.text,
      'reportDate': DateTime.now().toIso8601String(), // Formato ISO 8601
    };

    try {
      await _apiService.post(createIncidentEndpoint, incident);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incidencia reportada exitosamente.")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al reportar la incidencia: $e")),
      );
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportar Incidencia"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ingrese los detalles de la incidencia:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: "ID del Usuario",
                      controller: userIdController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: "Área Física",
                      value: selectedPhysicalAreaId,
                      items: _physicalAreas
                          .map((area) => DropdownMenuItem<String>(
                                value: area['id'].toString(),
                                child: Text(area['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPhysicalAreaId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: "Descripción",
                      controller: descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirmar Reporte"),
                              content: const Text(
                                  "¿Está seguro de que desea reportar esta incidencia?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Confirmar"),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await _createIncident();
                          }
                        },
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
                          "Reportar Incidencia",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
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

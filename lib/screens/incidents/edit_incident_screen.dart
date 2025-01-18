import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_constants.dart';

class EditIncidentScreen extends StatefulWidget {
  final int incidentId;

  const EditIncidentScreen({Key? key, required this.incidentId})
      : super(key: key);

  @override
  _EditIncidentScreenState createState() => _EditIncidentScreenState();
}

class _EditIncidentScreenState extends State<EditIncidentScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController reportDateController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  String? selectedStatus;
  String? selectedPhysicalAreaId;
  List<dynamic> physicalAreas = [];
  bool isLoading = false;
  bool canEditStatus = false;

  final List<String> statusOptions = ['pendiente', 'en progreso', 'resuelto'];

  @override
  void initState() {
    super.initState();
    _loadIncidentData();
    _fetchPhysicalAreas();
    _checkUserPermissions();
  }

  Future<void> _checkUserPermissions() async {
    final userInfo = await _authService.getUserInfo();
    final userType = userInfo['userType']?.toLowerCase() ?? '';
    setState(() {
      canEditStatus =
          (userType == 'administrador' || userType == 'servicios_generales');
    });
  }

  Future<void> _loadIncidentData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _apiService.get(
        getIncidentByIdEndpoint.replaceAll(
            "{id}", widget.incidentId.toString()),
      );

      setState(() {
        userIdController.text = response['userId'].toString();
        selectedPhysicalAreaId = response['physicalAreaId'].toString();
        descriptionController.text = response['description'];
        reportDateController.text = response['reportDate'];
        selectedStatus = response['status'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar los datos de la incidencia: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPhysicalAreas() async {
    try {
      final response = await _apiService.get(listPhysicalAreasEndpoint);
      setState(() {
        physicalAreas = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar las áreas físicas: $e")),
      );
    }
  }

  Future<void> _updateIncident() async {
    final updatedIncident = {
      'id': widget.incidentId,
      'userId': int.parse(userIdController.text),
      'physicalAreaId': int.parse(selectedPhysicalAreaId!),
      'description': descriptionController.text,
      'status': selectedStatus,
      'active': true,
    };

    try {
      await _apiService.put(
        editIncidentEndpoint.replaceAll("{id}", widget.incidentId.toString()),
        updatedIncident,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incidencia actualizada exitosamente.")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar la incidencia: $e")),
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
        title: const Text("Editar Incidencia"),
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
                      "Detalles de la incidencia:",
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
                      items: physicalAreas
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
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: "Fecha de Reporte",
                      controller: reportDateController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    if (canEditStatus)
                      _buildDropdownField(
                        label: "Estado",
                        value: selectedStatus,
                        items: statusOptions
                            .map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                      )
                    else
                      _buildFormField(
                        label: "Estado",
                        controller:
                            TextEditingController(text: selectedStatus),
                        readOnly: true,
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirmar Cambios"),
                              content: const Text(
                                  "¿Está seguro de que desea guardar estos cambios?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text("Confirmar"),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await _updateIncident();
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
                          "Guardar Cambios",
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

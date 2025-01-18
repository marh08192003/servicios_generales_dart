import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class EditPhysicalAreaScreen extends StatefulWidget {
  final int physicalAreaId;

  const EditPhysicalAreaScreen({Key? key, required this.physicalAreaId})
      : super(key: key);

  @override
  _EditPhysicalAreaScreenState createState() => _EditPhysicalAreaScreenState();
}

class _EditPhysicalAreaScreenState extends State<EditPhysicalAreaScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhysicalAreaData();
  }

  Future<void> _loadPhysicalAreaData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _apiService.get(
        getPhysicalAreaByIdEndpoint.replaceAll(
          "{id}",
          widget.physicalAreaId.toString(),
        ),
      );
      setState(() {
        nameController.text = response['name'];
        locationController.text = response['location'];
        descriptionController.text = response['description'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar los datos: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updatePhysicalArea() async {
    final updatedArea = {
      'name': nameController.text,
      'location': locationController.text,
      'description': descriptionController.text,
    };

    try {
      await _apiService.put(
        editPhysicalAreaEndpoint.replaceAll(
          "{id}",
          widget.physicalAreaId.toString(),
        ),
        updatedArea,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Área actualizada exitosamente")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar el área: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Área Física"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
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
                        const Center(
                          child: Icon(
                            Icons.edit_location,
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: nameController,
                          label: "Nombre del Área",
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: locationController,
                          label: "Ubicación",
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: descriptionController,
                          label: "Descripción",
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirmar cambios"),
                                  content: const Text(
                                      "¿Está seguro de guardar los cambios?"),
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
                                await _updatePhysicalArea();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Guardar Cambios",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
}

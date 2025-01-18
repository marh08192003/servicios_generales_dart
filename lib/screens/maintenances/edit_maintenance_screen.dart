import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class EditMaintenanceScreen extends StatefulWidget {
  final int maintenanceId;

  const EditMaintenanceScreen({Key? key, required this.maintenanceId})
      : super(key: key);

  @override
  _EditMaintenanceScreenState createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedMaintenanceType;
  int? _selectedPhysicalAreaId;
  DateTime? _selectedStartDate;
  String _priority = "media";

  List<dynamic> _physicalAreas = [];
  final List<String> _maintenanceTypes = [
    'Inspecciones',
    'Reparaciones',
    'Reemplazos de piezas',
    'Mantenimiento preventivo',
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceDetails();
    _fetchPhysicalAreas();
  }

  Future<void> _loadMaintenanceDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _apiService.get(
        getMaintenanceByIdEndpoint.replaceAll(
          "{id}",
          widget.maintenanceId.toString(),
        ),
      );

      setState(() {
        final backendType = response['maintenanceType'];
        _selectedMaintenanceType =
            _maintenanceTypes.contains(backendType) ? backendType : null;

        if (_selectedMaintenanceType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Maintenance type '${response['maintenanceType']}' is invalid."),
            ),
          );
        }

        _selectedPhysicalAreaId = response['physicalAreaId'];
        _durationController.text = response['duration'].toString();
        _descriptionController.text = response['description'];
        _priority = response['priority'];
        _selectedStartDate = DateTime.parse(response['startDate']);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading maintenance details: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPhysicalAreas() async {
    try {
      final areas = await _apiService.get(listPhysicalAreasEndpoint);
      setState(() {
        _physicalAreas = areas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading physical areas: $e")),
      );
    }
  }

  Future<void> _updateMaintenance() async {
    if (_formKey.currentState!.validate()) {
      final updatedMaintenance = {
        'maintenanceType': _selectedMaintenanceType,
        'physicalAreaId': _selectedPhysicalAreaId,
        'startDate': _selectedStartDate?.toIso8601String(),
        'duration': int.tryParse(_durationController.text),
        'description': _descriptionController.text,
        'priority': _priority,
      };

      try {
        await _apiService.put(
          editMaintenanceEndpoint.replaceAll(
            "{id}",
            widget.maintenanceId.toString(),
          ),
          updatedMaintenance,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mantenimiento actualizado exitosamente")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar el mantenimiento: $e")),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedStartDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedStartDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Widget _buildFormField({
    required String label,
    TextEditingController? controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    int? maxLines,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
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
        title: const Text("Editar Mantenimiento"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        label: "ID del Mantenimiento",
                        controller: TextEditingController(
                            text: widget.maintenanceId.toString()),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<String>(
                        label: "Tipo de Mantenimiento",
                        value: _selectedMaintenanceType,
                        items: _maintenanceTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedMaintenanceType = value),
                        validator: (value) =>
                            value == null ? "Seleccione un tipo" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<int>(
                        label: "Área Física",
                        value: _selectedPhysicalAreaId,
                        items: _physicalAreas
                            .map((area) => DropdownMenuItem<int>(
                                  value: area['id'] as int,
                                  child: Text(area['name'] as String),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedPhysicalAreaId = value),
                        validator: (value) =>
                            value == null ? "Seleccione un área" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: "Descripción",
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (value) =>
                            value!.isEmpty ? "Escriba una descripción" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: "Duración (horas)",
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? "Ingrese la duración" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: "Fecha de Inicio",
                        controller: TextEditingController(
                          text: _selectedStartDate?.toLocal().toString() ?? '',
                        ),
                        readOnly: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectStartDate,
                        ),
                        validator: (value) =>
                            _selectedStartDate == null ? "Seleccione fecha" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<String>(
                        label: "Prioridad",
                        value: _priority,
                        items: ['baja', 'media', 'alta']
                            .map((priority) => DropdownMenuItem<String>(
                                  value: priority,
                                  child: Text(priority.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _priority = value!),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateMaintenance,
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

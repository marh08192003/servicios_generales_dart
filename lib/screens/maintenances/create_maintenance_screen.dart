import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class CreateMaintenanceScreen extends StatefulWidget {
  @override
  _CreateMaintenanceScreenState createState() =>
      _CreateMaintenanceScreenState();
}

class _CreateMaintenanceScreenState extends State<CreateMaintenanceScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedMaintenanceType;
  int? _selectedPhysicalAreaId;
  DateTime? _selectedStartDate;

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
    _fetchPhysicalAreas();
  }

  Future<void> _fetchPhysicalAreas() async {
    setState(() {
      isLoading = true;
    });
    try {
      final areas = await _apiService.get(listPhysicalAreasEndpoint);
      setState(() {
        _physicalAreas = areas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar áreas físicas: $e")),
      );
    }
  }

  Future<void> _createMaintenance() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _apiService.post(createMaintenanceEndpoint, {
          'physicalAreaId': _selectedPhysicalAreaId,
          'maintenanceType': _selectedMaintenanceType,
          'startDate': _selectedStartDate?.toIso8601String(),
          'duration': int.tryParse(_durationController.text),
          'description': _descriptionController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mantenimiento creado exitosamente!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear mantenimiento: $e")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Mantenimiento"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _buildDropdownField<int>(
                      label: "Duración (horas)",
                      value: int.tryParse(_durationController.text),
                      items: List.generate(24, (index) => index + 1)
                          .map((value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _durationController.text = value.toString();
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? "Seleccione una duración" : null,
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
                      validator: (value) => _selectedStartDate == null
                          ? "Seleccione una fecha"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createMaintenance,
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
                        "Crear Mantenimiento",
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
    );
  }
}

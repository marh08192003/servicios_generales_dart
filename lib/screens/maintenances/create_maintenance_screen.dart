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

  @override
  void initState() {
    super.initState();
    _fetchPhysicalAreas();
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
          const SnackBar(content: Text("Maintenance created successfully!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating maintenance: $e")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Maintenance"),
      ),
      body: _physicalAreas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedMaintenanceType,
                      items: _maintenanceTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMaintenanceType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Maintenance Type",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a maintenance type.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedPhysicalAreaId,
                      items: _physicalAreas.map((area) {
                        return DropdownMenuItem<int>(
                          value: area['id'],
                          child: Text(area['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPhysicalAreaId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Physical Area",
                      ),
                      validator: (value) {
                        if (value == null) {
                          return "Please select a physical area.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please provide a description.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: int.tryParse(
                          _durationController.text), // Valor seleccionado
                      items:
                          List.generate(24, (index) => index + 1).map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()), // Muestra cada número
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _durationController.text = value.toString();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Duration (hours)",
                      ),
                      validator: (value) {
                        if (value == null) {
                          return "Please select a duration.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectStartDate,
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedStartDate != null
                            ? _selectedStartDate.toString()
                            : '',
                      ),
                      validator: (value) {
                        if (_selectedStartDate == null) {
                          return "Please select a start date.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _createMaintenance,
                      child: const Text("Create Maintenance"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

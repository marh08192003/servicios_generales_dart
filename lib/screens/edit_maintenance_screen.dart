import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

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
        // Validar si el tipo de mantenimiento devuelto por el backend coincide con los disponibles
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
          const SnackBar(content: Text("Maintenance updated successfully")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating maintenance: $e")),
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
        title: const Text("Edit Maintenance"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: widget.maintenanceId.toString(),
                      decoration: const InputDecoration(
                        labelText: "Maintenance ID",
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
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
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: "Duration (hours)",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please provide a duration.";
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
                    DropdownButtonFormField<String>(
                      value: _priority,
                      items: ['baja', 'media', 'alta'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _priority = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Priority"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Changes"),
                            content: const Text(
                                "Are you sure you want to save these changes?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await _updateMaintenance();
                        }
                      },
                      child: const Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

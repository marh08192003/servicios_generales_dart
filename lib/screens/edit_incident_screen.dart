import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_constants.dart';

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
        SnackBar(content: Text("Error loading incident data: $e")),
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
        SnackBar(content: Text("Error loading physical areas: $e")),
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
        SnackBar(content: Text("Incident updated successfully")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating incident: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Incident"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(labelText: "User ID"),
                    readOnly: true,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPhysicalAreaId,
                    items: physicalAreas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area['id'].toString(),
                        child: Text(area['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPhysicalAreaId = value;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: "Physical Area"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: reportDateController,
                    decoration: const InputDecoration(labelText: "Report Date"),
                    readOnly: true,
                  ),
                  if (canEditStatus)
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Status"),
                    )
                  else
                    TextField(
                      controller: TextEditingController(text: selectedStatus),
                      decoration: const InputDecoration(labelText: "Status"),
                      readOnly: true,
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
                        await _updateIncident();
                      }
                    },
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}

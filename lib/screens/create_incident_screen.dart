import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_constants.dart';

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
        SnackBar(content: Text("Error loading physical areas: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createIncident() async {
    final incident = {
      'userId': int.parse(userIdController.text),
      'physicalAreaId': int.parse(selectedPhysicalAreaId!),
      'description': descriptionController.text,
      'reportDate': DateTime.now().toIso8601String(), // Formato ISO 8601
    };

    try {
      await _apiService.post(createIncidentEndpoint, incident);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incident reported successfully!")),
      );
      Navigator.pop(context, true); // Indica que se creó correctamente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error reporting incident: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Incident"),
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
                    readOnly: true, // Campo no editable
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPhysicalAreaId,
                    items: _physicalAreas.map((area) {
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
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Report"),
                          content: const Text(
                              "Are you sure you want to report this incident?"),
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
                        await _createIncident();
                      }
                    },
                    child: const Text("Report Incident"),
                  ),
                ],
              ),
            ),
    );
  }
}

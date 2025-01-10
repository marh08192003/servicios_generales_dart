import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

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
            "{id}", widget.physicalAreaId.toString()),
      );

      setState(() {
        nameController.text = response['name'];
        locationController.text = response['location'];
        descriptionController.text = response['description'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading area data: $e")),
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
            "{id}", widget.physicalAreaId.toString()),
        updatedArea,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Area updated successfully")),
      );
      Navigator.pop(context, true); // Indica que hubo cambios
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating area: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Physical Area"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
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
                        await _updatePhysicalArea();
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

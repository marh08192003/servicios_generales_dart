import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class CreatePhysicalAreaScreen extends StatefulWidget {
  @override
  _CreatePhysicalAreaScreenState createState() =>
      _CreatePhysicalAreaScreenState();
}

class _CreatePhysicalAreaScreenState extends State<CreatePhysicalAreaScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> _createPhysicalArea() async {
    final newArea = {
      "name": nameController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "incident_count": 0, // Siempre será 0 al crear
      "active": true // Siempre será true al crear
    };

    setState(() {
      isLoading = true;
    });

    try {
      await _apiService.post(createPhysicalAreaEndpoint, newArea);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Physical Area created successfully!")),
      );
      Navigator.pop(context, true); // Indica que se creó correctamente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating physical area: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Physical Area"),
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3, // Campo para texto largo
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          locationController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Name and Location are required fields!",
                            ),
                          ),
                        );
                        return;
                      }
                      await _createPhysicalArea();
                    },
                    child: const Text("Create"),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';

class PhysicalAreaDetailScreen extends StatefulWidget {
  final int physicalAreaId;

  const PhysicalAreaDetailScreen({Key? key, required this.physicalAreaId})
      : super(key: key);

  @override
  _PhysicalAreaDetailScreenState createState() =>
      _PhysicalAreaDetailScreenState();
}

class _PhysicalAreaDetailScreenState extends State<PhysicalAreaDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _physicalAreaDetails;

  @override
  void initState() {
    super.initState();
    _physicalAreaDetails = _fetchPhysicalAreaDetails();
  }

  Future<Map<String, dynamic>> _fetchPhysicalAreaDetails() async {
    try {
      final response = await _apiService.get(
        getPhysicalAreaByIdEndpoint.replaceAll(
            "{id}", widget.physicalAreaId.toString()),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching physical area details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Physical Area Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _physicalAreaDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading physical area details: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final area = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    "Area ID: ${area['id']}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Name: ${area['name']}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Location: ${area['location']}"),
                  Text("Description: ${area['description']}"),
                  Text("Incident Count: ${area['incident_count']}"),
                  Text("Active: ${area['active'] == true ? 'Yes' : 'No'}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

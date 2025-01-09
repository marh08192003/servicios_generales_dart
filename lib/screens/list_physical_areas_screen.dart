import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class ListPhysicalAreasScreen extends StatefulWidget {
  @override
  _ListPhysicalAreasScreenState createState() =>
      _ListPhysicalAreasScreenState();
}

class _ListPhysicalAreasScreenState extends State<ListPhysicalAreasScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<dynamic>> _physicalAreas;

  @override
  void initState() {
    super.initState();
    _fetchPhysicalAreas();
  }

  void _fetchPhysicalAreas() {
    setState(() {
      _physicalAreas = _apiService
          .get(listPhysicalAreasEndpoint)
          .then((response) => response as List<dynamic>);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Physical Areas"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _physicalAreas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading physical areas: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No physical areas found"),
            );
          } else {
            final physicalAreas = snapshot.data!;
            return ListView.builder(
              itemCount: physicalAreas.length,
              itemBuilder: (context, index) {
                final area = physicalAreas[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      area['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(area['description'] ?? "No description"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class ListMyIncidentsScreen extends StatefulWidget {
  @override
  _ListMyIncidentsScreenState createState() => _ListMyIncidentsScreenState();
}

class _ListMyIncidentsScreenState extends State<ListMyIncidentsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _incidents;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  void _fetchIncidents() {
    setState(() {
      _incidents = _apiService
          .get(listMyIncidentsEndpoint)
          .then((data) => data as List<dynamic>)
          .catchError((error) {
        // Si el error es 404, retornamos una lista vacía
        if (error.toString().contains('404')) {
          return [];
        }
        throw error; // Si no es un error 404, lanzamos el error
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Incidents"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _incidents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading incidents: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("You have not reported any incidents."),
            );
          } else {
            final incidents = snapshot.data!;
            return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      "Incident ID: ${incident['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description: ${incident['description']}"),
                        Text("Status: ${incident['status']}"),
                        Text(
                            "Reported on: ${incident['reportDate'] ?? 'Unknown'}"),
                      ],
                    ),
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

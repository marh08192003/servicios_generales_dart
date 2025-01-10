import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class IncidentDetailScreen extends StatefulWidget {
  final int incidentId;

  const IncidentDetailScreen({Key? key, required this.incidentId})
      : super(key: key);

  @override
  _IncidentDetailScreenState createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _incidentDetails;

  @override
  void initState() {
    super.initState();
    _fetchIncidentDetails();
  }

  void _fetchIncidentDetails() {
    setState(() {
      _incidentDetails = _apiService
          .get(
            getIncidentByIdEndpoint.replaceAll(
                "{id}", widget.incidentId.toString()),
          )
          .then((data) => data as Map<String, dynamic>);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Incident Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _incidentDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading incident details: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("Incident not found."),
            );
          } else {
            final incident = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Incident ID: ${incident['id']}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Reported by User ID: ${incident['userId']}"),
                  Text("Physical Area ID: ${incident['physicalAreaId']}"),
                  Text("Description: ${incident['description']}"),
                  Text("Status: ${incident['status']}"),
                  Text("Reported on: ${incident['reportDate']}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

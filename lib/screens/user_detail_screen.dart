import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _userDetails;

  @override
  void initState() {
    super.initState();
    _userDetails = _fetchUserDetails();
  }

  Future<Map<String, dynamic>> _fetchUserDetails() async {
    try {
      final response = await _apiService.get(
        getUserByIdEndpoint.replaceAll("{id}", widget.userId.toString()),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading user details: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    "User ID: ${user['id']}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Name: ${user['firstName']} ${user['lastName']}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Email: ${user['institutionalEmail']}"),
                  Text("Phone: ${user['phone'] ?? 'N/A'}"),
                  Text("Role: ${user['userType']}"),
                  Text("Active: ${user['active'] == true ? 'Yes' : 'No'}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

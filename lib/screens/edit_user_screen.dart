import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;

  const EditUserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController userTypeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _apiService.get(
        getUserByIdEndpoint.replaceAll("{id}", widget.userId.toString()),
      );

      setState(() {
        idController.text = response['id'].toString();
        firstNameController.text = response['firstName'];
        lastNameController.text = response['lastName'];
        emailController.text = response['institutionalEmail'];
        phoneController.text = response['phone'] ?? '';
        userTypeController.text = response['userType'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading user data: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<void> _updateUser() async {
  final updatedUser = {
    'id': widget.userId,
    'firstName': firstNameController.text,
    'lastName': lastNameController.text,
    'institutionalEmail': emailController.text,
    'phone': phoneController.text,
    'userType': userTypeController.text,
    'password': passwordController.text.isEmpty ? null : passwordController.text,
    'active': true, // Siempre establecer true
  };

  try {
    await _apiService.put(
      editUserEndpoint.replaceAll("{id}", widget.userId.toString()),
      updatedUser,
    );

    // Actualizar información del usuario en SecureStorage
    await _apiService.authService.saveUserInfo(updatedUser); 

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User updated successfully")),
    );
    Navigator.pop(context, true); // Indica que hubo cambios
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error updating user: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit User"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(labelText: "User ID"),
                    readOnly: true, // Campo solo de lectura
                  ),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: "First Name"),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: "Last Name"),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                  ),
                  TextField(
                    controller: userTypeController,
                    decoration: InputDecoration(labelText: "Role"),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password (leave empty to keep current)",
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Confirm Changes"),
                          content: Text(
                              "Are you sure you want to save these changes?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Confirm"),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _updateUser();
                      }
                    },
                    child: Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}

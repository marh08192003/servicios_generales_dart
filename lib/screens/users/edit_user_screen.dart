import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_constants.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;

  const EditUserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedUserType;
  final List<String> userTypes = [
    'estudiante',
    'administrador',
    'profesor',
    'servicios_generales',
  ];

  bool isLoading = false;
  bool isEditingSelf =
      false; // Verifica si el usuario está editando su propio perfil

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
      final currentUserInfo = await _authService.getUserInfo();
      final currentUserId = int.parse(currentUserInfo['id']!);

      setState(() {
        isEditingSelf = (widget.userId == currentUserId);
      });

      final response = await _apiService.get(
        getUserByIdEndpoint.replaceAll("{id}", widget.userId.toString()),
      );

      setState(() {
        idController.text = response['id'].toString();
        firstNameController.text = response['firstName'];
        lastNameController.text = response['lastName'];
        emailController.text = response['institutionalEmail'];
        phoneController.text = response['phone'] ?? '';
        selectedUserType = response['userType'];
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
      'userType': selectedUserType,
      'password':
          passwordController.text.isEmpty ? null : passwordController.text,
      'active': true,
    };

    try {
      await _apiService.put(
        editUserEndpoint.replaceAll("{id}", widget.userId.toString()),
        updatedUser,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User updated successfully")),
      );
      Navigator.pop(context, true);
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
        title: const Text("Edit User"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: "User ID"),
                    readOnly: true,
                  ),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  if (!isEditingSelf)
                    DropdownButtonFormField<String>(
                      value: selectedUserType,
                      items: userTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: "User Type"),
                    )
                  else
                    TextField(
                      controller: TextEditingController(text: selectedUserType),
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "User Type"),
                    ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password (leave empty to keep current)",
                    ),
                    obscureText: true,
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
                        await _updateUser();
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

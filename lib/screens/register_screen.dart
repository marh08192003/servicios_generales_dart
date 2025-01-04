import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedUserType;

  final List<String> userTypes = [
    'estudiante',
    'administrador',
    'profesor',
    'servicios_generales'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: "ID (Cédula)"),
                keyboardType: TextInputType.number,
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
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: selectedUserType,
                items: userTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedUserType = value;
                },
                decoration: InputDecoration(labelText: "User Type"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Institutional Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final user = {
                    "id": int.tryParse(idController.text),
                    "firstName": firstNameController.text,
                    "lastName": lastNameController.text,
                    "phone": phoneController.text,
                    "userType": selectedUserType,
                    "institutionalEmail": emailController.text,
                    "password": passwordController.text,
                  };

                  final success = await _authService.register(user);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User registered successfully!")),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User registration failed!")),
                    );
                  }
                },
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

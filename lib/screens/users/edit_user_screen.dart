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
  bool isEditingSelf = false;

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
        SnackBar(content: Text("Error al cargar los datos: $e")),
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
        const SnackBar(content: Text("Usuario actualizado exitosamente")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar el usuario: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Usuario"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.edit,
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: idController,
                          label: "ID de Usuario",
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: firstNameController,
                          label: "Nombre",
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: lastNameController,
                          label: "Apellido",
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: emailController,
                          label: "Correo Electrónico",
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: phoneController,
                          label: "Teléfono",
                        ),
                        const SizedBox(height: 10),
                        if (!isEditingSelf)
                          _buildDropdownField(
                            value: selectedUserType,
                            items: userTypes,
                            label: "Tipo de Usuario",
                            onChanged: (value) {
                              setState(() {
                                selectedUserType = value!;
                              });
                            },
                          )
                        else
                          _buildTextField(
                            controller:
                                TextEditingController(text: selectedUserType),
                            label: "Tipo de Usuario",
                            readOnly: true,
                          ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: passwordController,
                          label: "Contraseña (opcional)",
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirmar cambios"),
                                  content: const Text(
                                      "¿Está seguro de guardar los cambios?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Confirmar"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await _updateUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Guardar Cambios",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}

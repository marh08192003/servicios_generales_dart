import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  late Future<Map<String, String>> _userInfo;

  @override
  void initState() {
    super.initState();
    _reloadUserInfo();
  }

  void _reloadUserInfo() {
    setState(() {
      _userInfo = _authService.getUserInfo();
    });
  }

  Future<void> _deleteAccount(int userId) async {
    try {
      await _authService.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta eliminada exitosamente.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar la cuenta: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú principal"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _userInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error al cargar la información del usuario"));
          } else {
            final userInfo = snapshot.data!;
            final userId = int.parse(userInfo['id']!);
            final userType = userInfo['userType']?.toLowerCase() ?? 'usuario';

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Contenedor superior con logo
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/uceva_logo_con_nombre.png',
                              width: 180,
                              height: 180,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Categorías como listas desplegables
                      if (userType == "administrador")
                        _buildExpansionTile(
                          "Manejo de usuarios",
                          [
                            _buildButton("Gestionar usuarios", () {
                              Navigator.pushNamed(context, '/list-users');
                            }),
                            _buildButton("Crear usuario", () async {
                              final result = await Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              );
                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Usuario registrado exitosamente!")),
                                );
                              }
                            }),
                          ],
                        ),
                      _buildExpansionTile(
                        "Áreas físicas",
                        [
                          _buildButton("Listar áreas físicas", () {
                            Navigator.pushNamed(
                                context, AppRoutes.listPhysicalAreas);
                          }),
                          if (userType == "administrador")
                            _buildButton("Crear área física", () async {
                              final result = await Navigator.pushNamed(
                                context,
                                AppRoutes.createPhysicalArea,
                              );
                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Área física creada exitosamente!")),
                                );
                              }
                            }),
                        ],
                      ),
                      if (userType == "administrador")
                        _buildExpansionTile(
                          "Mantenimiento",
                          [
                            _buildButton("Gestionar mantenimientos", () {
                              Navigator.pushNamed(
                                  context, AppRoutes.listMaintenances);
                            }),
                            _buildButton("Crear mantenimiento", () async {
                              final result = await Navigator.pushNamed(
                                context,
                                AppRoutes.createMaintenance,
                              );
                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Mantenimiento creado exitosamente!")),
                                );
                              }
                            }),
                            _buildButton("Asignar usuarios", () {
                              Navigator.pushNamed(
                                  context, AppRoutes.assignUsersToMaintenance);
                            }),
                          ],
                        ),
                      if (userType == "servicios_generales")
                        _buildExpansionTile(
                          "Mantenimiento asignado",
                          [
                            _buildButton("Ver mantenimientos asignados", () {
                              Navigator.pushNamed(
                                  context, AppRoutes.listAssignedMaintenances);
                            }),
                          ],
                        ),
                      _buildExpansionTile(
                        "Incidencias",
                        [
                          _buildButton("Reportar incidencia", () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.createIncident,
                            );
                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Incidencia reportada exitosamente!")),
                              );
                            }
                          }),
                          _buildButton("Mis incidencias", () {
                            Navigator.pushNamed(
                                context, AppRoutes.listMyIncidents);
                          }),
                          if (userType == "administrador" ||
                              userType == "servicios_generales")
                            _buildButton("Todas las incidencias", () {
                              Navigator.pushNamed(
                                  context, AppRoutes.listAllIncidents);
                            }),
                        ],
                      ),
                      _buildExpansionTile(
                        "Mi perfil",
                        [
                          _buildButton("Editar información", () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.editUser,
                              arguments:
                                  userId, // Asegúrate de pasar el userId aquí
                            );
                            if (result == true) {
                              _reloadUserInfo();
                            }
                          }),
                          _buildButton(
                            "Eliminar cuenta",
                            () async {
                              String inputText = '';
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                      "Confirmar eliminación de cuenta"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Escribe \"eliminar cuenta\" para confirmar.",
                                      ),
                                      TextField(
                                        onChanged: (value) {
                                          inputText = value;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: "Escribe aquí",
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (inputText.trim() ==
                                            "eliminar cuenta") {
                                          Navigator.pop(context, true);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Texto incorrecto. Escriba \"eliminar cuenta\" para confirmar.",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("Confirmar"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await _deleteAccount(userId);
                              }
                            },
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildExpansionTile(String title, List<Widget> buttons) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        children: buttons,
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../config/api_constants.dart';
import '../../services/api_service.dart';
import '../../config/app_routes.dart';

class ListUsersScreen extends StatefulWidget {
  @override
  _ListUsersScreenState createState() => _ListUsersScreenState();
}

class _ListUsersScreenState extends State<ListUsersScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _users = []; // Lista de usuarios de la página actual
  int _currentPage = 0; // Página actual
  final int _pageSize = 4; // Tamaño de la página
  bool _isLoading = false; // Si está cargando datos
  bool _hasMore = true; // Si hay más datos disponibles

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers({int page = 0}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService
          .get("$listUsersEndpoint?page=$page&size=$_pageSize");
      final fetchedUsers = response as List<dynamic>;

      setState(() {
        _users = fetchedUsers;
        _isLoading = false;
        _hasMore = fetchedUsers.length ==
            _pageSize; // Si la página está completa, hay más datos
        _currentPage = page;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar usuarios: $e")),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await _apiService
          .delete(deleteUserEndpoint.replaceAll("{id}", userId.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario eliminado exitosamente.")),
      );
      _fetchUsers(
          page: _currentPage); // Refrescar la página actual después de eliminar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar usuario: $e")),
      );
    }
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de "Anterior"
          ElevatedButton(
            onPressed: _currentPage > 0 && !_isLoading
                ? () {
                    _fetchUsers(page: _currentPage - 1);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Anterior"),
          ),

          // Botón de "Siguiente"
          ElevatedButton(
            onPressed: _hasMore && !_isLoading
                ? () {
                    _fetchUsers(page: _currentPage + 1);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Siguiente"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Usuarios"),
        backgroundColor: Colors.green,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.userDetails,
                            arguments: user['id'],
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "ID: ${user['id']} || ${user['firstName']} ${user['lastName']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          "Correo: ${user['institutionalEmail']}"),
                                      Text("Rol: ${user['userType']}"),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final result =
                                            await Navigator.pushNamed(
                                          context,
                                          AppRoutes.editUser,
                                          arguments: user['id'],
                                        );
                                        if (result == true) {
                                          _fetchUsers(page: _currentPage);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                "Confirmar eliminación"),
                                            content: const Text(
                                                "¿Está seguro de eliminar este usuario?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("Eliminar"),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await _deleteUser(user['id']);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildPaginationControls(), // Controles de paginación
        ],
      ),
    );
  }
}

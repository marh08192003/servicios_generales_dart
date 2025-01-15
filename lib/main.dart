import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/users/list_users_screen.dart';
import 'screens/physical_areas/list_physical_areas_screen.dart';
import 'screens/incidents/create_incident_screen.dart';
import 'screens/maintenances/list_maintenances_screen.dart';
import 'screens/maintenances/assign_users_to_maintenance_screen.dart';
import 'config/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Incidencias',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.home: (context) => HomeScreen(),
        AppRoutes.register: (context) => RegisterScreen(),
        AppRoutes.listUsers: (context) => ListUsersScreen(),
        AppRoutes.createIncident: (context) => CreateIncidentScreen(),
        AppRoutes.listPhysicalAreas: (context) => ListPhysicalAreasScreen(),
        AppRoutes.listMaintenances: (context) => ListMaintenancesScreen(),
        AppRoutes.assignUsersToMaintenance: (context) =>
            AssignUsersToMaintenanceScreen(),
      },
    );
  }
}

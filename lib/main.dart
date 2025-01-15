import 'package:flutter/material.dart';
import 'screens/incidents/edit_incident_screen.dart';
import 'screens/incidents/incident_detail_screen.dart';
import 'screens/incidents/list_all_incidents_screen.dart';
import 'screens/incidents/list_my_incidents_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/physical_areas/create_physical_area_screen.dart';
import 'screens/physical_areas/edit_physical_area_screen.dart';
import 'screens/physical_areas/physical_area_detail_screen.dart';
import 'screens/users/list_users_screen.dart';
import 'screens/users/edit_user_screen.dart';
import 'screens/users/user_detail_screen.dart';
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
        AppRoutes.editUser: (context) => EditUserScreen(
            userId: ModalRoute.of(context)!.settings.arguments as int),
        AppRoutes.userDetails: (context) => UserDetailScreen(
            userId: ModalRoute.of(context)!.settings.arguments as int),
        AppRoutes.listPhysicalAreas: (context) => ListPhysicalAreasScreen(),
        AppRoutes.createPhysicalArea: (context) => CreatePhysicalAreaScreen(),
        AppRoutes.editPhysicalArea: (context) => EditPhysicalAreaScreen(
            physicalAreaId: ModalRoute.of(context)!.settings.arguments as int),
        AppRoutes.physicalAreaDetails: (context) => PhysicalAreaDetailScreen(
            physicalAreaId: ModalRoute.of(context)!.settings.arguments as int),
        AppRoutes.listMaintenances: (context) => ListMaintenancesScreen(),
        AppRoutes.assignUsersToMaintenance: (context) =>
            AssignUsersToMaintenanceScreen(),
        AppRoutes.createIncident: (context) => CreateIncidentScreen(),
        AppRoutes.listMyIncidents: (context) => ListMyIncidentsScreen(),
        AppRoutes.listAllIncidents: (context) => ListAllIncidentsScreen(),
        AppRoutes.incidentDetails: (context) => IncidentDetailScreen(
            incidentId: ModalRoute.of(context)!.settings.arguments as int),
        AppRoutes.editIncident: (context) => EditIncidentScreen(
            incidentId: ModalRoute.of(context)!.settings.arguments as int),
      },
    );
  }
}

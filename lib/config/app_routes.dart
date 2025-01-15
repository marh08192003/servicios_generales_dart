class AppRoutes {
  // Login and Home
  static const String login = '/login';
  static const String home = '/home';

  // User Management
  static const String register = '/register';
  static const String listUsers = '/list-users';
  static const String editUser = '/edit-user';
  static const String userDetails = '/user-details';

  // Physical Areas
  static const String listPhysicalAreas = '/list-physical-areas';
  static const String createPhysicalArea = '/create-physical-area';
  static const String editPhysicalArea = '/edit-physical-area';
  static const String physicalAreaDetails = '/physical-area-details';

  // Incidents
  static const String createIncident = '/create-incident';
  static const String listMyIncidents = '/list-my-incidents';
  static const String listAllIncidents = '/list-all-incidents';
  static const String incidentDetails = '/incident-details';
  static const String editIncident = '/edit-incident';

  // Maintenances
  static const String listMaintenances = '/list-maintenances';
  static const String createMaintenance = '/create-maintenance';
  static const String assignUsersToMaintenance = '/assign-users-to-maintenance';
  static const String listAssignedMaintenances = '/list-assigned-maintenances';
  static const String maintenanceDetails = '/maintenance-details';
  static const String editMaintenance = '/edit-maintenance';
}

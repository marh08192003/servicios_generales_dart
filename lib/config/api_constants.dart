// Base URL de la API
const String baseUrl = "http://192.168.20.22:8080";

// Endpoints de autenticación
const String authBaseEndpoint = "/auth";
const String registerEndpoint = "$authBaseEndpoint/register";
const String loginEndpoint = "$authBaseEndpoint/login";

// Endpoints de usuarios
const String usersBaseEndpoint = "/api/v1/users";
const String listUsersEndpoint = "$usersBaseEndpoint/list";
const String getUserByIdEndpoint = "$usersBaseEndpoint/list/{id}"; // Reemplazar dinámicamente {id}
const String createUserEndpoint = "$usersBaseEndpoint/create";
const String editUserEndpoint = "$usersBaseEndpoint/edit/{id}"; // Reemplazar dinámicamente {id}
const String deleteUserEndpoint = "$usersBaseEndpoint/delete/{id}"; // Reemplazar dinámicamente {id}

// Endpoints de incidencias
const String incidentsBaseEndpoint = "/api/v1/incidents";
const String listIncidentsEndpoint = "$incidentsBaseEndpoint/list";
const String getIncidentByIdEndpoint = "$incidentsBaseEndpoint/list/{id}"; // Reemplazar dinámicamente {id}
const String listIncidentsByPhysicalAreaEndpoint = "$incidentsBaseEndpoint/list/area/{physicalAreaId}"; // Reemplazar {physicalAreaId}
const String createIncidentEndpoint = "$incidentsBaseEndpoint/create";
const String editIncidentEndpoint = "$incidentsBaseEndpoint/edit/{id}"; // Reemplazar dinámicamente {id}
const String deleteIncidentEndpoint = "$incidentsBaseEndpoint/delete/{id}"; // Reemplazar dinámicamente {id}

// Endpoints de áreas físicas
const String physicalAreasBaseEndpoint = "/api/v1/physical-areas";
const String listPhysicalAreasEndpoint = "$physicalAreasBaseEndpoint/list";
const String getPhysicalAreaByIdEndpoint = "$physicalAreasBaseEndpoint/list/{id}"; // Reemplazar dinámicamente {id}
const String createPhysicalAreaEndpoint = "$physicalAreasBaseEndpoint/create";
const String editPhysicalAreaEndpoint = "$physicalAreasBaseEndpoint/edit/{id}"; // Reemplazar dinámicamente {id}
const String deletePhysicalAreaEndpoint = "$physicalAreasBaseEndpoint/delete/{id}"; // Reemplazar dinámicamente {id}

// Endpoints de mantenimientos
const String maintenancesBaseEndpoint = "/api/v1/maintenances";
const String listMaintenancesEndpoint = "$maintenancesBaseEndpoint/list";
const String getMaintenanceByIdEndpoint = "$maintenancesBaseEndpoint/list/{id}"; // Reemplazar dinámicamente {id}
const String createMaintenanceEndpoint = "$maintenancesBaseEndpoint/create";
const String editMaintenanceEndpoint = "$maintenancesBaseEndpoint/edit/{id}"; // Reemplazar dinámicamente {id}
const String deleteMaintenanceEndpoint = "$maintenancesBaseEndpoint/delete/{id}"; // Reemplazar dinámicamente {id}

// Endpoints de asignaciones de mantenimiento
const String maintenanceAssignmentsBaseEndpoint = "/api/v1/maintenance-assignments";
const String listMaintenanceAssignmentsEndpoint = "$maintenanceAssignmentsBaseEndpoint/list";
const String getMaintenanceAssignmentByIdEndpoint = "$maintenanceAssignmentsBaseEndpoint/list/{id}"; // Reemplazar dinámicamente {id}
const String createMaintenanceAssignmentEndpoint = "$maintenanceAssignmentsBaseEndpoint/create";
const String editMaintenanceAssignmentEndpoint = "$maintenanceAssignmentsBaseEndpoint/edit/{id}"; // Reemplazar dinámicamente {id}
const String deleteMaintenanceAssignmentEndpoint = "$maintenanceAssignmentsBaseEndpoint/delete/{id}"; // Reemplazar dinámicamente {id}";

// Headers comunes
const String authorizationHeader = "Authorization";
const String contentTypeHeader = "Content-Type";
const String contentTypeJson = "application/json";

// Otros
const Duration apiTimeout = Duration(seconds: 30); // Tiempo de espera para las solicitudes

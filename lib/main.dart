import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/users/list_users_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Incidencias',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/list-users': (context) => ListUsersScreen(),
      },
    );
  }
}

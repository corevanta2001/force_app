import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/client/client_home.dart';
import 'screens/client/client_new_order.dart';
import 'screens/client/client_tracking.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_orders.dart';
import 'screens/admin/admin_vans.dart';
import 'screens/admin/admin_drivers.dart';
import 'screens/admin/admin_income.dart';
import 'screens/admin/admin_clients.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ForceApp());
}

class ForceApp extends StatelessWidget {
  const ForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FORCE',
      theme: ForceTheme.light,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/client_home': (context) => ClientHome(),
        '/client_dashboard': (context) => ClientHome(),
        '/client_new_order': (context) => ClientNewOrder(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/admin_orders': (context) => AdminOrders(),
        '/admin_vans': (context) => AdminVans(),
        '/admin_drivers': (context) => AdminDrivers(),
        '/admin_income': (context) => AdminIncome(),
        '/admin_clients': (context) => AdminClients(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/client_tracking') {
          final arguments = settings.arguments;

          if (arguments is String) {
            return MaterialPageRoute(
              builder: (_) => ClientTracking(orderId: arguments),
            );
          }
        }

        return null;
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'config/theme.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/client/client_home.dart';
import 'screens/client/client_new_order.dart';
import 'screens/client/client_tracking.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_orders.dart';
import 'screens/admin/admin_vans.dart';
import 'screens/admin/admin_drivers.dart';
import 'screens/admin/admin_income.dart';
import 'screens/admin/admin_clients.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Supabase
  try {
    await Supabase.initialize(
      url: 'https://qrqabogrnwtyhedhbiml.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFycWFib2dybnd0eWhlZGhiaW1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4NzkyNzEsImV4cCI6MjEwNTQ1NTI3MX0.WFryJq4wAJxhbHw2V_UI1Kjb8cR3nm0vo9ZUm_s-BZU',
    );

    debugPrint('Supabase initialized successfully.');
  } catch (e, stackTrace) {
    debugPrint('Supabase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('Flutter error: ${details.exception}');
  };

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
        '/home': (context) => HomeScreen(),
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

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Invalid order ID.'),
              ),
            ),
          );
        }

        return null;
      },
    );
  }
}
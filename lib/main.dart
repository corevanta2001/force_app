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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase OK');
  } catch (e) {
    print('Firebase Error: $e');
  }

  try {
    await Supabase.initialize(
      url: 'https://qrqabogrnwtyhedhbiml.supabase.co', 
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFycWFib2dybnd0eWhlZGhiaW1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4NzkyNzEsImV4cCI6MjEwNTQ1NTI3MX0.WFryJq4wAJxhbHw2V_UI1Kjb8cR3nm0vo9ZUm_s-BZU'
    );
    print('Supabase OK');
  } catch (e) {
    print('Supabase Error (ignoring for now): $e');
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, 
    theme: ForceTheme.light,
    initialRoute: '/home',
    routes: {
      '/home': (c) => HomeScreen(),
      '/login': (c) => LoginScreen(),
      '/register': (c) => RegisterScreen(),
      '/client_home': (c) => ClientHome(),
      '/client_dashboard': (c) => ClientHome(),
      '/client_new_order': (c) => ClientNewOrder(),
      '/admin_dashboard': (c) => AdminDashboard(),
      '/admin_orders': (c) => AdminOrders(),
      '/admin_vans': (c) => AdminVans(),
      '/admin_drivers': (c) => AdminDrivers(),
      '/admin_income': (c) => AdminIncome(),
      '/admin_clients': (c) => AdminClients(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/client_tracking') {
        final orderId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ClientTracking(orderId: orderId));
      }
      return null;
    },
  ));
}

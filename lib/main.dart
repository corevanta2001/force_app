import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';

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
    // Don't crash app if supabase keys are fake - still show UI
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, 
    theme: ForceTheme.light, 
    home: const LoginScreen()
  ));
}

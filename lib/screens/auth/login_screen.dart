import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if(emailCtrl.text.isEmpty || passCtrl.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill email and password")));
      return;
    }
    setState(()=> loading=true);
    try{
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      final doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
      final role = doc.data()?['role']??'client';
      if(mounted){
        if(role=='admin'){
          Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (r)=> false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/client_home', (r)=> false);
        }
      }
    } on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message??"Login failed")));
    }
    setState(()=> loading=false);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F172A), Color(0xFF1E293B)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 20),
              IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=> Navigator.pushNamedAndRemoveUntil(context, '/home', (r)=> false)),
              SizedBox(height: 10),
              Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("Login to Force Delivery", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
                  SizedBox(height: 14),
                  TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)), obscureText: true),
                  SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)), onPressed: loading? null : login, child: loading? CircularProgressIndicator(color: Colors.white) : Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                  SizedBox(height: 12),
                  TextButton(onPressed: ()=> Navigator.pushNamed(context, '/register'), child: Text("No account? Register with ID & Cell")),
                  TextButton(onPressed: ()=> Navigator.pushNamedAndRemoveUntil(context, '/home', (r)=> false), child: Text("Back to Home Screen")),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

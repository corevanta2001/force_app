import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../client/client_home.dart';
import '../admin/admin_dashboard.dart';
import 'register_screen.dart';
class LoginScreen extends StatefulWidget{ const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginScreenState();}
class _LoginScreenState extends State<LoginScreen>{
  final emailC=TextEditingController(text:"user@gmail.com"); final passC=TextEditingController(text:""); final _auth=AuthService(); bool loading=false;
  @override Widget build(BuildContext context)=>Scaffold(body:Padding(padding:EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    Icon(Icons.local_shipping,size:80,color:Color(0xFFFF6B00)), Text("FORCE DELIVERY",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)), SizedBox(height:30),
    TextField(controller:emailC,decoration:InputDecoration(labelText:"Email",prefixIcon:Icon(Icons.email))), SizedBox(height:12),
    TextField(controller:passC,obscureText:true,decoration:InputDecoration(labelText:"Password",prefixIcon:Icon(Icons.lock))), SizedBox(height:20),
    loading?CircularProgressIndicator():SizedBox(width:double.infinity,child:ElevatedButton(onPressed:()async{ setState(()=>loading=true); try{ final user=await _auth.login(emailC.text.trim(),passC.text.trim()); if(_auth.isAdmin(user)){ Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>AdminDashboard())); } else { Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ClientHome())); } } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString()))); } setState(()=>loading=false); },child:Text("LOGIN"))),
    TextButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>RegisterScreen())),child:Text("Create Account"))
  ])));
}
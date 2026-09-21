import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
class RegisterScreen extends StatefulWidget{ @override State<RegisterScreen> createState()=>_RegisterScreenState();}
class _RegisterScreenState extends State<RegisterScreen>{
  final nameC=TextEditingController(); final emailC=TextEditingController(); final passC=TextEditingController(); final phoneC=TextEditingController(); bool loading=false;
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text("Create Account")),body:Padding(padding:EdgeInsets.all(20),child:Column(children:[
    TextField(controller:nameC,decoration:InputDecoration(labelText:"Full Name",prefixIcon:Icon(Icons.person))), SizedBox(height:12),
    TextField(controller:emailC,decoration:InputDecoration(labelText:"Email",prefixIcon:Icon(Icons.email))), SizedBox(height:12),
    TextField(controller:phoneC,decoration:InputDecoration(labelText:"EcoCash Number",prefixIcon:Icon(Icons.phone))), SizedBox(height:12),
    TextField(controller:passC,decoration:InputDecoration(labelText:"Password",prefixIcon:Icon(Icons.lock)),obscureText:true), SizedBox(height:20),
    loading?CircularProgressIndicator():SizedBox(width:double.infinity,child:ElevatedButton(onPressed:()async{ setState(()=>loading=true); await AuthService().register(nameC.text,emailC.text,passC.text,phoneC.text); setState(()=>loading=false); Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>LoginScreen())); },child:Text("REGISTER")))
  ])));
}
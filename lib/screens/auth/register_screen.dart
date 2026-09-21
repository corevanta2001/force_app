import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final cellCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String role = 'client';
  bool loading = false;
  String? cellError;
  String? idError;

  bool validateCell(String cell){
    cell = cell.trim();
    if(cell.startsWith('+263')){
      setState(()=> cellError = "Don't use +263. Use 0... e.g. 0771234567");
      return false;
    }
    if(!RegExp(r'^0[0-9]{9}$').hasMatch(cell)){
      setState(()=> cellError = "Invalid. Must be 10 digits starting with 0 e.g. 0771234567");
      return false;
    }
    setState(()=> cellError=null);
    return true;
  }

  Future<bool> checkCellUsed(String cell) async {
    final q = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: cell.trim()).limit(1).get();
    if(q.docs.isNotEmpty){
      setState(()=> cellError = "Cell number already used by another account!");
      return true;
    }
    return false;
  }

  Future<bool> checkIdUsed(String idNum) async {
    final q = await FirebaseFirestore.instance.collection('users').where('idNumber', isEqualTo: idNum.trim()).limit(1).get();
    if(q.docs.isNotEmpty){
      setState(()=> idError = "ID number already used!");
      return true;
    }
    return false;
  }

  Future<void> register() async {
    if(nameCtrl.text.isEmpty || idCtrl.text.isEmpty || cellCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill all fields")));
      return;
    }
    if(!validateCell(cellCtrl.text)) return;
    setState(()=> loading=true);
    try{
      bool cellUsed = await checkCellUsed(cellCtrl.text);
      if(cellUsed){ setState(()=> loading=false); return; }
      bool idUsed = await checkIdUsed(idCtrl.text);
      if(idUsed){ setState(()=> loading=false); return; }

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name': nameCtrl.text.trim(),
        'idNumber': idCtrl.text.trim(),
        'phone': cellCtrl.text.trim(),
        'cellNumber': cellCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'role': role,
        'totalOrders': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account created!")));
        if(role=='admin'){
          Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (r)=> false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/client_home', (r)=> false);
        }
      }
    } on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message??"Error")));
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
    }
    setState(()=> loading=false);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Create Account"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("ID Number and Cell Required", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Full Name *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
          SizedBox(height: 12),
          TextField(controller: idCtrl, decoration: InputDecoration(labelText: "ID Number *", hintText: "e.g. 63-1234567-A-12", border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge), errorText: idError), onChanged: (v)=> setState(()=> idError=null)),
          SizedBox(height: 12),
          TextField(controller: cellCtrl, decoration: InputDecoration(labelText: "Cell Number *", hintText: "0771234567 (NOT +263)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone), errorText: cellError), keyboardType: TextInputType.phone, onChanged: (v){ if(cellError!=null) validateCell(v); }),
          if(cellError==null) Padding(padding: EdgeInsets.only(top: 4, left: 12), child: Text("Must start with 0, 10 digits, no +263", style: TextStyle(fontSize: 10, color: Colors.grey))),
          SizedBox(height: 12),
          TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
          SizedBox(height: 12),
          TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)), obscureText: true),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(value: role, decoration: InputDecoration(labelText: "Role", border: OutlineInputBorder()), items: [DropdownMenuItem(value: 'client', child: Text("Client")), DropdownMenuItem(value: 'admin', child: Text("Admin"))], onChanged: (v)=> setState(()=> role=v!)),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)), onPressed: loading? null : register, child: loading? CircularProgressIndicator(color: Colors.white) : Text("Register - Check Cell Uniqueness", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          SizedBox(height: 12),
          Center(child: TextButton(onPressed: ()=> Navigator.pushNamed(context, '/login'), child: Text("Already have account? Login"))),
        ]),
      ),
    );
  }
}

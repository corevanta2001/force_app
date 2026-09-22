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
    try {
      final q = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: cell.trim()).limit(1).get();
      if(q.docs.isNotEmpty){
        setState(()=> cellError = "Cell number already used by another account!");
        return true;
      }
    } catch (e) {
      debugPrint("checkCellUsed error: $e");
    }
    return false;
  }

  Future<bool> checkIdUsed(String idNum) async {
    try {
      final q = await FirebaseFirestore.instance.collection('users').where('idNumber', isEqualTo: idNum.trim()).limit(1).get();
      if(q.docs.isNotEmpty){
        setState(()=> idError = "ID number already used!");
        return true;
      }
    } catch (e) {
      debugPrint("checkIdUsed error: $e");
    }
    return false;
  }

  Future<void> register() async {
    if(nameCtrl.text.isEmpty || idCtrl.text.isEmpty || cellCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fill all fields")));
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
        'role': 'client',
        'totalOrders': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created!")));
        Navigator.pushNamedAndRemoveUntil(context, '/client_home', (r)=> false);
      }
    } on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message??"Error")));
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
    }
    if(mounted) setState(()=> loading=false);
  }

  @override
  void dispose(){
    nameCtrl.dispose(); idCtrl.dispose(); cellCtrl.dispose(); emailCtrl.dispose(); passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account"), backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("ID Number and Cell Required", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 12),
          TextField(controller: idCtrl, decoration: InputDecoration(labelText: "ID Number *", hintText: "e.g. 63-1234567-A-12", border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.badge), errorText: idError), onChanged: (v)=> setState(()=> idError=null)),
          const SizedBox(height: 12),
          TextField(controller: cellCtrl, decoration: InputDecoration(labelText: "Cell Number *", hintText: "0771234567 (NOT +263)", border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.phone), errorText: cellError), keyboardType: TextInputType.phone, onChanged: (v){ if(cellError!=null) validateCell(v); }),
          if(cellError==null) const Padding(padding: EdgeInsets.only(top: 4, left: 12), child: Text("Must start with 0, 10 digits, no +263", style: TextStyle(fontSize: 10, color: Colors.grey))),
          const SizedBox(height: 12),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
          const SizedBox(height: 12),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)), obscureText: true),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)), onPressed: loading? null : register, child: loading? const CircularProgressIndicator(color: Colors.white) : const Text("Register - Check Cell Uniqueness", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: ()=> Navigator.pushNamed(context, '/login'), child: const Text("Already have account? Login"))),
        ]),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  static const adminEmail = "puremundex@gmail.com";
  Future<User?> login(String email,String pass) async { final c=await _auth.signInWithEmailAndPassword(email:email,password:pass); return c.user; }
  Future<User?> register(String name,String email,String pass,String phone) async {
    final cred=await _auth.createUserWithEmailAndPassword(email:email,password:pass);
    await cred.user!.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({'uid':cred.user!.uid,'name':name,'email':email,'phone':phone,'role':email==adminEmail?'admin':'client','avatarUrl':'','createdAt':FieldValue.serverTimestamp(),'totalOrders':0});
    return cred.user;
  }
  bool isAdmin(User? u)=>u?.email==adminEmail;
  User? get currentUser=>_auth.currentUser;
  Future<void> logout()=>_auth.signOut();
}
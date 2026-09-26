import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [Icon(Icons.logout, color: Color(0xFF0F172A)), SizedBox(width: 8), Text("Log out?")]),
        content: Text("Are you sure you want to log out to the home screen?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text("Log Out"),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(title: Text("My Profile"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (c, s) {
          var d = s.data?.data() as Map<String, dynamic>?;
          return ListView(padding: EdgeInsets.all(0), children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 48, color: Color(0xFF0F172A)),
                  ),
                ),
                SizedBox(height: 12),
                Text(d?['name'] ?? 'Client', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text(email ?? d?['email'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text("ID: ${d?['idNumber'] ?? 'Not set'}  •  Cell: ${d?['phone'] ?? d?['cellNumber'] ?? ''}",
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
                SizedBox(height: 10),
                Chip(
                  label: Text("${d?['totalOrders'] ?? 0} orders", style: TextStyle(fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.white,
                  avatar: Icon(Icons.shopping_bag, size: 16, color: Color(0xFF0F172A)),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    ListTile(
                      leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.badge, color: Color(0xFF1E3A8A))),
                      title: Text("ID Number", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(d?['idNumber'] ?? 'Not set', style: TextStyle(fontSize: 14)),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.phone, color: Colors.green.shade700)),
                      title: Text("Cell (0... no +263)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(d?['phone'] ?? d?['cellNumber'] ?? 'Not set', style: TextStyle(fontSize: 14)),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.email, color: Colors.orange.shade700)),
                      title: Text("Email", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(d?['email'] ?? email ?? '', style: TextStyle(fontSize: 14)),
                    ),
                  ]),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: Icon(Icons.logout_rounded),
                    label: Text("Logout to Home Screen", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
                SizedBox(height: 16),
                Center(child: Text("Force App - Secured @FORCE", style: TextStyle(fontSize: 11, color: Colors.grey))),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}
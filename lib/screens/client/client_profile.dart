import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      appBar: AppBar(title: Text("My Profile"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (c, s) {
          var d = s.data?.data() as Map<String, dynamic>?;
          int totalOrders = (d?['totalOrders'] ?? 0);
          return ListView(padding: EdgeInsets.all(16), children: [
            Center(child: Column(children: [
              CircleAvatar(radius: 45, backgroundColor: Color(0xFF0F172A), child: Icon(Icons.person, size: 45, color: Colors.white)),
              SizedBox(height: 12),
              Text(d?['name'] ?? 'Client', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(email ?? d?['email'] ?? '', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Chip(label: Text("$totalOrders orders"), backgroundColor: Colors.grey.shade200),
            ])),
            SizedBox(height: 24),
            Card(child: Column(children: [
              ListTile(leading: Icon(Icons.phone), title: Text("Phone"), subtitle: Text(d?['phone'] ?? 'Not set'), trailing: Icon(Icons.edit, size: 18)),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.email), title: Text("Email"), subtitle: Text(d?['email'] ?? email ?? '')),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.badge), title: Text("Role"), subtitle: Text(d?['role'] ?? 'client')),
            ])),
            SizedBox(height: 16),
            Card(child: Column(children: [
              ListTile(leading: Icon(Icons.help_outline), title: Text("Help & Support"), trailing: Icon(Icons.chevron_right), onTap: () {}),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text("Privacy Policy"), trailing: Icon(Icons.chevron_right), onTap: () {}),
            ])),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                icon: Icon(Icons.logout),
                label: Text("Logout"),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                },
              ),
            ),
            SizedBox(height: 8),
            Center(child: Text("Force App v1.0.0", style: TextStyle(fontSize: 11, color: Colors.grey))),
          ]);
        },
      ),
    );
  }
}

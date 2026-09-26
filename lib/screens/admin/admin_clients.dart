import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminClients extends StatelessWidget {
  const AdminClients({super.key});

  void _showClientDetails(BuildContext context, Map<String, dynamic> d) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(d['name'] ?? d['email'] ?? 'Client Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Name: ${d['name'] ?? 'N/A'}"),
              SizedBox(height: 8),
              Text("Email: ${d['email'] ?? 'N/A'}"),
              SizedBox(height: 8),
              Text("Phone: ${d['phone'] ?? d['phoneNumber'] ?? 'N/A'}"),
              SizedBox(height: 8),
              Text("ID Number: ${d['nationalId'] ?? d['idNumber'] ?? d['id'] ?? 'N/A'}"),
              SizedBox(height: 8),
              Text("Address: ${d['address'] ?? 'N/A'}"),
              if (d['idPhotoUrl'] != null) ...[
                SizedBox(height: 8),
                Text("ID Document:"),
                SizedBox(height: 4),
                Image.network(d['idPhotoUrl'], height: 150, errorBuilder: (_, __, ___) => Text('Could not load ID image')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clients"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'client').snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: s.data!.docs.length,
            itemBuilder: (c, i) {
              var d = s.data!.docs[i].data() as Map<String, dynamic>;
              final phone = d['phone'] ?? d['phoneNumber'] ?? 'N/A';
              final idNum = d['nationalId'] ?? d['idNumber'] ?? d['id'] ?? 'N/A';
              return Card(child: ListTile(
                title: Text(d['name'] ?? d['email'] ?? 'Client'),
                subtitle: Text("${d['email'] ?? ''}\nPhone: $phone | ID: $idNum"),
                isThreeLine: true,
                trailing: Icon(Icons.person_outline),
                onTap: () => _showClientDetails(context, d),
              ));
            },
          );
        },
      ),
    );
  }
}
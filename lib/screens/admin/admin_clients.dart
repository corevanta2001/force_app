import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminClients extends StatelessWidget {
  const AdminClients({super.key});
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
              return Card(child: ListTile(
                title: Text(d['name']??d['email']??'Client'),
                subtitle: Text(d['email']??''),
                trailing: Icon(Icons.person_outline),
              ));
            },
          );
        },
      ),
    );
  }
}

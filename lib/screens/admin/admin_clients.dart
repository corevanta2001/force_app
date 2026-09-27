import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminClients extends StatelessWidget {
  const AdminClients({super.key});

  String _initials(String name) {
    var p = name.trim().split(' ');
    if (p.isEmpty || p[0].isEmpty) return '?';
    if (p.length == 1) return p[0][0].toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  void _showClientDetails(BuildContext context, Map<String, dynamic> d) {
    final phone = d['phone']?? d['phoneNumber']?? 'N/A';
    final idNum = d['nationalId']?? d['idNumber']?? d['id']?? 'N/A';
    showDialog(
      context: context,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                  child: Center(child: Text(_initials(d['name']?? d['email']?? 'C'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
                ),
                SizedBox(height: 10),
                Text(d['name']?? 'Client', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(d['email']?? '', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [
                _detailTile(Icons.phone_rounded, "Phone", phone.toString(), Colors.green),
                _detailTile(Icons.badge_rounded, "ID Number", idNum.toString(), Colors.purple),
                _detailTile(Icons.location_on_rounded, "Address", (d['address']?? 'N/A').toString(), Colors.orange),
                _detailTile(Icons.email_rounded, "Email", (d['email']?? 'N/A').toString(), Colors.blue),
                if (d['idPhotoUrl']!= null)...[
                  SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: Text("ID Document", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(d['idPhotoUrl'], height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 80, color: Colors.grey.shade100, child: Center(child: Text('Could not load ID image', style: TextStyle(fontSize: 11, color: Colors.grey))))),
                  ),
                ],
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => Navigator.pop(c),
                    child: Text("Close"),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
        SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(title: Text("Clients", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0, centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'client').snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
          if (s.data!.docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline_rounded, size: 56, color: Colors.grey.shade300), SizedBox(height: 8), Text("No clients yet", style: TextStyle(color: Colors.grey))]));
          return Column(children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E40AF)]), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.people_rounded, color: Colors.white, size: 22)),
                SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${s.data!.docs.length} Total Clients", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Tap a client for full details", style: TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: s.data!.docs.length,
                itemBuilder: (c, i) {
                  var d = s.data!.docs[i].data() as Map<String, dynamic>;
                  final phone = d['phone']?? d['phoneNumber']?? 'N/A';
                  final idNum = d['nationalId']?? d['idNumber']?? d['id']?? 'N/A';
                  final name = (d['name']?? d['email']?? 'Client').toString();
                  return Card(
                    elevation: 2, shadowColor: Colors.black12,
                    margin: EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showClientDetails(context, d),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.teal.shade700])), child: Center(child: Text(_initials(name), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                          SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 2),
                            Text(d['email']?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.phone, size: 11, color: Colors.grey), SizedBox(width: 3), Text(phone.toString(), style: TextStyle(fontSize: 11)),
                              SizedBox(width: 10),
                              Icon(Icons.badge, size: 11, color: Colors.grey), SizedBox(width: 3), Expanded(child: Text("ID: $idNum", style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                            ]),
                          ])),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}
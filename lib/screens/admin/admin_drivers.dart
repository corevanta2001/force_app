import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_driver_detail.dart';

class AdminDrivers extends StatelessWidget {
  const AdminDrivers({super.key});

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  String _initials(String name) {
    var p = name.trim().split(' ');
    if (p.isEmpty || p[0].isEmpty) return '?';
    if (p.length == 1) return p[0][0].toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.person_add_rounded, color: Colors.purple)), SizedBox(width: 8), Text("Add Driver", style: TextStyle(fontWeight: FontWeight.bold))]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: _dec("Name *", Icons.person_rounded)),
          SizedBox(height: 10),
          TextField(controller: idCtrl, decoration: _dec("ID Number", Icons.badge_rounded)),
          SizedBox(height: 10),
          TextField(controller: phoneCtrl, decoration: _dec("Cell Number (0...)", Icons.phone_rounded), keyboardType: TextInputType.phone),
          SizedBox(height: 6),
          Text("Use 0... format, not +263", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty || idCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.red));
                return;
              }
              if (phoneCtrl.text.trim().startsWith('+263')) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cell must not start with +263. Use 0..."), backgroundColor: Colors.red));
                return;
              }
              final q = await FirebaseFirestore.instance.collection('drivers').where('phone', isEqualTo: phoneCtrl.text.trim()).limit(1).get();
              if (q.docs.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cell already used by another driver!"), backgroundColor: Colors.red));
                return;
              }
              await FirebaseFirestore.instance.collection('drivers').add({
                'name': nameCtrl.text.trim(),
                'idNumber': idCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'status': 'available',
                'totalDeliveries': 0,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Driver added"), backgroundColor: Colors.green));
            },
            child: Text("Add Driver"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(title: Text("Drivers", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0, centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF0F172A),
        icon: Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text("Add Driver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
          int avail = s.data!.docs.where((d) => ((d.data() as Map)['status']?? 'available') == 'available').length;
          if (s.data!.docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.group_off_outlined, size: 56, color: Colors.grey.shade300), SizedBox(height: 8), Text("No drivers yet", style: TextStyle(color: Colors.grey))]));
          return Column(children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF6D28D9)]), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.groups_rounded, color: Colors.white, size: 24)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${s.data!.docs.length} Total Drivers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("$avail available • ${s.data!.docs.length - avail} busy", style: TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: s.data!.docs.length,
                itemBuilder: (c, i) {
                  var doc = s.data!.docs[i];
                  var d = doc.data() as Map<String, dynamic>;
                  bool isAvail = (d['status']?? 'available') == 'available';
                  String name = d['name']?? 'Driver';
                  return Card(
                    elevation: 2, shadowColor: Colors.black12,
                    margin: EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDriverDetail(driverId: doc.id, driverName: name, driverPhone: d['phone']?? ''))),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          Stack(children: [
                            Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: isAvail? [Colors.green.shade400, Colors.green.shade700] : [Colors.grey.shade400, Colors.grey.shade600])), child: Center(child: Text(_initials(name), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                            Positioned(bottom: 0, right: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: isAvail? Colors.greenAccent : Colors.orange, border: Border.all(color: Colors.white, width: 2)))),
                          ]),
                          SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                              Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isAvail? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(isAvail? "AVAILABLE" : "BUSY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isAvail? Colors.green : Colors.orange))),
                            ]),
                            SizedBox(height: 4),
                            Row(children: [Icon(Icons.badge_outlined, size: 11, color: Colors.grey), SizedBox(width: 3), Text("ID: ${d['idNumber']?? ''}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600))]),
                            Row(children: [Icon(Icons.phone_outlined, size: 11, color: Colors.grey), SizedBox(width: 3), Text(d['phone']?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))]),
                          ])),
                          Column(children: [
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDriverDetail(driverId: doc.id, driverName: name, driverPhone: d['phone']?? ''))),
                              child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFF0F172A).withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.local_shipping_rounded, color: Color(0xFF0F172A), size: 18)),
                            ),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Switch(value: isAvail, activeColor: Colors.green, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, onChanged: (v) async { await doc.reference.update({'status': v? 'available' : 'busy'}); }),
                              InkWell(
                                onTap: () async {
                                  bool confirm = await showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text("Delete Driver?"), content: Text("Delete $name permanently?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: Text("Delete", style: TextStyle(color: Colors.white)))]))?? false;
                                  if (confirm) await doc.reference.delete();
                                },
                                child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16)),
                              ),
                            ]),
                          ]),
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
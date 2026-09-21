import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_driver_detail.dart';

class AdminDrivers extends StatelessWidget {
  const AdminDrivers({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drivers - Trips & Expenses"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0F172A),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){
          final nameCtrl = TextEditingController();
          final phoneCtrl = TextEditingController();
          final idCtrl = TextEditingController();
          showDialog(context: context, builder: (c)=> AlertDialog(
            title: Text("Add Driver"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name *")),
              TextField(controller: idCtrl, decoration: InputDecoration(labelText: "ID Number")),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: "Cell Number (0... no +263)")),
            ]),
            actions: [
              TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
              ElevatedButton(onPressed: () async {
                if(phoneCtrl.text.trim().startsWith('+263')){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cell must not start with +263. Use 0...")));
                  return;
                }
                final q = await FirebaseFirestore.instance.collection('drivers').where('phone', isEqualTo: phoneCtrl.text.trim()).limit(1).get();
                if(q.docs.isNotEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cell already used by another driver!")));
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
              }, child: Text("Add")),
            ],
          ));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
        builder: (c,s){
          if(!s.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: s.data!.docs.length,
            itemBuilder: (c,i){
              var doc = s.data!.docs[i];
              var d = doc.data() as Map<String, dynamic>;
              bool avail = (d['status']??'available')=='available';
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: avail? Colors.green : Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(d['name']??'Driver', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("ID: ${d['idNumber']??''} | ${d['phone']??''} | ${d['status']}"),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Icon(Icons.local_shipping, color: Color(0xFF0F172A)), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminDriverDetail(driverId: doc.id, driverName: d['name']??'Driver', driverPhone: d['phone']??'')))),
                    Switch(value: avail, onChanged: (v) async { await doc.reference.update({'status': v? 'available':'busy'}); }),
                    IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async {
                      bool confirm = await showDialog(context: context, builder: (ctx)=> AlertDialog(title: Text("Delete Driver?"), content: Text("Delete ${d['name']}?"), actions: [TextButton(onPressed: ()=> Navigator.pop(ctx,false), child: Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: ()=> Navigator.pop(ctx,true), child: Text("Delete", style: TextStyle(color: Colors.white)))]))??false;
                      if(confirm) await doc.reference.delete();
                    }),
                  ]),
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminDriverDetail(driverId: doc.id, driverName: d['name']??'Driver', driverPhone: d['phone']??''))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVans extends StatelessWidget {
  const AdminVans({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vans - Admin sets available & can delete"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0F172A),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){
          final plateCtrl = TextEditingController();
          final typeCtrl = TextEditingController(text: "Small Van");
          showDialog(context: context, builder: (c)=> AlertDialog(
            title: Text("Add Van"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: plateCtrl, decoration: InputDecoration(labelText: "Plate Number")),
              TextField(controller: typeCtrl, decoration: InputDecoration(labelText: "Van Type")),
            ]),
            actions: [
              TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
              ElevatedButton(onPressed: () async {
                await FirebaseFirestore.instance.collection('vans').add({
                  'plateNumber': plateCtrl.text.trim().isEmpty? 'AFG-${DateTime.now().millisecondsSinceEpoch%10000}' : plateCtrl.text.trim(),
                  'type': typeCtrl.text.trim(),
                  'capacityKg': 500,
                  'status': 'available',
                  'totalIncomeGenerated': 0,
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
        stream: FirebaseFirestore.instance.collection('vans').snapshots(),
        builder: (c,s){
          if(!s.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: s.data!.docs.length,
            itemBuilder: (c,i){
              var doc = s.data!.docs[i];
              var d = doc.data() as Map<String, dynamic>;
              bool available = (d['status']??'available')=='available';
              return Card(child: ListTile(
                leading: Icon(Icons.local_shipping, color: available? Colors.green : Colors.grey),
                title: Text(d['plateNumber']??'No Plate', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Type: ${d['type']} | Status: ${d['status']}"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Switch(value: available, onChanged: (v) async {
                    await doc.reference.update({'status': v? 'available' : 'busy'});
                  }),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async {
                    bool confirm = await showDialog(context: context, builder: (c)=> AlertDialog(title: Text("Delete Van?"), content: Text("Are you sure you want to delete ${d['plateNumber']}?"), actions: [TextButton(onPressed: ()=> Navigator.pop(c,false), child: Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: ()=> Navigator.pop(c,true), child: Text("Delete", style: TextStyle(color: Colors.white)))]))??false;
                    if(confirm) await doc.reference.delete();
                  }),
                ]),
              ));
            },
          );
        },
      ),
    );
  }
}

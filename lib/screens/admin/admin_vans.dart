import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVans extends StatelessWidget {
  const AdminVans({super.key});

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  void _showAddDialog(BuildContext context) {
    final plateCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: "Small Van");
    final capCtrl = TextEditingController(text: "500");
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFF0F172A).withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.add_road_rounded, color: Color(0xFF0F172A))), SizedBox(width: 8), Text("Add New Van", style: TextStyle(fontWeight: FontWeight.bold))]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: plateCtrl, decoration: _dec("Plate Number", Icons.confirmation_number_rounded)),
          SizedBox(height: 10),
          TextField(controller: typeCtrl, decoration: _dec("Van Type", Icons.category_rounded)),
          SizedBox(height: 10),
          TextField(controller: capCtrl, decoration: _dec("Capacity (Kg)", Icons.fitness_center_rounded), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            onPressed: () async {
              if (typeCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill van type"), backgroundColor: Colors.red));
                return;
              }
              await FirebaseFirestore.instance.collection('vans').add({
                'plateNumber': plateCtrl.text.trim().isEmpty? 'AFG-${DateTime.now().millisecondsSinceEpoch % 10000}' : plateCtrl.text.trim().toUpperCase(),
                'type': typeCtrl.text.trim(),
                'capacityKg': int.tryParse(capCtrl.text.trim())?? 500,
                'status': 'available',
                'totalIncomeGenerated': 0,
                'totalDeliveries': 0,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Van added"), backgroundColor: Colors.green));
            },
            child: Text("Add Van"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(title: Text("Fleet Management", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0, centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF0F172A),
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Add Van", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vans').snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
          int avail = s.data!.docs.where((d) => ((d.data() as Map)['status']?? 'available') == 'available').length;
          if (s.data!.docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_shipping_outlined, size: 56, color: Colors.grey.shade300), SizedBox(height: 8), Text("No vans yet - tap Add Van", style: TextStyle(color: Colors.grey))]));
          return Column(children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E40AF)]), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${s.data!.docs.length} Total Vans", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  bool available = (d['status']?? 'available') == 'available';
                  return Card(
                    elevation: 2, shadowColor: Colors.black12,
                    margin: EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: available? Colors.green.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.local_shipping_rounded, color: available? Colors.green : Colors.grey, size: 26),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(d['plateNumber']?? 'No Plate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(width: 6),
                            Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: available? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(available? "AVAILABLE" : "BUSY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: available? Colors.green : Colors.orange))),
                          ]),
                          SizedBox(height: 4),
                          Text("${d['type']?? ''} • ${d['capacityKg']?? 500} Kg", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          Text("${d['totalDeliveries']?? 0} deliveries", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ])),
                        Column(children: [
                          Switch(value: available, activeColor: Colors.green, onChanged: (v) async { await doc.reference.update({'status': v? 'available' : 'busy'}); }),
                          InkWell(
                            onTap: () async {
                              bool confirm = await showDialog(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text("Delete Van?"), content: Text("Delete ${d['plateNumber']} permanently?"), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(c, true), child: Text("Delete", style: TextStyle(color: Colors.white)))]))?? false;
                              if (confirm) await doc.reference.delete();
                            },
                            child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18)),
                          ),
                        ]),
                      ]),
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
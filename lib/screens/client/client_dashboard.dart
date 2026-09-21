import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'client_tracking.dart';
import 'client_new_order.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  Widget kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 16, color: color), SizedBox(width: 4), Text(title, style: TextStyle(fontSize: 11, color: Colors.black54))]),
          SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ordersStream = FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).snapshots();
    return Scaffold(
      appBar: AppBar(title: Text("My Dashboard"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientNewOrder())))
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          int pending = docs.where((d) => (d.data() as Map)['status'] == 'pending').length;
          int delivered = docs.where((d) => (d.data() as Map)['status'] == 'delivered').length;
          double totalSpent = 0;
          for (var d in docs) { totalSpent += ((d.data() as Map)['deliveryFee'] ?? 0).toDouble(); }

          if (docs.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text("No orders yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Create your first delivery"),
              SizedBox(height: 16),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientNewOrder())), child: Text("New Order", style: TextStyle(color: Colors.white))),
            ]));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                kpiCard("Total", "${docs.length}", Icons.list_alt, Color(0xFF0F172A)),
                kpiCard("Pending", "$pending", Icons.pending, Colors.orange),
                kpiCard("Delivered", "$delivered", Icons.check_circle, Colors.green),
              ]),
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Total Spent", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("\$${totalSpent.toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  Icon(Icons.wallet, color: Colors.white70)
                ]),
              ),
              SizedBox(height: 12),
              Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("Recent Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: docs.length > 5 ? 5 : docs.length,
                itemBuilder: (c, i) {
                  final doc = docs[i];
                  var d = doc.data() as Map<String, dynamic>;
                  Color stColor = d['status'] == 'delivered' ? Colors.green : Colors.orange;
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.local_shipping, color: Color(0xFF0F172A)),
                      title: Text(d['orderNumber'] ?? 'Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text("${d['dropoffAddress'] ?? ''}", maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text("\$${d['deliveryFee'] ?? 0}", style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: stColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(d['status'] ?? 'pending', style: TextStyle(fontSize: 9, color: stColor))),
                      ]),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientTracking(orderId: doc.id))),
                    ),
                  );
                },
              ),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF0F172A),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("New Order", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientNewOrder())),
      ),
    );
  }
}

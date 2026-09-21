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
          Row(children: [Icon(icon, size: 16, color: color), SizedBox(width: 4), Expanded(child: Text(title, style: TextStyle(fontSize: 10, color: Colors.black54), overflow: TextOverflow.ellipsis))]),
          SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: Text("My Dashboard"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientNewOrder())))
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;

          int pending = docs.where((d) => (d.data() as Map)['status'] == 'pending').length;
          int accepted = docs.where((d) => ((d.data() as Map)['status']??'').toString().contains('deposit') || (d.data() as Map)['status']=='accepted_awaiting_deposit').length;
          int inTransit = docs.where((d) => (d.data() as Map)['status'] == 'in_transit').length;
          int delivered = docs.where((d) => (d.data() as Map)['status'] == 'delivered').length;
          int declined = docs.where((d) => (d.data() as Map)['status'] == 'declined' || (d.data() as Map)['status'] == 'canceled').length;

          double totalSpent = 0;
          for (var doc in docs) {
            var map = doc.data() as Map<String, dynamic>;
            totalSpent += (map['totalAmount']?? map['deliveryFee']??0).toDouble();
          }

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

          // Sort locally by createdAt desc
          docs.sort((a,b){
            var aT = (a.data() as Map)['createdAt'];
            var bT = (b.data() as Map)['createdAt'];
            if(aT==null || bT==null) return 0;
            return (bT as Timestamp).compareTo(aT as Timestamp);
          });

          return SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                kpiCard("Pending", "$pending", Icons.pending, Colors.orange),
                kpiCard("Accepted", "$accepted", Icons.check_circle_outline, Colors.purple),
                kpiCard("In Transit", "$inTransit", Icons.local_shipping, Colors.blue),
              ]),
              Row(children: [
                kpiCard("Delivered", "$delivered", Icons.done_all, Colors.green),
                kpiCard("Declined", "$declined", Icons.cancel, Colors.red),
                kpiCard("Total", "${docs.length}", Icons.list_alt, Color(0xFF0F172A)),
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
              Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("Recent Orders - All Statuses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (c, i) {
                  final doc = docs[i];
                  var d = doc.data() as Map<String, dynamic>;
                  String st = d['status']??'pending';
                  Color stColor = st=='delivered'? Colors.green : st=='declined' || st=='canceled'? Colors.red : st=='in_transit'? Colors.blue : st.contains('deposit')? Colors.purple : Colors.orange;
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.local_shipping, color: Color(0xFF0F172A)),
                      title: Text("${d['orderNumber'] ?? 'Order'} - ${d['storeName']??''}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text("${(d['items'] as List?)?.length??0} items | ${d['dropoffAddress'] ?? ''}", maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text("\$${d['totalAmount']?? d['deliveryFee']??0}", style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: stColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(st.replaceAll('_',' '), style: TextStyle(fontSize: 8, color: stColor, fontWeight: FontWeight.bold))),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_orders.dart';
import 'admin_vans.dart';
import 'admin_income.dart';
import 'admin_drivers.dart';
import 'admin_clients.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  Widget kpi(String title, String value, Color color, VoidCallback? onTap){
    return Expanded(child: InkWell(onTap: onTap, child: Container(padding: EdgeInsets.all(14), margin: EdgeInsets.all(4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 12, color: Colors.black54)), SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))]))));
  }
  @override
  Widget build(BuildContext context){
    final db = FirebaseFirestore.instance;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, actions: [
        IconButton(icon: Icon(Icons.logout), onPressed: () async { await FirebaseAuth.instance.signOut(); if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (r)=> false); }),
      ]),
      drawer: Drawer(child: ListView(children: [
        DrawerHeader(decoration: BoxDecoration(color: Color(0xFF0F172A)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.admin_panel_settings, color: Colors.white, size: 40), SizedBox(height: 8), Text("Force Admin", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))])),
        ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard"), onTap: ()=> Navigator.pop(context)),
        ListTile(leading: Icon(Icons.receipt_long), title: Text("All Orders"), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))),
        ListTile(leading: Icon(Icons.local_shipping), title: Text("Vans - Available/Delete"), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminVans()))),
        ListTile(leading: Icon(Icons.person), title: Text("Drivers - Trips & Expenses"), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminDrivers()))),
        ListTile(leading: Icon(Icons.attach_money), title: Text("Income"), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminIncome()))),
        ListTile(leading: Icon(Icons.people), title: Text("Clients"), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminClients()))),
        Divider(),
        ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Logout to Home", style: TextStyle(color: Colors.red)), onTap: () async { await FirebaseAuth.instance.signOut(); if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (r)=> false); }),
      ])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          StreamBuilder<QuerySnapshot>(
            stream: db.collection('orders').snapshots(),
            builder: (c,s){
              int pending=0, accepted=0, inTransit=0, delivered=0, declined=0, canceled=0;
              if(s.hasData){
                for(var d in s.data!.docs){
                  var st = (d.data() as Map)['status']??'';
                  if(st=='pending') pending++;
                  if(st.contains('deposit') || st=='accepted_awaiting_deposit') accepted++;
                  if(st=='in_transit') inTransit++;
                  if(st=='delivered') delivered++;
                  if(st=='declined') declined++;
                  if(st=='canceled') canceled++;
                }
              }
              return Column(children: [
                Row(children: [kpi("Pending", "$pending", Colors.orange, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))), kpi("Accepted", "$accepted", Colors.purple, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))), kpi("In Transit", "$inTransit", Colors.blue, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders())))]),
                Row(children: [kpi("Delivered", "$delivered", Colors.green, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminIncome()))), kpi("Declined", "$declined", Colors.red, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))), kpi("Canceled", "$canceled", Colors.grey, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders())))]),
              ]);
            },
          ),
          SizedBox(height: 12),
          StreamBuilder<DocumentSnapshot>(stream: db.collection('daily_income').doc(today).snapshots(), builder: (c,s){ final data = s.data?.data() as Map<String, dynamic>?; return Row(children: [kpi("Income", "\$${data?['totalIncome']??0}", Colors.green, null), kpi("Expenses", "\$${data?['totalExpenses']??0}", Colors.red, null), kpi("Net", "\$${data?['netProfit']??0}", Color(0xFF0F172A), null)]); }),
        ]),
      ),
    );
  }
}

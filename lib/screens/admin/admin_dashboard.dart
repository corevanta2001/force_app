import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_orders.dart';
import 'admin_vans.dart';
import 'admin_income.dart';
import 'admin_drivers.dart';
import 'admin_clients.dart';
import 'dart:async';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [Icon(Icons.logout, color: Color(0xFF0F172A)), SizedBox(width: 8), Text("Log out?")]),
        content: Text("Are you sure you want to log out to home screen?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(c, true),
            child: Text("Log Out"),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    }
  }

  Future<void> _nuclearDeleteDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => _NuclearCountdownDialog(),
    );
  }

  Widget kpi(String title, String value, Color color, IconData icon, VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(14),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 3))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String subtitle, Color color, Widget page) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(padding: EdgeInsets.all(9), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
        onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => page)); },
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    final db = FirebaseFirestore.instance;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(margin: EdgeInsets.only(right: 8, top: 8, bottom: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: IconButton(icon: Icon(Icons.logout, size: 18), tooltip: "Logout", onPressed: () => _confirmLogout(context))),
        ],
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18, 48, 18, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28)),
              SizedBox(height: 12),
              Text("Force Admin", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text("Company Control Center", style: TextStyle(color: Colors.white70, fontSize: 11)),
              SizedBox(height: 10),
              Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.greenAccent.withOpacity(0.4))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: Colors.greenAccent), SizedBox(width: 6), Text("SYSTEM ONLINE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))])),
            ]),
          ),
          SizedBox(height: 10),
          Expanded(child: ListView(padding: EdgeInsets.zero, children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text("MANAGEMENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2))),
            _drawerItem(context, Icons.dashboard_rounded, "Dashboard", "Overview & KPIs", Color(0xFF0F172A), AdminDashboard()),
            _drawerItem(context, Icons.receipt_long_rounded, "All Orders", "Accept, assign, deliver", Colors.orange, AdminOrders()),
            _drawerItem(context, Icons.local_shipping_rounded, "Vans", "Available & manage", Colors.blue, AdminVans()),
            _drawerItem(context, Icons.person_rounded, "Drivers", "Trips & expenses", Colors.purple, AdminDrivers()),
            _drawerItem(context, Icons.attach_money_rounded, "Income", "Profit & breakdown", Colors.green, AdminIncome()),
            _drawerItem(context, Icons.people_rounded, "Clients", "Customer details", Colors.teal, AdminClients()),
            SizedBox(height: 8),
            Divider(indent: 16, endIndent: 16),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text("DANGER ZONE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 1.2))),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Container(padding: EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.warning_rounded, color: Colors.white, size: 20)),
                title: Text("NUCLEAR RESET", style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Delete ALL data - irreversible", style: TextStyle(fontSize: 10, color: Colors.red.shade400)),
                onTap: () { Navigator.pop(context); _nuclearDeleteDialog(context); },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Container(padding: EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.logout_rounded, color: Colors.red, size: 20)),
                title: Text("Logout to Home", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text("End admin session", style: TextStyle(fontSize: 10, color: Colors.grey)),
                onTap: () => _confirmLogout(context),
              ),
            ),
          ])),
          Padding(padding: EdgeInsets.all(12), child: Text("Force App v1.0.0", style: TextStyle(fontSize: 10, color: Colors.grey))),
        ]),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E40AF)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Welcome back, Admin", style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text("Here's what's happening today", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ])),
              Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.insights, color: Colors.white, size: 24)),
            ]),
          ),
          SizedBox(height: 14),
          Text("Orders Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
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
                Row(children: [
                  kpi("Pending", "$pending", Colors.orange, Icons.hourglass_empty_rounded, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))),
                  kpi("Accepted", "$accepted", Colors.purple, Icons.check_circle_outline_rounded, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))),
                  kpi("In Transit", "$inTransit", Colors.blue, Icons.local_shipping_rounded, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))),
                ]),
                Row(children: [
                  kpi("Delivered", "$delivered", Colors.green, Icons.done_all_rounded, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminIncome()))),
                  kpi("Declined", "$declined", Colors.red, Icons.cancel_outlined, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))),
                  kpi("Canceled", "$canceled", Colors.grey, Icons.block, ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> AdminOrders()))),
                ]),
              ]);
            },
          ),
          SizedBox(height: 14),
          Text("Today's Finance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          StreamBuilder<DocumentSnapshot>(
            stream: db.collection('daily_income').doc(today).snapshots(),
            builder: (c,s){
              final data = s.data?.data() as Map<String, dynamic>?;
              double inc = ((data?['totalIncome']??0) as num).toDouble();
              double exp = ((data?['totalExpenses']??0) as num).toDouble();
              double net = ((data?['netProfit']??0) as num).toDouble();
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(18)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _financeStat("Income", "\$${inc.toStringAsFixed(0)}", Colors.greenAccent),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _financeStat("Expenses", "\$${exp.toStringAsFixed(0)}", Colors.redAccent),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _financeStat("Net Profit", "\$${net.toStringAsFixed(0)}", Colors.white),
                ]),
              );
            },
          ),
          SizedBox(height: 18),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.shade200)),
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red, size: 28),
              title: Text("NUCLEAR DELETE ALL DATA", style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text("Reset everything to start - admin & client", style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
              trailing: Icon(Icons.warning, color: Colors.red),
              onTap: () => _nuclearDeleteDialog(context),
            ),
          ),
          SizedBox(height: 14),
          Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              _quickAction(context, Icons.receipt_long, "Orders", Colors.orange, AdminOrders()),
              _quickAction(context, Icons.local_shipping, "Vans", Colors.blue, AdminVans()),
              _quickAction(context, Icons.person, "Drivers", Colors.purple, AdminDrivers()),
              _quickAction(context, Icons.attach_money, "Income", Colors.green, AdminIncome()),
              _quickAction(context, Icons.people, "Clients", Colors.teal, AdminClients()),
              _quickAction(context, Icons.logout, "Logout", Colors.red, null),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _financeStat(String label, String value, Color color) {
    return Column(children: [
      Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
      SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, Widget? page) {
    return InkWell(
      onTap: () {
        if (page!= null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        else _confirmLogout(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _NuclearCountdownDialog extends StatefulWidget {
  @override
  State<_NuclearCountdownDialog> createState() => _NuclearCountdownDialogState();
}

class _NuclearCountdownDialogState extends State<_NuclearCountdownDialog> {
  int secondsLeft = 10;
  Timer? timer;
  bool deleting = false;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) { t.cancel(); setState(() => confirmed = true); }
      else setState(() => secondsLeft--);
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  Future<void> _deleteAll() async {
    setState(() => deleting = true);
    final db = FirebaseFirestore.instance;
    const collections = ['orders','users','drivers','vans','daily_income','notifications'];
    try {
      for (String col in collections) {
        var snap = await db.collection(col).get();
        for (var doc in snap.docs) {
          await doc.reference.delete();
        }
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All data deleted - system reset"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.red.shade50,
      title: Row(children: [Icon(Icons.warning_rounded, color: Colors.red, size: 28), SizedBox(width: 8), Text("NUCLEAR DELETE", style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold))]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("This will PERMANENTLY delete ALL data:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("• All orders\n• All clients\n• All drivers\n• All vans\n• All income records", style: TextStyle(fontSize: 12)),
        SizedBox(height: 12),
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)), child: Text("Resetting everything to start. This cannot be undone!", style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
        SizedBox(height: 16),
        if (!confirmed)
          Column(children: [
            Text("$secondsLeft", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red)),
            Text("seconds until delete is enabled...", style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 8),
            LinearProgressIndicator(value: (10 - secondsLeft) / 10, backgroundColor: Colors.red.shade100, color: Colors.red),
          ])
        else
          Text("You can now delete. Are you absolutely sure?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900)),
      ]),
      actions: [
        TextButton(onPressed: deleting? null : () => Navigator.pop(context), child: Text("CANCEL - Keep Data")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: (!confirmed || deleting)? null : _deleteAll,
          child: deleting? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(confirmed? "DELETE EVERYTHING NOW" : "WAIT $secondsLeft s"),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminIncome extends StatelessWidget {
  const AdminIncome({super.key});

  String formatDate(DateTime dt) {
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${weekdays[dt.weekday-1]}, ${dt.day} ${months[dt.month-1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Income & Expenses"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'delivered').snapshots(),
        builder: (c,s){
          if(!s.hasData) return Center(child: CircularProgressIndicator());
          double totalIncome=0, totalExp=0;
          for(var doc in s.data!.docs){
            var d = doc.data() as Map;
            totalIncome += (d['totalAmount']?? d['deliveryFee']??0).toDouble();
            totalExp += (d['expenses']??0).toDouble();
          }
          return Column(children: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DailyIncomeDetailsScreen()));
              },
              child: Container(width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.touch_app, color: Colors.white54, size: 14),
                    SizedBox(width: 4),
                    Text("Delivered Orders: ${s.data!.docs.length} • Tap for daily details", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Total Income", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("\$${totalIncome.toStringAsFixed(2)}", style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      ]),
                      Divider(color: Colors.white12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Total Expenses", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("\$${totalExp.toStringAsFixed(2)}", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
                      ]),
                      Divider(color: Colors.white12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Net Profit", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text("\$${(totalIncome-totalExp).toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                  ),
                  SizedBox(height: 6),
                  Text("Tap to view breakdown by date", style: TextStyle(color: Colors.blue.shade200, fontSize: 11, decoration: TextDecoration.underline)),
                ])),
            ),
            Expanded(child: ListView.builder(
              itemCount: s.data!.docs.length,
              itemBuilder: (c,i){
                var d = s.data!.docs[i].data() as Map<String, dynamic>;
                List items = d['items']?? [];
                return Card(margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(
                  title: Text(d['orderNumber']??'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Client: ${d['userName']??''} | Store: ${d['storeName']??''}", style: TextStyle(fontSize: 11)),
                    Text("Driver: ${d['driverName']??''} Van: ${d['vanPlate']??''}", style: TextStyle(fontSize: 11)),
                    Text("Deposit: \$${d['depositAmount']??0} | Total: \$${d['totalAmount']?? d['deliveryFee']??0}", style: TextStyle(fontSize: 11, color: Colors.purple)),
                    Text("Items: ${items.map((e)=> "${e['name']} x${e['qty']}").join(', ')}", style: TextStyle(fontSize: 10)),
                    if((d['expenseReceipts']??[]).isNotEmpty) Text("Receipts: ${(d['expenseReceipts'] as List).join(', ')}", style: TextStyle(fontSize: 10)),
                  ]),
                  trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("+\$${d['totalAmount']?? d['deliveryFee']??0}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text("-\$${d['expenses']??0}", style: TextStyle(color: Colors.red, fontSize: 12)),
                    Text("Net \$${((d['totalAmount']?? d['deliveryFee']??0) - (d['expenses']??0)).toStringAsFixed(2)}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ));
              },
            )),
          ]);
        },
      ),
    );
  }
}

class DailyIncomeDetailsScreen extends StatefulWidget {
  @override
  State<DailyIncomeDetailsScreen> createState() => _DailyIncomeDetailsScreenState();
}

class _DailyIncomeDetailsScreenState extends State<DailyIncomeDetailsScreen> {
  DateTime? selectedDate;

  String dayKey(DateTime dt) => "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}";

  String prettyDate(DateTime dt) {
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${weekdays[dt.weekday-1]}, ${dt.day} ${months[dt.month-1]} ${dt.year}';
  }

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (d!= null) setState(() => selectedDate = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text("Daily Income Breakdown"),
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.calendar_month), tooltip: "Search by date", onPressed: pickDate),
          if (selectedDate!= null)
            IconButton(icon: Icon(Icons.clear), tooltip: "Clear filter", onPressed: () => setState(() => selectedDate = null)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.white,
            child: Row(children: [
              Expanded(
                child: InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(Icons.calendar_today, size: 18, color: Color(0xFF1E3A8A)),
                      SizedBox(width: 8),
                      Text(selectedDate == null? "Search by date - tap to pick" : prettyDate(selectedDate!), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'delivered').snapshots(),
              builder: (c, s) {
                if (!s.hasData) return Center(child: CircularProgressIndicator());
                Map<String, List<Map<String,dynamic>>> grouped = {};
                Map<String, double> incomeByDay = {};
                Map<String, double> expByDay = {};

                for (var doc in s.data!.docs) {
                  var d = doc.data() as Map<String, dynamic>;
                  Timestamp? ts = d['deliveredAt'] as Timestamp?;
                  DateTime dt = ts?.toDate()?? DateTime.now();
                  String k = dayKey(dt);
                  if (selectedDate!= null && k!= dayKey(selectedDate!)) continue;
                  grouped.putIfAbsent(k, () => []).add({...d, '_dt': dt});
                  double inc = ((d['totalAmount']?? d['deliveryFee']?? 0) as num).toDouble();
                  double ex = ((d['expenses']?? 0) as num).toDouble();
                  incomeByDay[k] = (incomeByDay[k]?? 0) + inc;
                  expByDay[k] = (expByDay[k]?? 0) + ex;
                }

                var keys = grouped.keys.toList()..sort((a,b) => b.compareTo(a));
                if (keys.isEmpty) return Center(child: Text(selectedDate==null? "No transactions yet" : "No transactions on this date"));

                double grandIncome = incomeByDay.values.fold(0.0, (a,b)=>a+b);
                double grandExp = expByDay.values.fold(0.0, (a,b)=>a+b);

                return ListView(
                  padding: EdgeInsets.all(12),
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E40AF)]), borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Column(children: [Text("Total Income", style: TextStyle(color: Colors.white70, fontSize: 11)), Text("\$${grandIncome.toStringAsFixed(2)}", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18))]),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Column(children: [Text("Total Expenses", style: TextStyle(color: Colors.white70, fontSize: 11)), Text("\$${grandExp.toStringAsFixed(2)}", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18))]),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Column(children: [Text("Net", style: TextStyle(color: Colors.white70, fontSize: 11)), Text("\$${(grandIncome-grandExp).toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
                      ]),
                    ),
                    SizedBox(height: 12),
                  ...keys.map((k) {
                      DateTime dt = grouped[k]!.first['_dt'];
                      double di = incomeByDay[k]!;
                      double de = expByDay[k]!;
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF1E3A8A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.calendar_today, color: Color(0xFF1E3A8A))),
                          title: Text(prettyDate(dt), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("${grouped[k]!.length} transaction(s) • Income \$${di.toStringAsFixed(2)} • Exp \$${de.toStringAsFixed(2)}", style: TextStyle(fontSize: 11)),
                          trailing: Text("Net \$${(di-de).toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, color: (di-de)>=0? Colors.green: Colors.red)),
                          children: grouped[k]!.map((d) {
                            List items = d['items']?? [];
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Expanded(child: Text("${d['orderNumber']??''} - ${d['userName']??''}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text("+\$${d['totalAmount']?? d['deliveryFee']??0}", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text("-\$${d['expenses']??0} exp", style: TextStyle(color: Colors.red, fontSize: 11)),
                                  ]),
                                ]),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(6)),
                                  child: Text("Deposit Paid: \$${d['depositAmount']??0} | Proof: ${d['proofOfPayment']??'N/A'}", style: TextStyle(fontSize: 11, color: Colors.purple.shade800)),
                                ),
                                SizedBox(height: 6),
                                Text("Items bought:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                               ...items.map((it) => Padding(
                                  padding: EdgeInsets.only(left: 8, top: 2),
                                  child: Text("• ${it['name']} x ${it['qty']} ${it['price']!=null? "- \$${it['price']}": ""}", style: TextStyle(fontSize: 11)),
                                )).toList(),
                                SizedBox(height: 4),
                                Text("Driver: ${d['driverName']??''} | Van: ${d['vanPlate']??''} (${d['vanType']??''})", style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                if ((d['expenseReceipts']??[]).isNotEmpty)
                                  Text("Receipts: ${(d['expenseReceipts'] as List).join(', ')}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ]),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock, size: 12, color: Colors.grey), SizedBox(width: 4), Text("This record is permanent and cannot be erased", style: TextStyle(fontSize: 11, color: Colors.grey))])),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
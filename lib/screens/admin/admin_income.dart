import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminIncome extends StatelessWidget {
  const AdminIncome({super.key});
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
            Container(width: double.infinity, color: Color(0xFF0F172A), padding: EdgeInsets.all(20), child: Column(children: [
              Text("Delivered Orders: ${s.data!.docs.length}", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Text("\$${totalIncome.toStringAsFixed(2)} Income", style: TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("\$${totalExp.toStringAsFixed(2)} Expenses", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              Text("\$${(totalIncome-totalExp).toStringAsFixed(2)} Net Profit", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ])),
            Expanded(child: ListView.builder(
              itemCount: s.data!.docs.length,
              itemBuilder: (c,i){
                var d = s.data!.docs[i].data() as Map<String, dynamic>;
                return Card(margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: ListTile(
                  title: Text(d['orderNumber']??'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Client: ${d['userName']??''} | Store: ${d['storeName']??''}"),
                    Text("Driver: ${d['driverName']??''} Van: ${d['vanPlate']??''}"),
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

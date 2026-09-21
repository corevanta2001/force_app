import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDriverDetail extends StatelessWidget {
  final String driverId;
  final String driverName;
  final String driverPhone;
  const AdminDriverDetail({super.key, required this.driverId, required this.driverName, required this.driverPhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$driverName Trips"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('driverName', isEqualTo: driverName).snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator());
          var docs = s.data!.docs;
          double totalIncome = 0, totalExp = 0;
          for (var doc in docs) {
            var d = doc.data() as Map<String, dynamic>;
            totalIncome += (d['totalAmount'] ?? d['deliveryFee'] ?? 0).toDouble();
            totalExp += (d['expenses'] ?? 0).toDouble();
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Color(0xFF0F172A),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driverName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(driverPhone, style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 8),
                    Text("Trips: ${docs.length} | Income: \$${totalIncome.toStringAsFixed(2)} | Expenses: \$${totalExp.toStringAsFixed(2)} | Net: \$${(totalIncome - totalExp).toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? Center(child: Text("No trips for this driver yet"))
                    : ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (c, i) {
                          var doc = docs[i];
                          var d = doc.data() as Map<String, dynamic>;
                          List receipts = d['expenseReceipts'] ?? [];
                          List items = d['items'] ?? [];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(d['orderNumber'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: d['status'] == 'delivered' ? Colors.green.withOpacity(0.15) : Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                        child: Text(d['status'] ?? '', style: TextStyle(fontSize: 9)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text("Client: ${d['userName'] ?? ''} | Store: ${d['storeName'] ?? ''}", style: TextStyle(fontSize: 11)),
                                  Text("Items: ${items.map((e) => "${e['name']} x ${e['qty']}").join(', ')}", style: TextStyle(fontSize: 10)),
                                  Text("From: ${d['storeName'] ?? d['pickupAddress'] ?? ''} -> ${d['dropoffAddress'] ?? ''}", style: TextStyle(fontSize: 10)),
                                  Divider(),
                                  Text("Full Amount: \$${d['totalAmount'] ?? d['deliveryFee'] ?? 0} | Deposit: \$${d['depositAmount'] ?? 0}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text("Expenses Incurred: \$${d['expenses'] ?? 0}", style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                                  if (receipts.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text("Expense Receipts / List:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ...receipts.map((r) => Text("• $r", style: TextStyle(fontSize: 10, color: Colors.black87))).toList(),
                                  ],
                                  SizedBox(height: 4),
                                  Text("Van: ${d['vanPlate'] ?? ''} ${d['vanType'] ?? ''} | ETA: ${d['eta'] ?? ''}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

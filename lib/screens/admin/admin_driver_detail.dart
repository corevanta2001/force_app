import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDriverDetail extends StatelessWidget {
  final String driverId;
  final String driverName;
  final String driverPhone;
  const AdminDriverDetail({super.key, required this.driverId, required this.driverName, required this.driverPhone});

  String _initials(String name) {
    var parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _statusColor(String st) {
    if (st == 'delivered') return Colors.green;
    if (st == 'in_transit') return Colors.blue;
    if (st == 'declined') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('driverName', isEqualTo: driverName).snapshots(),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
          var docs = s.data!.docs;
          double totalIncome = 0, totalExp = 0;
          for (var doc in docs) {
            var d = doc.data() as Map<String, dynamic>;
            totalIncome += ((d['totalAmount']?? d['deliveryFee']?? 0) as num).toDouble();
            totalExp += ((d['expenses']?? 0) as num).toDouble();
          }
          double net = totalIncome - totalExp;
          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.indigo.shade600])),
                        child: Center(child: Text(_initials(driverName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(driverName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Row(children: [const Icon(Icons.phone, size: 12, color: Colors.white70), const SizedBox(width: 4), Text(driverPhone, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
                        const SizedBox(height: 4),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text("${docs.length} TRIPS", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                      ])),
                    ]),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        _stat("Income", "\$${totalIncome.toStringAsFixed(2)}", Colors.greenAccent, Icons.trending_up),
                        Container(width: 1, height: 36, color: Colors.white12),
                        _stat("Expenses", "\$${totalExp.toStringAsFixed(2)}", Colors.redAccent, Icons.trending_down),
                        Container(width: 1, height: 36, color: Colors.white12),
                        _stat("Net", "\$${net.toStringAsFixed(2)}", Colors.white, Icons.account_balance_wallet),
                      ]),
                    ),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 4), child: Row(children: [const Text("Trip History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const Spacer(), Text("${docs.length} total", style: const TextStyle(fontSize: 11, color: Colors.grey))])),
              Expanded(
                child: docs.isEmpty
                   ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_shipping_outlined, size: 56, color: Colors.grey.shade300), const SizedBox(height: 8), const Text("No trips for this driver yet", style: TextStyle(color: Colors.grey))]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: docs.length,
                        itemBuilder: (c, i) {
                          var doc = docs[i];
                          var d = doc.data() as Map<String, dynamic>;
                          List receipts = d['expenseReceipts']?? [];
                          List items = d['items']?? [];
                          String st = d['status']?? '';
                          Color sc = _statusColor(st);
                          return Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(d['orderNumber']?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: sc.withOpacity(0.3))),
                                        child: Text(st.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: sc)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _infoRow(Icons.person, "Client: ${d['userName']?? ''} • ${d['storeName']?? ''}"),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Text("Items: ${items.map((e) => "${e['name']} x ${e['qty']}").join(', ')}", style: const TextStyle(fontSize: 11)),
                                  ),
                                  const SizedBox(height: 4),
                                  _infoRow(Icons.route, "${d['storeName']?? d['pickupAddress']?? ''} → ${d['dropoffAddress']?? ''}"),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("FULL AMOUNT", style: TextStyle(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.bold)), Text("\$${d['totalAmount']?? d['deliveryFee']?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]))),
                                      const SizedBox(width: 8),
                                      Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("DEPOSIT", style: TextStyle(fontSize: 9, color: Colors.purple.shade700, fontWeight: FontWeight.bold)), Text("\$${d['depositAmount']?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]))),
                                      const SizedBox(width: 8),
                                      Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("EXPENSES", style: TextStyle(fontSize: 9, color: Colors.red.shade700, fontWeight: FontWeight.bold)), Text("\$${d['expenses']?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red))]))),
                                    ],
                                  ),
                                  if (receipts.isNotEmpty)...[
                                    const SizedBox(height: 8),
                                    const Text("Expense Receipts:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    for (var r in receipts)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Row(children: [const Icon(Icons.receipt_long, size: 12, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text("$r", style: const TextStyle(fontSize: 10)))]),
                                      ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(children: [const Icon(Icons.directions_car, size: 12, color: Colors.grey), const SizedBox(width: 4), Text("Van: ${d['vanPlate']?? ''} ${d['vanType']?? ''} • ETA: ${d['eta']?? ''}", style: const TextStyle(fontSize: 10, color: Colors.grey))]),
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

  Widget _stat(String label, String value, Color color, IconData icon) {
    return Column(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    ]);
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 13, color: Colors.grey), const SizedBox(width: 6), Expanded(child: Text(text, style: const TextStyle(fontSize: 11)))]);
  }
}
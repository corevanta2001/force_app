import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientTracking extends StatefulWidget {
  final String orderId;
  const ClientTracking({super.key, required this.orderId});
  @override
  State<ClientTracking> createState() => _ClientTrackingState();
}

class _ClientTrackingState extends State<ClientTracking> {
  final proofController = TextEditingController();
  bool loading = false;

  Future<void> submitProof(double deposit) async {
    if (proofController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter proof of payment reference / upload link")));
      return;
    }
    setState(() => loading = true);
    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'proofOfPayment': proofController.text.trim(),
      'depositPaid': true,
      'proofSubmittedAt': FieldValue.serverTimestamp(),
      'status': 'deposit_paid',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    setState(() => loading = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Proof sent to admin")));
  }

  Widget stepItem(String title, String subtitle, bool done, bool active) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: done ? Colors.green : active ? Colors.orange : Colors.grey.shade300, shape: BoxShape.circle), child: Icon(done ? Icons.check : Icons.circle, size: 14, color: Colors.white)),
        if (title != "Delivered") Container(width: 2, height: 30, color: done ? Colors.green : Colors.grey.shade300),
      ]),
      SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: done || active ? FontWeight.bold : FontWeight.normal)),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
        SizedBox(height: 20),
      ])),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Track Order"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (c, s) {
          if (!s.hasData) return Center(child: CircularProgressIndicator());
          var d = s.data!.data() as Map<String, dynamic>?;
          if (d == null) return Center(child: Text("Not found"));
          String status = d['status'] ?? 'pending';
          double deposit = (d['depositAmount'] ?? 0).toDouble();
          double total = (d['totalAmount'] ?? 0).toDouble();
          double remaining = (d['remainingAmount'] ?? (total - deposit)).toDouble();
          List items = d['items'] ?? [];
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(d['orderNumber'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Chip(label: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), backgroundColor: status == 'declined' ? Colors.red.shade100 : status == 'delivered' ? Colors.green.shade100 : Colors.orange.shade100),
                    ]),
                    Divider(),
                    Text("Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ...items.map((it) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text("• ${it['name']} x ${it['qty']}"),
                        )),
                    SizedBox(height: 8),
                    Text("Store: ${d['storeName'] ?? 'Any'}", style: TextStyle(fontSize: 12)),
                    Text("Delivery Location: ${d['deliveryLocation'] ?? ''}"),
                    Text("Dropoff: ${d['dropoffAddress'] ?? ''}"),
                    if ((d['notes'] ?? '').toString().isNotEmpty) Text("Notes: ${d['notes']}"),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("T&C: ${d['termsAccepted'] == true ? 'ACCEPTED (irreversible) ✓' : 'Not accepted'}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: d['termsAccepted'] == true ? Colors.green : Colors.red)),
                        if (d['termsAcceptedAt'] != null) Text("Accepted at: ${d['termsAcceptedAt'].toString()}", style: TextStyle(fontSize: 9)),
                      ]),
                    ),
                    if (status == 'declined')
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                        child: Text("DECLINED: ${d['declineReason'] ?? 'No reason'}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    if (total > 0) ...[
                      Divider(),
                      Text("Deposit: \$$deposit", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Total: \$$total"),
                      Text("Remaining after deposit: \$$remaining", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                    ],
                    if (d['proofOfPayment'] != '' && d['proofOfPayment'] != null)
                      Padding(padding: EdgeInsets.only(top: 6), child: Text("Proof: ${d['proofOfPayment']}", style: TextStyle(fontSize: 11, color: Colors.blue))),
                    if (d['driverName'] != '' && d['driverName'] != null) ...[
                      Divider(),
                      Text("Driver: ${d['driverName']} | ${d['driverPhone']}"),
                      Text("Van: ${d['vanPlate']} (${d['vanType']})"),
                      Text("ETA: ${d['eta']}"),
                    ],
                    if ((d['expenses'] ?? 0) > 0) Text("Expenses: \$${d['expenses']}"),
                  ]),
                ),
              ),
              SizedBox(height: 16),
              if (status == 'accepted_awaiting_deposit')
                Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Company Accepted! Pay Deposit", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                      SizedBox(height: 8),
                      Text("Deposit Required: \$$deposit\nTotal: \$$total\nRemaining: \$$remaining"),
                      SizedBox(height: 12),
                      TextField(controller: proofController, decoration: InputDecoration(labelText: "Proof of Payment - Reference / EcoCash Code / Image Link", border: OutlineInputBorder())),
                      SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple), onPressed: loading ? null : () => submitProof(deposit), child: Text("I Paid Deposit - Send Proof", style: TextStyle(color: Colors.white)))),
                    ]),
                  ),
                ),
              SizedBox(height: 16),
              Text("Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    stepItem("Pending", "Waiting for company", status != 'pending' || status == 'declined', status == 'pending'),
                    stepItem("Accepted - Deposit Needed", "Company set deposit: \$$deposit", ['accepted_awaiting_deposit', 'deposit_paid', 'in_transit', 'delivered'].contains(status), status == 'accepted_awaiting_deposit'),
                    stepItem("Deposit Paid - Proof Sent", "You paid and sent proof", ['deposit_paid', 'in_transit', 'delivered'].contains(status), status == 'deposit_paid'),
                    stepItem("In Transit", "Driver: ${d['driverName'] ?? 'assigning...'} | ETA ${d['eta'] ?? ''}", ['in_transit', 'delivered'].contains(status), status == 'in_transit'),
                    stepItem("Delivered", "Full amount \$${total > 0 ? total : d['deliveryFee'] ?? 0} received", status == 'delivered', false),
                    if (status == 'declined') stepItem("Declined", d['declineReason'] ?? '', true, false),
                  ]),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

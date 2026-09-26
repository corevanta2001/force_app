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
  final searchController = TextEditingController();
  String searchQuery = '';
  bool loading = false;
  bool isCleared = false;

  String formatDateTime(dynamic ts) {
    if (ts == null) return '';
    try {
      DateTime dt;
      if (ts is Timestamp) dt = ts.toDate();
      else if (ts is DateTime) dt = ts;
      else return ts.toString();
      String two(int n) => n.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12 ? 'PM' : 'AM';
      int h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(h)}:${two(dt.minute)} $ampm';
    } catch (_) { return ''; }
  }

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

  Future<void> clearOrderView() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Clear Order?"),
        content: Text("This will clear this order from your view. It will NOT delete it from the system."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: Text("Clear")),
        ],
      ),
    );
    if (ok == true) {
      setState(() => isCleared = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order cleared from view")));
        Navigator.pop(context);
      }
    }
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

  bool matchesSearch(Map<String, dynamic> d, List items) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    if ((d['orderNumber'] ?? '').toString().toLowerCase().contains(q)) return true;
    if ((d['driverName'] ?? '').toString().toLowerCase().contains(q)) return true;
    for (var it in items) {
      if ((it['name'] ?? '').toString().toLowerCase().contains(q)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isCleared) return Scaffold(body: Center(child: Text("Order cleared")));
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Order"),
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: clearOrderView,
            icon: Icon(Icons.clear_all, color: Colors.white, size: 18),
            label: Text("Clear", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
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

          List filteredItems = items;
          if (searchQuery.isNotEmpty) {
            final q = searchQuery.toLowerCase();
            filteredItems = items.where((it) => (it['name'] ?? '').toString().toLowerCase().contains(q)).toList();
          }

          bool searchNoMatch = searchQuery.isNotEmpty && !matchesSearch(d, items);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search by order number / driver / item",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(icon: Icon(Icons.clear), onPressed: () { setState(() { searchController.clear(); searchQuery = ''; }); })
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (v) => setState(() => searchQuery = v.trim()),
              ),
              SizedBox(height: 12),
              if (searchNoMatch)
                Card(color: Colors.orange.shade50, child: Padding(padding: EdgeInsets.all(12), child: Text("No match for '$searchQuery' in order number / driver / items", style: TextStyle(fontSize: 12)))),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(d['orderNumber'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Chip(label: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), backgroundColor: status == 'declined' ? Colors.red.shade100 : status == 'delivered' ? Colors.green.shade100 : Colors.orange.shade100),
                    ]),
                    Text("Created: ${formatDateTime(d['createdAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    if (d['acceptedAt'] != null) Text("Accepted: ${formatDateTime(d['acceptedAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    if (d['inTransitAt'] != null) Text("In Transit: ${formatDateTime(d['inTransitAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    if (d['deliveredAt'] != null) Text("Delivered: ${formatDateTime(d['deliveredAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    if (d['proofSubmittedAt'] != null) Text("Proof sent: ${formatDateTime(d['proofSubmittedAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Divider(),
                    Text("Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ...filteredItems.map((it) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text("• ${it['name']} x ${it['qty']}"),
                        )),
                    if (filteredItems.isEmpty) Text("No items match search", style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                        if (d['termsAcceptedAt'] != null) Text("Accepted at: ${formatDateTime(d['termsAcceptedAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                    ),
                    if (status == 'declined')
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("DECLINED: ${d['declineReason'] ?? 'No reason'}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          if (d['declinedAt'] != null) Text("Declined at: ${formatDateTime(d['declinedAt'])}", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ]),
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
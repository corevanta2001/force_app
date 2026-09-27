import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});
  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  final searchCtrl = TextEditingController();
  String searchQuery = '';

  String formatDateTime(dynamic ts) {
    if (ts == null) return '';
    try {
      DateTime dt;
      if (ts is Timestamp) dt = ts.toDate();
      else if (ts is DateTime) dt = ts;
      else return ts.toString();
      String two(int n) => n.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12? 'PM' : 'AM';
      int h = dt.hour % 12 == 0? 12 : dt.hour % 12;
      return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(h)}:${two(dt.minute)} $ampm';
    } catch (_) { return ''; }
  }

  void _warn(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700));
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  Future<void> confirmClear(BuildContext context, DocumentReference ref, String orderNumber) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [Icon(Icons.clear_all, color: Colors.orange), SizedBox(width: 8), Text("Clear Order?")]),
        content: Text("Clear order $orderNumber from admin view? It will NOT be permanently deleted."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(c, true),
            child: Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.update({'adminCleared': true, 'adminClearedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order cleared from admin view")));
    }
  }

  Future<void> showAcceptDialog(BuildContext context, DocumentReference ref) async {
    final depositCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.check_circle, color: Colors.green)), SizedBox(width: 8), Expanded(child: Text("Accept Order", style: TextStyle(fontWeight: FontWeight.bold)))]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: depositCtrl, decoration: _dec("Deposit Needed \$", Icons.payments), keyboardType: TextInputType.number),
          SizedBox(height: 10),
          TextField(controller: totalCtrl, decoration: _dec("Full Amount \$", Icons.attach_money), keyboardType: TextInputType.number),
          SizedBox(height: 8),
          Text("Remaining will be auto calculated", style: TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (depositCtrl.text.trim().isEmpty || totalCtrl.text.trim().isEmpty) { _warn("Please fill in all fields"); return; }
              double dep = double.tryParse(depositCtrl.text)?? -1;
              double tot = double.tryParse(totalCtrl.text)?? 0;
              if(tot<=0){ _warn("Total must be > 0"); return; }
              await ref.update({'depositAmount': dep, 'totalAmount': tot, 'remainingAmount': tot - dep, 'deliveryFee': tot, 'status': 'accepted_awaiting_deposit', 'acceptedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
              Navigator.pop(c);
            }, child: Text("Accept & Set", style: TextStyle(color: Colors.white))),
        ],
      );
    });
  }

  Future<void> showDeclineDialog(BuildContext context, DocumentReference ref) async {
    final reasonCtrl = TextEditingController();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 8), Text("Decline Order")]),
        content: TextField(controller: reasonCtrl, decoration: _dec("Reason for declining", Icons.message), maxLines: 3),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (reasonCtrl.text.trim().isEmpty) { _warn("Please enter a decline reason"); return; }
              await ref.update({'status': 'declined', 'declineReason': reasonCtrl.text.trim(), 'declinedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
              Navigator.pop(c);
            }, child: Text("Decline", style: TextStyle(color: Colors.white))),
        ],
      );
    });
  }

  Future<void> showInTransitDialog(BuildContext context, DocumentReference ref) async {
    final driverNameCtrl = TextEditingController();
    final driverPhoneCtrl = TextEditingController();
    final vanPlateCtrl = TextEditingController();
    final vanTypeCtrl = TextEditingController();
    final etaCtrl = TextEditingController();
    final driversSnap = await FirebaseFirestore.instance.collection('drivers').limit(20).get();
    final vansSnap = await FirebaseFirestore.instance.collection('vans').where('status', isEqualTo: 'available').limit(20).get();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Icon(Icons.local_shipping, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text("Set In Transit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              decoration: _dec("Select Driver (available)", Icons.person),
              items: driversSnap.docs.map((d)=> DropdownMenuItem(value: d.id, child: Text("${(d.data()['name']??'Driver')} - ${d.data()['phone']??''}", style: TextStyle(fontSize: 12)))).toList(),
              onChanged: (id) async {
                if(id==null) return;
                final dd = await FirebaseFirestore.instance.collection('drivers').doc(id).get();
                final data = dd.data()??{};
                driverNameCtrl.text = data['name']??'';
                driverPhoneCtrl.text = data['phone']??'';
              },
            ),
            SizedBox(height: 8),
            TextField(controller: driverNameCtrl, decoration: _dec("Driver Name", Icons.badge)),
            SizedBox(height: 8),
            TextField(controller: driverPhoneCtrl, decoration: _dec("Driver Phone / Details", Icons.phone)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: _dec("Select Van (available)", Icons.directions_car),
              items: vansSnap.docs.map((d)=> DropdownMenuItem(value: d.id, child: Text("${d.data()['plateNumber']??''} - ${d.data()['type']??''}", style: TextStyle(fontSize: 12)))).toList(),
              onChanged: (id) async {
                if(id==null) return;
                final vd = await FirebaseFirestore.instance.collection('vans').doc(id).get();
                final data = vd.data()??{};
                vanPlateCtrl.text = data['plateNumber']??'';
                vanTypeCtrl.text = data['type']??'';
              },
            ),
            SizedBox(height: 8),
            TextField(controller: vanPlateCtrl, decoration: _dec("Van Plate", Icons.confirmation_number)),
            SizedBox(height: 8),
            TextField(controller: vanTypeCtrl, decoration: _dec("Van Type", Icons.category)),
            SizedBox(height: 8),
            TextField(controller: etaCtrl, decoration: _dec("ETA (e.g. 2 hours)", Icons.access_time)),
          ]),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (driverNameCtrl.text.trim().isEmpty || driverPhoneCtrl.text.trim().isEmpty || vanPlateCtrl.text.trim().isEmpty || vanTypeCtrl.text.trim().isEmpty || etaCtrl.text.trim().isEmpty) { _warn("Please fill in all fields"); return; }
              await ref.update({'driverName': driverNameCtrl.text.trim(), 'driverPhone': driverPhoneCtrl.text.trim(), 'vanPlate': vanPlateCtrl.text.trim(), 'vanType': vanTypeCtrl.text.trim(), 'eta': etaCtrl.text.trim(), 'status': 'in_transit', 'inTransitAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
              Navigator.pop(c);
            }, child: Text("Set In Transit", style: TextStyle(color: Colors.white))),
        ],
      );
    });
  }

  Future<void> showDeliveredDialog(BuildContext context, DocumentReference ref, Map<String, dynamic> data) async {
    final expenseCtrl = TextEditingController(text: (data['expenses']??0).toString());
    final receiptCtrl = TextEditingController();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Icon(Icons.done_all, color: Colors.green), SizedBox(width: 8), Text("Mark Delivered")]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: Text("Full Amount: \$${data['totalAmount']?? data['deliveryFee']??0} will be added to income", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          SizedBox(height: 10),
          TextField(controller: expenseCtrl, decoration: _dec("Expense of Delivery \$", Icons.money_off), keyboardType: TextInputType.number),
          SizedBox(height: 8),
          TextField(controller: receiptCtrl, decoration: _dec("Receipts / Details", Icons.receipt)),
        ]),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (expenseCtrl.text.trim().isEmpty || receiptCtrl.text.trim().isEmpty) { _warn("Please fill in all fields"); return; }
              double exp = double.tryParse(expenseCtrl.text)?? -1;
              if (exp < 0) { _warn("Enter valid expense"); return; }
              double total = (data['totalAmount']?? data['deliveryFee']??0).toDouble();
              await ref.update({'expenses': exp, 'expenseReceipts': FieldValue.arrayUnion([receiptCtrl.text.trim()]), 'status': 'delivered', 'deliveredAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(), 'netProfit': total - exp});
              final today = DateTime.now().toIso8601String().split('T')[0];
              await FirebaseFirestore.instance.collection('daily_income').doc(today).set({'totalIncome': FieldValue.increment(total), 'totalExpenses': FieldValue.increment(exp), 'netProfit': FieldValue.increment(total - exp), 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
              Navigator.pop(c);
            }, child: Text("Mark Delivered", style: TextStyle(color: Colors.white))),
        ],
      );
    });
  }

  bool matchesSearch(Map<String, dynamic> d) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    if ((d['userName']?? '').toString().toLowerCase().contains(q)) return true;
    if ((d['orderNumber']?? '').toString().toLowerCase().contains(q)) return true;
    if ((d['driverName']?? '').toString().toLowerCase().contains(q)) return true;
    if ((d['vanType']?? '').toString().toLowerCase().contains(q)) return true;
    if ((d['vanPlate']?? '').toString().toLowerCase().contains(q)) return true;
    List items = d['items']?? [];
    for (var it in items) { if ((it['name']?? '').toString().toLowerCase().contains(q)) return true; }
    return false;
  }

  Widget _statusChip(String st) {
    Color col = st=='delivered'? Colors.green : st=='declined'? Colors.red : st=='in_transit'? Colors.blue : st.contains('deposit')? Colors.purple : Colors.orange;
    IconData ic = st=='delivered'? Icons.check_circle : st=='declined'? Icons.cancel : st=='in_transit'? Icons.local_shipping : Icons.hourglass_empty;
    return Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: col.withOpacity(0.3))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ic, size: 12, color: col), SizedBox(width: 4), Text(st.replaceAll('_',' ').toUpperCase(), style: TextStyle(fontSize: 9, color: col, fontWeight: FontWeight.bold))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(title: Text("All Orders", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0, centerTitle: true),
      body: Column(
        children: [
          Container(
            color: Color(0xFF0F172A),
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: searchCtrl,
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                labelText: "Search client / driver / items / van",
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: 18),
                suffixIcon: searchQuery.isNotEmpty? IconButton(icon: Icon(Icons.clear, size: 18), onPressed: () => setState(() { searchCtrl.clear(); searchQuery = ''; })) : null,
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) => setState(() => searchQuery = v.trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
              builder: (c,s){
                if(!s.hasData) return Center(child: CircularProgressIndicator());
                var docs = s.data!.docs.where((doc) {
                  var d = doc.data() as Map<String, dynamic>;
                  if (d['adminCleared'] == true) return false;
                  return matchesSearch(d);
                }).toList();
                if(docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox, size: 48, color: Colors.grey.shade300), SizedBox(height: 8), Text("No orders found", style: TextStyle(color: Colors.grey))]));
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (c,i){
                    var doc = docs[i];
                    var d = doc.data() as Map<String, dynamic>;
                    var st = d['status']??'pending';
                    List items = d['items']??[];
                    return Card(
                      elevation: 3, shadowColor: Colors.black12,
                      margin: EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(d['orderNumber']??'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            _statusChip(st),
                            SizedBox(width: 4),
                            InkWell(onTap: () => confirmClear(context, doc.reference, d['orderNumber']?? ''), borderRadius: BorderRadius.circular(8), child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.clear_all, color: Colors.orange, size: 16))),
                          ]),
                          SizedBox(height: 6),
                          Wrap(spacing: 6, children: [
                            Chip(avatar: Icon(Icons.access_time, size: 12), label: Text("Created ${formatDateTime(d['createdAt'])}", style: TextStyle(fontSize: 9)), visualDensity: VisualDensity.compact),
                            if(d['deliveredAt']!=null) Chip(label: Text("Delivered ${formatDateTime(d['deliveredAt'])}", style: TextStyle(fontSize: 9)), visualDensity: VisualDensity.compact),
                          ]),
                          Divider(height: 16),
                          Row(children: [Icon(Icons.person, size: 14, color: Colors.grey), SizedBox(width: 4), Expanded(child: Text("${d['userName']??''} | ${d['userPhone']??''}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)))]),
                          SizedBox(height: 4),
                          Row(children: [Icon(Icons.store, size: 14, color: Colors.grey), SizedBox(width: 4), Expanded(child: Text("${d['storeName']??'Any'} → ${d['dropoffAddress']??''}", style: TextStyle(fontSize: 11, color: Colors.grey.shade700)))]),
                          SizedBox(height: 8),
                          Container(width: double.infinity, padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("ITEMS (${items.length})", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            SizedBox(height: 4),
                           ...items.map((it)=> Padding(padding: EdgeInsets.symmetric(vertical: 1), child: Row(children: [Icon(Icons.circle, size: 6, color: Colors.blueGrey), SizedBox(width: 6), Expanded(child: Text("${it['name']} x ${it['qty']}", style: TextStyle(fontSize: 12)))]))).toList(),
                          ])),
                          SizedBox(height: 8),
                          Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: d['termsAccepted']==true? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: d['termsAccepted']==true? Colors.green.shade200 : Colors.red.shade200)), child: Row(children: [Icon(d['termsAccepted']==true? Icons.verified : Icons.warning, size: 14, color: d['termsAccepted']==true? Colors.green: Colors.red), SizedBox(width: 6), Expanded(child: Text("T&C: ${d['termsAccepted']==true? 'ACCEPTED ✓' : 'NOT ACCEPTED'} ${d['termsAcceptedAt']!=null? '• '+formatDateTime(d['termsAcceptedAt']) : ''}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))])),
                          if(d['depositAmount']!=null) Padding(padding: EdgeInsets.only(top: 8), child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)), child: Text("Deposit: \$${d['depositAmount']} | Total: \$${d['totalAmount']} | Remaining: \$${d['remainingAmount']}\nProof: ${d['proofOfPayment']??'none'}", style: TextStyle(fontSize: 11, color: Colors.purple.shade800)))),
                          if(d['driverName']!=null && d['driverName']!='') Padding(padding: EdgeInsets.only(top: 6), child: Text("Driver: ${d['driverName']} | Van: ${d['vanPlate']} ${d['vanType']} | ETA: ${d['eta']}", style: TextStyle(fontSize: 11))),
                          if(d['declineReason']!=null && d['declineReason']!='') Padding(padding: EdgeInsets.only(top: 6), child: Text("Decline: ${d['declineReason']}", style: TextStyle(fontSize: 11, color: Colors.red))),
                          SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 6, children: [
                            if(st=='pending')...[
                              ElevatedButton.icon(icon: Icon(Icons.check, size: 14), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), onPressed: ()=> showAcceptDialog(context, doc.reference), label: Text("Accept", style: TextStyle(fontSize: 11))),
                              ElevatedButton.icon(icon: Icon(Icons.close, size: 14), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), onPressed: ()=> showDeclineDialog(context, doc.reference), label: Text("Decline", style: TextStyle(fontSize: 11))),
                            ],
                            if(st=='deposit_paid') ElevatedButton.icon(icon: Icon(Icons.local_shipping, size: 14), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: ()=> showInTransitDialog(context, doc.reference), label: Text("To In Transit", style: TextStyle(fontSize: 11))),
                            if(st=='in_transit') ElevatedButton.icon(icon: Icon(Icons.done_all, size: 14), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: ()=> showDeliveredDialog(context, doc.reference, d), label: Text("Mark Delivered", style: TextStyle(fontSize: 11))),
                            if(st=='accepted_awaiting_deposit') Chip(avatar: Icon(Icons.hourglass_empty, size: 14), label: Text("Waiting for deposit proof", style: TextStyle(fontSize: 10))),
                          ]),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
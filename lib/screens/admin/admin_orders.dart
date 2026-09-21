import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrders extends StatelessWidget {
  const AdminOrders({super.key});

  Future<void> showAcceptDialog(BuildContext context, DocumentReference ref) async {
    final depositCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        title: Text("Accept Order - Set Amounts"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: depositCtrl, decoration: InputDecoration(labelText: "Deposit Needed \$"), keyboardType: TextInputType.number),
          SizedBox(height: 8),
          TextField(controller: totalCtrl, decoration: InputDecoration(labelText: "Full Amount Needed (after deposit total) \$"), keyboardType: TextInputType.number),
          SizedBox(height: 8),
          Text("Remaining will be auto calculated", style: TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(onPressed: () async {
            double dep = double.tryParse(depositCtrl.text)??0;
            double tot = double.tryParse(totalCtrl.text)??0;
            if(tot<=0){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Total must >0"))); return; }
            await ref.update({
              'depositAmount': dep,
              'totalAmount': tot,
              'remainingAmount': tot - dep,
              'deliveryFee': tot,
              'status': 'accepted_awaiting_deposit',
              'acceptedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            Navigator.pop(c);
          }, child: Text("Accept & Set")),
        ],
      );
    });
  }

  Future<void> showDeclineDialog(BuildContext context, DocumentReference ref) async {
    final reasonCtrl = TextEditingController();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        title: Text("Decline Order"),
        content: TextField(controller: reasonCtrl, decoration: InputDecoration(labelText: "Reason for declining"), maxLines: 3),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
            await ref.update({
              'status': 'declined',
              'declineReason': reasonCtrl.text.trim(),
              'declinedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
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
        title: Text("Set In Transit - Driver & Van"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Driver (available)"),
              items: driversSnap.docs.map((d)=> DropdownMenuItem(value: d.id, child: Text("${(d.data()['name']??'Driver')} - ${d.data()['phone']??''}"))).toList(),
              onChanged: (id) async {
                if(id==null) return;
                final dd = await FirebaseFirestore.instance.collection('drivers').doc(id).get();
                final data = dd.data()??{};
                driverNameCtrl.text = data['name']??'';
                driverPhoneCtrl.text = data['phone']??'';
              },
            ),
            TextField(controller: driverNameCtrl, decoration: InputDecoration(labelText: "Driver Name")),
            TextField(controller: driverPhoneCtrl, decoration: InputDecoration(labelText: "Driver Phone / Details")),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Van (available)"),
              items: vansSnap.docs.map((d)=> DropdownMenuItem(value: d.id, child: Text("${d.data()['plateNumber']??''} - ${d.data()['type']??''}"))).toList(),
              onChanged: (id) async {
                if(id==null) return;
                final vd = await FirebaseFirestore.instance.collection('vans').doc(id).get();
                final data = vd.data()??{};
                vanPlateCtrl.text = data['plateNumber']??'';
                vanTypeCtrl.text = data['type']??'';
              },
            ),
            TextField(controller: vanPlateCtrl, decoration: InputDecoration(labelText: "Van Plate / Available Van")),
            TextField(controller: vanTypeCtrl, decoration: InputDecoration(labelText: "Van Type")),
            TextField(controller: etaCtrl, decoration: InputDecoration(labelText: "Expected Time of Arrival", hintText: "e.g. 2 hours, Tomorrow 9am")),
          ]),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(onPressed: () async {
            await ref.update({
              'driverName': driverNameCtrl.text.trim(),
              'driverPhone': driverPhoneCtrl.text.trim(),
              'vanPlate': vanPlateCtrl.text.trim(),
              'vanType': vanTypeCtrl.text.trim(),
              'eta': etaCtrl.text.trim(),
              'status': 'in_transit',
              'inTransitAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            Navigator.pop(c);
          }, child: Text("Set In Transit")),
        ],
      );
    });
  }

  Future<void> showDeliveredDialog(BuildContext context, DocumentReference ref, Map<String, dynamic> data) async {
    final expenseCtrl = TextEditingController(text: (data['expenses']??0).toString());
    final receiptCtrl = TextEditingController();
    return showDialog(context: context, builder: (c){
      return AlertDialog(
        title: Text("Mark Delivered - Income & Expense"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Full Amount: \$${data['totalAmount']?? data['deliveryFee']??0} will be added to income"),
          SizedBox(height: 8),
          TextField(controller: expenseCtrl, decoration: InputDecoration(labelText: "Expense of Delivery (set by driver) \$"), keyboardType: TextInputType.number),
          TextField(controller: receiptCtrl, decoration: InputDecoration(labelText: "Receipts / Expense Receipt Link / Details")),
        ]),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(c), child: Text("Cancel")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () async {
            double exp = double.tryParse(expenseCtrl.text)??0;
            double total = (data['totalAmount']?? data['deliveryFee']??0).toDouble();
            await ref.update({
              'expenses': exp,
              'expenseReceipts': FieldValue.arrayUnion([receiptCtrl.text.trim()]),
              'status': 'delivered',
              'deliveredAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'netProfit': total - exp,
            });
            final today = DateTime.now().toIso8601String().split('T')[0];
            await FirebaseFirestore.instance.collection('daily_income').doc(today).set({
              'totalIncome': FieldValue.increment(total),
              'totalExpenses': FieldValue.increment(exp),
              'netProfit': FieldValue.increment(total - exp),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            Navigator.pop(c);
          }, child: Text("Mark Delivered", style: TextStyle(color: Colors.white))),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Orders - Company Control"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (c,s){
          if(!s.hasData) return Center(child: CircularProgressIndicator());
          if(s.data!.docs.isEmpty) return Center(child: Text("No orders"));
          return ListView.builder(
            itemCount: s.data!.docs.length,
            itemBuilder: (c,i){
              var doc = s.data!.docs[i];
              var d = doc.data() as Map<String, dynamic>;
              var st = d['status']??'pending';
              Color stColor = st=='delivered'? Colors.green : st=='declined'? Colors.red : st=='in_transit'? Colors.blue : st.contains('deposit')? Colors.purple : Colors.orange;
              List items = d['items']??[];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(d['orderNumber']??'', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: stColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(st.replaceAll('_',' ').toUpperCase(), style: TextStyle(fontSize: 10, color: stColor, fontWeight: FontWeight.bold))),
                    ]),
                    SizedBox(height: 4),
                    Text("${d['userName']??''} | ${d['userPhone']??''}", style: TextStyle(fontSize: 11)),
                    Text("Store: ${d['storeName']??'Any'} | Delivery: ${d['deliveryLocation']??''} -> ${d['dropoffAddress']??''}", style: TextStyle(fontSize: 11)),
                    SizedBox(height: 4),
                    Text("Items:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                   ...items.map((it)=> Text("• ${it['name']} x ${it['qty']}", style: TextStyle(fontSize: 11))).toList(),
                    SizedBox(height: 4),
                    Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: d['termsAccepted']==true? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(4)), child: Text("T&C: ${d['termsAccepted']==true? 'ACCEPTED (irreversible) ✓' : 'NOT ACCEPTED'} | ${d['termsAcceptedAt']!=null? 'at '+d['termsAcceptedAt'].toString() : ''}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                    if(d['depositAmount']!=null && d['depositAmount']>0) Padding(padding: EdgeInsets.only(top: 4), child: Text("Deposit: \$${d['depositAmount']} | Total: \$${d['totalAmount']} | Remaining: \$${d['remainingAmount']} | Proof: ${d['proofOfPayment']??'none'}", style: TextStyle(fontSize: 11, color: Colors.purple))),
                    if(d['driverName']!=null && d['driverName']!='') Text("Driver: ${d['driverName']} | Van: ${d['vanPlate']} ${d['vanType']} | ETA: ${d['eta']}", style: TextStyle(fontSize: 11)),
                    if(d['declineReason']!=null && d['declineReason']!='') Text("Decline Reason: ${d['declineReason']}", style: TextStyle(fontSize: 11, color: Colors.red)),
                    SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      if(st=='pending')...[
                        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size(0,30)), onPressed: ()=> showAcceptDialog(context, doc.reference), child: Text("Accept + Set Deposit/Total", style: TextStyle(fontSize: 10, color: Colors.white))),
                        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size(0,30)), onPressed: ()=> showDeclineDialog(context, doc.reference), child: Text("Decline", style: TextStyle(fontSize: 10, color: Colors.white))),
                      ],
                      if(st=='deposit_paid') ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size(0,30)), onPressed: ()=> showInTransitDialog(context, doc.reference), child: Text("Set Driver/Van/ETA -> In Transit", style: TextStyle(fontSize: 10, color: Colors.white))),
                      if(st=='in_transit') ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size(0,30)), onPressed: ()=> showDeliveredDialog(context, doc.reference, d), child: Text("Mark Delivered + Expense", style: TextStyle(fontSize: 10, color: Colors.white))),
                      if(st=='accepted_awaiting_deposit') Chip(label: Text("Waiting for client deposit proof", style: TextStyle(fontSize: 9))),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

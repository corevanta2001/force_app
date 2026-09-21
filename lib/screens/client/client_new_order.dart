import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientNewOrder extends StatefulWidget {
  const ClientNewOrder({super.key});
  @override
  State<ClientNewOrder> createState() => _ClientNewOrderState();
}

class _ClientNewOrderState extends State<ClientNewOrder> {
  final deliveryLocation = TextEditingController();
  final storeName = TextEditingController();
  final dropoff = TextEditingController();
  final notes = TextEditingController();
  final List<Map<String, dynamic>> items = [{'name':'','qty':1}];
  bool termsAccepted = false;
  bool loading = false;

  void addItem() => setState(() => items.add({'name':'','qty':1}));
  void removeItem(int i) => setState(() => items.removeAt(i));

  Future<void> submit() async {
    if (deliveryLocation.text.isEmpty || dropoff.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delivery location and dropoff required")));
      return;
    }
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You must accept Terms & Conditions")));
      return;
    }
    if (items.isEmpty || items.any((e) => (e['name'] as String).trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill all item names")));
      return;
    }
    setState(()=> loading=true);
    try{
      final user = FirebaseAuth.instance.currentUser!;
      final uDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final uData = uDoc.data()??{};
      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'userId': user.uid,
        'userName': uData['name']?? user.email?? 'Client',
        'userEmail': user.email,
        'userPhone': uData['phone']??'',
        'items': items.map((e)=> {'name': e['name'].toString().trim(), 'qty': e['qty']}).toList(),
        'deliveryLocation': deliveryLocation.text.trim(),
        'storeName': storeName.text.trim(),
        'pickupAddress': storeName.text.trim().isEmpty? 'Store pickup' : storeName.text.trim(),
        'dropoffAddress': dropoff.text.trim(),
        'deliveryAddress': dropoff.text.trim(),
        'notes': notes.text.trim(),
        'status': 'pending',
        'termsAccepted': true,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'termsText': 'Client accepted T&C at order time - irreversible',
        'depositAmount': 0,
        'totalAmount': 0,
        'remainingAmount': 0,
        'deliveryFee': 0,
        'depositPaid': false,
        'proofOfPayment': '',
        'proofSubmittedAt': null,
        'declineReason': '',
        'driverId': '',
        'driverName': '',
        'driverPhone': '',
        'vanPlate': '',
        'vanType': '',
        'eta': '',
        'expenses': 0,
        'expenseReceipts': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'totalOrders': FieldValue.increment(1)});
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order sent! Waiting for company approval")));
        Navigator.pop(context);
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error $e")));
    }
    setState(()=> loading=false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Order - Shopping List"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("What do you want? (List)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
         ...List.generate(items.length, (i){
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(flex: 3, child: TextField(decoration: InputDecoration(labelText: "Item ${i+1} name", border: OutlineInputBorder(), isDense: true), onChanged: (v)=> items[i]['name']=v)),
                SizedBox(width: 8),
                Expanded(child: TextField(decoration: InputDecoration(labelText: "Qty", border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, controller: TextEditingController(text: items[i]['qty'].toString()), onChanged: (v)=> items[i]['qty']=int.tryParse(v)??1)),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: items.length>1? ()=> removeItem(i) : null),
              ]),
            );
          }),
          TextButton.icon(onPressed: addItem, icon: Icon(Icons.add), label: Text("Add Item")),
          Divider(),
          Text("Store & Location", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: storeName, decoration: InputDecoration(labelText: "Store Name (optional)", hintText: "e.g. Pick n Pay, TM, Enchanter", border: OutlineInputBorder(), prefixIcon: Icon(Icons.store))),
          SizedBox(height: 12),
          TextField(controller: deliveryLocation, decoration: InputDecoration(labelText: "Delivery Location / Area *", hintText: "e.g. Harare CBD, Borrowdale", border: OutlineInputBorder(), prefixIcon: Icon(Icons.my_location))),
          SizedBox(height: 12),
          TextField(controller: dropoff, decoration: InputDecoration(labelText: "Exact Dropoff Address *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))),
          SizedBox(height: 12),
          TextField(controller: notes, decoration: InputDecoration(labelText: "Notes", border: OutlineInputBorder()), maxLines: 2),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Checkbox(value: termsAccepted, onChanged: (v)=> setState(()=> termsAccepted=v!)),
                Expanded(child: Text("I accept Terms & Conditions - I agree to pay deposit when required, pay full amount on delivery, and this acceptance is irreversible and visible to admin.", style: TextStyle(fontSize: 12))),
              ]),
              SizedBox(height: 4),
              Text("By ticking, admin will see: ACCEPTED at ${DateTime.now()}", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F172A)), onPressed: loading? null : submit, child: loading? CircularProgressIndicator(color: Colors.white) : Text("Submit Order for Approval", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }
}

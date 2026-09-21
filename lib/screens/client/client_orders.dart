import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'client_tracking.dart';

class ClientOrders extends StatefulWidget {
  const ClientOrders({super.key});
  @override
  State<ClientOrders> createState() => _ClientOrdersState();
}

class _ClientOrdersState extends State<ClientOrders> {
  String filter = 'all';
  Color getColor(String s){
    if(s=='delivered') return Colors.green;
    if(s=='declined') return Colors.red;
    if(s=='in_transit') return Colors.blue;
    if(s=='accepted_awaiting_deposit' || s=='deposit_paid') return Colors.purple;
    return Colors.orange;
  }
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: Text("My Orders"), backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white),
      body: Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: EdgeInsets.all(8), child: Row(children: [
          for (var f in ['all','pending','accepted_awaiting_deposit','deposit_paid','in_transit','delivered','declined'])
            Padding(padding: EdgeInsets.only(right: 6), child: FilterChip(label: Text(f.replaceAll('_',' ')), selected: filter==f, onSelected: (_)=> setState(()=> filter=f))),
        ])),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots(),
          builder: (c,s){
            if(!s.hasData) return Center(child: CircularProgressIndicator());
            var docs = s.data!.docs;
            if(filter!='all') docs = docs.where((d)=> (d.data() as Map)['status']==filter).toList();
            if(docs.isEmpty) return Center(child: Text("No $filter orders"));
            return ListView.builder(itemCount: docs.length, itemBuilder: (c,i){
              var doc = docs[i];
              var d = doc.data() as Map<String, dynamic>;
              var st = d['status']??'pending';
              return Card(margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: ListTile(
                title: Text(d['orderNumber']??'', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Store: ${d['storeName']??'Any'} | Items: ${(d['items'] as List?)?.length??0}", maxLines: 1),
                  Text("To: ${d['dropoffAddress']??''}", maxLines: 1),
                  if(st=='declined') Text("Declined: ${d['declineReason']??''}", style: TextStyle(color: Colors.red, fontSize: 11)),
                  if(st=='accepted_awaiting_deposit') Text("Deposit needed: \$${d['depositAmount']??0} / Total: \$${d['totalAmount']??0}", style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if((d['totalAmount']??0)>0) Text("\$${d['totalAmount']}", style: TextStyle(fontWeight: FontWeight.bold)) else Text("\$${d['deliveryFee']??0}"),
                  Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: getColor(st).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(st.replaceAll('_',' '), style: TextStyle(fontSize: 9, color: getColor(st)))),
                ]),
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ClientTracking(orderId: doc.id))),
              ));
            });
          },
        )),
      ]),
    );
  }
}

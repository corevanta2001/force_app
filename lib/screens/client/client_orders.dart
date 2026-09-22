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
    if(s=='delivered') return const Color(0xFF10B981);
    if(s=='declined') return const Color(0xFFEF4444);
    if(s=='in_transit') return const Color(0xFF3B82F6);
    if(s=='accepted_awaiting_deposit' || s=='deposit_paid') return const Color(0xFF8B5CF6);
    return const Color(0xFFF59E0B);
  }

  IconData getIcon(String s){
    if(s=='delivered') return Icons.check_circle;
    if(s=='declined') return Icons.cancel;
    if(s=='in_transit') return Icons.local_shipping;
    if(s=='accepted_awaiting_deposit') return Icons.account_balance_wallet;
    if(s=='deposit_paid') return Icons.payments;
    return Icons.hourglass_top_rounded;
  }

  String pretty(String s) => s.replaceAll('_', ' ').toUpperCase();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid==null) return Scaffold(appBar: AppBar(title: const Text("My Orders")), body: const Center(child: Text("Please login again")));

    final filters = ['all','pending','accepted_awaiting_deposit','deposit_paid','in_transit','delivered','declined'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
            for (var f in filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f.replaceAll('_',' '), style: TextStyle(fontSize: 12, fontWeight: filter==f? FontWeight.bold : FontWeight.w400)),
                  selected: filter==f,
                  selectedColor: const Color(0xFF0F172A),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: filter==f? Colors.white : Colors.black87),
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (_)=> setState(()=> filter=f),
                ),
              ),
          ])),
        ),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots(),
          builder: (c,s){
            if(s.hasError){
              return Center(
                child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.warning_amber_rounded, size: 56, color: Colors.orange),
                  const SizedBox(height: 12),
                  const Text("Orders can't load - missing index", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${s.error}", style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: (){}, child: const Text("FIX: Create Index in Firebase Console")),
                  const SizedBox(height: 8),
                  const Text("Go to Firebase Console > Firestore > Indexes > Composite > Create Index\nCollection: orders Fields: userId ASC, createdAt DESC", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                ])),
              );
            }
            if(s.connectionState==ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if(!s.hasData) return const Center(child: CircularProgressIndicator());

            var docs = s.data!.docs;
            if(filter!='all') docs = docs.where((d)=> (d.data() as Map)['status']==filter).toList();

            if(docs.isEmpty){
              return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]), child: Icon(filter=='all'? Icons.shopping_bag_outlined : getIcon(filter), size: 48, color: Colors.grey.shade400)),
                  const SizedBox(height: 16),
                  Text(filter=='all'? "No orders yet" : "No ${filter.replaceAll('_',' ')} orders", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(filter=='all'? "Your orders will appear here.\nPlace your first delivery!" : "You have no orders with this status.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if(filter!='all') OutlinedButton(onPressed: ()=> setState(()=> filter='all'), child: const Text("Show All Orders")),
                ]),
              );
            }

            return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (c,i){
              var doc = docs[i];
              var d = doc.data() as Map<String, dynamic>;
              var st = (d['status']??'pending').toString();
              var col = getColor(st);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0,4))], border: Border(left: BorderSide(color: col, width: 5))),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ClientTracking(orderId: doc.id))),
                  child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(d['orderNumber']??'#${doc.id.substring(0,6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(getIcon(st), size: 14, color: col),
                        const SizedBox(width: 4),
                        Text(pretty(st), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col)),
                      ])),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.store, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(child: Text("Store: ${d['storeName']??'Any Store'} • ${(d['items'] as List?)?.length??0} items", style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(d['totalAmount']!=null && d['totalAmount']>0? "\$${d['totalAmount']}" : "\$${d['deliveryFee']??0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(child: Text(d['dropoffAddress']??'Dropoff location', style: TextStyle(fontSize: 12, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    if(st=='declined' && d['declineReason']!=null) Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.info, size: 14, color: Colors.red), const SizedBox(width: 6), Expanded(child: Text("Declined: ${d['declineReason']}", style: const TextStyle(color: Colors.red, fontSize: 11)))])),
                    if(st=='accepted_awaiting_deposit') Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.account_balance_wallet, size: 14, color: Colors.purple), const SizedBox(width: 6), Text("Deposit: \$${d['depositAmount']??0} / Total: \$${d['totalAmount']??0}", style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold))])),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: Text(d['createdAt']!=null? (d['createdAt'] is Timestamp? (d['createdAt'] as Timestamp).toDate().toString().substring(0,16) : "") : "", style: TextStyle(fontSize: 10, color: Colors.grey.shade500))),
                  ])),
                ),
              );
            });
          },
        )),
      ]),
    );
  }
}

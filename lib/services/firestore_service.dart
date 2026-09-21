import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> markDelivered(String orderId, String receiptUrl, [String? extra]) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'delivered',
      'receiptUrl': receiptUrl,
      'deliveredAt': Timestamp.now(),
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  Future<void> markCanceled(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'canceled'});
  }
}

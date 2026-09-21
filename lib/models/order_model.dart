import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, accepted, inTransit, delivered, canceled }

class OrderModel {
  String id;
  String orderNumber;
  String userId;
  String userName;
  String userPhone;
  List<Map<String, dynamic>> items;
  
  // NEW: Store where to buy from
  String storeName;
  String storeLocation;

  String deliveryLocationText;
  double deliveryLat;
  double deliveryLng;

  double deliveryFee;
  double goodsCost; // NEW: cost of goods set by admin
  double get totalAmount => goodsCost + deliveryFee;

  double depositAmount;
  bool depositPaid;
  String paymentMethod;
  String ecoCashTxId;
  String paymentStatus; // NEW: pending, fee_set, paid

  OrderStatus status;
  String vanId;
  String vanType;
  String deliveryPersonId;
  double vanExpenses;
  String receiptUrl;
  String adminNote; // NEW: admin can add note like "Out of stock"
  
  DateTime createdAt;
  DateTime? estimatedDeliveryAt;
  DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    this.storeName = '',
    this.storeLocation = '',
    required this.deliveryLocationText,
    required this.deliveryLat,
    required this.deliveryLng,
    this.deliveryFee = 0,
    this.goodsCost = 0,
    this.depositAmount = 0,
    this.depositPaid = false,
    this.paymentMethod = 'EcoCash',
    this.ecoCashTxId = '',
    this.paymentStatus = 'pending',
    this.status = OrderStatus.pending,
    this.vanId = '',
    this.vanType = '',
    this.deliveryPersonId = '',
    this.vanExpenses = 0,
    this.receiptUrl = '',
    this.adminNote = '',
    required this.createdAt,
    this.estimatedDeliveryAt,
    this.deliveredAt,
  });

  Map<String, dynamic> toMap() => {
        'orderNumber': orderNumber,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'items': items,
        'storeName': storeName,
        'storeLocation': storeLocation,
        'deliveryLocationText': deliveryLocationText,
        'deliveryLat': deliveryLat,
        'deliveryLng': deliveryLng,
        'deliveryFee': deliveryFee,
        'goodsCost': goodsCost,
        'totalAmount': totalAmount,
        'depositAmount': depositAmount,
        'depositPaid': depositPaid,
        'paymentMethod': paymentMethod,
        'ecoCashTxId': ecoCashTxId,
        'paymentStatus': paymentStatus,
        'status': status.name,
        'vanId': vanId,
        'vanType': vanType,
        'deliveryPersonId': deliveryPersonId,
        'vanExpenses': vanExpenses,
        'receiptUrl': receiptUrl,
        'adminNote': adminNote,
        'createdAt': Timestamp.fromDate(createdAt),
        'estimatedDeliveryAt': estimatedDeliveryAt != null ? Timestamp.fromDate(estimatedDeliveryAt!) : null,
        'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderNumber: m['orderNumber'] ?? '',
      userId: m['userId'] ?? '',
      userName: m['userName'] ?? '',
      userPhone: m['userPhone'] ?? '',
      items: List<Map<String, dynamic>>.from(m['items'] ?? []),
      storeName: m['storeName'] ?? '',
      storeLocation: m['storeLocation'] ?? '',
      deliveryLocationText: m['deliveryLocationText'] ?? '',
      deliveryLat: (m['deliveryLat'] ?? 0).toDouble(),
      deliveryLng: (m['deliveryLng'] ?? 0).toDouble(),
      deliveryFee: (m['deliveryFee'] ?? 0).toDouble(),
      goodsCost: (m['goodsCost'] ?? 0).toDouble(),
      depositAmount: (m['depositAmount'] ?? 0).toDouble(),
      depositPaid: m['depositPaid'] ?? false,
      paymentMethod: m['paymentMethod'] ?? 'EcoCash',
      ecoCashTxId: m['ecoCashTxId'] ?? '',
      paymentStatus: m['paymentStatus'] ?? 'pending',
      status: OrderStatus.values.firstWhere((e) => e.name == m['status'], orElse: () => OrderStatus.pending),
      vanId: m['vanId'] ?? '',
      vanType: m['vanType'] ?? '',
      deliveryPersonId: m['deliveryPersonId'] ?? '',
      vanExpenses: (m['vanExpenses'] ?? 0).toDouble(),
      receiptUrl: m['receiptUrl'] ?? '',
      adminNote: m['adminNote'] ?? '',
      createdAt: (m['createdAt'] as Timestamp).toDate(),
      estimatedDeliveryAt: m['estimatedDeliveryAt'] != null ? (m['estimatedDeliveryAt'] as Timestamp).toDate() : null,
      deliveredAt: m['deliveredAt'] != null ? (m['deliveredAt'] as Timestamp).toDate() : null,
    );
  }
}

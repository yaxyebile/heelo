import 'package:hive/hive.dart';

part 'order.g.dart';

// ── Order Status ──────────────────────────────────────────────────────────────
@HiveType(typeId: 5)
enum OrderStatus {
  @HiveField(0)
  pending,          // User placed order, pending payment confirmation
  @HiveField(1)
  paymentConfirmed, // Admin confirmed money received
  @HiveField(2)
  approved,         // Admin approved order, preparing for delivery
  @HiveField(3)
  outForDelivery,   // Delivery driver picked it up
  @HiveField(4)
  delivered,        // Delivered to customer
  @HiveField(5)
  cancelled,        // Cancelled by admin
}

// ── Payment Method ────────────────────────────────────────────────────────────
@HiveType(typeId: 9)
enum PaymentMethod {
  @HiveField(0)
  evcPlus,
  @HiveField(1)
  edahab,
}

// ── Order Item ────────────────────────────────────────────────────────────────
@HiveType(typeId: 6)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String productId;
  @HiveField(1)
  final String productName;
  @HiveField(2)
  final double price;
  @HiveField(3)
  final int quantity;
  @HiveField(4)
  final String storeId;
  @HiveField(5)
  final String storeName;
  @HiveField(6)
  final String image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.storeId,
    required this.storeName,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'storeId': storeId,
        'storeName': storeName,
        'image': image,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        storeId: json['storeId'] as String,
        storeName: json['storeName'] as String,
        image: json['image'] as String? ?? '',
      );
}

// ── Order ─────────────────────────────────────────────────────────────────────
@HiveType(typeId: 7)
class Order extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final List<OrderItem> items;
  @HiveField(3)
  final double totalAmount;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final OrderStatus status;
  @HiveField(6)
  final String storeId;
  @HiveField(7)
  final PaymentMethod paymentMethod;
  @HiveField(8)
  final bool isPaid;
  @HiveField(9)
  final String? deliveryPersonId;   // Assigned delivery person
  @HiveField(10)
  final DateTime? pickedUpAt;       // When delivery picked up
  @HiveField(11)
  final DateTime? deliveredAt;      // When delivered
  @HiveField(12)
  final String? customerName;
  @HiveField(13)
  final String? customerPhone;
  @HiveField(14)
  final String? customerAddress;
  @HiveField(15)
  final String deliveryType; // 'delivery' or 'pickup'
  @HiveField(16)
  final String? canceledByDriverId;
  @HiveField(17)
  final String? canceledByDriverName;

  bool get isPickup =>
      deliveryType == 'pickup' ||
      (customerAddress?.toLowerCase().contains('[pickup]') ?? false) ||
      (customerAddress?.toLowerCase().contains('pickup') ?? false);

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = OrderStatus.pending,
    required this.storeId,
    required this.paymentMethod,
    this.isPaid = false,
    this.deliveryPersonId,
    this.pickedUpAt,
    this.deliveredAt,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.deliveryType = 'delivery',
    this.canceledByDriverId,
    this.canceledByDriverName,
  });

  Order copyWith({
    OrderStatus? status,
    bool? isPaid,
    String? deliveryPersonId,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? deliveryType,
    String? canceledByDriverId,
    String? canceledByDriverName,
  }) {
    return Order(
      id: id,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      date: date,
      status: status ?? this.status,
      storeId: storeId,
      paymentMethod: paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      deliveryType: deliveryType ?? this.deliveryType,
      canceledByDriverId: canceledByDriverId ?? this.canceledByDriverId,
      canceledByDriverName: canceledByDriverName ?? this.canceledByDriverName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'total_amount': totalAmount,
        'date': date.toUtc().toIso8601String(),
        'status': status.name,
        'store_id': storeId,
        'payment_method': paymentMethod.name,
        'is_paid': isPaid,
        'delivery_person_id': deliveryPersonId,
        'picked_up_at': pickedUpAt?.toUtc().toIso8601String(),
        'delivered_at': deliveredAt?.toUtc().toIso8601String(),
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'delivery_type': deliveryType,
        'canceled_by_driver_id': canceledByDriverId,
        'canceled_by_driver_name': canceledByDriverName,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = rawItems is List
        ? rawItems
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <OrderItem>[];

    final rawDeliveryType = json['delivery_type'] as String?;
    final addr = (json['customer_address'] as String?)?.toLowerCase() ?? '';
    final isPickupAddr = addr.contains('[pickup]') || addr.contains('pickup');

    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      items: itemsList,
      totalAmount: (json['total_amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String).toLocal(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      storeId: json['store_id'] as String,
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == json['payment_method'],
        orElse: () => PaymentMethod.evcPlus,
      ),
      isPaid: json['is_paid'] as bool? ?? false,
      deliveryPersonId: json['delivery_person_id'] as String?,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String).toLocal()
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String).toLocal()
          : null,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerAddress: json['customer_address'] as String?,
      deliveryType: (rawDeliveryType == 'pickup' || isPickupAddr) ? 'pickup' : (rawDeliveryType ?? 'delivery'),
      canceledByDriverId: json['canceled_by_driver_id'] as String?,
      canceledByDriverName: json['canceled_by_driver_name'] as String?,
    );
  }
}

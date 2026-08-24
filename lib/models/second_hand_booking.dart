import 'property_booking.dart'; // Re-use BookingStatus
import 'order.dart'; // PaymentMethod

class SecondHandBooking {
  final String id;
  final String itemId;
  final String itemTitle;
  final String userId;
  final String userName;
  final String userPhone;
  final double totalPrice;
  final double depositAmount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String transactionPhone;
  final BookingStatus status;
  final DateTime createdAt;

  SecondHandBooking({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.totalPrice,
    required this.depositAmount,
    this.currency = 'USD',
    required this.paymentMethod,
    required this.transactionPhone,
    this.status = BookingStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'item_title': itemTitle,
        'user_id': userId,
        'user_name': userName,
        'user_phone': userPhone,
        'total_price': totalPrice,
        'deposit_amount': depositAmount,
        'currency': currency,
        'payment_method': paymentMethod.name,
        'transaction_phone': transactionPhone,
        'status': status.name,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  factory SecondHandBooking.fromJson(Map<String, dynamic> json) {
    return SecondHandBooking(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      itemTitle: json['item_title'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhone: json['user_phone'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.evcPlus,
      ),
      transactionPhone: json['transaction_phone'] as String? ?? '',
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  SecondHandBooking copyWith({BookingStatus? status}) {
    return SecondHandBooking(
      id: id,
      itemId: itemId,
      itemTitle: itemTitle,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      totalPrice: totalPrice,
      depositAmount: depositAmount,
      currency: currency,
      paymentMethod: paymentMethod,
      transactionPhone: transactionPhone,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

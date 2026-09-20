import 'property_listing.dart';
import 'order.dart'; // For PaymentMethod

enum BookingStatus { pending, approved, cancelled }

class PropertyBooking {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final PropertyType propertyType;
  final PropertyListingType listingType;
  final String userId;
  final String userName;
  final String userPhone;
  final double totalPrice;
  final double depositAmount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String transactionPhone;
  final BookingStatus status;
  final bool isFullyPaid;
  final DateTime createdAt;

  PropertyBooking({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyType,
    required this.listingType,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.totalPrice,
    required this.depositAmount,
    this.currency = 'USD',
    required this.paymentMethod,
    required this.transactionPhone,
    this.status = BookingStatus.pending,
    this.isFullyPaid = false,
    required this.createdAt,
  });

  double get remainingAmount => isFullyPaid ? 0.0 : (totalPrice - depositAmount);
  double get paidAmount => isFullyPaid ? totalPrice : depositAmount;

  String get propertyTypeLabel {
    switch (propertyType) {
      case PropertyType.house:
        return 'Guri';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.land:
        return 'Dhul';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.shop:
        return 'Dukaanka';
    }
  }

  String get listingTypeLabel =>
      listingType == PropertyListingType.rent ? 'Kireysi' : 'Iibsi';

  String get statusLabel {
    if (isFullyPaid) return 'Dhamaystiran';
    switch (status) {
      case BookingStatus.pending:
        return 'Sugeysa Ansixin';
      case BookingStatus.approved:
        return 'Waa La Ansixiyay';
      case BookingStatus.cancelled:
        return 'Waa La Diiday';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'property_title': propertyTitle,
        'property_type': propertyType.name,
        'listing_type': listingType.name,
        'user_id': userId,
        'user_name': userName,
        'user_phone': userPhone,
        'total_price': totalPrice,
        'deposit_amount': depositAmount,
        'currency': currency,
        'payment_method': paymentMethod.name,
        'transaction_phone': transactionPhone,
        'status': status.name,
        'is_fully_paid': isFullyPaid,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  factory PropertyBooking.fromJson(Map<String, dynamic> json) {
    return PropertyBooking(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      propertyTitle: json['property_title'] as String,
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['property_type'],
        orElse: () => PropertyType.house,
      ),
      listingType: PropertyListingType.values.firstWhere(
        (e) => e.name == json['listing_type'],
        orElse: () => PropertyListingType.rent,
      ),
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
      isFullyPaid: json['is_fully_paid'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  PropertyBooking copyWith({
    BookingStatus? status,
    bool? isFullyPaid,
  }) {
    return PropertyBooking(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyType: propertyType,
      listingType: listingType,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      totalPrice: totalPrice,
      depositAmount: depositAmount,
      currency: currency,
      paymentMethod: paymentMethod,
      transactionPhone: transactionPhone,
      status: status ?? this.status,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      createdAt: createdAt,
    );
  }
}

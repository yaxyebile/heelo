class Coupon {
  final String id;
  final String code;
  final double discountPercent;
  final double discountFixed;
  final bool isActive;
  final DateTime? validUntil;

  Coupon({
    required this.id,
    required this.code,
    this.discountPercent = 0,
    this.discountFixed = 0,
    this.isActive = true,
    this.validUntil,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json['id'] as String,
        code: json['code'] as String,
        discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
        discountFixed: (json['discount_fixed'] as num?)?.toDouble() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        validUntil: json['valid_until'] != null
            ? DateTime.parse(json['valid_until'] as String).toLocal()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discount_percent': discountPercent,
        'discount_fixed': discountFixed,
        'is_active': isActive,
        'valid_until': validUntil?.toUtc().toIso8601String(),
      };

  double applyDiscount(double total) {
    var result = total;
    if (discountPercent > 0) result -= total * (discountPercent / 100);
    if (discountFixed > 0) result -= discountFixed;
    return result < 0 ? 0 : result;
  }
}

class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        userId: json['user_id'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}

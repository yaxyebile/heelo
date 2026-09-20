import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 4)
class Product extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final String image;
  @HiveField(5)
  final String categoryId;
  @HiveField(6)
  final String storeId;
  @HiveField(7)
  final String storeName;
  @HiveField(8)
  final double rating;
  @HiveField(9)
  final int stock;
  @HiveField(10)
  final bool isApproved;  // Only admin-approved products show to users

  /// Extra gallery URLs (Supabase); primary image in [image].
  final List<String> gallery;

  /// Optional video URL (YouTube, MP4, or Supabase-hosted).
  final String videoUrl;

  final List<String> sizes;
  final List<String> colors;
  final double? originalPrice;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount ? (((originalPrice! - price) / originalPrice!) * 100).round() : 0;

  /// 7% platform fee markup applied to every product item
  double get priceWithFee => double.parse((price * 1.07).toStringAsFixed(2));
  double get platformFee => double.parse((price * 0.07).toStringAsFixed(2));

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.storeId,
    required this.storeName,
    this.rating = 0.0,
    required this.stock,
    this.isApproved = false,
    this.gallery = const [],
    this.videoUrl = '',
    this.sizes = const [],
    this.colors = const [],
    this.originalPrice,
  });

  List<String> get allImages {
    if (gallery.isNotEmpty) return gallery;
    if (image.isNotEmpty) return [image];
    return [];
  }

  static List<String> _parseList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    String? image,
    List<String>? gallery,
    String? videoUrl,
    String? categoryId,
    String? storeId,
    String? storeName,
    double? rating,
    int? stock,
    bool? isApproved,
    List<String>? sizes,
    List<String>? colors,
    double? originalPrice,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      isApproved: isApproved ?? this.isApproved,
      gallery: gallery ?? this.gallery,
      videoUrl: videoUrl ?? this.videoUrl,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'images': gallery.isNotEmpty ? gallery : (image.isNotEmpty ? [image] : []),
        'category_id': categoryId,
        'store_id': storeId,
        'store_name': storeName,
        'rating': rating,
        'stock': stock,
        'is_approved': isApproved,
        'video_url': videoUrl.isNotEmpty ? videoUrl : null,
        'sizes': sizes.isNotEmpty ? sizes : [],
        'colors': colors.isNotEmpty ? colors : [],
        'original_price': originalPrice,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    final gallery = _parseList(json['images']);
    final parsedSizes = _parseList(json['sizes']);
    final parsedColors = _parseList(json['colors']);
    final primary = json['image'] as String? ?? '';
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      image: primary.isNotEmpty ? primary : (gallery.isNotEmpty ? gallery.first : ''),
      categoryId: json['category_id'] as String,
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: json['stock'] as int? ?? 0,
      isApproved: json['is_approved'] as bool? ?? false,
      gallery: gallery,
      videoUrl: json['video_url'] as String? ?? '',
      sizes: parsedSizes,
      colors: parsedColors,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
    );
  }
}

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

  final List<String> sizes;
  final List<String> colors;

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
    this.sizes = const [],
    this.colors = const [],
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
    String? categoryId,
    String? storeId,
    String? storeName,
    double? rating,
    int? stock,
    bool? isApproved,
    List<String>? sizes,
    List<String>? colors,
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
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
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
        'sizes': sizes.isNotEmpty ? sizes : [],
        'colors': colors.isNotEmpty ? colors : [],
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
      sizes: parsedSizes,
      colors: parsedColors,
    );
  }
}

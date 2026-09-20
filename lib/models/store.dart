import 'package:hive/hive.dart';

part 'store.g.dart';

@HiveType(typeId: 2)
class Store extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String logo;
  @HiveField(3)
  final String banner;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final String contact;
  @HiveField(6)
  final double rating;
  @HiveField(7)
  final int followers;
  @HiveField(8)
  final bool isApproved;
  @HiveField(9)
  final String ownerId;
  @HiveField(10)
  final bool hasDelivery;
  @HiveField(11)
  final String? evcNumber;
  @HiveField(12)
  final String? edahabNumber;

  final bool isBanned;
  final bool isRestaurant;

  Store({
    required this.id,
    required this.name,
    required this.logo,
    required this.banner,
    required this.description,
    required this.contact,
    this.rating = 0.0,
    this.followers = 0,
    this.isApproved = false,
    required this.ownerId,
    this.hasDelivery = true,
    this.evcNumber,
    this.edahabNumber,
    this.isBanned = false,
    this.isRestaurant = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo': logo,
        'banner': banner,
        'description': description,
        'contact': contact,
        'rating': rating,
        'followers': followers,
        'is_approved': isApproved,
        'owner_id': ownerId,
        'has_delivery': hasDelivery,
        'evc_number': evcNumber,
        'edahab_number': edahabNumber,
        'is_banned': isBanned,
        'is_restaurant': isRestaurant,
      };

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        logo: json['logo'] as String? ?? '',
        banner: json['banner'] as String? ?? '',
        description: json['description'] as String? ?? '',
        contact: json['contact'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        followers: json['followers'] as int? ?? 0,
        isApproved: json['is_approved'] as bool? ?? false,
        ownerId: json['owner_id'] as String,
        hasDelivery: json['has_delivery'] as bool? ?? true,
        evcNumber: json['evc_number'] as String?,
        edahabNumber: json['edahab_number'] as String?,
        isBanned: json['is_banned'] as bool? ?? false,
        isRestaurant: json['is_restaurant'] as bool? ?? false,
      );
}

enum PropertyType { house, apartment, land, villa, shop }
enum PropertyListingType { rent, sale }

class PropertyListing {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final PropertyType propertyType;
  final PropertyListingType listingType;
  final double price;
  final String currency; // e.g. 'USD', 'SOS', 'ETB', 'AED'
  final String location;
  final double areaSqm;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final List<String> amenities;
  final bool isApproved;
  final bool isAvailable;
  final bool isReserved;
  final String? videoUrl;
  final DateTime createdAt;

  PropertyListing({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.propertyType,
    required this.listingType,
    required this.price,
    required this.currency,
    required this.location,
    required this.areaSqm,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.images = const [],
    this.amenities = const [],
    this.isApproved = false,
    this.isAvailable = true,
    this.isReserved = false,
    this.videoUrl,
    required this.createdAt,
  });

  String get primaryImage => images.isNotEmpty ? images.first : '';

  String get availabilityLabel {
    if (isReserved) return 'Waa La Carbuntay';
    if (!isAvailable) return 'Lama Heli Karo';
    return 'Diyaar';
  }

  String get formattedPrice {
    final formatted = price >= 1000000
        ? '${(price / 1000000).toStringAsFixed(1)}M'
        : price >= 1000
            ? '${(price / 1000).toStringAsFixed(0)}K'
            : price.toStringAsFixed(0);
    return '$currency $formatted';
  }

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

  static List<String> _parseList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'owner_id': ownerId,
        'owner_name': ownerName,
        'owner_phone': ownerPhone,
        'property_type': propertyType.name,
        'listing_type': listingType.name,
        'price': price,
        'currency': currency,
        'location': location,
        'area_sqm': areaSqm,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'images': images,
        'amenities': amenities,
        'is_approved': isApproved,
        'is_available': isAvailable,
        'is_reserved': isReserved,
        'video_url': videoUrl,
        'created_at': createdAt.toIso8601String(),
      };

  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    return PropertyListing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      ownerPhone: json['owner_phone'] as String? ?? '',
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == (json['property_type'] as String? ?? 'house'),
        orElse: () => PropertyType.house,
      ),
      listingType: PropertyListingType.values.firstWhere(
        (e) => e.name == (json['listing_type'] as String? ?? 'rent'),
        orElse: () => PropertyListingType.rent,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      location: json['location'] as String? ?? '',
      areaSqm: (json['area_sqm'] as num?)?.toDouble() ?? 0,
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      images: _parseList(json['images']),
      amenities: _parseList(json['amenities']),
      isApproved: json['is_approved'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      isReserved: json['is_reserved'] as bool? ?? false,
      videoUrl: json['video_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  PropertyListing copyWith({
    String? title,
    String? description,
    bool? isApproved,
    bool? isAvailable,
    bool? isReserved,
    String? videoUrl,
    double? price,
    String? currency,
  }) {
    return PropertyListing(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      propertyType: propertyType,
      listingType: listingType,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      location: location,
      areaSqm: areaSqm,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      images: images,
      amenities: amenities,
      isApproved: isApproved ?? this.isApproved,
      isAvailable: isAvailable ?? this.isAvailable,
      isReserved: isReserved ?? this.isReserved,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt,
    );
  }
}

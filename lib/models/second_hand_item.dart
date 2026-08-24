// ─────────────────────────────────────────────
// second_hand_item.dart  –  Alaabta Casriga ah
// ─────────────────────────────────────────────

enum SecondHandCategory {
  electronics,   // Tignoolajiyada
  clothing,      // Dharka
  furniture,     // Alaabta Guriga
  vehicles,      // Gaadiidka
  sports,        // Cayaaraha
  books,         // Buugaagta
  appliances,    // Mishiimadaha
  other,         // Kale
}

enum SecondHandCondition {
  likeNew,    // Sida cusub
  good,       // Wanaagsan
  fair,       // Dhexdhexaad
  poor,       // Xaalad xumo
}

enum SecondHandStatus {
  pending,    // Sugeysa ansixin admin
  approved,   // La ansixiyay – soo muuqda
  reserved,   // Waa La Carbuntay
  sold,       // Waa la gatay
  rejected,   // Admin diidey
}

class SecondHandItem {
  final String id;
  final String title;
  final String description;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final SecondHandCategory category;
  final SecondHandCondition condition;
  final double price;
  final String currency;
  final String location;
  final List<String> images;
  final SecondHandStatus status;
  final String? videoUrl;
  final int stock;
  final DateTime createdAt;

  SecondHandItem({
    required this.id,
    required this.title,
    required this.description,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.category,
    required this.condition,
    required this.price,
    this.currency = 'USD',
    required this.location,
    this.images = const [],
    this.status = SecondHandStatus.pending,
    this.videoUrl,
    this.stock = 1,
    required this.createdAt,
  });

  bool get inStock => stock > 0;

  String get primaryImage => images.isNotEmpty ? images.first : '';

  String get categoryLabel {
    switch (category) {
      case SecondHandCategory.electronics:  return 'Tignoolajiyada';
      case SecondHandCategory.clothing:     return 'Dharka';
      case SecondHandCategory.furniture:    return 'Alaabta Guriga';
      case SecondHandCategory.vehicles:     return 'Gaadiidka';
      case SecondHandCategory.sports:       return 'Cayaaraha';
      case SecondHandCategory.books:        return 'Buugaagta';
      case SecondHandCategory.appliances:   return 'Mishiimadaha';
      case SecondHandCategory.other:        return 'Kale';
    }
  }

  String get conditionLabel {
    switch (condition) {
      case SecondHandCondition.likeNew: return 'Sida Cusub';
      case SecondHandCondition.good:    return 'Xaalad Wanaagsan';
      case SecondHandCondition.fair:    return 'Dhexdhexaad';
      case SecondHandCondition.poor:    return 'Xaalad Xumo';
    }
  }

  String get statusLabel {
    switch (status) {
      case SecondHandStatus.pending:  return 'Sugeysa Ansixin';
      case SecondHandStatus.approved: return 'La Daabacay';
      case SecondHandStatus.reserved: return 'Waa La Carbuntay';
      case SecondHandStatus.sold:     return 'Waa La Gatay';
      case SecondHandStatus.rejected: return 'Waa La Diidey';
    }
  }

  String get formattedPrice {
    final f = price >= 1000000
        ? '${(price / 1000000).toStringAsFixed(1)}M'
        : price >= 1000
            ? '${(price / 1000).toStringAsFixed(0)}K'
            : price.toStringAsFixed(0);
    return '$currency $f';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'seller_phone': sellerPhone,
        'category': category.name,
        'condition': condition.name,
        'price': price,
        'currency': currency,
        'location': location,
        'images': images,
        'status': status.name,
        'video_url': videoUrl,
        'stock': stock,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  factory SecondHandItem.fromJson(Map<String, dynamic> json) {
    return SecondHandItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      sellerName: json['seller_name'] as String? ?? '',
      sellerPhone: json['seller_phone'] as String? ?? '',
      category: SecondHandCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SecondHandCategory.other,
      ),
      condition: SecondHandCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => SecondHandCondition.good,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      location: json['location'] as String? ?? '',
      images: _parseList(json['images']),
      status: SecondHandStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SecondHandStatus.pending,
      ),
      videoUrl: json['video_url'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  static List<String> _parseList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    return [];
  }

  SecondHandItem copyWith({SecondHandStatus? status, String? videoUrl, int? stock}) {
    return SecondHandItem(
      id: id,
      title: title,
      description: description,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      category: category,
      condition: condition,
      price: price,
      currency: currency,
      location: location,
      images: images,
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
      stock: stock ?? this.stock,
      createdAt: createdAt,
    );
  }
}

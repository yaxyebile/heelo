class CargoAd {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String phone;
  final DateTime createdAt;

  CargoAd({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.description = '',
    this.phone = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'description': description,
        'phone': phone,
        'created_at': createdAt.toIso8601String(),
      };

  factory CargoAd.fromJson(Map<String, dynamic> json) => CargoAd(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String? ?? '',
        description: json['description'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at']),
      );
}

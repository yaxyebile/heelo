import 'package:hive/hive.dart';

part 'promo_banner.g.dart';

@HiveType(typeId: 8)
class PromoBanner {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String imageUrl;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String tag;

  @HiveField(4)
  final String btnText;

  @HiveField(5)
  final String colorHex;

  PromoBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.tag,
    required this.btnText,
    required this.colorHex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'title': title,
        'tag': tag,
        'btn_text': btnText,
        'color_hex': colorHex,
      };

  factory PromoBanner.fromJson(Map<String, dynamic> json) => PromoBanner(
        id: json['id'] as String,
        imageUrl: json['image_url'] as String,
        title: json['title'] as String,
        tag: json['tag'] as String? ?? '',
        btnText: json['btn_text'] as String? ?? 'Shop Now',
        colorHex: json['color_hex'] as String? ?? '0xFFFF6B00',
      );
}

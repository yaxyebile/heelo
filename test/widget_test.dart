import 'package:flutter_test/flutter_test.dart';
import 'package:hakabo/models/product.dart';

void main() {
  test('Product model JSON serialization test', () {
    final json = {
      'id': 'test-prod-123',
      'name': 'Wireless Charger',
      'description': 'Description here',
      'price': 49.99,
      'image': 'https://example.com/primary.jpg',
      'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
      'category_id': 'cat-9',
      'store_id': 'store-4',
      'store_name': 'My Store',
      'rating': 4.5,
      'stock': 12,
      'is_approved': true,
      'video_url': 'https://example.com/demo.mp4',
    };

    final product = Product.fromJson(json);

    expect(product.id, 'test-prod-123');
    expect(product.name, 'Wireless Charger');
    expect(product.price, 49.99);
    expect(product.gallery.length, 2);
    expect(product.videoUrl, 'https://example.com/demo.mp4');
    expect(product.isApproved, true);
  });
}

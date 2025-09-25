import 'package:flutter_test/flutter_test.dart';
import 'package:ecom/models/product.dart';

void main() {
  test('Product.fromMap parse les types hétérogènes', () {
    final map = {
      'name': 'X',
      'description': 'Y',
      'price': 12,
      'imageUrl': 'url',
      'category': 'cat',
      'stock': '5',
      'isAvailable': true,
      'rating': 4,
      'reviewCount': 10,
      'isFeatured': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    final p = Product.fromMap(map, 'id1');
    expect(p.id, 'id1');
    expect(p.name, 'X');
    expect(p.price, 12.0);
    expect(p.stock, 5);
    expect(p.isFeatured, true);
  });
}



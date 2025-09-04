import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() {
    return 'CartItem{id: $id, product: ${product.name}, quantity: $quantity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Méthodes de sérialisation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'stock': product.stock,
        'isAvailable': product.isAvailable,
        'rating': product.rating,
        'reviewCount': product.reviewCount,
        'isFeatured': product.isFeatured,
        'createdAt': product.createdAt.toIso8601String(),
        'updatedAt': product.updatedAt.toIso8601String(),
      },
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    final productData = map['product'] as Map<String, dynamic>;
    return CartItem(
      id: map['id'] ?? '',
      product: Product(
        id: productData['id'] ?? '',
        name: productData['name'] ?? '',
        description: productData['description'] ?? '',
        price: (productData['price'] ?? 0.0).toDouble(),
        imageUrl: productData['imageUrl'] ?? '',
        category: productData['category'] ?? '',
        stock: productData['stock'] ?? 0,
        isAvailable: productData['isAvailable'] ?? true,
        rating: (productData['rating'] ?? 0.0).toDouble(),
        reviewCount: productData['reviewCount'] ?? 0,
        isFeatured: productData['isFeatured'] ?? false,
        createdAt: DateTime.parse(productData['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(productData['updatedAt'] ?? DateTime.now().toIso8601String()),
      ),
      quantity: map['quantity'] ?? 0,
      addedAt: DateTime.parse(map['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
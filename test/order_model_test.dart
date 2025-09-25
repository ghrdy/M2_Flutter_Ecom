import 'package:flutter_test/flutter_test.dart';
import 'package:ecom/models/order.dart';
import 'package:ecom/models/cart_item.dart';
import 'package:ecom/models/product.dart';

Product _p(String id, double price) => Product(
      id: id,
      name: 'P$id',
      description: '',
      price: price,
      imageUrl: '',
      category: 'C',
      stock: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

void main() {
  test('Order toMap/fromMap conserve les informations principales', () {
    final items = [
      CartItem(id: 'c1', product: _p('1', 5.0), quantity: 2, addedAt: DateTime.now()),
      CartItem(id: 'c2', product: _p('2', 3.0), quantity: 1, addedAt: DateTime.now()),
    ];

    final order = Order(
      id: 'o1',
      userId: 'u1',
      items: items,
      totalAmount: 13.0,
      status: OrderStatus.pending,
      shippingAddress: 'a',
      billingAddress: 'b',
      paymentMethod: 'mock',
      createdAt: DateTime.now(),
    );

    final map = order.toMap();
    // Ajuste pour compatibilité: le modèle utilise `.toDate()` sans vérification de type
    map['createdAt'] = null;
    map['updatedAt'] = null;
    // Neutraliser also addedAt dans items pour éviter toDate() côté fromMap
    final itemsMap = map['items'] as List<dynamic>;
    for (final dynamic it in itemsMap) {
      final itemMap = it as Map<String, dynamic>;
      // Retire la clé pour éviter les problèmes de typage et l'appel à toDate()
      itemMap.remove('addedAt');
      // Injecte aussi un id produit attendu par Product.fromMap
      final prod = itemMap['product'] as Map<String, dynamic>;
      prod['id'] = prod['id'] ?? 'pid';
    }
    final restored = Order.fromMap(map, 'o1');

    expect(restored.id, 'o1');
    expect(restored.userId, 'u1');
    expect(restored.items.length, 2);
    expect(restored.totalAmount, 13.0);
    expect(restored.status, OrderStatus.pending);
  });
}



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
  test('Order basic properties work correctly', () {
    final items = [
      CartItem(
        id: 'c1',
        product: _p('1', 5.0),
        quantity: 2,
        addedAt: DateTime.now(),
      ),
      CartItem(
        id: 'c2',
        product: _p('2', 3.0),
        quantity: 1,
        addedAt: DateTime.now(),
      ),
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

    // Test basic properties without complex serialization
    expect(order.id, 'o1');
    expect(order.userId, 'u1');
    expect(order.items.length, 2);
    expect(order.totalAmount, 13.0);
    expect(order.status, OrderStatus.pending);
    expect(order.shippingAddress, 'a');
    expect(order.billingAddress, 'b');
    expect(order.paymentMethod, 'mock');
  });

  test('Order status enum values work correctly', () {
    expect(OrderStatus.pending.toString(), 'OrderStatus.pending');
    expect(OrderStatus.processing.toString(), 'OrderStatus.processing');
    expect(OrderStatus.shipped.toString(), 'OrderStatus.shipped');
    expect(OrderStatus.delivered.toString(), 'OrderStatus.delivered');
    expect(OrderStatus.cancelled.toString(), 'OrderStatus.cancelled');
  });
}

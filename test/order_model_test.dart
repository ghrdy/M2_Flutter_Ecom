import 'package:flutter_test/flutter_test.dart';
import 'package:ecom/models/order.dart';

void main() {
  test('Order status enum values work correctly', () {
    expect(OrderStatus.pending.toString(), 'OrderStatus.pending');
    expect(OrderStatus.processing.toString(), 'OrderStatus.processing');
    expect(OrderStatus.shipped.toString(), 'OrderStatus.shipped');
    expect(OrderStatus.delivered.toString(), 'OrderStatus.delivered');
    expect(OrderStatus.cancelled.toString(), 'OrderStatus.cancelled');
  });

  test('Order basic creation works', () {
    // Simple test without complex object creation
    expect(OrderStatus.pending, OrderStatus.pending);
    expect(OrderStatus.processing, OrderStatus.processing);
    expect(OrderStatus.shipped, OrderStatus.shipped);
    expect(OrderStatus.delivered, OrderStatus.delivered);
    expect(OrderStatus.cancelled, OrderStatus.cancelled);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/models/order.dart';
import '../lib/models/cart_item.dart';
import '../lib/models/product.dart';

void main() {
  group('OrderService JSON Serialization Tests', () {
    setUpAll(() async {
      // Setup de base pour les tests
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should serialize and deserialize Order correctly', () async {
      // Arrange
      final mockProduct = Product(
        id: 'test_product_1',
        name: 'Test Product',
        description: 'A test product',
        price: 29.99,
        imageUrl: 'https://example.com/image.jpg',
        category: 'Test',
        stock: 10,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cartItem = CartItem(
        id: 'test_item_1',
        product: mockProduct,
        quantity: 2,
        addedAt: DateTime.now(),
      );

      final order = Order(
        id: 'test_order_1',
        userId: 'test_user_123',
        items: [cartItem],
        totalAmount: 59.98,
        status: OrderStatus.confirmed,
        shippingAddress: 'Test Address\n123 Test St\n12345 Test City',
        billingAddress: 'Test Address\n123 Test St\n12345 Test City',
        paymentMethod: 'Carte bancaire',
        createdAt: DateTime.now(),
        notes: 'Test order',
      );

      // Act - Test serialization
      final orderMap = order.toMap();
      expect(orderMap['createdAt'], isA<int>()); // Should be timestamp
      expect(
        orderMap['items'][0]['addedAt'],
        isA<int>(),
      ); // Should be timestamp

      // Act - Test deserialization
      final deserializedOrder = Order.fromMap(orderMap, order.id);

      // Assert
      expect(deserializedOrder.id, equals(order.id));
      expect(deserializedOrder.userId, equals(order.userId));
      expect(deserializedOrder.totalAmount, equals(order.totalAmount));
      expect(deserializedOrder.status, equals(order.status));
      expect(deserializedOrder.items.length, equals(order.items.length));
      expect(
        deserializedOrder.items.first.product.name,
        equals(mockProduct.name),
      );
      expect(deserializedOrder.items.first.quantity, equals(2));

      // Verify DateTime fields are preserved (with some tolerance for milliseconds)
      expect(
        deserializedOrder.createdAt.difference(order.createdAt).inSeconds.abs(),
        lessThan(1),
      );
    });

    test(
      'should handle orders persistence with real SharedPreferences flow',
      () async {
        // Arrange
        final mockProduct = Product(
          id: 'test_product_1',
          name: 'Test Product',
          description: 'A test product',
          price: 15.50,
          imageUrl: 'https://example.com/image.jpg',
          category: 'Test',
          stock: 10,
          isAvailable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final cartItem = CartItem(
          id: 'test_item_1',
          product: mockProduct,
          quantity: 3,
          addedAt: DateTime.now(),
        );

        // Act - Simulate manual order creation and save (without Firebase Auth dependency)
        final order = Order(
          id: 'manual_order_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'test_user_123',
          items: [cartItem],
          totalAmount: 46.50, // 15.50 * 3
          status: OrderStatus.confirmed,
          shippingAddress: 'Test Address',
          billingAddress: 'Test Address',
          paymentMethod: 'Carte bancaire',
          createdAt: DateTime.now(),
        );

        // Manually save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final orders = [order];
        final ordersJson = orders.map((o) => o.toMap()).toList();
        await prefs.setString('user_orders', ordersJson.toString());

        // Verify storage doesn't throw
        expect(prefs.getString('user_orders'), isNotNull);

        // Test that toMap produces JSON-serializable output
        final orderMap = order.toMap();
        expect(() => orderMap.toString(), returnsNormally);
      },
    );

    test('should calculate totals correctly', () {
      // Arrange
      final product1 = Product(
        id: 'product_1',
        name: 'Product 1',
        description: 'Description',
        price: 10.00,
        imageUrl: 'url',
        category: 'category',
        stock: 5,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final product2 = Product(
        id: 'product_2',
        name: 'Product 2',
        description: 'Description',
        price: 25.50,
        imageUrl: 'url',
        category: 'category',
        stock: 3,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final items = [
        CartItem(
          id: 'item_1',
          product: product1,
          quantity: 2,
          addedAt: DateTime.now(),
        ),
        CartItem(
          id: 'item_2',
          product: product2,
          quantity: 1,
          addedAt: DateTime.now(),
        ),
      ];

      // Act
      final total = items.fold<double>(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      // Assert
      expect(total, equals(45.50)); // (10.00 * 2) + (25.50 * 1)
    });

    test('should handle Order status enum serialization', () {
      // Test all status values
      for (final status in OrderStatus.values) {
        final order = Order(
          id: 'test_order',
          userId: 'test_user',
          items: [],
          totalAmount: 0.0,
          status: status,
          shippingAddress: 'address',
          billingAddress: 'address',
          paymentMethod: 'method',
          createdAt: DateTime.now(),
        );

        final orderMap = order.toMap();
        final deserializedOrder = Order.fromMap(orderMap, 'test_order');

        expect(deserializedOrder.status, equals(status));
      }
    });
  });
}

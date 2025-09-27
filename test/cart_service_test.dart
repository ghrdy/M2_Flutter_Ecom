import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom/services/cart_service.dart';
import 'package:ecom/models/product.dart';

Product _p(String id, {double price = 5.0}) => Product(
  id: id,
  name: 'P$id',
  description: '',
  price: price,
  imageUrl: '',
  category: 'C',
  stock: 100,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartService', () {
    test('ajout met à jour quantité et total', () async {
      final cart = CartService();
      await cart.clearCart();

      await cart.addItem(_p('1', price: 10.0), 2);
      await cart.addItem(_p('2', price: 3.0), 1);

      expect(cart.itemCount, 3);
      expect(cart.totalPrice, 23.0);
    });

    test('updateQuantity modifie quantité et total', () async {
      final cart = CartService();
      await cart.clearCart();

      final prod = _p('1', price: 7.0);
      await cart.addItem(prod, 1);
      await cart.updateQuantity('1', 3);

      expect(cart.getQuantity('1'), 3);
      expect(cart.totalPrice, 21.0);
    });

    test('removeItem supprime et met à jour total', () async {
      final cart = CartService();
      await cart.clearCart();

      await cart.addItem(_p('1', price: 4.0), 1);
      await cart.addItem(_p('2', price: 6.0), 2);
      await cart.removeItem('2');

      expect(cart.itemCount, 1);
      expect(cart.totalPrice, 4.0);
    });
  });
}

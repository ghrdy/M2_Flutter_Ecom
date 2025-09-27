import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService;

  CartViewModel({CartService? cartService})
    : _cartService = cartService ?? CartService();

  bool _isLoading = false;
  List<CartItem> _items = [];

  bool get isLoading => _isLoading;
  List<CartItem> get items => _items;

  Future<void> loadCart() async {
    _setLoading(true);
    _items = await _cartService.getItems();
    _setLoading(false);
  }

  Future<void> add(Product product, int quantity) async {
    await _cartService.addItem(product, quantity);
    await loadCart();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await _cartService.removeItem(productId);
    } else {
      await _cartService.updateQuantity(productId, quantity);
    }
    await loadCart();
  }

  Future<void> remove(String productId) async {
    await _cartService.removeItem(productId);
    await loadCart();
  }

  Future<void> clear() async {
    await _cartService.clearCart();
    await loadCart();
  }

  double get subtotal => _items.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

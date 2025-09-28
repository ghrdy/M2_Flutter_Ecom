import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class CheckoutViewModel extends ChangeNotifier {
  final CartService _cartService;
  final OrderService _orderService;

  CheckoutViewModel({CartService? cartService, OrderService? orderService})
    : _cartService = cartService ?? CartService(),
      _orderService = orderService ?? OrderService();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  Future<void> loadCart() async {
    _items = await _cartService.getItems();
    notifyListeners();
  }

  double get subtotal => _items.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double shippingCost({double freeFrom = 50.0, double cost = 5.99}) {
    return subtotal > freeFrom ? 0.0 : cost;
  }

  double total({double freeFrom = 50.0, double cost = 5.99}) {
    return subtotal + shippingCost(freeFrom: freeFrom, cost: cost);
  }

  Future<String?> placeOrder({
    required String shippingAddress,
    required String billingAddress,
    required String paymentMethod,
    String? notes,
    double freeFrom = 50.0,
    double cost = 5.99,
  }) async {
    if (_items.isEmpty) return null;
    _setProcessing(true);
    try {
      final shippingCostValue = shippingCost(freeFrom: freeFrom, cost: cost);
      final orderId = await _orderService.createOrder(
        items: _items,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        paymentMethod: paymentMethod,
        notes: notes,
        shippingCost: shippingCostValue,
      );
      await _cartService.clearCart();
      await loadCart();
      return orderId;
    } catch (_) {
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }
}

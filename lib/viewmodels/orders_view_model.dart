import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrderService _orderService;

  OrdersViewModel({OrderService? orderService})
    : _orderService = orderService ?? OrderService();

  bool _isLoading = false;
  List<Order> _orders = [];

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;

  Future<void> loadOrders() async {
    _setLoading(true);
    _orders = await _orderService.getUserOrders();
    _setLoading(false);
  }

  Future<int> get count async => _orderService.getOrderCount();
  Future<double> get totalSpent async => _orderService.getTotalSpent();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

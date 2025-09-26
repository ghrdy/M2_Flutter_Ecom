import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  static const String _ordersKey = 'user_orders';
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  /// Créer une nouvelle commande à partir des items du panier
  Future<String> createOrder({
    required List<CartItem> items,
    required String shippingAddress,
    required String billingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (items.isEmpty) {
      throw Exception('Le panier est vide');
    }

    // Calculer le montant total
    final totalAmount = items.fold<double>(
      0.0,
      (total, item) => total + (item.product.price * item.quantity),
    );

    // Générer un ID unique pour la commande
    final orderId =
        'order_${DateTime.now().millisecondsSinceEpoch}_${user.uid.substring(0, 8)}';

    final order = Order(
      id: orderId,
      userId: user.uid,
      items: items,
      totalAmount: totalAmount,
      status: OrderStatus.confirmed,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      notes: notes,
    );

    await _saveOrder(order);
    return orderId;
  }

  /// Sauvegarder une commande localement
  Future<void> _saveOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orders = await getUserOrders();

      // Ajouter la nouvelle commande en première position
      orders.insert(0, order);

      // Sauvegarder la liste mise à jour
      final ordersJson = orders.map((order) => order.toMap()).toList();
      await prefs.setString(_ordersKey, json.encode(ordersJson));

      print('✅ ORDER_SERVICE: Commande ${order.id} sauvegardée localement');
    } catch (e) {
      print('❌ ORDER_SERVICE: Erreur lors de la sauvegarde de la commande: $e');
      rethrow;
    }
  }

  /// Récupérer toutes les commandes de l'utilisateur connecté
  Future<List<Order>> getUserOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);

      if (ordersJson == null || ordersJson.isEmpty) {
        return [];
      }

      final List<dynamic> ordersList = json.decode(ordersJson);
      final orders = ordersList
          .map((orderData) => Order.fromMap(orderData, orderData['id'] ?? ''))
          .where((order) => order.userId == user.uid) // Filtrer par utilisateur
          .toList();

      // Trier par date de création décroissante (plus récentes en premier)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print(
        '📦 ORDER_SERVICE: ${orders.length} commandes récupérées pour ${user.uid}',
      );
      return orders;
    } catch (e) {
      print(
        '❌ ORDER_SERVICE: Erreur lors de la récupération des commandes: $e',
      );
      return [];
    }
  }

  /// Récupérer une commande par son ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final orders = await getUserOrders();
      return orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw StateError('Commande non trouvée'),
      );
    } catch (e) {
      print('❌ ORDER_SERVICE: Commande $orderId non trouvée: $e');
      return null;
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final orders = await getUserOrders();
      final orderIndex = orders.indexWhere((order) => order.id == orderId);

      if (orderIndex == -1) {
        return false;
      }

      // Mettre à jour la commande
      orders[orderIndex] = orders[orderIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = orders.map((order) => order.toMap()).toList();
      await prefs.setString(_ordersKey, json.encode(ordersJson));

      print(
        '✅ ORDER_SERVICE: Statut de la commande $orderId mis à jour: $newStatus',
      );
      return true;
    } catch (e) {
      print('❌ ORDER_SERVICE: Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  /// Supprimer toutes les commandes (pour les tests ou reset)
  Future<void> clearAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
      print('🗑️ ORDER_SERVICE: Toutes les commandes supprimées');
    } catch (e) {
      print('❌ ORDER_SERVICE: Erreur lors de la suppression des commandes: $e');
    }
  }

  /// Obtenir le nombre total de commandes de l'utilisateur
  Future<int> getOrderCount() async {
    final orders = await getUserOrders();
    return orders.length;
  }

  /// Obtenir le montant total dépensé par l'utilisateur
  Future<double> getTotalSpent() async {
    final orders = await getUserOrders();
    return orders.fold<double>(
      0.0,
      (total, order) => total + order.totalAmount,
    );
  }

  /// Obtenir les commandes récentes (derniers 30 jours)
  Future<List<Order>> getRecentOrders({int days = 30}) async {
    final orders = await getUserOrders();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return orders
        .where((order) => order.createdAt.isAfter(cutoffDate))
        .toList();
  }
}

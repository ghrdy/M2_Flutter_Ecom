import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _cartKey = 'cart_items';
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Charger le panier depuis le stockage local
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        _items = cartList
            .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
      _items = [];
    }
  }

  // Sauvegarder le panier dans le stockage local
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toMap()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde du panier: $e');
    }
  }

  // Ajouter un produit au panier
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    await loadCart();

    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Le produit existe déjà, augmenter la quantité
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Nouveau produit
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      _items.add(cartItem);
    }

    await _saveCart();
  }

  // Mettre à jour la quantité d'un produit
  Future<void> updateQuantity(String productId, int quantity) async {
    await loadCart();

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      await _saveCart();
    }
  }

  // Supprimer un produit du panier
  Future<void> removeFromCart(String productId) async {
    await loadCart();
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
  }

  // Vider le panier
  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
  }

  // Vérifier si un produit est dans le panier
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Obtenir la quantité d'un produit dans le panier
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: '',
        product: Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
          stock: 0,
          isAvailable: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  // Obtenir un élément du panier par ID de produit
  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Nouvelles méthodes pour compatibilité
  Future<List<CartItem>> getItems() async {
    await loadCart();
    return _items;
  }

  Future<void> addItem(Product product, int quantity) async {
    await addToCart(product, quantity: quantity);
  }

  Future<void> removeItem(String productId) async {
    await removeFromCart(productId);
  }
}

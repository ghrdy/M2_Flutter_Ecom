import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/catalog_repository.dart';

class CatalogViewModel extends ChangeNotifier {
  final CatalogRepository _repository;

  CatalogViewModel(this._repository);

  bool _isLoading = false;
  String _errorMessage = '';
  List<Product> _products = [];
  List<Product> _featured = [];
  List<String> _categories = [];
  String _selectedCategory = 'Toutes';
  String _query = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Product> get products => _products;
  List<Product> get featured => _featured;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get query => _query;

  Future<void> loadInitial() async {
    await Future.wait([
      loadCategories(),
      loadProducts(),
      loadFeaturedProducts(),
    ]);
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      if (_query.isNotEmpty) {
        _products = await _repository.searchProducts(_query);
      } else if (_selectedCategory != 'Toutes') {
        _products = await _repository.fetchProductsByCategory(
          _selectedCategory,
        );
      } else {
        _products = await _repository.fetchProducts();
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des produits';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    try {
      final list = await _repository.fetchCategories();
      _categories = ['Toutes', ...list];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _featured = await _repository.fetchFeaturedProducts();
      notifyListeners();
    } catch (_) {}
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    loadProducts();
  }

  void search(String query) {
    _query = query.trim();
    notifyListeners();
    loadProducts();
  }

  Future<Product?> loadProductById(String id) async {
    try {
      return await _repository.fetchProductById(id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

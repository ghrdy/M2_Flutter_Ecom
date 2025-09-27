import '../models/product.dart';

/// Abstraction du catalogue pour MVVM/Clean
abstract class CatalogRepository {
  Future<List<Product>> fetchProducts();
  Future<List<Product>> fetchFeaturedProducts();
  Future<Product?> fetchProductById(String id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> fetchProductsByCategory(String category);
  Future<List<String>> fetchCategories();
}

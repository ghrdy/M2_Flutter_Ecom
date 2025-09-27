import '../models/product.dart';
import '../services/firestore_service.dart';
import 'catalog_repository.dart';

/// Implémentation Firestore du CatalogRepository
class FirestoreCatalogRepository implements CatalogRepository {
  @override
  Future<List<Product>> fetchProducts() {
    return FirestoreService.getProducts();
  }

  @override
  Future<List<Product>> fetchFeaturedProducts() {
    return FirestoreService.getFeaturedProducts();
  }

  @override
  Future<Product?> fetchProductById(String id) {
    return FirestoreService.getProductById(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) {
    return FirestoreService.searchProducts(query);
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String category) {
    return FirestoreService.getProductsByCategory(category);
  }

  @override
  Future<List<String>> fetchCategories() {
    return FirestoreService.getCategories();
  }
}

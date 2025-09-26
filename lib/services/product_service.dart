import '../models/product.dart';
import 'firestore_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // Récupérer tous les produits
  Future<List<Product>> getProducts() async {
    return await FirestoreService.getProducts();
  }

  // Récupérer les produits mis en avant
  Future<List<Product>> getFeaturedProducts() async {
    return await FirestoreService.getFeaturedProducts();
  }

  // Récupérer un produit par ID
  Future<Product?> getProductById(String id) async {
    return await FirestoreService.getProductById(id);
  }

  // Rechercher des produits
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return await getProducts();
    return await FirestoreService.searchProducts(query);
  }

  // Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(String category) async {
    return await FirestoreService.getProductsByCategory(category);
  }

  // Récupérer toutes les catégories
  Future<List<String>> getCategories() async {
    return await FirestoreService.getCategories();
  }

  // Initialiser la base de données
  static Future<void> initializeDatabase() async {
    await FirestoreService.initializeDatabase();
  }
}

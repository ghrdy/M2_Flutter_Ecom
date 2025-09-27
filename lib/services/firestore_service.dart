import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _productsCollection = 'produits';

  // Récupérer tous les produits
  static Future<List<Product>> getProducts() async {
    try {
      print('🔍 FIRESTORE: Début de la récupération des produits...');
      print(
        '🗄️ FIRESTORE: Projet Firebase: ${_firestore.app.options.projectId}',
      );
      print('📂 FIRESTORE: Collection: $_productsCollection');

      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get(); // Suppression du orderBy pour éviter les erreurs d'index

      print(
        '📊 FIRESTORE: Nombre de documents trouvés: ${snapshot.docs.length}',
      );

      if (snapshot.docs.isEmpty) {
        print('⚠️ FIRESTORE: Aucun produit trouvé dans la collection');

        // Test de connexion de base
        print('🔧 FIRESTORE: Test de connexion...');
        await _firestore.collection('_test').limit(1).get();
        print('🔧 FIRESTORE: Test réussi, Firebase est connecté');

        return [];
      }

      final products = <Product>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('📦 FIRESTORE: Document ${doc.id}');
          print('📄 FIRESTORE: Champs: ${data.keys.toList()}');
          print('🏷️ FIRESTORE: name = ${data['name']}');
          print('💰 FIRESTORE: price = ${data['price']}');
          print(
            '📦 FIRESTORE: stock = ${data['stock']} (type: ${data['stock'].runtimeType})',
          );
          print('⭐ FIRESTORE: isFeatured = ${data['isFeatured']}');

          // Debug spécifique pour le stock
          if (data['stock'] == null) {
            print(
              '🚨 FIRESTORE: ATTENTION - Le stock est NULL dans Firestore pour ${doc.id}',
            );
            print(
              '🔍 FIRESTORE: Tous les champs disponibles: ${data.keys.toList()}',
            );
          } else {
            print(
              '✅ FIRESTORE: Stock trouvé: ${data['stock']} (type: ${data['stock'].runtimeType})',
            );
          }

          final product = Product.fromMap(data, doc.id);
          products.add(product);
          print(
            '✅ FIRESTORE: Produit ajouté: ${product.name} (Featured: ${product.isFeatured}, Stock: ${product.stock}, Available: ${product.isAvailable})',
          );
        } catch (e, stackTrace) {
          print(
            '❌ FIRESTORE: Erreur lors du parsing du document ${doc.id}: $e',
          );
          print('📍 FIRESTORE: Stack trace: $stackTrace');
        }
      }

      print('🎉 FIRESTORE: Total de ${products.length} produits récupérés');
      return products;
    } catch (e, stackTrace) {
      print('❌ FIRESTORE: Erreur lors de la récupération des produits: $e');
      print('🔍 FIRESTORE: Type d\'erreur: ${e.runtimeType}');

      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        print(
          '🚫 FIRESTORE: ERREUR DE PERMISSIONS - Vérifiez les règles Firestore !',
        );
        print('💡 FIRESTORE: Allez dans Firebase Console → Firestore → Règles');
        print('💡 FIRESTORE: Ajoutez: allow read, write: if true;');
      } else if (e.toString().contains('not-found')) {
        print('📂 FIRESTORE: Collection "products" non trouvée');
      } else if (e.toString().contains('network')) {
        print('🌐 FIRESTORE: Problème de réseau');
      } else {
        print('❓ FIRESTORE: Erreur inconnue');
      }

      print('📍 FIRESTORE: Stack trace: $stackTrace');
      return [];
    }
  }

  // Récupérer les produits mis en avant
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      print('🌟 FIRESTORE: Récupération des produits mis en avant...');
      print('🎯 FIRESTORE: Filtre: isFeatured = true');

      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('isFeatured', isEqualTo: true)
          .limit(6)
          .get(); // Suppression du orderBy pour éviter les erreurs d'index

      print('📊 FIRESTORE: Produits featured trouvés: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print(
          '⚠️ FIRESTORE: Aucun produit featured trouvé avec isFeatured=true',
        );

        // Test pour voir tous les produits et leurs valeurs isFeatured
        print('🔍 FIRESTORE: Vérification des valeurs isFeatured...');
        final allSnapshot = await _firestore
            .collection(_productsCollection)
            .get();
        for (var doc in allSnapshot.docs) {
          final data = doc.data();
          print(
            '🔍 FIRESTORE: ${doc.id} -> isFeatured: ${data['isFeatured']} (type: ${data['isFeatured'].runtimeType})',
          );
        }
      }

      final products = <Product>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final product = Product.fromMap(data, doc.id);
          products.add(product);
          print('⭐ FIRESTORE: Produit featured: ${product.name}');
        } catch (e, stackTrace) {
          print(
            '❌ FIRESTORE: Erreur lors du parsing du produit featured ${doc.id}: $e',
          );
          print('📍 FIRESTORE: Stack trace: $stackTrace');
        }
      }

      print('🎉 FIRESTORE: ${products.length} produits featured récupérés');
      return products;
    } catch (e, stackTrace) {
      print(
        '❌ FIRESTORE: Erreur lors de la récupération des produits mis en avant: $e',
      );
      print('📍 FIRESTORE: Stack trace: $stackTrace');
      return [];
    }
  }

  // Récupérer un produit par ID
  static Future<Product?> getProductById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  // Rechercher des produits
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Product.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche de produits: $e');
      return [];
    }
  }

  // Récupérer les produits par catégorie
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Product.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits par catégorie: $e');
      return [];
    }
  }

  // Récupérer toutes les catégories
  static Future<List<String>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get();

      final Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  // Ajouter un produit
  static Future<String?> addProduct(Product product) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection(_productsCollection)
          .add(product.toMap());
      return docRef.id;
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
      return null;
    }
  }

  // Mettre à jour un produit
  static Future<bool> updateProduct(String id, Product product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(id)
          .update(product.toMap());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      return false;
    }
  }

  // Supprimer un produit
  static Future<bool> deleteProduct(String id) async {
    try {
      await _firestore.collection(_productsCollection).doc(id).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      return false;
    }
  }

  // Initialiser la base de données avec des produits d'exemple
  static Future<void> initializeDatabase() async {
    try {
      // Vérifier si des produits existent déjà
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('La base de données contient déjà des produits');
        return;
      }

      // Ajouter des produits d'exemple
      final List<Map<String, dynamic>> sampleProducts = [
        {
          'name': 'iPhone 15 Pro',
          'description': 'Le dernier iPhone avec puce A17 Pro et caméra 48MP',
          'price': 1199.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500',
          'category': 'Smartphones',
          'stock': 50,
          'rating': 4.8,
          'reviewCount': 1247,
          'isFeatured': true,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'MacBook Pro 16"',
          'description':
              'MacBook Pro avec puce M3 Max et écran Liquid Retina XDR',
          'price': 2499.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
          'category': 'Ordinateurs',
          'stock': 25,
          'rating': 4.9,
          'reviewCount': 892,
          'isFeatured': true,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'AirPods Pro 2',
          'description': 'Écouteurs sans fil avec réduction de bruit active',
          'price': 249.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=500',
          'category': 'Audio',
          'stock': 100,
          'rating': 4.7,
          'reviewCount': 2156,
          'isFeatured': true,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'iPad Air',
          'description':
              'Tablette polyvalente avec puce M2 et écran Liquid Retina',
          'price': 599.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500',
          'category': 'Tablettes',
          'stock': 75,
          'rating': 4.6,
          'reviewCount': 1834,
          'isFeatured': false,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Apple Watch Series 9',
          'description':
              'Montre connectée avec GPS et capteurs de santé avancés',
          'price': 399.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=500',
          'category': 'Montres',
          'stock': 60,
          'rating': 4.5,
          'reviewCount': 967,
          'isFeatured': true,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Magic Keyboard',
          'description': 'Clavier sans fil avec rétroéclairage et Touch ID',
          'price': 149.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
          'category': 'Accessoires',
          'stock': 40,
          'rating': 4.4,
          'reviewCount': 543,
          'isFeatured': false,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      ];

      for (var productData in sampleProducts) {
        await _firestore.collection(_productsCollection).add(productData);
      }

      print(
        'Base de données initialisée avec ${sampleProducts.length} produits',
      );
    } catch (e) {
      print('Erreur lors de l\'initialisation de la base de données: $e');
    }
  }
}

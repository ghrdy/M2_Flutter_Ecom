import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  print('🔥 Test de connexion Firebase...');
  print('=====================================');
  
  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé avec succès!');
    
    final firestore = FirebaseFirestore.instance;
    print('📱 Projet ID: ${firestore.app.options.projectId}');
    
    // Test 1: Lister toutes les collections
    print('\n🗂️  Test 1: Collections disponibles...');
    try {
      final collections = await firestore.listCollections();
      print('📊 Collections trouvées: ${collections.length}');
      for (var collection in collections) {
        print('   - ${collection.id}');
      }
    } catch (e) {
      print('⚠️  Impossible de lister les collections (normal pour le web): $e');
    }
    
    // Test 2: Accéder à la collection products
    print('\n📦 Test 2: Collection "products"...');
    final productsRef = firestore.collection('products');
    final snapshot = await productsRef.get();
    
    print('📊 Nombre de documents dans "products": ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('⚠️  La collection "products" est vide!');
      
      // Test 3: Ajouter un produit de test
      print('\n➕ Test 3: Ajout d\'un produit de test...');
      await productsRef.add({
        'name': 'Produit Test',
        'description': 'Description test',
        'price': 99.99,
        'imageUrl': 'https://via.placeholder.com/300',
        'category': 'Test',
        'stock': 10,
        'isAvailable': true,
        'rating': 4.5,
        'reviewCount': 100,
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Produit de test ajouté!');
      
      // Revérifier
      final newSnapshot = await productsRef.get();
      print('📊 Nouveaux documents: ${newSnapshot.docs.length}');
    } else {
      // Test 4: Afficher les produits existants
      print('\n📋 Test 4: Produits existants...');
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('🛍️  ${doc.id}: ${data['name'] ?? 'Nom manquant'}');
        print('   Prix: ${data['price'] ?? 'Prix manquant'}');
        print('   Stock: ${data['stock'] ?? 'Stock manquant'}');
        print('   Featured: ${data['isFeatured'] ?? 'Featured manquant'}');
        print('   ---');
      }
    }
    
    // Test 5: Requête avec filtre
    print('\n⭐ Test 5: Produits featured...');
    final featuredSnapshot = await productsRef
        .where('isFeatured', isEqualTo: true)
        .get();
    print('📊 Produits featured: ${featuredSnapshot.docs.length}');
    
    print('\n🎉 Tests terminés avec succès!');
    
  } catch (e, stackTrace) {
    print('❌ ERREUR: $e');
    print('📍 Stack trace: $stackTrace');
  }
}

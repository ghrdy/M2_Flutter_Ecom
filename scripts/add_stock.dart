import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main(List<String> args) async {
  print('🚀 Script d\'ajout de stock...');

  if (args.length < 2) {
    print('❌ Usage: dart scripts/add_stock.dart <product_name> <stock_amount>');
    print('   Exemple: dart scripts/add_stock.dart "iPhone 15 Pro" 100');
    return;
  }

  final String productName = args[0];
  final int stockAmount = int.tryParse(args[1]) ?? 0;

  if (stockAmount <= 0) {
    print('❌ Le montant du stock doit être un nombre positif');
    return;
  }

  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé');

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    const String collectionName = 'produits';

    // Rechercher le produit par nom
    print('🔍 Recherche du produit: $productName');
    final QuerySnapshot snapshot = await firestore
        .collection(collectionName)
        .where('name', isEqualTo: productName)
        .get();

    if (snapshot.docs.isEmpty) {
      print('❌ Aucun produit trouvé avec le nom: $productName');
      print('💡 Vérifiez le nom exact du produit dans Firestore');
      return;
    }

    if (snapshot.docs.length > 1) {
      print('⚠️ Plusieurs produits trouvés avec le nom: $productName');
    }

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String currentStock = data['stock']?.toString() ?? 'null';

      print('\n📦 Produit trouvé:');
      print('   ID: ${doc.id}');
      print('   Nom: ${data['name']}');
      print('   Stock actuel: $currentStock');
      print('   Nouveau stock: $stockAmount');

      // Mettre à jour le stock
      await firestore.collection(collectionName).doc(doc.id).update({
        'stock': stockAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('   ✅ Stock mis à jour avec succès!');
    }

    print('\n🎉 Script terminé!');
  } catch (e, stackTrace) {
    print('❌ Erreur: $e');
    print('📍 Stack trace: $stackTrace');
  }
}

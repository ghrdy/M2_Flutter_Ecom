import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  print('🚀 Démarrage du script de correction du stock...');

  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé');

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    const String collectionName = 'produits';

    // Récupérer tous les produits
    print('🔍 Récupération de tous les produits...');
    final QuerySnapshot snapshot = await firestore
        .collection(collectionName)
        .get();

    print('📊 Nombre de produits trouvés: ${snapshot.docs.length}');

    int updatedCount = 0;
    int errorCount = 0;

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final String productName = data['name'] ?? 'Sans nom';

        print('\n📦 Produit: $productName (ID: ${doc.id})');
        print(
          '   Stock actuel: ${data['stock']} (type: ${data['stock'].runtimeType})',
        );

        // Vérifier si le stock est null ou manquant
        if (data['stock'] == null) {
          print('   🚨 Stock manquant - Ajout d\'une valeur par défaut');

          // Définir un stock par défaut basé sur le type de produit
          int defaultStock = 50; // Valeur par défaut

          // Ajuster selon la catégorie
          final String category = data['category'] ?? '';
          switch (category.toLowerCase()) {
            case 'smartphones':
              defaultStock = 30;
              break;
            case 'ordinateurs':
              defaultStock = 15;
              break;
            case 'tablettes':
              defaultStock = 25;
              break;
            case 'audio':
              defaultStock = 100;
              break;
            case 'montres':
              defaultStock = 40;
              break;
            case 'accessoires':
              defaultStock = 75;
              break;
            default:
              defaultStock = 50;
          }

          // Mettre à jour le document
          await firestore.collection(collectionName).doc(doc.id).update({
            'stock': defaultStock,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print('   ✅ Stock mis à jour: $defaultStock');
          updatedCount++;
        } else {
          print('   ✅ Stock déjà présent: ${data['stock']}');
        }
      } catch (e) {
        print('   ❌ Erreur pour le produit ${doc.id}: $e');
        errorCount++;
      }
    }

    print('\n🎉 Script terminé!');
    print('📊 Résumé:');
    print('   - Produits mis à jour: $updatedCount');
    print('   - Erreurs: $errorCount');
    print('   - Total traité: ${snapshot.docs.length}');
  } catch (e, stackTrace) {
    print('❌ Erreur fatale: $e');
    print('📍 Stack trace: $stackTrace');
  }
}

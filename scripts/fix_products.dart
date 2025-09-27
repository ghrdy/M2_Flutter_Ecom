import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  print('🔧 Correction des produits dans Firebase...');

  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  try {
    // Récupérer tous les produits
    final snapshot = await firestore.collection('products').get();

    print('📦 ${snapshot.docs.length} produits trouvés');

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Vérifier et corriger les champs manquants
      Map<String, dynamic> updates = {};

      if (!data.containsKey('createdAt') || data['createdAt'] == null) {
        updates['createdAt'] = FieldValue.serverTimestamp();
      }

      if (!data.containsKey('updatedAt') || data['updatedAt'] == null) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
      }

      if (!data.containsKey('isAvailable')) {
        updates['isAvailable'] = true;
      }

      if (!data.containsKey('rating')) {
        updates['rating'] = 4.5;
      }

      if (!data.containsKey('reviewCount')) {
        updates['reviewCount'] = 100;
      }

      if (!data.containsKey('isFeatured')) {
        updates['isFeatured'] = true;
      }

      // Mettre à jour le document s'il y a des corrections
      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
        print('✅ Produit ${data['name']} corrigé: ${updates.keys.toList()}');
      } else {
        print('👍 Produit ${data['name']} déjà correct');
      }
    }

    print('🎉 Correction terminée avec succès!');
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

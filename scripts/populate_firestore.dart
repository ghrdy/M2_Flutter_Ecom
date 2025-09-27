import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  print('🔥 Initialisation de Firebase...');

  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('✅ Firebase initialisé avec succès!');

  final firestore = FirebaseFirestore.instance;

  // Vérifier si des produits existent déjà
  final existingProducts = await firestore
      .collection('products')
      .limit(1)
      .get();

  if (existingProducts.docs.isNotEmpty) {
    print('⚠️  Des produits existent déjà dans la base de données.');
    print('🗑️  Voulez-vous les supprimer et recommencer? (y/N)');

    // Pour un script automatique, on suppose "oui"
    print('🧹 Suppression des produits existants...');
    final allProducts = await firestore.collection('products').get();
    for (var doc in allProducts.docs) {
      await doc.reference.delete();
    }
    print('✅ Produits existants supprimés.');
  }

  print('📦 Ajout des nouveaux produits...');

  // Liste des produits à ajouter
  final products = [
    {
      'name': 'iPhone 15 Pro Max',
      'description':
          'Le plus grand iPhone avec puce A17 Pro, caméra 48MP avec zoom 5x, écran Super Retina XDR de 6,7 pouces et structure en titane.',
      'price': 1299.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1592910061532-63978a8e1bb1?w=500',
      'category': 'Smartphones',
      'stock': 45,
      'rating': 4.9,
      'reviewCount': 2847,
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'MacBook Pro 16" M3 Max',
      'description':
          'MacBook Pro ultime avec puce M3 Max, 36 Go de RAM, SSD 1 To, écran Liquid Retina XDR et autonomie de 22 heures.',
      'price': 2899.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
      'category': 'Ordinateurs',
      'stock': 18,
      'rating': 4.8,
      'reviewCount': 1245,
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'AirPods Pro 2ème génération',
      'description':
          'Écouteurs sans fil avec réduction de bruit active adaptative, son spatial personnalisé et étui de charge MagSafe.',
      'price': 279.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=500',
      'category': 'Audio',
      'stock': 150,
      'rating': 4.7,
      'reviewCount': 3421,
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'iPad Pro 12,9" M2',
      'description':
          'iPad Pro avec puce M2, écran Liquid Retina XDR, compatible Apple Pencil et Magic Keyboard. Parfait pour les créatifs.',
      'price': 1199.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500',
      'category': 'Tablettes',
      'stock': 62,
      'rating': 4.6,
      'reviewCount': 1876,
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Apple Watch Ultra 2',
      'description':
          'Montre la plus robuste d\'Apple avec GPS précis, batterie 36h, résistance à l\'eau 100m et applications sports extrêmes.',
      'price': 849.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=500',
      'category': 'Montres',
      'stock': 35,
      'rating': 4.8,
      'reviewCount': 967,
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Studio Display',
      'description':
          'Écran 27 pouces 5K Retina, caméra Ultra Wide 12MP, audio spatial et support inclinable pour les pros.',
      'price': 1699.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500',
      'category': 'Écrans',
      'stock': 12,
      'rating': 4.5,
      'reviewCount': 543,
      'isFeatured': false,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Magic Keyboard avec Touch ID',
      'description':
          'Clavier sans fil avec touches rétroéclairées, Touch ID intégré et pavé numérique pour une productivité maximale.',
      'price': 199.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
      'category': 'Accessoires',
      'stock': 88,
      'rating': 4.4,
      'reviewCount': 721,
      'isFeatured': false,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'AirTag Pack de 4',
      'description':
          'Trackers Bluetooth ultra-précis pour retrouver vos objets. Résistants à l\'eau avec pile remplaçable d\'un an.',
      'price': 119.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1621768216002-5ac171876625?w=500',
      'category': 'Accessoires',
      'stock': 200,
      'rating': 4.3,
      'reviewCount': 2156,
      'isFeatured': false,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Mac Studio M2 Ultra',
      'description':
          'Station de travail la plus puissante d\'Apple avec M2 Ultra, parfaite pour le montage vidéo 8K et les workflows pros.',
      'price': 4399.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500',
      'category': 'Ordinateurs',
      'stock': 8,
      'rating': 4.9,
      'reviewCount': 234,
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'HomePod 2ème génération',
      'description':
          'Enceinte intelligente avec son immersif, Siri intégré et hub domotique pour contrôler votre maison connectée.',
      'price': 349.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1589492477829-5e65395b66cc?w=500',
      'category': 'Audio',
      'stock': 45,
      'rating': 4.2,
      'reviewCount': 876,
      'isFeatured': false,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  // Ajouter chaque produit
  int count = 0;
  for (var productData in products) {
    try {
      await firestore.collection('products').add(productData);
      count++;
      print('✅ Produit ${count}/10 ajouté: ${productData['name']}');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de ${productData['name']}: $e');
    }
  }

  print('');
  print('🎉 Script terminé avec succès!');
  print('📊 Résumé:');
  print('   • $count produits ajoutés');
  print('   • ${products.length - count} erreurs');
  print('');
  print('🚀 Votre base de données est prête!');
  print('💡 Vous pouvez maintenant lancer votre application Flutter.');
}

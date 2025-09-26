import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/widgets/product_card.dart';
import 'package:ecom/models/product.dart';

Product _makeProduct({
  String id = 'p1',
  String name = 'Produit Test',
  double price = 9.99,
  String imageUrl = '',
  String category = 'Catégorie',
  int stock = 10,
  bool isAvailable = true,
}) {
  return Product(
    id: id,
    name: name,
    description: 'Description',
    price: price,
    imageUrl: imageUrl,
    category: category,
    stock: stock,
    isAvailable: isAvailable,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  testWidgets('ProductCard affiche nom, catégorie et prix', (tester) async {
    final product = _makeProduct(name: 'Mon Produit', price: 12.5);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );

    expect(find.text('Mon Produit'), findsOneWidget);
    expect(find.text('Catégorie'), findsOneWidget);
    expect(find.text('12.50 €'), findsOneWidget);
  });

  testWidgets('ProductCard déclenche onAddToCart quand cliqué', (tester) async {
    final product = _makeProduct(stock: 3);
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            onAddToCart: () => tapped++,
          ),
        ),
      ),
    );

    // Le bouton est un petit carré avec une icône add. On cible l'icône.
    final addIconFinder = find.byIcon(Icons.add);
    expect(addIconFinder, findsOneWidget);

    await tester.tap(addIconFinder);
    await tester.pump();

    expect(tapped, 1);
  });
}



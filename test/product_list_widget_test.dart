import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/widgets/product_card.dart';
import 'package:ecom/models/product.dart';

class _ProductList extends StatelessWidget {
  final List<Product> products;
  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        ),
      ),
    );
  }
}

Product _makeProduct(String id) => Product(
      id: id,
      name: 'Produit $id',
      description: 'Desc',
      price: 10 + id.hashCode % 5,
      imageUrl: '',
      category: 'Cat',
      stock: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

void main() {
  testWidgets('La liste rend toutes les ProductCard', (tester) async {
    final products = List.generate(6, (i) => _makeProduct('p$i'));

    await tester.pumpWidget(_ProductList(products: products));
    await tester.pumpAndSettle();

    // Vérifie qu'au moins une carte est visible
    expect(find.byType(ProductCard), findsWidgets);

    // Le premier élément doit être visible sans scroll
    expect(find.text('Produit p0'), findsOneWidget);

    // Assure la visibilité de la dernière carte via scrollUntilVisible
    await tester.scrollUntilVisible(
      find.text('Produit p5'),
      400.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Le dernier doit être visible après scroll
    expect(find.text('Produit p5'), findsOneWidget);
  });
}



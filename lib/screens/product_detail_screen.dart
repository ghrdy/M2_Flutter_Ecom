import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  Product? _product;
  bool _isLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    // Simulation du chargement d'un produit - vous pouvez remplacer par Firebase
    await Future.delayed(const Duration(milliseconds: 500));

    // Produits d'exemple (même liste que dans le catalogue)
    final products = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'Le dernier iPhone avec puce A17 Pro et caméra avancée. Écran Super Retina XDR de 6,1 pouces, système de caméra Pro avec téléobjectif 5x, et des performances exceptionnelles pour tous vos besoins.',
        price: 1229.0,
        imageUrl: 'https://images.unsplash.com/photo-1592910061532-63978a8e1bb1?w=500',
        category: 'Électronique',
        stock: 10,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'MacBook Air M2',
        description: 'Ultra-portable avec puce M2 et écran Retina. Design fin et léger, autonomie exceptionnelle, et performances professionnelles pour créer, travailler et jouer.',
        price: 1499.0,
        imageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500',
        category: 'Électronique',
        stock: 5,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'T-shirt Premium',
        description: 'T-shirt en coton bio, coupe moderne. Matière douce et respirante, coupe ajustée, parfait pour un look décontracté ou sportif.',
        price: 29.99,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
        category: 'Vêtements',
        stock: 20,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Sneakers Sport',
        description: 'Chaussures de sport confortables et stylées. Semelle amortissante, design moderne, idéales pour le sport et le quotidien.',
        price: 89.99,
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500',
        category: 'Sport',
        stock: 15,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '5',
        name: 'Casque Audio',
        description: 'Casque sans fil avec réduction de bruit. Son haute fidélité, réduction de bruit active, autonomie de 30 heures.',
        price: 299.99,
        imageUrl: 'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=500',
        category: 'Électronique',
        stock: 8,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '6',
        name: 'Veste Denim',
        description: 'Veste en denim vintage, style décontracté. Coupe classique, finitions soignées, s\'adapte à tous les styles.',
        price: 79.99,
        imageUrl: 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=500',
        category: 'Vêtements',
        stock: 12,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '7',
        name: 'Canapé Moderne',
        description: 'Canapé 3 places en tissu, design scandinave. Confort optimal, style épuré, parfait pour votre salon moderne.',
        price: 899.99,
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500',
        category: 'Maison',
        stock: 3,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '8',
        name: 'Montre Connectée',
        description: 'Montre intelligente avec suivi de la santé. GPS intégré, moniteur cardiaque, étanche, compatible iOS et Android.',
        price: 399.99,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
        category: 'Électronique',
        stock: 6,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _product = products.firstWhere(
      (product) => product.id == widget.productId,
      orElse: () => products.first,
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addToCart() async {
    if (_product != null) {
      await _cartService.addItem(_product!, _quantity);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_product!.name} ajouté au panier ($_quantity)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Voir le panier',
              textColor: Colors.white,
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Produit non trouvé'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Produit non trouvé'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _product!.name,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        surfaceTintColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey[700]),
              onPressed: () => context.go('/cart'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[50],
              child: _product!.imageUrl.isNotEmpty
                  ? Image.network(
                      _product!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et prix
                  Text(
                    _product!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_product!.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Catégorie et stock
                  Row(
                    children: [
                      Chip(
                        label: Text(_product!.category),
                        backgroundColor: Colors.blue[100],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_product!.stock} en stock',
                        style: TextStyle(
                          color: _product!.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _product!.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sélecteur de quantité
                  Text(
                    'Quantité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                          color: Colors.grey[600],
                          iconSize: 18,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _quantity.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _quantity < _product!.stock
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add),
                          color: Colors.grey[600],
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton ajouter au panier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _product!.isAvailable && _product!.stock > 0
                          ? _addToCart
                          : null,
                      child: Text(
                        _product!.isAvailable
                            ? 'Ajouter au panier - ${(_product!.price * _quantity).toStringAsFixed(2)} €'
                            : 'Produit indisponible',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _product!.isAvailable && _product!.stock > 0
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
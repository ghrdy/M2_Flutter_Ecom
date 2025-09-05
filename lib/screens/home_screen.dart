import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFeaturedProducts();
    _cartService.loadCart();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      print('🏠 HOME: Début du chargement des produits...');
      
      // D'abord, essayons de récupérer TOUS les produits
      print('🔍 Tentative de récupération de TOUS les produits...');
      final allProducts = await _productService.getProducts();
      print('📦 TOUS les produits: ${allProducts.length}');
      
      for (var product in allProducts) {
        print('📦 - ${product.name} (Featured: ${product.isFeatured})');
      }
      
      // Ensuite les produits featured
      print('⭐ Tentative de récupération des produits featured...');
      final featuredProducts = await _productService.getFeaturedProducts();
      print('⭐ Produits featured: ${featuredProducts.length}');
      
      // Si pas de featured, on prend les premiers produits
      final productsToShow = featuredProducts.isNotEmpty 
          ? featuredProducts 
          : allProducts.take(6).toList();
      
      print('🏠 HOME: Produits à afficher: ${productsToShow.length}');
      
      for (var product in productsToShow) {
        print('🏠 HOME: - ${product.name} (${product.price}€)');
      }
      
      setState(() {
        _featuredProducts = productsToShow;
        _isLoading = false;
      });
      
      print('🏠 HOME: État mis à jour, loading = false');
    } catch (e, stackTrace) {
      print('❌ HOME: Erreur lors du chargement des produits: $e');
      print('📍 HOME: Stack trace: $stackTrace');
      setState(() {
        _featuredProducts = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar moderne avec gradient
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🛍️ ShopApp',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  _buildHeaderButton(
                                    icon: Icons.shopping_cart_outlined,
                                    onPressed: () => context.go('/cart'),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildHeaderButton(
                                    icon: Icons.logout,
                                    onPressed: _signOut,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            'Découvrez',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'nos produits',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Technologie de pointe et design exceptionnel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Boutons de navigation rapide
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.grid_view_rounded,
                        title: 'Catalogue',
                        subtitle: 'Voir tous nos produits',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        onTap: () => context.go('/catalog'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.favorite_outline_rounded,
                        title: 'Favoris',
                        subtitle: 'Vos coups de cœur',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        ),
                        onTap: () => context.go('/catalog'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section produits mis en avant
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Produits tendance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d3436),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/catalog'),
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Color(0xFF667eea),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Grille de produits
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: ShimmerLoading(),
                  ),
                )
              : _featuredProducts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, 
                                     size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun produit trouvé',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Produits: ${_featuredProducts.length}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() { _isLoading = true; });
                                    _loadFeaturedProducts();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('🔄 Recharger'),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    print('🔧 DEBUG: Collection utilisée: produits');
                                    print('🔧 DEBUG: Firebase connecté: ${_productService.toString()}');
                                  },
                                  child: const Text('🔧 Debug'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _featuredProducts.length) return null;
                        final product = _featuredProducts[index];
                        return FadeTransition(
                          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                          child: ProductCard(
                            product: product,
                            onTap: () => context.go('/product/${product.id}'),
                            onAddToCart: () async {
                              await _cartService.addItem(product, 1);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} ajouté au panier'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Voir',
                                      textColor: Colors.white,
                                      onPressed: () => context.go('/cart'),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                      childCount: _featuredProducts.length,
                    ),
                  ),
                ),

          // Espacement final
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.grey[700]),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
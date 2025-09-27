import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/catalog_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/settings_screen.dart';

// Classe pour écouter les changements d'authentification
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Transitions personnalisées avec direction automatique
Page<void> _buildPageWithSlideTransition({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Utilise la direction naturelle de Flutter
      // animation : 0.0 -> 1.0 (entrée)
      // secondaryAnimation : 1.0 -> 0.0 (sortie)

      const curve = Curves.easeInOut;

      // Animation d'entrée (slide de droite vers gauche)
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve)).animate(animation);

      // Animation de sortie (slide de gauche vers droite)
      final slideOutAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1.0, 0.0),
      ).chain(CurveTween(curve: curve)).animate(secondaryAnimation);

      return SlideTransition(
        position: slideAnimation,
        child: SlideTransition(position: slideOutAnimation, child: child),
      );
    },
  );
}

// Fonction pour vérifier l'authentification
String? _authGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  final isLoggedIn = user != null;
  final isLoggingIn = state.matchedLocation == '/login';

  // Si l'utilisateur n'est pas connecté et n'est pas sur la page de login
  if (!isLoggedIn && !isLoggingIn) {
    return '/login';
  }

  // Si l'utilisateur est connecté et essaie d'accéder à la page de login
  if (isLoggedIn && isLoggingIn) {
    return '/home';
  }

  // Pas de redirection nécessaire
  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: _authGuard,
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  routes: [
    GoRoute(path: '/', name: 'root', redirect: (context, state) => '/home'),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const HomeScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const LoginScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/catalog',
      name: 'catalog',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const CatalogScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/product/:id',
      name: 'product',
      pageBuilder: (context, state) {
        final productId = state.pathParameters['id']!;
        return _buildPageWithSlideTransition(
          child: ProductDetailScreen(productId: productId),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const CartScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const CheckoutScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const OrdersScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => _buildPageWithSlideTransition(
        child: const SettingsScreen(),
        state: state,
      ),
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page non trouvée'))),
);

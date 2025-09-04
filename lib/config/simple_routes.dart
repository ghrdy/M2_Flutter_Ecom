import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/simple_home_screen.dart';
import '../screens/login_screen.dart';

final GoRouter simpleRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const SimpleHomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/catalog',
      name: 'catalog',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Catalogue')),
        body: const Center(child: Text('Page Catalogue - En construction')),
      ),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Panier')),
        body: const Center(child: Text('Page Panier - En construction')),
      ),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Commandes')),
        body: const Center(child: Text('Page Commandes - En construction')),
      ),
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text('Page non trouvée'),
    ),
  ),
);

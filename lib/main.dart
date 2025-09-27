import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'repositories/firestore_catalog_repository.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/catalog_view_model.dart';
import 'viewmodels/cart_view_model.dart';
import 'viewmodels/checkout_view_model.dart';
import 'viewmodels/orders_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) =>
              CatalogViewModel(FirestoreCatalogRepository())..loadInitial(),
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()..loadCart()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()..loadCart()),
        ChangeNotifierProvider(create: (_) => OrdersViewModel()..loadOrders()),
      ],
      child: MaterialApp.router(
        title: 'E-commerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}

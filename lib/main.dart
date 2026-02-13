import 'package:flutter/material.dart';
import 'data/products_data.dart';
import 'models/cart_item.dart';
import 'models/product.dart';
import 'screens/admin_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_details_screen.dart';
import 'data/products_data.dart';


void main() {
  runApp(const TechStoreApp());
}

class TechStoreApp extends StatefulWidget {
  const TechStoreApp({super.key});

  @override
  State<TechStoreApp> createState() => _TechStoreAppState();
}

class _TechStoreAppState extends State<TechStoreApp> {
  final Map<String, CartItem> _cart = {}; // key: productId
  final List<Product> _products = List<Product>.from(demoProducts);



  int get cartItemsCount =>
      _cart.values.fold<int>(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      _cart.values.fold<double>(0.0, (sum, item) => sum + item.subTotal);

  void addToCart(Product product) {
    setState(() {
      final existing = _cart[product.id];
      if (existing == null) {
        _cart[product.id] = CartItem(product: product, quantity: 1);
      } else {
        _cart[product.id] = existing.copyWith(quantity: existing.quantity + 1);
      }
    });
  }
  void addProduct(Product product) {
    setState(() {
      _products.insert(0, product); // ajoute en haut du catalogue
    });
  }


  void removeFromCart(String productId) {
    setState(() => _cart.remove(productId));
  }

  void increaseQty(String productId) {
    setState(() {
      final item = _cart[productId];
      if (item == null) return;
      _cart[productId] = item.copyWith(quantity: item.quantity + 1);
    });
  }

  void decreaseQty(String productId) {
    setState(() {
      final item = _cart[productId];
      if (item == null) return;

      if (item.quantity <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = item.copyWith(quantity: item.quantity - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = HomeScreen(
      products: _products,
      cartCount: cartItemsCount,
      onAddToCart: addToCart,
    );


    return MaterialApp(
      title: 'TechStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      // Plus clair que de dépendre uniquement de routes pour "/"
      home: home,

      routes: {
        ProductDetailsScreen.routeName: (_) => ProductDetailsScreen(
          onAddToCart: addToCart,
        ),
        CartScreen.routeName: (_) => CartScreen(
          cartItems: _cart,
          total: cartTotal,
          onRemove: removeFromCart,
          onIncrease: increaseQty,
          onDecrease: decreaseQty,
        ),
        AdminScreen.routeName: (_) => AdminScreen(onAddProduct: addProduct),
      },

      // Optionnel : évite un crash si route inconnue
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page introuvable')),
        ),
      ),
    );
  }
}

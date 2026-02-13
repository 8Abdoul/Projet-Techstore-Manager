import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-details';

  final void Function(Product product) onAddToCart;

  const ProductDetailsScreen({
    super.key,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${product.price.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              onAddToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté au panier')),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Ajouter au panier'),
          ),
        ],
      ),
    );
  }
}

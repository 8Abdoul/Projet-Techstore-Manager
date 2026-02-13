import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/cart_screen.dart';
import '../screens/product_details_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/cart_badge.dart';
import '../widgets/product_item.dart';
import '../data/products_data.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  final List<Product> products;
  final int cartCount;
  final void Function(Product product) onAddToCart;

  const HomeScreen({
    super.key,
    required this.products,
    required this.cartCount,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final featured =
    products.where((p) => featuredProductIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechStore'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
            icon: CartBadge(
              count: cartCount,
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'À la une',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final p = featured[i];
                return SizedBox(
                  width: 280,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                      ProductDetailsScreen.routeName,
                      arguments: p,
                    ),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(p.imageUrl, fit: BoxFit.cover),
                          Container(color: Colors.black.withAlpha(64)),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.price.toStringAsFixed(2)} €',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Catalogue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (ctx, i) {
              final p = products[i];
              return ProductItem(
                product: p,
                onTap: () => Navigator.of(context).pushNamed(
                  ProductDetailsScreen.routeName,
                  arguments: p,
                ),
                onAddToCart: () {
                  onAddToCart(p);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${p.title} ajouté au panier')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

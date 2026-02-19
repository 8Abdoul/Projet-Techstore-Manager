import 'package:flutter/material.dart';
import '../models/product.dart';

// Palette : une couleur d'accent par carte selon l'index
const _accents = [
  Color(0xFF3B82F6), // bleu
  Color(0xFF8B5CF6), // violet
  Color(0xFF10B981), // émeraude
  Color(0xFFF59E0B), // ambre
  Color(0xFFEF4444), // rouge corail
  Color(0xFF06B6D4), // cyan
  Color(0xFFF97316), // orange
  Color(0xFF6366F1), // indigo
];

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final int index;

  const ProductItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.index = 0,
  });

  Color get _accent => _accents[index % _accents.length];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: _accent.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image avec gestion d'erreur et badge prix ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accent,
                        ),
                      ),
                    ),
                    errorBuilder: (_, __, ___) => Container(
                      color: _accent.withOpacity(0.08),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices, size: 40, color: _accent.withOpacity(0.5)),
                          const SizedBox(height: 6),
                          Text('Image indisponible',
                              style: TextStyle(fontSize: 11, color: _accent.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  ),

                  // Barre de couleur en haut
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(height: 3, color: _accent),
                  ),

                  // Badge prix
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Infos + bouton ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart, size: 15),
                      label: const Text('Ajouter', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

import 'package:flutter/material.dart';

import '../models/product.dart';

class AdminScreen extends StatefulWidget {
  static const routeName = '/admin';

  final void Function(Product product) onAddProduct;

  const AdminScreen({
    super.key,
    required this.onAddProduct,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  String _imagePreviewUrl = '';

  @override
  void initState() {
    super.initState();

    // Met à jour l'aperçu quand on change l'URL
    _imageCtrl.addListener(() {
      final url = _imageCtrl.text.trim();
      if (url == _imagePreviewUrl) return;

      // On n'actualise l'aperçu que si ça ressemble à une URL valide
      if (_isValidImageUrl(url)) {
        setState(() => _imagePreviewUrl = url);
      } else {
        setState(() => _imagePreviewUrl = '');
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  bool _isValidImageUrl(String value) {
    if (!_isValidHttpUrl(value)) return false;

    // Extension optionnelle : on accepte aussi les URLs sans extension (picsum, etc.)
    final lower = value.toLowerCase();
    final hasImageExt = lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');

    return hasImageExt || lower.contains('picsum.photos') || lower.contains('image');
  }

  double _parsePrice(String raw) {
    // Accepte "12,5" ou "12.5"
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final price = _parsePrice(_priceCtrl.text);

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: price,
      imageUrl: _imageCtrl.text.trim(),
    );

    widget.onAddProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produit ajouté ✅')),
    );

    _formKey.currentState!.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _priceCtrl.clear();
    _imageCtrl.clear();
    setState(() => _imagePreviewUrl = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  hintText: 'Ex: 12.99 ou 12,99',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final val = _parsePrice(v ?? '');
                  if (val <= 0) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  final url = (v ?? '').trim();
                  if (url.isEmpty) return 'Champ requis';
                  if (!_isValidHttpUrl(url)) return 'URL invalide (http/https)';
                  // optionnel : rendre plus strict
                  if (!_isValidImageUrl(url)) return 'URL image invalide';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),

              // Aperçu image
              Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagePreviewUrl.isEmpty
                    ? const Center(child: Text('Aperçu image'))
                    : Image.network(
                  _imagePreviewUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Center(child: Text('Impossible de charger l’image')),
                ),
              ),

              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter le produit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

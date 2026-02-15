import 'package:flutter/material.dart';
import '../models/product.dart';

class AdminScreen extends StatefulWidget {
  static const routeName = '/admin';

  final List<Product> products;
  final void Function(Product product) onAddProduct;
  final void Function(Product product) onUpdateProduct;
  final void Function(String productId) onDeleteProduct;

  const AdminScreen({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onUpdateProduct,
    required this.onDeleteProduct,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // --- Form controllers (utilisés pour Add ET Edit)
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  String _imagePreviewUrl = '';
  Product? _editing; // si non null => on est en mode modification

  @override
  void initState() {
    super.initState();
    _imageCtrl.addListener(() {
      final url = _imageCtrl.text.trim();
      if (url == _imagePreviewUrl) return;

      if (_isValidHttpUrl(url)) {
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

  double _parsePrice(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _priceCtrl.clear();
    _imageCtrl.clear();
    setState(() {
      _editing = null;
      _imagePreviewUrl = '';
    });
  }

  void _startEdit(Product p) {
    setState(() {
      _editing = p;
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toStringAsFixed(2);
      _imageCtrl.text = p.imageUrl;
      _imagePreviewUrl = p.imageUrl;
    });
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final price = _parsePrice(_priceCtrl.text);
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final img = _imageCtrl.text.trim();

    if (_editing == null) {
      // ADD
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: desc,
        price: price,
        imageUrl: img,
      );
      widget.onAddProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté ✅')),
      );
    } else {
      // EDIT
      final updated = Product(
        id: _editing!.id, // on garde l'ID
        title: title,
        description: desc,
        price: price,
        imageUrl: img,
      );

      widget.onUpdateProduct(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit modifié ✅')),
      );
    }

    _resetForm();
  }

  Future<void> _confirmDelete(Product p) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('“${p.title}” sera supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (res == true) {
      widget.onDeleteProduct(p.id);
      if (_editing?.id == p.id) _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editing != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FORM
            Text(
              isEditing ? 'Modifier le produit' : 'Ajouter un produit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit',
                      border: OutlineInputBorder(),
                    ),
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
                    validator: (v) {
                      final url = (v ?? '').trim();
                      if (url.isEmpty) return 'Champ requis';
                      if (!_isValidHttpUrl(url)) return 'URL invalide (http/https)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

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

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: Icon(isEditing ? Icons.save : Icons.add),
                          label: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isEditing)
                        OutlinedButton(
                          onPressed: _resetForm,
                          child: const Text('Annuler'),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // --- LIST
            const Text(
              'Produits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (widget.products.isEmpty)
              const Text('Aucun produit pour le moment.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final p = widget.products[i];
                  return Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.imageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 52,
                            height: 52,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      title: Text(p.title),
                      subtitle: Text('${p.price.toStringAsFixed(2)} €'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Modifier',
                            onPressed: () => _startEdit(p),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            tooltip: 'Supprimer',
                            onPressed: () => _confirmDelete(p),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

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
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  String _imagePreviewUrl = '';
  Product? _editing;

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
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: desc,
        price: price,
        imageUrl: img,
      );
      widget.onAddProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté ✅'), backgroundColor: Colors.green),
      );
    } else {
      final updated = Product(
        id: _editing!.id,
        title: title,
        description: desc,
        price: price,
        imageUrl: img,
      );
      widget.onUpdateProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit modifié ✅'), backgroundColor: Colors.blue),
      );
    }
    _resetForm();
  }

  Future<void> _confirmDelete(Product p) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('"${p.title}" sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
      appBar: AppBar(
        title: const Text('Administration', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── FORMULAIRE ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit : Icons.add_box,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Modifier le produit' : 'Ajouter un produit',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nom du produit',
                            prefixIcon: Icon(Icons.title),
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
                            prefixIcon: Icon(Icons.description),
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
                            prefixIcon: Icon(Icons.euro),
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
                            prefixIcon: Icon(Icons.image),
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

                        // Aperçu image
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _imagePreviewUrl.isEmpty
                              ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Aperçu de l\'image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                              : Image.network(
                            _imagePreviewUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('Impossible de charger l\'image',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _submit,
                                icon: Icon(isEditing ? Icons.save : Icons.add),
                                label: Text(isEditing ? 'Enregistrer les modifications' : 'Ajouter au catalogue'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            if (isEditing) ...[
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _resetForm,
                                child: const Text('Annuler'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── LISTE DES PRODUITS ──
            Row(
              children: [
                const Text('Catalogue produits',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${widget.products.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (widget.products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucun produit pour le moment.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final p = widget.products[i];
                  final isSelected = _editing?.id == p.id;
                  return Card(
                    elevation: isSelected ? 3 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: isSelected
                          ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                          : BorderSide.none,
                    ),
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
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${p.price.toStringAsFixed(2)} €'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Modifier',
                            onPressed: () => _startEdit(p),
                            icon: Icon(Icons.edit,
                                color: isSelected ? Theme.of(ctx).colorScheme.primary : null),
                          ),
                          IconButton(
                            tooltip: 'Supprimer',
                            onPressed: () => _confirmDelete(p),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductModel? product; // null = create, non-null = edit

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  String _category = 'Electronics';
  bool _submitting = false;

  static const _categories = [
    'Electronics', 'Clothing', 'Food', 'Books', 'Sports', 'Home', 'Other'
  ];

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '');
    _category = p?.category ?? 'Electronics';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final provider = context.read<ProductProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.product!.copyWith(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        category: _category,
        stock: int.parse(_stockCtrl.text.trim()),
      );
      success = await provider.updateProduct(updated);
    } else {
      success = await provider.createProduct(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        category: _category,
        stock: int.parse(_stockCtrl.text.trim()),
      );
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Error desconocido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductProvider>();

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit_rounded : Icons.add_circle_rounded,
                    color: provider.isSQL ? const Color(0xFF4FC3F7) : const Color(0xFFAED581),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditing ? 'Editar Producto' : 'Nuevo Producto',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name field
              _buildField(
                controller: _nameCtrl,
                label: 'Nombre',
                hint: 'Ej: Laptop Pro 15"',
                icon: Icons.inventory_2_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // Price field
              _buildField(
                controller: _priceCtrl,
                label: 'Precio (\$)',
                hint: '0.00',
                icon: Icons.attach_money_rounded,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Precio inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF16213E),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration('Categoría', Icons.category_rounded),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),

              // Stock field
              _buildField(
                controller: _stockCtrl,
                label: 'Stock',
                hint: '0',
                icon: Icons.warehouse_rounded,
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey[400])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isSQL
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFFAED581),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text(
                              _isEditing ? 'Actualizar' : 'Crear',
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 18),
      filled: true,
      fillColor: const Color(0xFF16213E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }
}

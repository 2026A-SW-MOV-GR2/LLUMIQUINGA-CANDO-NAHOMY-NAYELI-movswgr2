import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import 'product_form_dialog.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final int index;

  const ProductCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final accentColor = provider.isSQL ? const Color(0xFF4FC3F7) : const Color(0xFFAED581);

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 60).ms),
        SlideEffect(begin: const Offset(0, 0.1), duration: 300.ms, delay: (index * 60).ms),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForCategory(product.category), color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _badge(product.category, Colors.purple.shade300),
                        const SizedBox(width: 6),
                        _badge('Stock: ${product.stock}', Colors.orange.shade300),
                      ],
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _actionBtn(
                        icon: Icons.edit_rounded,
                        color: Colors.blue.shade300,
                        onTap: () => _showEdit(context),
                      ),
                      const SizedBox(width: 6),
                      _actionBtn(
                        icon: Icons.delete_rounded,
                        color: Colors.red.shade300,
                        onTap: () => _confirmDelete(context, provider),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  void _showEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        content: Text(
          '¿Eliminar "${product.name}"?',
          style: GoogleFonts.inter(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteProduct(product.id);
            },
            child: Text('Eliminar', style: GoogleFonts.inter(color: Colors.red.shade300)),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Electronics': return Icons.devices_rounded;
      case 'Clothing': return Icons.checkroom_rounded;
      case 'Food': return Icons.restaurant_rounded;
      case 'Books': return Icons.menu_book_rounded;
      case 'Sports': return Icons.sports_basketball_rounded;
      case 'Home': return Icons.home_rounded;
      default: return Icons.category_rounded;
    }
  }
}

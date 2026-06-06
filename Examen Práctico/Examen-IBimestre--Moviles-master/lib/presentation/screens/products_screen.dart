import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/engine_indicator_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final isSQL = provider.isSQL;
        final accentColor = isSQL ? const Color(0xFF4FC3F7) : const Color(0xFFAED581);

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1B),
          appBar: _buildAppBar(context, provider, accentColor),
          body: _buildBody(provider, accentColor),
          floatingActionButton: _buildFab(context, accentColor),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProductProvider provider,
    Color accentColor,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF0D0D1B),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventario',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const EngineIndicatorChip(),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              Icon(Icons.bubble_chart_rounded,
                  size: 16,
                  color: !provider.isSQL ? const Color(0xFFAED581) : Colors.grey[600]),
              Switch(
                value: provider.isSQL,
                onChanged: (val) {
                  provider.switchEngine(
                    val ? DatabaseEngine.sql : DatabaseEngine.nosql,
                  );
                },
                activeColor: const Color(0xFF4FC3F7),
                inactiveThumbColor: const Color(0xFFAED581),
                inactiveTrackColor: const Color(0xFFAED581).withOpacity(0.3),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
              Icon(Icons.table_rows_rounded,
                  size: 16,
                  color: provider.isSQL ? const Color(0xFF4FC3F7) : Colors.grey[600]),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 1,
          color: accentColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildBody(ProductProvider provider, Color accentColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: GoogleFonts.inter(color: Colors.red.shade300),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.refresh();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return _buildEmptyState(accentColor);
    }

    return Column(
      children: [
        // Header con stats
        _buildStats(provider, accentColor),

        // Lista de productos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: provider.products.length,
            itemBuilder: (ctx, i) => ProductCard(
              product: provider.products[i],
              index: i,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ProductProvider provider, Color accentColor) {
    final totalValue = provider.products.fold(0.0, (sum, p) => sum + (p.price * p.stock));
    final totalItems = provider.products.fold(0, (sum, p) => sum + p.stock);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _statItem('Productos', provider.products.length.toString(), accentColor),
          _divider(),
          _statItem('Items', totalItems.toString(), accentColor),
          _divider(),
          _statItem('Valor Total', '\$${totalValue.toStringAsFixed(0)}', accentColor),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.jetBrainsMono(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label,
              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: Colors.grey[800]);

  Widget _buildEmptyState(Color accentColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: accentColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Sin productos',
            style: GoogleFonts.spaceGrotesk(color: Colors.grey[400], fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para agregar el primero',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildFab(BuildContext context, Color accentColor) {
    return FloatingActionButton.extended(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const ProductFormDialog(),
      ),
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
      icon: const Icon(Icons.add_rounded),
      label: Text('Nuevo', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
    ).animate().scale(delay: 200.ms, duration: 300.ms);
  }
}

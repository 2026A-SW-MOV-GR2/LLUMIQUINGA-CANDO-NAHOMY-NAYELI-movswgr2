import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class EngineIndicatorChip extends StatelessWidget {
  const EngineIndicatorChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final isSQL = provider.isSQL;
        final color = isSQL ? const Color(0xFF4FC3F7) : const Color(0xFFAED581);
        final icon = isSQL ? Icons.table_rows_rounded : Icons.bubble_chart_rounded;
        final label = isSQL ? 'SQLite' : 'Hive NoSQL';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ).animate(key: ValueKey(isSQL)).fadeIn(duration: 200.ms).slideX(begin: 0.1);
      },
    );
  }
}

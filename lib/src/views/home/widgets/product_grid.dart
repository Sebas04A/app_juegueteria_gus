// Guardar en: lib/src/views/home/widgets/product_grid.dart

import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import 'product_card.dart';

// Ahora este widget devuelve un SliverGrid, que es la versión de GridView
// para usar dentro de CustomScrollView.
class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.68,
        ),
        // SliverChildBuilderDelegate es el equivalente a itemBuilder para slivers.
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return ProductCard(product: product);
        }, childCount: products.length),
      ),
    );
  }
}

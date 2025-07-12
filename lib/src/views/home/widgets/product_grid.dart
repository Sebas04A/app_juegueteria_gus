// Guardar en: lib/src/views/home/widgets/product_grid.dart

import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // GridView se encarga de mostrar los productos en una cuadrícula adaptable.
    return GridView.builder(
      // Añadimos un padding generoso para que no esté pegado a los bordes.
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // Mostramos 2 columnas.
        crossAxisCount: 2,
        // Espaciado horizontal entre tarjetas.
        crossAxisSpacing: 16.0,
        // Espaciado vertical entre tarjetas.
        mainAxisSpacing: 16.0,
        // Relación de aspecto para que las tarjetas sean más altas que anchas.
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        // Usamos nuestro ProductCard rediseñado.
        return ProductCard(product: product);
      },
    );
  }
}

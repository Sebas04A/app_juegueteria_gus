// Guardar en: lib/src/views/home/widgets/product_card.dart

import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_colors.dart'; // Importamos nuestros colores
// import '../../product_detail/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Usamos el CardTheme definido en main.dart
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          print('Navegar al detalle de: ${product.prodNombre}');
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN DE IMAGEN CON INDICADOR DE STOCK ---
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    child: Image.network(
                      product.firstImage,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.toys_outlined,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Imagen no disponible",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Etiqueta de stock en la esquina
                  if (product.prodStock < 10 && product.prodStock > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '¡Pocos!',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // --- SECCIÓN DE DETALLES ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Text(
                    product.prodCategoria.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Nombre del producto
                  Text(
                    product.prodNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // --- PRECIO Y BOTÓN DE COMPRA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Precio
                      Text(
                        '\$${product.prodPrecio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      // Botón de Añadir al Carrito
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            print('Añadir al carrito: ${product.prodNombre}');
                            // Lógica para añadir al carrito
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.prodNombre} añadido al carrito.',
                                ),
                                backgroundColor: AppColors.textPrimary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
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

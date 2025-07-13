// Guardar en: lib/src/views/home/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../services/auth_provider.dart';
import '../../../utils/app_colors.dart';
import '../../login/login_screen.dart'; // Importamos la pantalla de login

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          print('Navegar al detalle de: ${product.prodNombre}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (código de la imagen sin cambios) ...
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (código de categoría y nombre sin cambios) ...
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.prodPrecio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      // --- LÓGICA DE COMPRA ACTUALIZADA ---
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            // Obtenemos el authProvider sin escuchar cambios.
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );

                            if (authProvider.isLoggedIn) {
                              // Si está logueado, añade al carrito.
                              print('Añadir al carrito: ${product.prodNombre}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.prodNombre} añadido al carrito.',
                                  ),
                                  backgroundColor: AppColors.textPrimary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              // Si no, muestra un mensaje y redirige a login.
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Debes iniciar sesión para comprar.',
                                  ),
                                  action: SnackBarAction(
                                    label: 'INGRESAR',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
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

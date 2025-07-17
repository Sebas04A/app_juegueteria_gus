// Guardar en: lib/src/views/home/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../services/auth_provider.dart';
import '../../../utils/app_colors.dart';
import '../../login/login_screen.dart';
import '../../product_detail/product_detail_screen.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../services/api_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'product-image-${product.idProducto}';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: product.idProducto,
              heroTag: heroTag,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN DE IMAGEN MEJORADA ---
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0),
                      ),
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
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
                  ),
                  // Botón de Favoritos
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        print('Favorito presionado: ${product.prodNombre}');
                      },
                    ),
                  ),
                ],
              ),
            ),
            // --- SECCIÓN DE DETALLES REFINADA ---
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Categoría
                    Text(
                      product.prodCategoria.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Nombre del producto
                    Text(
                      product.prodNombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Precio y botón de compra
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.prodPrecio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        _buildAddToCartButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget del botón de añadir al carrito
  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );

            if (!authProvider.isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Debes iniciar sesión para comprar.'),
                  action: SnackBarAction(
                    label: 'INGRESAR',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ),
              );
              return;
            }

            if (product.prodStock <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.prodNombre} está agotado.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Mostrar diálogo para elegir cantidad
            int cantidadSeleccionada = 1;
            final result = await showDialog<int>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Elegir cantidad'),
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Stock disponible: ${product.prodStock}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: cantidadSeleccionada > 1
                                    ? () => setState(() {
                                        cantidadSeleccionada--;
                                      })
                                    : null,
                              ),
                              Text(
                                '$cantidadSeleccionada',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed:
                                    cantidadSeleccionada < product.prodStock
                                    ? () => setState(() {
                                        cantidadSeleccionada++;
                                      })
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(cantidadSeleccionada);
                      },
                      child: const Text(
                        'Añadir',
                        style: TextStyle(
                          color: Colors
                              .white, // Cambia a cualquier color que desees
                        ),
                      ),
                    ),
                  ],
                );
              },
            );

            if (result == null) {
              // Cancelado
              return;
            }

            // Verificar stock en backend
            try {
              final api = ApiService();
              bool tieneStock = await api.verificarStockDisponible(
                product.idProducto,
                result,
              );

              if (!tieneStock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No hay suficiente stock disponible de ${product.prodNombre}.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Llamar API para agregar al backend
              await api.addToCart(
                userId: authProvider.userId!,
                productId: product.idProducto,
                quantity: result,
              );

              // Actualizar carrito localmente
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );

              cartProvider.agregarLocal(
                CartItem(
                  productoId: product.idProducto,
                  nombre: product.prodNombre,
                  precio: product.prodPrecio,
                  cantidad: result,
                  stock: product.prodStock,
                  prodImg: product.firstImage,
                  edad: '',
                  carritoId: 0,
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.prodNombre} añadido al carrito.'),
                  backgroundColor: AppColors.textPrimary,
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error al agregar ${product.prodNombre} al carrito.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            Icons.add_shopping_cart_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

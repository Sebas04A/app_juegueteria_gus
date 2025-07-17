// Guardar en: lib/src/views/product_detail/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:juegueteria_gustavito/src/models/cart_item_model.dart';
import 'package:juegueteria_gustavito/src/services/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final String heroTag;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;
  final ApiService _apiService = ApiService();
  int _quantity = 1;
  int _selectedImageIndex = 0; // Para controlar la imagen seleccionada

  @override
  void initState() {
    super.initState();
    _productFuture = _apiService.getProductById(widget.productId);
  }

  void _incrementQuantity(int stock) {
    if (_quantity < stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget();
        }

        final product = snapshot.data!;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(product),
              SliverToBoxAdapter(child: _buildProductInfo(product)),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(context, product),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 400.0, // Aumentamos la altura para la galería
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.surface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visor de imagen principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Hero(
                    tag: widget.heroTag,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.network(
                        product.prodImg.isNotEmpty
                            ? product.prodImg[_selectedImageIndex]
                            : product.firstImage,
                        key: ValueKey<int>(
                          _selectedImageIndex,
                        ), // Clave para la animación
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.toys_outlined,
                              size: 100,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              // Galería de miniaturas
              if (product.prodImg.length > 1)
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.prodImg.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageIndex = index;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedImageIndex == index
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(product.prodImg[index]),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.prodCategoria.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Chip(
                label: Text('Stock: ${product.prodStock}'),
                backgroundColor:
                    (product.prodStock > 0 ? Colors.green : Colors.red)
                        .withOpacity(0.1),
                labelStyle: TextStyle(
                  color: product.prodStock > 0
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.prodNombre,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  i < 4 ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
              const SizedBox(width: 8),
              const Text(
                '(125 reseñas)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Descripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            product.prodDescripcion,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Product product) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: const Icon(Icons.remove, size: 18),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _incrementQuantity(product.prodStock),
                  icon: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Añadir al Carrito'),
              onPressed: () async {
                try {
                  final api = ApiService();
                  bool tieneStock = await api.verificarStockDisponible(
                    product.idProducto,
                    _quantity,
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
                  // Obtener el ID del usuario autenticado
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  if (authProvider.userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Debes iniciar sesión para agregar al carrito.',
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
                    quantity: _quantity,
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
                      cantidad: _quantity,
                      stock: product.prodStock,
                      prodImg: product.firstImage,
                      edad: '',
                      carritoId: 0,
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${product.prodNombre} añadido al carrito.',
                      ),
                      backgroundColor: AppColors.textPrimary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error al agregar al carrito: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al agregar ${product.prodNombre} al carrito.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '¡$_quantity ${product.prodNombre} añadido(s) al carrito!',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'VER CARRITO',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/cart');
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No se pudo cargar el producto.',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

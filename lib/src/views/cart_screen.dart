import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).cargarCarrito(authProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final total = cartProvider.items.fold<double>(
      0,
      (sum, item) => sum + (item.precio * item.cantidad),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de Compras')),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('Carrito vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return ListTile(
                        leading: item.prodImg.isNotEmpty
                            ? Image.network(
                                item.prodImg,
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image),
                        title: Text(item.nombre),
                        subtitle: Text('Cantidad: ${item.cantidad}'),
                        trailing: Text(
                          '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!authProvider.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Debes iniciar sesión para realizar la compra.',
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        // Construir DTO de compra
                        final compraData = {
                          "carrito": {
                            "productos": cartProvider.items
                                .map(
                                  (e) => {
                                    "idProducto": e.productoId,
                                    "cantidad": e.cantidad,
                                  },
                                )
                                .toList(),
                          },
                          "direccion": "Dirección de prueba",
                          "metodoPago": "Tarjeta",
                          "cliente": {
                            "cliCedula": authProvider.userId!,
                            "cliNombre": "Usuario",
                            "cliApellido": "Demo",
                            "cliTelefono": "000000000",
                          },
                        };

                        await _apiService.realizarCompra(compraData);

                        final carritoId = await _apiService
                            .obtenerCarritoIdPorUsuario(authProvider.userId!);

                        if (carritoId != null) {
                          print("✅ CarritoID obtenido: $carritoId");

                          // Traer todos los detalles
                          final detalles = await _apiService
                              .obtenerTodosLosDetalles();

                          final detallesDelCarrito = detalles
                              .where((d) => d.carritoId == carritoId)
                              .toList();

                          if (detallesDelCarrito.isNotEmpty) {
                            for (final detalle in detallesDelCarrito) {
                              await _apiService.eliminarCarritoDetallePorId(
                                detalle.id,
                              );
                              print(
                                "✅ Detalle eliminado: ${detalle.id} del carrito $carritoId",
                              );
                            }
                          } else {
                            print(
                              "⚠️ No se encontraron detalles para el carrito $carritoId",
                            );
                          }

                          // ✅ Intentar borrar el carrito
                          final carritoEliminado = await _apiService
                              .eliminarCarrito(carritoId);

                          if (carritoEliminado) {
                            print("✅ Carrito eliminado en backend: $carritoId");
                          } else {
                            print(
                              "❌ No se logró eliminar el carrito $carritoId",
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo eliminar el carrito en backend.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          print("⚠️ No se encontró CarritoID para el usuario.");
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Compra realizada con éxito!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // ✅ Limpiar local y recargar carrito desde backend
                        cartProvider.limpiarCarrito();

                        await cartProvider.cargarCarrito(authProvider.userId!);

                        // ✅ Forzar reconstrucción de pantalla
                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al realizar la compra: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('Comprar (\$${total.toStringAsFixed(2)})'),
                  ),
                ),
              ],
            ),
    );
  }
}

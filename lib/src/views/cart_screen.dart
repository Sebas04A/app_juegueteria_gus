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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editarCantidad(
                                context,
                                item,
                                cartProvider,
                                authProvider,
                              ),
                            ),
                          ],
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
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Debes iniciar sesión para realizar la compra.',
                            ),
                          ),
                        );
                        return;
                      }

                      _mostrarDialogoCompra(
                        context,
                        cartProvider,
                        authProvider,
                      );
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
                    child: Text(
                      'Comprar (\$${total.toStringAsFixed(2)})',
                      style: TextStyle(
                        color: Colors.white,
                      ), // Cambia Colors.red por el color que desees
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// ✅ Diálogo de compra
  void _mostrarDialogoCompra(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) {
    final scaffoldContext = context;

    final TextEditingController direccionController = TextEditingController(
      text: "Dirección de prueba",
    );
    String metodoPagoSeleccionado = "Tarjeta";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Finalizar compra"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: direccionController,
                decoration: InputDecoration(labelText: "Dirección"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: metodoPagoSeleccionado,
                items: [
                  DropdownMenuItem(value: "Tarjeta", child: Text("Tarjeta")),
                  DropdownMenuItem(
                    value: "Transferencia",
                    child: Text("Transferencia"),
                  ),
                  DropdownMenuItem(value: "Efectivo", child: Text("Efectivo")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    metodoPagoSeleccionado = value;
                  }
                },
                decoration: InputDecoration(labelText: "Método de pago"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Confirmar Compra"),
              onPressed: () async {
                Navigator.of(context).pop();

                // ✅ MOSTRAR LOADER
                showDialog(
                  barrierDismissible: false,
                  context: scaffoldContext,
                  builder: (context) =>
                      Center(child: CircularProgressIndicator()),
                );

                await _realizarCompra(
                  scaffoldContext,
                  cartProvider,
                  authProvider,
                  direccionController.text,
                  metodoPagoSeleccionado,
                );

                // ✅ CERRAR LOADER
                Navigator.of(scaffoldContext).pop();

                direccionController.dispose();
              },
            ),
          ],
        );
      },
    );
  }

  /// ✅ Lógica simplificada: solo realizar compra y limpiar carrito
  Future<void> _realizarCompra(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
    String direccion,
    String metodoPago,
  ) async {
    try {
      // ✅ Paso 1 - llamar a API de compra (esto crea la factura en backend)
      await _apiService.realizarCompra({
        "carrito": {
          "productos": cartProvider.items
              .map((e) => {"idProducto": e.productoId, "cantidad": e.cantidad})
              .toList(),
        },
        "direccion": direccion,
        "metodoPago": metodoPago,
        "cliente": {
          "cliCedula": authProvider.userId!,
          "cliNombre": "Usuario",
          "cliApellido": "Demo",
          "cliTelefono": "000000000",
        },
      });

      // ✅ Paso 2 - obtener facturas
      final facturas = await _apiService.obtenerFacturas();

      // ✅ Paso 3 - filtrar por el usuario actual
      final facturasUsuario = facturas.where((f) {
        final usuarioId = f["idUsuario"] ?? f["IdUsuario"] ?? f["id_usuario"];
        return usuarioId?.toString() == authProvider.userId;
      }).toList();

      if (facturasUsuario.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se encontró ninguna factura para confirmar."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Paso 4 - tomar la más reciente (la de mayor FacturaID)
      facturasUsuario.sort(
        (a, b) => (b["FacturaID"] as int).compareTo(a["FacturaID"] as int),
      );

      final ultimaFactura = facturasUsuario.first;
      final idFactura = ultimaFactura["FacturaID"];

      print("✅ Factura encontrada: ID = $idFactura");

      // ✅ Paso 5 - llamar a confirmarCompra
      final confirmado = await _apiService.confirmarCompra({
        "IdFactura": idFactura,
      });

      if (confirmado) {
        // ✅ PASO 6 - ELIMINAR CARRITO Y DETALLES

        final carritoId = await _apiService.obtenerCarritoIdPorUsuario(
          authProvider.userId!,
        );

        if (carritoId != null) {
          final detalles = await _apiService.obtenerTodosLosDetalles();

          final detallesDelCarrito = detalles
              .where((d) => d.carritoId == carritoId)
              .toList();

          if (detallesDelCarrito.isNotEmpty) {
            for (final detalle in detallesDelCarrito) {
              await _apiService.eliminarCarritoDetallePorId(detalle.id);
              print(
                "✅ Detalle eliminado: ${detalle.id} del carrito $carritoId",
              );
            }
          }

          final carritoEliminado = await _apiService.eliminarCarrito(carritoId);

          if (carritoEliminado) {
            print("✅ Carrito eliminado en backend: $carritoId");
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo eliminar el carrito en backend.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Compra confirmada correctamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar carrito local
        cartProvider.limpiarCarrito();
        await cartProvider.cargarCarrito(authProvider.userId!);
        setState(() {});
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo confirmar la compra.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar la compra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editarCantidad(
    BuildContext context,
    var item,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) async {
    try {
      int nuevaCantidad = item.cantidad;

      final result = await showDialog<int>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Editar cantidad'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: nuevaCantidad > 0
                          ? () => setState(() {
                              nuevaCantidad--;
                            })
                          : null,
                    ),
                    Text(
                      '$nuevaCantidad',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final canIncrease = await _apiService
                            .verificarStockDisponible(
                              item.productoId,
                              nuevaCantidad + 1,
                            );
                        if (canIncrease) {
                          setState(() {
                            nuevaCantidad++;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No hay suficiente stock para ${nuevaCantidad + 1}.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
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
                onPressed: () {
                  Navigator.of(context).pop(nuevaCantidad);
                },
                child: const Text('Actualizar'),
              ),
            ],
          );
        },
      );

      if (result == null) return;

      final diferencia = result - item.cantidad;

      if (result == 0) {
        await _apiService.editCart(
          userId: authProvider.userId!,
          products: [
            {"idProducto": item.productoId, "cantidad": -item.cantidad},
          ],
        );

        cartProvider.eliminarProductoLocal(item.productoId);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.nombre} eliminado del carrito.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (diferencia != 0) {
        final detalles = await _apiService.obtenerTodosLosDetalles();
        final carritoId = await _apiService.obtenerCarritoIdPorUsuario(
          authProvider.userId!,
        );

        CarritoDetalleItem? detalle;
        for (final d in detalles) {
          if (d.productoId == item.productoId && d.carritoId == carritoId) {
            detalle = d;
            break;
          }
        }

        if (detalle != null) {
          final data = {
            "CarritoDetalleID": detalle.id,
            "CarritoID": detalle.carritoId,
            "ProductoID": detalle.productoId,
            "Cantidad": result,
          };

          await _apiService.actualizarDetalleCarrito(detalle.id, data);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cantidad de ${item.nombre} actualizada a $result.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print("⚠️ No se encontró el detalle para actualizar en el backend.");
        }
      } else {
        print("⚠️ La cantidad no ha cambiado.");
      }

      await cartProvider.cargarCarrito(authProvider.userId!);
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando cantidad: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

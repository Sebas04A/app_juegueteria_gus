import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartProvider>(
        context,
        listen: false,
      ).cargarCarrito("usuario1");
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de Compras')),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('Carrito vacío'))
          : ListView.builder(
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
                              Icon(Icons.broken_image),
                        )
                      : Icon(Icons.image),
                  title: Text(item.nombre),
                  subtitle: Text('Cantidad: ${item.cantidad}'),
                  trailing: Text(
                    '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                  ),
                );
              },
            ),
    );
  }
}

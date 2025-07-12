import 'package:flutter/material.dart';

// Por ahora, esta pantalla será un placeholder simple.
// Más adelante, aquí llamaremos al servicio para obtener y mostrar los productos.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juguetería Fantasía'),
        actions: [
          // Icono para el carrito de compras
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Lógica para ir al carrito de compras
              print('Carrito presionado!');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '¡Bienvenido a nuestra juguetería!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Un indicador de carga que usaremos mientras obtenemos los datos
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Cargando productos...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para una acción principal, como buscar o filtrar
          print('Botón flotante presionado!');
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

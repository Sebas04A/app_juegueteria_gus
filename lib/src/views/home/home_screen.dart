import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'widgets/product_grid.dart'; // Importamos nuestro nuevo widget de cuadrícula
import '../login/login_screen.dart';

import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Hacemos que este método sea Future<void> para usarlo con RefreshIndicator
  Future<void> _fetchProducts() async {
    setState(() {
      _productsFuture = _apiService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Un color de fondo sutil para la app
      appBar: AppBar(
        title: const Text('Juguetería Gustavito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      // RefreshIndicator permite al usuario "jalar para recargar" la lista.
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(); // Usamos un widget de ayuda para el error.
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyWidget(); // Usamos un widget de ayuda para el estado vacío.
            }

            // ¡Datos listos! Mostramos nuestra nueva y bonita cuadrícula.
            return ProductGrid(products: snapshot.data!);
          },
        ),
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (auth.isLoggedIn) {
                // Si está logueado, cerramos sesión.
                auth.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Has cerrado sesión.'),
                    backgroundColor: AppColors.textSecondary,
                  ),
                );
              } else {
                // Si no, lo mandamos a la pantalla de login.
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            label: Text(auth.isLoggedIn ? 'Salir' : 'Ingresar'),
            icon: Icon(auth.isLoggedIn ? Icons.logout : Icons.login),
            backgroundColor: auth.isLoggedIn
                ? Colors.red.shade400
                : AppColors.secondary,
            foregroundColor: auth.isLoggedIn
                ? Colors.white
                : AppColors.textPrimary,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // Widget de ayuda para mostrar un mensaje de error amigable.
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 70),
            const SizedBox(height: 20),
            const Text(
              '¡Ups! No pudimos conectar con la tienda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Por favor, revisa tu conexión a internet y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: _fetchProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de ayuda para cuando no hay productos.
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.storefront_outlined, color: Colors.grey, size: 70),
          const SizedBox(height: 20),
          const Text(
            'Nuestra tienda está vacía por ahora.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vuelve más tarde para ver nuestros juguetes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

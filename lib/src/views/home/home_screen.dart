// Guardar en: lib/src/views/home/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_colors.dart';
import 'widgets/product_grid.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();

  // Lista para almacenar todos los productos obtenidos de la API.
  List<Product> _allProducts = [];
  // Lista para almacenar los productos que coinciden con la búsqueda.
  List<Product> _filteredProducts = [];
  // Future para controlar el estado de la carga inicial.
  Future<void>? _loadProductsFuture;
  // Estado para manejar la carga y errores.
  String _statusMessage = 'Cargando juguetes...';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de productos.
    _loadProductsFuture = _fetchProducts();
    // Añadimos un listener al controlador de búsqueda para filtrar en tiempo real.
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusMessage = 'Cargando juguetes...';
    });
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
        if (_allProducts.isEmpty) {
          _statusMessage = 'Nuestra tienda está vacía por ahora.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _statusMessage = '¡Ups! No pudimos conectar con la tienda.';
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.prodNombre.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          // Usamos un SliverToBoxAdapter para poder añadir widgets normales dentro de un CustomScrollView.
          SliverToBoxAdapter(child: _buildSearchBar()),
          _buildSliverBody(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // --- WIDGETS DE AYUDA PARA CONSTRUIR LA UI ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Juguetería Fantasía',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-157653B742034-8a0386743239?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.primary),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          onPressed: () {
            print('Carrito presionado!');
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar peluches, carritos, legos...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSliverBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hasError) {
      return SliverFillRemaining(
        child: _buildStatusWidget(
          Icons.cloud_off,
          _statusMessage,
          isError: true,
        ),
      );
    }
    if (_allProducts.isEmpty) {
      return SliverFillRemaining(
        child: _buildStatusWidget(Icons.storefront_outlined, _statusMessage),
      );
    }
    if (_filteredProducts.isEmpty) {
      return SliverFillRemaining(
        child: _buildStatusWidget(
          Icons.search_off,
          'No se encontraron juguetes con ese nombre.',
        ),
      );
    }

    // Si todo está bien, mostramos la cuadrícula de productos.
    return ProductGrid(products: _filteredProducts);
  }

  Widget _buildStatusWidget(
    IconData icon,
    String message, {
    bool isError = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isError ? Colors.redAccent : Colors.grey,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isError) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: () => setState(() {
                  _loadProductsFuture = _fetchProducts();
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return FloatingActionButton.extended(
          onPressed: () {
            if (auth.isLoggedIn) {
              auth.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Has cerrado sesión.')),
              );
            } else {
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
    );
  }
}

// Nota: El widget ProductGrid ahora debe ser un Sliver.
// He actualizado el ProductGrid para que funcione dentro de un CustomScrollView.

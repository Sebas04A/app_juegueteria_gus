import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  Future<void> cargarCarrito(String idUsuario) async {
    _items = await _apiService.ObtenerCarrito(idUsuario);
    notifyListeners();
  }

  void agregarLocal(CartItem item) {
    final index = _items.indexWhere((e) => e.productoId == item.productoId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        cantidad: _items[index].cantidad + 1,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void limpiarCarrito() {
    _items = [];
    notifyListeners();
  }

  // ✅ Método para eliminar producto localmente
  void eliminarProductoLocal(int productoId) {
    _items.removeWhere((item) => item.productoId == productoId);
    notifyListeners();
  }

  // ✅ Método para actualizar la cantidad localmente
  void actualizarCantidadLocal(int productoId, int nuevaCantidad) {
    for (var item in _items) {
      if (item.productoId == productoId) {
        item.cantidad = nuevaCantidad;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> agregarProductoBackend({
    required String userId,
    required CartItem item,
    int? cantidad, // Cantidad opcional
  }) async {
    await _apiService.addToCart(
      userId: userId,
      productId: item.productoId,
      quantity: cantidad ?? item.cantidad,
    );

    // Recargar carrito después de agregar
    await cargarCarrito(userId);
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/compra_dto.dart';
import '../models/user_model.dart';

Product singleProductFromJson(String str) => Product.fromJson(json.decode(str));

class ApiService {
  final String _baseUrl = "https://pruebas.tryasp.net/api";

  Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/integracion/productos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return productFromJson(response.body);
    } else {
      throw Exception('Falló la carga de productos');
    }
  }

  Future<Product> getProductById(int id) async {
    final url = Uri.parse('$_baseUrl/integracion/productos/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return singleProductFromJson(response.body);
    } else {
      throw Exception('Falló la carga del producto con id: $id');
    }
  }

  Future<String?> loginUser(String username, String password) async {
    final url = Uri.parse('$_baseUrl/Usuarios/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'id_usuario': username, 'contrasena': password}),
    );

    if (response.statusCode == 200) {
      return username;
    } else {
      return null;
    }
  }

  Future<bool> registerUser(User user) async {
    final url = Uri.parse('$_baseUrl/Usuarios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: userToJson(user),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<List<CartItem>> ObtenerCarrito(String userId) async {
    final url = Uri.parse('$_baseUrl/integracion/Carrito/Contenido/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return List<CartItem>.from(
          decoded.map((item) => CartItem.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Error al cargar carrito');
    }
  }

  Future<void> addToCart({
    required String userId,
    required int productId,
    required int quantity,
  }) async {
    final url = Uri.parse('$_baseUrl/integracion/CompraInterna');
    final body = jsonEncode({
      "id_usuario": userId,
      "producto_id": productId,
      "cantidad": quantity,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al agregar producto al carrito');
    }
  }

  Future<void> editCart({
    required String userId,
    required List<Map<String, dynamic>> products,
  }) async {
    final url = Uri.parse('$_baseUrl/integracion/Carrito/Editar');
    final body = jsonEncode({"id_usuario": userId, "productos": products});

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar el carrito');
    }
  }

  Future<void> realizarCompra(Map<String, dynamic> compraDto) async {
    final url = Uri.parse('$_baseUrl/integracion/compra');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(compraDto),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al procesar la compra');
    }
  }

  Future<void> realizarCompraDTO(CompraDTO compra) async {
    final url = Uri.parse('$_baseUrl/integracion/compra');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(compra.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al procesar la compra');
    }
  }

  Future<bool> eliminarCarrito(int carritoId) async {
    final url = Uri.parse('$_baseUrl/Carrito/$carritoId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          'Error al eliminar carrito - Status Code: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('Error al eliminar carrito: $e');
      return false;
    }
  }

  /// ✅ Nuevo método: obtener el carritoId del usuario
  Future<int?> obtenerCarritoIdPorUsuario(String userId) async {
    final url = Uri.parse('$_baseUrl/Carrito');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        for (final carrito in data) {
          if (carrito["id_usuario"].toString() == userId) {
            return carrito["CarritoID"];
          }
        }
      }
      return null;
    } else {
      return null;
    }
  }

  /// ✅ Nuevo método: obtener TODOS los detalles de carrito
  Future<List<CarritoDetalleItem>> obtenerTodosLosDetalles() async {
    final url = Uri.parse('$_baseUrl/CarritoDetalle');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>() // solo mapas
            .map((e) => CarritoDetalleItem.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Error al consultar detalles');
    }
  }

  /// ✅ Nuevo método: eliminar un detalle por ID
  Future<void> eliminarCarritoDetallePorId(int detalleId) async {
    final url = Uri.parse('$_baseUrl/CarritoDetalle/$detalleId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar detalle del carrito');
    }
  }

  Future<bool> verificarStockDisponible(int idProducto, int cantidad) async {
    final url = Uri.parse('$_baseUrl/integracion/stock/$idProducto/$cantidad');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded == true;
      } else {
        print('Error verificando stock - Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error verificando stock: $e');
      return false;
    }
  }

  Future<int> verificarStockMaximo(int idProducto) async {
    final url = Uri.parse('$_baseUrl/integracion/productos/$idProducto');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['ProdStock'] ?? 0;
      } else {
        print('Error al obtener stock - Status: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error al obtener stock: $e');
      return 0;
    }
  }

  Future<void> actualizarDetalleCarrito(
    int detalleId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/CarritoDetalle/$detalleId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        print(
          'Error al actualizar detalle carrito - Status: ${response.statusCode}',
        );
        throw Exception('Error al actualizar detalle del carrito');
      }
    } catch (e) {
      print('Error al actualizar detalle del carrito: $e');
      throw Exception('Error de red al actualizar detalle del carrito');
    }
  }

  Future<bool> confirmarCompra(Map<String, dynamic> confirmarDto) async {
    final url = Uri.parse('$_baseUrl/integracion/confirmarCompra');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(confirmarDto),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded == true) {
          return true;
        } else {
          return false;
        }
      } else {
        print('Error confirmando compra - Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error confirmando compra: $e');
      return false;
    }
  }

  Future<List<dynamic>> obtenerFacturas() async {
    final url = Uri.parse('https://pruebas.tryasp.net/facturas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error obteniendo facturas: ${response.body}');
    }
  }
}

/// ✅ Modelo auxiliar para detalles
class CarritoDetalleItem {
  final int id;
  final int carritoId;
  final int productoId;
  final int cantidad;

  CarritoDetalleItem({
    required this.id,
    required this.carritoId,
    required this.productoId,
    required this.cantidad,
  });

  factory CarritoDetalleItem.fromJson(Map<String, dynamic> json) {
    return CarritoDetalleItem(
      id: json['CarritoDetalleID'] ?? 0,
      carritoId: json['CarritoID'] ?? 0,
      productoId: json['ProductoID'] ?? 0,
      cantidad: json['Cantidad'] ?? 0,
    );
  }
}

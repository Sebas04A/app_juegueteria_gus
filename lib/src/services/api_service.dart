// Guardar en: lib/src/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/compra_dto.dart';

class ApiService {
  final String _baseUrl = "https://pruebas.tryasp.net/api/integracion";

  Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/productos');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<Product> products = productFromJson(response.body);
        return products;
      } else {
        print('Error - Status Code: ${response.statusCode}');
        throw Exception('Falló la carga de productos desde el servidor');
      }
    } catch (e) {
      print('Error al obtener productos: $e');
      throw Exception('Ocurrió un error al conectar con el servidor');
    }
  }

  Future<List<CartItem>> ObtenerCarrito(String userId) async {
    final url = Uri.parse('$_baseUrl/Carrito/Contenido/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is String) {
          // Devuelve texto si no hay carrito
          return [];
        }
        return List<CartItem>.from(
          decoded.map((item) => CartItem.fromJson(item)),
        );
      } else {
        print('Error al cargar carrito - Status Code: ${response.statusCode}');
        throw Exception('Error al cargar carrito');
      }
    } catch (e) {
      print('Error al obtener carrito: $e');
      throw Exception('Ocurrió un error al conectar con el servidor');
    }
  }

  Future<void> addToCart({
    required String userId,
    required int productId,
    required int quantity,
  }) async {
    final url = Uri.parse('$_baseUrl/CompraInterna');

    final body = jsonEncode({
      "id_usuario": userId,
      "producto_id": productId,
      "cantidad": quantity,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        print(
          'Error al agregar al carrito - Status Code: ${response.statusCode}',
        );
        throw Exception('Error al agregar producto al carrito');
      }
    } catch (e) {
      print('Error al agregar al carrito: $e');
      throw Exception('Error de red al agregar producto al carrito');
    }
  }

  Future<void> editCart({
    required String userId,
    required List<Map<String, dynamic>> products,
  }) async {
    final url = Uri.parse('$_baseUrl/Carrito/Editar');

    final body = jsonEncode({"id_usuario": userId, "productos": products});

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        print(
          'Error al editar el carrito - Status Code: ${response.statusCode}',
        );
        throw Exception('Error al editar el carrito');
      }
    } catch (e) {
      print('Error al editar el carrito: $e');
      throw Exception('Error de red al editar el carrito');
    }
  }

  Future<void> realizarCompra(Map<String, dynamic> compraDto) async {
    final url = Uri.parse('$_baseUrl/compra');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(compraDto),
      );

      if (response.statusCode != 200) {
        print(
          'Error al realizar la compra - Status Code: ${response.statusCode}',
        );
        throw Exception('Error al procesar la compra');
      }
    } catch (e) {
      print('Error al realizar la compra: $e');
      throw Exception('Error de red al procesar la compra');
    }
  }

  Future<void> realizarCompraDTO(CompraDTO compra) async {
    final url = Uri.parse('$_baseUrl/compra');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(compra.toJson()),
      );

      if (response.statusCode != 200) {
        print(
          'Error al realizar la compra - Status Code: ${response.statusCode}',
        );
        throw Exception('Error al procesar la compra');
      }
    } catch (e) {
      print('Error al realizar la compra: $e');
      throw Exception('Error de red al procesar la compra');
    }
  }
}

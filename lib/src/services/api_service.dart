// Guardar en: lib/src/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/compra_dto.dart';
import '../models/user_model.dart'; // Importamos el nuevo modelo de usuario

Product singleProductFromJson(String str) => Product.fromJson(json.decode(str));

class ApiService {
  final String _baseUrl = "https://pruebas.tryasp.net/api";

  Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/integracion/productos');

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

  // --- NUEVO MÉTODO PARA OBTENER PRODUCTO POR ID ---
  Future<Product> getProductById(int id) async {
    final url = Uri.parse('$_baseUrl/integracion/productos/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Usamos nuestra nueva función de ayuda para decodificar el objeto único.
        return singleProductFromJson(response.body);
      } else {
        // Si el producto no se encuentra (ej. 404) o hay otro error.
        throw Exception('Falló la carga del producto con id: $id');
      }
    } catch (e) {
      throw Exception('Ocurrió un error al conectar con el servidor');
    }
  }

  Future<String?> loginUser(String username, String password) async {
    final url = Uri.parse('$_baseUrl/Usuarios/login');
    print('Intentando login con usuario: $username y contraseña: $password');
    print('URL de login: $url');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'id_usuario': username, 'contrasena': password}),
      );

      // La API devuelve 200 OK en un login exitoso.
      if (response.statusCode == 200) {
        // Podríamos decodificar una respuesta más compleja, pero por ahora,
        // si el login es exitoso, devolvemos el nombre de usuario como ID.
        return username;
      } else {
        // Si el código de estado no es 200 (ej. 401 Unauthorized), el login falló.
        return null;
      }
    } catch (e) {
      // Captura errores de red (sin conexión, etc.)
      print('Error en la llamada de login: $e');
      throw Exception('Error de red durante el inicio de sesión');
    }
  }

  Future<bool> registerUser(User user) async {
    final url = Uri.parse('$_baseUrl/Usuarios');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: userToJson(user), // Usamos la función de nuestro modelo
      );

      // Un código 201 (Created) usualmente indica éxito en un POST.
      // También podemos aceptar 200 (OK) si la API lo devuelve así.
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        // Podemos intentar decodificar un mensaje de error del cuerpo de la respuesta.
        print(
          'Error de registro - Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error en la llamada de registro: $e');
      throw Exception('Error de red durante el registro');
    }
  }

  Future<List<CartItem>> ObtenerCarrito(String userId) async {
    final url = Uri.parse('$_baseUrl/integracion/Carrito/Contenido/$userId');

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
    final url = Uri.parse('$_baseUrl/integracion/CompraInterna');

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
    final url = Uri.parse('$_baseUrl/integracion/Carrito/Editar');

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
    final url = Uri.parse('$_baseUrl/integracion/compra');

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
    final url = Uri.parse('$_baseUrl/integracion/compra');

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

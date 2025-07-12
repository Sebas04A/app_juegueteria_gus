// Guardar en: lib/src/services/api_service.dart

import 'package:http/http.dart' as http;
import '../models/product_model.dart'; // Importamos nuestro modelo

class ApiService {
  // URL base de tu API
  final String _baseUrl = "https://pruebas.tryasp.net/api/integracion";

  // Método para obtener la lista de todos los productos
  Future<List<Product>> getProducts() async {
    final url = Uri.parse('$_baseUrl/productos');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa (código 200), decodificamos el JSON
        // usando la función que creamos en el modelo.
        final List<Product> products = productFromJson(response.body);
        return products;
      } else {
        // Si el servidor devuelve un código de error, lanzamos una excepción
        // para poder manejarla en la UI.
        print('Error - Status Code: ${response.statusCode}');
        throw Exception('Falló la carga de productos desde el servidor');
      }
    } catch (e) {
      // Capturamos cualquier error durante la llamada de red (ej: sin internet)
      // o durante la decodificación del JSON.
      print('Error al obtener productos: $e');
      throw Exception('Ocurrió un error al conectar con el servidor');
    }
  }
}

// Guardar en: lib/src/models/product_model.dart

import 'dart:convert';

// Función de utilidad para decodificar una lista de productos desde un string JSON
List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

// Función de utilidad para codificar un producto a un string JSON
String productToJson(Product data) => json.encode(data.toJson());

class Product {
  final int idProducto;
  final String prodCategoria;
  final String prodNombre;
  final String prodDescripcion;
  final double prodPrecio;
  final int prodStock;
  final String prodProveedor;
  final List<String> prodImg;

  Product({
    required this.idProducto,
    required this.prodCategoria,
    required this.prodNombre,
    required this.prodDescripcion,
    required this.prodPrecio,
    required this.prodStock,
    required this.prodProveedor,
    required this.prodImg,
  });

  // Factory constructor para crear una instancia de Product desde un mapa (JSON).
  // Este método mapea las claves del JSON a las propiedades de la clase.
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    idProducto: json["idProducto"],
    prodCategoria: json["prodCategoria"],
    prodNombre: json["prodNombre"],
    prodDescripcion: json["prodDescripcion"],
    // Nos aseguramos de que el precio se convierta a double correctamente.
    prodPrecio: (json["prodPrecio"] as num).toDouble(),
    prodStock: json["prodStock"],
    prodProveedor: json["prodProveedor"],
    // Mapeamos la lista de imágenes.
    prodImg: List<String>.from(json["prodImg"].map((x) => x)),
  );

  // Método para convertir una instancia de Product a un mapa (JSON).
  Map<String, dynamic> toJson() => {
    "idProducto": idProducto,
    "prodCategoria": prodCategoria,
    "prodNombre": prodNombre,
    "prodDescripcion": prodDescripcion,
    "prodPrecio": prodPrecio,
    "prodStock": prodStock,
    "prodProveedor": prodProveedor,
    "prodImg": List<dynamic>.from(prodImg.map((x) => x)),
  };

  // Un método de ayuda para obtener la primera imagen de la lista de forma segura.
  // Si la lista de imágenes está vacía, devuelve una URL de imagen de marcador de posición.
  String get firstImage {
    return prodImg.isNotEmpty
        ? prodImg.first
        : 'https://placehold.co/600x400/ECEFF1/90A4AE?text=Sin+Imagen';
  }
}

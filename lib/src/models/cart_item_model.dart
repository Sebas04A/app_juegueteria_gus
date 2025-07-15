class CartItem {
  final int carritoId;
  final int productoId;
  final String nombre;
  final double precio;
  int cantidad;
  final int stock;
  final String prodImg;
  final String edad;

  CartItem({
    required this.carritoId,
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.stock,
    required this.prodImg,
    required this.edad,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productoId: json["producto_id"] ?? 0,
    nombre: json["nombre"] ?? "",
    precio: (json["precio"] ?? 0).toDouble(),
    cantidad: json["cantidad"] ?? 0,
    stock: json["stock"] ?? 0,
    prodImg: json["prodImg"] ?? "",
    edad: json["edad"] ?? "",
    carritoId: json["carrito_id"] ?? 0,
  );

  CartItem copyWith({
    int? carritoId,
    int? productoId,
    String? nombre,
    double? precio,
    int? cantidad,
    int? stock,
    String? prodImg,
    String? edad,
  }) {
    return CartItem(
      carritoId: carritoId ?? this.carritoId,
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      stock: stock ?? this.stock,
      prodImg: prodImg ?? this.prodImg,
      edad: edad ?? this.edad,
    );
  }
}

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

class CartItem {
  final int productoId;
  final String nombre;
  final double precio;
  final int cantidad;
  final int stock;
  final String prodImg;
  final String edad;

  CartItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.stock,
    required this.prodImg,
    required this.edad,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productoId: json["producto_id"],
    nombre: json["nombre"],
    precio: (json["precio"] as num).toDouble(),
    cantidad: json["cantidad"],
    stock: json["stock"],
    prodImg: json["prodImg"] ?? "",
    edad: json["edad"] ?? "",
  );

  CartItem copyWith({
    int? productoId,
    String? nombre,
    double? precio,
    int? cantidad,
    int? stock,
    String? prodImg,
    String? edad,
  }) {
    return CartItem(
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

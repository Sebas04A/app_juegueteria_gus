class CompraDetalleDTO {
  final int productoId;
  final int cantidad;
  final double precioUnitario;

  CompraDetalleDTO({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toJson() => {
        "producto_id": productoId,
        "cantidad": cantidad,
        "precio_unitario": precioUnitario,
      };
}

class CompraDTO {
  final String idUsuario;
  final String metodoPago;
  final double total;
  final List<CompraDetalleDTO> detalles;

  CompraDTO({
    required this.idUsuario,
    required this.metodoPago,
    required this.total,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
        "id_usuario": idUsuario,
        "metodo_pago": metodoPago,
        "total": total,
        "detalles": detalles.map((e) => e.toJson()).toList(),
      };
}

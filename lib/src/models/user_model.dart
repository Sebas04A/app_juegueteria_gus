// Guardar en: lib/src/models/user_model.dart

import 'dart:convert';

// Función para convertir un objeto User a JSON string.
String userToJson(User data) => json.encode(data.toJson());

class User {
  final String idUsuario;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String contrasena;
  final String fechaNacimiento; // Formato "yyyy-MM-dd"
  final String genero;
  final String? comentario;
  final String fechaRegistro; // Formato ISO 8601
  final String? ultimaActividad;
  final String estadoCuenta;
  final bool verificado;
  final String tipoUsuario;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.contrasena,
    required this.fechaNacimiento,
    required this.genero,
    this.comentario,
    required this.fechaRegistro,
    this.ultimaActividad,
    required this.estadoCuenta,
    required this.verificado,
    required this.tipoUsuario,
  });

  // Método para convertir la instancia de la clase a un mapa JSON.
  Map<String, dynamic> toJson() => {
    "id_usuario": idUsuario,
    "nombre": nombre,
    "apellido": apellido,
    "email": email,
    "telefono": telefono,
    "contrasena": contrasena,
    "fecha_nacimiento": fechaNacimiento,
    "genero": genero,
    "comentario": comentario,
    "fecha_registro": fechaRegistro,
    "ultima_actividad": ultimaActividad,
    "estado_cuenta": estadoCuenta,
    "verificado": verificado,
    "tipo_usuario": tipoUsuario,
  };
}

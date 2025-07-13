// Guardar en: lib/src/utils/validators.dart

class Validators {
  // Valida que el campo solo contenga letras y espacios.
  static String? isTextOnly(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName es requerido.';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'El campo $fieldName solo puede contener letras.';
    }
    return null;
  }

  // Valida que el número de teléfono sea un móvil ecuatoriano válido.
  static String? isEcuadorianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de teléfono es requerido.';
    }
    if (!RegExp(r'^09\d{8}$').hasMatch(value)) {
      return 'Ingresa un número de celular válido (ej: 09... y 10 dígitos).';
    }
    return null;
  }

  // Valida que el email tenga un formato correcto.
  static String? isEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido.';
    }
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  // Valida una cédula ecuatoriana.
  static String? isEcuadorianId(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de cédula es requerido.';
    }

    if (value.length != 10) {
      return 'La cédula debe tener 10 dígitos.';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'La cédula solo puede contener números.';
    }

    int provincia = int.parse(value.substring(0, 2));
    if (provincia < 1 || provincia > 24) {
      return 'Código de provincia inválido.';
    }

    int tercerDigito = int.parse(value[2]);
    if (tercerDigito >= 6) {
      return 'Tercer dígito inválido.';
    }

    List<int> coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int producto = int.parse(value[i]) * coeficientes[i];
      suma += (producto >= 10) ? producto - 9 : producto;
    }

    int digitoVerificadorCalculado = (suma % 10 == 0) ? 0 : 10 - (suma % 10);
    int digitoVerificadorReal = int.parse(value[9]);

    if (digitoVerificadorCalculado != digitoVerificadorReal) {
      return 'Número de cédula inválido.';
    }

    return null;
  }
}

// Guardar en: lib/src/views/register/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart'; // Importamos nuestro archivo de validaciones

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo del formulario
  final _idUsuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmContrasenaController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  String? _generoSeleccionado;
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Es importante limpiar los controladores
    _idUsuarioController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmContrasenaController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text = "${picked.toLocal()}".split(
          ' ',
        )[0]; // Formato yyyy-MM-dd
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final newUser = User(
      idUsuario: _idUsuarioController.text,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      email: _emailController.text,
      telefono: _telefonoController.text,
      contrasena: _contrasenaController.text,
      fechaNacimiento: _fechaNacimientoController.text,
      genero: _generoSeleccionado!,
      fechaRegistro: DateTime.now().toIso8601String(),
      estadoCuenta: 'activo',
      verificado: false,
      tipoUsuario: 'comprador',
    );

    final success = await authProvider.register(newUser);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(); // Regresa a la pantalla de login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Ahora puedes iniciar sesión.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Ocurrió un error inesperado.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear una cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Campos del formulario con validaciones actualizadas ---
              TextFormField(
                controller: _idUsuarioController,
                decoration: const InputDecoration(labelText: 'Cédula'),
                keyboardType: TextInputType.number,
                validator: Validators.isEcuadorianId, // Nueva validación
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                keyboardType: TextInputType.text,
                validator: (v) =>
                    Validators.isTextOnly(v, 'Nombre'), // Nueva validación
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                keyboardType: TextInputType.text,
                validator: (v) =>
                    Validators.isTextOnly(v, 'Apellido'), // Nueva validación
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.isEmail, // Validación mejorada
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono Celular',
                ),
                keyboardType: TextInputType.phone,
                validator:
                    Validators.isEcuadorianPhoneNumber, // Nueva validación
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v!.isEmpty) return 'La contraseña es requerida';
                  if (v.length < 6)
                    return 'La contraseña debe tener al menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmContrasenaController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                obscureText: true,
                validator: (v) {
                  if (v != _contrasenaController.text)
                    return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (v) => v!.isEmpty ? 'La fecha es requerida' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _generoSeleccionado,
                decoration: const InputDecoration(labelText: 'Género'),
                items: ['masculino', 'femenino', 'otro']
                    .map(
                      (label) =>
                          DropdownMenuItem(child: Text(label), value: label),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _generoSeleccionado = value;
                  });
                },
                validator: (v) => v == null ? 'Selecciona un género' : null,
              ),
              const SizedBox(height: 32),
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Registrarme',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

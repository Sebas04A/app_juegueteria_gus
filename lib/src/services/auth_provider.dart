// Guardar en: lib/src/services/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  String? get userId => _userId;
  bool get isLoggedIn => _userId != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loggedInUserId = await _apiService.loginUser(username, password);

      if (loggedInUserId != null) {
        _userId = loggedInUserId;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Usuario o contraseña incorrectos.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage =
          'No se pudo conectar con el servidor. Inténtalo de nuevo.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- NUEVO MÉTODO DE REGISTRO ---
  Future<bool> register(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.registerUser(user);
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            'No se pudo completar el registro. El usuario o email podría ya existir.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage =
          'Error de conexión. Revisa tu internet e inténtalo de nuevo.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _userId = null;
    notifyListeners();
  }
}

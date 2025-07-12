import 'package:flutter/material.dart';
import 'src/utils/app_colors.dart'; // Importamos nuestra nueva paleta de colores
import 'src/views/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juguetería Fantasía',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Usamos nuestra paleta de colores personalizada
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor:
            AppColors.background, // Color de fondo para las pantallas
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 1.0,
          surfaceTintColor: Colors
              .transparent, // Evita que la barra cambie de color al hacer scroll
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

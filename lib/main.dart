import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/utils/app_colors.dart';
import 'src/views/home/home_screen.dart';
import 'src/views/cart_screen.dart';
import 'src/providers/cart_provider.dart';

import 'package:provider/provider.dart'; // Importamos provider
import 'src/services/auth_provider.dart';
import 'src/views/splash/splash_screen.dart'; // Importamos nuestro provider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juguetería Gustavito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 1.0,
          surfaceTintColor: Colors.transparent,
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
      // initialRoute: '/',
      home: const SplashScreen(),
      routes: {
        // '/': (context) => const HomeScreen(),
        '/cart': (context) => CartScreen(),
      },
      // routes: {
      //   '/cart': (ctx) => const CartScreen(),
      // },
    );
  }
}

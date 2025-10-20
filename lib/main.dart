import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/start_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/password_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Madshop',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white, // фон всех экранов
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // цвет кнопки
              foregroundColor: Colors.white, // цвет текста на кнопке
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // скругление углов
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade200, // светло-серый фон всех полей
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const StartScreen(),
          '/create': (_) => const CreateAccountScreen(),
          '/login': (_) => const LoginScreen(),
          '/password': (_) => const PasswordScreen(),
          '/shop': (_) => const ShopScreen(),
          '/favourites': (_) => const FavouritesScreen(),
          '/cart': (_) => const CartScreen(),
        },
      ),
    );
  }
}

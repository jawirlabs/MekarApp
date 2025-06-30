import 'package:flutter/material.dart';
import 'package:mekarjs/screens/login_screen.dart';
import 'package:mekarjs/screens/product_screen.dart';
import 'package:mekarjs/screens/navbar_screen.dart';
import 'package:mekarjs/screens/home_screen.dart';
import 'package:mekarjs/screens/chat_screen.dart';
import 'package:mekarjs/screens/sales_screen.dart';
import 'package:mekarjs/screens/purchase_screen.dart';
import 'package:mekarjs/screens/inventory_screen.dart';
import 'package:mekarjs/screens/employee_screen.dart';
import 'package:mekarjs/screens/production_screen.dart';
import 'package:mekarjs/screens/profile_screen.dart';
import 'package:mekarjs/core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MekarJS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => NavbarPage(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/sales': (context) => const SalesScreen(),
        '/purchase': (context) => const PurchaseScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/employee': (context) => const EmployeeScreen(),
        '/production': (context) => const ProductionScreen(),
        '/product': (context) => const ProductScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
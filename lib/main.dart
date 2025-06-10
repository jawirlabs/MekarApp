import 'package:flutter/material.dart';
import 'package:mekarjs/features/auth/presentation/pages/login_page.dart';
import 'package:mekarjs/features/auth/presentation/pages/register_page.dart';
import 'package:mekarjs/features/product/presentation/pages/product_page.dart';
import 'package:mekarjs/features/welcome/presentation/pages/welcome_page.dart';
import 'package:mekarjs/features/home/presentation/pages/navbar_page.dart';
import 'package:mekarjs/features/home/presentation/pages/home_page.dart';
import 'package:mekarjs/features/chat/presentation/pages/chat_page.dart';
import 'package:mekarjs/features/sales/presentation/pages/sales_page.dart';
// import 'package:mekarjs/features/customer/presentation/pages/customer_page.dart';
import 'package:mekarjs/features/purchase/presentation/pages/purchase_page.dart';
// import 'package:mekarjs/features/supplier/presentation/pages/supplier_page.dart';
import 'package:mekarjs/features/inventory/presentation/pages/inventory_page.dart';
import 'package:mekarjs/features/employee/presentation/pages/employee_page.dart';
import 'package:mekarjs/features/production/presentation/pages/production_page.dart';
import 'package:mekarjs/features/website/presentation/pages/website_page.dart';
import 'package:mekarjs/features/profile/presentation/pages/profile_page.dart';
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
      initialRoute: '/main',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => NavbarPage(),
        '/home': (context) => const HomePage(),
        '/chat': (context) => const ChatPage(),
        '/sales': (context) => const SalesPage(),
        // '/customer': (context) => const CustomerPage(),
        '/purchase': (context) => const PurchasePage(),
        // '/supplier': (context) => const SupplierPage(),
        '/inventory': (context) => const InventoryPage(),
        '/employee': (context) => const EmployeePage(),
        '/production': (context) => const ProductionPage(),
        '/product': (context) => const ProductPage(),
        '/website': (context) => const WebsitePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
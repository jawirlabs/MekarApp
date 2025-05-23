import 'package:flutter/material.dart';
import 'package:mekarjs/features/auth/presentation/pages/login_page.dart';
import 'package:mekarjs/features/auth/presentation/pages/register_page.dart';
import 'package:mekarjs/features/chat/presentation/pages/chat_page.dart';
import 'package:mekarjs/features/home/presentation/pages/navrail_page.dart';
import 'package:mekarjs/features/profile/presentation/pages/profile_page.dart';
import 'package:mekarjs/features/welcome/presentation/pages/welcome_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MekarJS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavrailPage(),
        '/chat': (context) => const ChatPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

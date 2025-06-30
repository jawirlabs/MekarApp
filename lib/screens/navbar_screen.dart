import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mekarjs/screens/chat_screen.dart';
import 'package:mekarjs/screens/home_screen.dart';
import 'package:mekarjs/screens/profile_screen.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0;

  final _pages = const [
    ChatScreen(),     // Tanya AI
    HomeScreen(),     // Dashboard
    ProfileScreen(),  // Profil
  ];

  final _destinations = const [
    NavigationDestination(
      icon: Icon(LucideIcons.sparkles),
      selectedIcon: Icon(LucideIcons.sparkles),
      label: 'Tanya AI',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.layoutDashboard),
      selectedIcon: Icon(LucideIcons.layoutDashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.user),
      selectedIcon: Icon(LucideIcons.user),
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      // appBar: AppBar(
      //   backgroundColor: colorScheme.surface,
      //   elevation: 0,
      //   surfaceTintColor: colorScheme.surfaceTint,
      //   centerTitle: true,
      //   title: Image.asset(
      //     'assets/mekarjs.png',
      //     height: 40,
      //     fit: BoxFit.contain,
      //   ),
      // ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              HapticFeedback.lightImpact();
            },
            height: 72,
            backgroundColor: Colors.transparent,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: _destinations,
          ),
        ),
      ),
    );
  }
}

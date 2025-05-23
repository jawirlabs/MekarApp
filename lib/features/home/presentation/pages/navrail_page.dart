import 'package:flutter/material.dart';
import 'package:mekarjs/features/chat/presentation/pages/chat_page.dart';
import 'package:mekarjs/features/customer/presentation/pages/customer_page.dart';
import 'package:mekarjs/features/employee/presentation/pages/employee_page.dart';
import 'package:mekarjs/features/home/presentation/pages/home_page.dart';
import 'package:mekarjs/features/inventory/presentation/pages/inventory_page.dart';
import 'package:mekarjs/features/production/presentation/pages/production_page.dart';
import 'package:mekarjs/features/purchase/presentation/pages/purchase_page.dart';
import 'package:mekarjs/features/sales/presentation/pages/sales_page.dart';
import 'package:mekarjs/features/supplier/presentation/pages/supplier_page.dart';
import 'package:mekarjs/features/website/presentation/pages/website_page.dart';
import 'package:mekarjs/features/profile/presentation/pages/profile_page.dart';

class NavrailPage extends StatefulWidget {
  const NavrailPage({super.key});

  @override
  State<NavrailPage> createState() => _NavrailPageState();
}

class _NavrailPageState extends State<NavrailPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ChatPage(),
    SalesPage(),
    CustomerPage(),
    PurchasePage(),
    SupplierPage(),
    InventoryPage(),
    EmployeePage(),
    ProductionPage(),
    WebsitePage(),
    ProfilePage(),
  ];

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: Text('Chat AI'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.point_of_sale_outlined),
      selectedIcon: Icon(Icons.point_of_sale),
      label: Text('Sales'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: Text('Customer'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: Text('Purchase'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.local_shipping_outlined),
      selectedIcon: Icon(Icons.local_shipping),
      label: Text('Supplier'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory),
      label: Text('Inventory'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: Text('Employee'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.factory_outlined),
      selectedIcon: Icon(Icons.factory),
      label: Text('Production'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.web_outlined),
      selectedIcon: Icon(Icons.web),
      label: Text('Website'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profile'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              groupAlignment: 0.0,
              destinations: _destinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}

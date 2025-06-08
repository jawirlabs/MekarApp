import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mekarjs/core/theme/colors.dart';
import 'package:mekarjs/features/chat/presentation/pages/chat_page.dart';
import 'package:mekarjs/features/customer/presentation/pages/customer_page.dart';
import 'package:mekarjs/features/employee/presentation/pages/employee_page.dart';
import 'package:mekarjs/features/home/presentation/pages/home_page.dart';
import 'package:mekarjs/features/inventory/presentation/pages/inventory_page.dart';
import 'package:mekarjs/features/product/presentation/pages/product_page.dart';
import 'package:mekarjs/features/production/presentation/pages/production_page.dart';
import 'package:mekarjs/features/purchase/presentation/pages/purchase_page.dart';
import 'package:mekarjs/features/sales/presentation/pages/sales_page.dart';
import 'package:mekarjs/features/supplier/presentation/pages/supplier_page.dart';
import 'package:mekarjs/features/website/presentation/pages/website_page.dart';
import 'package:mekarjs/features/profile/presentation/pages/profile_page.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    // HomePage(),
    ChatPage(),
    SalesPage(),
    CustomerPage(),
    PurchasePage(),
    SupplierPage(),
    InventoryPage(),
    ProductPage(),
    EmployeePage(),
    ProductionPage(),
    WebsitePage(),
    ProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    // {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.auto_awesome, 'label': 'Tanya AI'},
    {'icon': Icons.point_of_sale_outlined, 'label': 'Sales'},
    {'icon': Icons.group_outlined, 'label': 'Customer'},
    {'icon': Icons.shopping_cart_outlined, 'label': 'Purchase'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Supplier'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Inventory'},
    {'icon': Icons.inventory_outlined, 'label': 'Product'},
    {'icon': Icons.people_outline, 'label': 'Employee'},
    {'icon': Icons.factory_outlined, 'label': 'Production'},
    {'icon': Icons.web_outlined, 'label': 'Website'},
    {'icon': Icons.person_outline, 'label': 'Profile'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Image.asset(
                'assets/mekarjs.png',
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),

      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.background: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'],
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
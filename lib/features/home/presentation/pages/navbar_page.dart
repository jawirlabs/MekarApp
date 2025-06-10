import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mekarjs/core/theme/colors.dart';
import 'package:mekarjs/features/chat/presentation/pages/chat_page.dart';
import 'package:mekarjs/features/employee/presentation/pages/employee_page.dart';
import 'package:mekarjs/features/inventory/presentation/pages/inventory_page.dart';
import 'package:mekarjs/features/product/presentation/pages/product_page.dart';
import 'package:mekarjs/features/production/presentation/pages/production_page.dart';
import 'package:mekarjs/features/purchase/presentation/pages/purchase_page.dart';
import 'package:mekarjs/features/sales/presentation/pages/sales_page.dart';
import 'package:mekarjs/features/website/presentation/pages/website_page.dart';
import 'package:mekarjs/features/profile/presentation/pages/profile_page.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0;
  final Color activeColor = const Color(0xFFFFBB00);

  final List<Widget> _pages = const [
    ChatPage(),
    SalesPage(),
    PurchasePage(),
    InventoryPage(),
    ProductPage(),
    EmployeePage(),
    ProductionPage(),
    WebsitePage(),
    ProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.auto_awesome_outlined, 'iconFilled': Icons.auto_awesome, 'label': 'Tanya AI'},
    {'icon': Icons.point_of_sale_outlined, 'iconFilled': Icons.point_of_sale, 'label': 'Sales'},
    {'icon': Icons.shopping_cart_outlined, 'iconFilled': Icons.shopping_cart, 'label': 'Purchase'},
    {'icon': Icons.inventory_2_outlined, 'iconFilled': Icons.inventory_2, 'label': 'Inventory'},
    {'icon': Icons.inventory_outlined, 'iconFilled': Icons.inventory, 'label': 'Product'},
    {'icon': Icons.people_outline, 'iconFilled': Icons.people, 'label': 'Employee'},
    {'icon': Icons.factory_outlined, 'iconFilled': Icons.factory, 'label': 'Production'},
    {'icon': Icons.web_outlined, 'iconFilled': Icons.web, 'label': 'Website'},
    {'icon': Icons.person_outline, 'iconFilled': Icons.person, 'label': 'Profile'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(90),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Color(0xFFFFBB00).withOpacity(0.05),
      // Subtle border dengan primary color
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFFFBB00).withOpacity(0.2),
          width: 1,
        ),
      ),
    ),
    child: SafeArea(
      child: Stack(
        children: [
          // Background decorative shapes
          Positioned(
            right: -30,
            top: -15,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFFFFBB00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFFFBB00).withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          // Additional decorative shapes
          Positioned(
            left: 100,
            top: 10,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Color(0xFFFFBB00).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: 5,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Color(0xFFFFBB00).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 20,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 8,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFFFFBB00).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned(
            right: 150,
            top: 5,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(0xFFFFBB00).withOpacity(0.07),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Main content
          Row(
            children: [
              // Logo centered
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/mekarjs.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Notification icon dengan badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: Color(0xFFFFBB00).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFFFFBB00),
                        size: 20,
                      ),
                    ),
                    // Notification badge
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),
      
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        // color: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? activeColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected 
                        ? Border.all(
                            color: activeColor.withOpacity(0.3),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? activeColor.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? item['iconFilled'] : item['icon'],
                          color: isSelected
                              ? activeColor
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected 
                              ? FontWeight.w700 
                              : FontWeight.w500,
                          color: isSelected
                              ? activeColor
                              : Colors.grey.shade600,
                          letterSpacing: 0.2,
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
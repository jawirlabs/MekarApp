import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mekarjs/core/theme/colors.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final Dio _dio = Dio();
  List<dynamic> purchases = [];
  List<dynamic> filteredPurchases = [];
  bool isLoading = true;
  String? selectedBranch;
  String? selectedPaymentMethod;
  String searchQuery = '';
  final double _borderRadius = 12.0; // Increased border radius value

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    try {
      final response = await _dio.get('https://mekarjs-api.vercel.app/api/purchase');
      setState(() {
        purchases = response.data;
        filteredPurchases = purchases;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching purchases: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      filteredPurchases = purchases.where((purchase) {
        final branchMatch = selectedBranch == null || 
            purchase['branch'].toLowerCase() == selectedBranch!.toLowerCase();
        final paymentMatch = selectedPaymentMethod == null || 
            purchase['paymentMethod'] == selectedPaymentMethod;
        final searchMatch = searchQuery.isEmpty ||
            purchase['supplier']['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            purchase['products'].any((product) => 
                product['productName'].toLowerCase().contains(searchQuery.toLowerCase()));
        return branchMatch && paymentMatch && searchMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search supplier or product',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black.withOpacity(0.15)),
                                borderRadius: BorderRadius.circular(_borderRadius),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Branch',
                                    labelStyle: TextStyle(color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                  ),
                                  value: selectedBranch,
                                  dropdownColor: AppColors.background,
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('All Branches', style: TextStyle(color: AppColors.textPrimary)),
                                    ),
                                    ...['branch_1', 'Branch_2', 'Branch_3']
                                        .map((branch) => DropdownMenuItem(
                                              value: branch,
                                              child: Text(
                                                branch,
                                                style: const TextStyle(color: AppColors.textPrimary),
                                              ),
                                            ))
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBranch = value;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black.withOpacity(0.15)),
                                borderRadius: BorderRadius.circular(_borderRadius),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Method',
                                    labelStyle: TextStyle(color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                  ),
                                  value: selectedPaymentMethod,
                                  dropdownColor: AppColors.background,
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('All Methods', style: TextStyle(color: AppColors.textPrimary)),
                                    ),
                                    ...['cash', 'credit', 'transfer']
                                        .map((method) => DropdownMenuItem(
                                              value: method,
                                              child: Text(
                                                method,
                                                style: const TextStyle(color: AppColors.textPrimary),
                                              ),
                                            ))
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPaymentMethod = value;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredPurchases.isEmpty
                      ? Center(
                          child: Text(
                            'No purchases found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredPurchases.length,
                          itemBuilder: (context, index) {
                            final purchase = filteredPurchases[index];
                            return _buildPurchaseCard(purchase);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAt = DateTime.parse(purchase['createdAt']).toLocal();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: Colors.black.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(_borderRadius * 1.5), // Even more rounded for cards
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchase['supplier']['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    // border: Border.all(color: Colors.black.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(20), // More rounded for badges
                  ),
                  child: Text(
                    purchase['branch'],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${purchase['supplier']['address']}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              'Contact: ${purchase['supplier']['contact']}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Products:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            ...purchase['products'].map<Widget>((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        product['productName'],
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Qty: ${product['quantity']}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Rp${NumberFormat('#,###').format(product['unitPrice'])}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Rp${NumberFormat('#,###').format(product['quantity'] * product['unitPrice'])}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(
              color: Colors.black12,
              height: 24,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(purchase['paymentMethod']),
                    // border: Border.all(color: Colors.black.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(20), // More rounded for payment method badge
                  ),
                  child: Text(
                    purchase['paymentMethod'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Total: Rp${NumberFormat('#,###').format(purchase['totalAmount'])}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${dateFormat.format(createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'cash':
        return Colors.green;
      case 'credit':
        return Colors.orange;
      case 'transfer':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
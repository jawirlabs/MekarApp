import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mekarjs/core/theme/colors.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final Dio _dio = Dio();
  List<dynamic> sales = [];
  List<dynamic> filteredSales = [];
  bool isLoading = true;
  String? selectedBranch;
  String? selectedPaymentMethod;
  String searchQuery = '';
  final double _borderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    try {
      final response = await _dio.get('https://mekarjs-api.vercel.app/api/sale');
      setState(() {
        sales = response.data;
        filteredSales = sales;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching sales: $e'),
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
      filteredSales = sales.where((sale) {
        final branchMatch = selectedBranch == null || 
            sale['branch'].toLowerCase() == selectedBranch!.toLowerCase();
        final paymentMatch = selectedPaymentMethod == null || 
            sale['paymentMethod'] == selectedPaymentMethod;
        final searchMatch = searchQuery.isEmpty ||
            sale['customer']['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            sale['products'].any((product) => 
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
                            labelText: 'Search customer or product',
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
                  child: filteredSales.isEmpty
                      ? Center(
                          child: Text(
                            'No sales found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredSales.length,
                          itemBuilder: (context, index) {
                            final sale = filteredSales[index];
                            return _buildSaleCard(sale);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAt = DateTime.parse(sale['createdAt']).toLocal();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: Colors.black.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(_borderRadius * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                  sale['customer']['name'],
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale['branch'],
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
              'Address: ${sale['customer']['address']}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              'Contact: ${sale['customer']['contact']}',
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
            ...sale['products'].map<Widget>((product) {
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
                        'Rp${NumberFormat('#,###').format(product['sellingPrice'])}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Rp${NumberFormat('#,###').format(product['quantity'] * product['sellingPrice'])}',
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
                    color: _getPaymentMethodColor(sale['paymentMethod']),
                    // border: Border.all(color: Colors.black.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale['paymentMethod'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Total: Rp${NumberFormat('#,###').format(sale['totalAmount'])}',
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
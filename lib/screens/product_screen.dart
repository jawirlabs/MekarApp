import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mekarjs/core/theme/colors.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://mekarjs-api.vercel.app/api/product';
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _products = data.map((item) => Product.fromJson(item)).toList();
          _filteredProducts = List.from(_products);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load products: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching products: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Search filter
        final matchesSearch = _searchController.text.isEmpty ||
            product.productName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            product.sku.toLowerCase().contains(_searchController.text.toLowerCase());

        // Price range filter
        final minPrice = int.tryParse(_minPriceController.text) ?? 0;
        final maxPrice = int.tryParse(_maxPriceController.text) ?? double.maxFinite.toInt();
        final matchesPrice = product.unitPrice >= minPrice && product.unitPrice <= maxPrice;

        // Quantity range filter
        final minQuantity = int.tryParse(_minQuantityController.text) ?? 0;
        final maxQuantity = int.tryParse(_maxQuantityController.text) ?? double.maxFinite.toInt();
        final matchesQuantity = product.quantity >= minQuantity && product.quantity <= maxQuantity;

        return matchesSearch && matchesPrice && matchesQuantity;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minQuantityController.clear();
      _maxQuantityController.clear();
      _filteredProducts = List.from(_products);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 32),
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredProducts.isEmpty
                        ? const Center(child: Text('No products found'))
                        : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or SKU',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: TextStyle(color: AppColors.textPrimary),
              onChanged: (value) => _applyFilters(),
            ),
            const SizedBox(height: 12),

            // Price range filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(color: AppColors.textPrimary),
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(color: AppColors.textPrimary),
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quantity range filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Quantity',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Quantity',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reset button
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _resetFilters,
                  child: const Text('Reset Filters'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            title: Text(
              product.productName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'SKU: ${product.sku} • Qty: ${product.quantity}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Text(
              currencyFormat.format(product.saleValue),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('SKU', product.sku),
                    _buildDetailRow('Unit Price', currencyFormat.format(product.unitPrice)),
                    _buildDetailRow('Quantity', product.quantity.toString()),
                    _buildDetailRow('Total Value', currencyFormat.format(product.saleValue)),
                    _buildDetailRow('Created At', DateFormat('dd MMM yyyy HH:mm').format(product.createdAt)),
                    _buildDetailRow('Updated At', DateFormat('dd MMM yyyy HH:mm').format(product.updatedAt)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: AppColors.textPrimary)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String id;
  final String sku;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int saleValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.sku,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.saleValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      sku: json['sku'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      saleValue: json['saleValue'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
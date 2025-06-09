import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mekarjs/core/theme/colors.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://mekarjs-api.vercel.app/api/production';
  
  List<ProductionRecord> _productionRecords = [];
  List<ProductionRecord> _filteredRecords = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();
  final TextEditingController _minValueController = TextEditingController();
  final TextEditingController _maxValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductionRecords();
  }

  Future<void> _fetchProductionRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _productionRecords = data.map((item) => ProductionRecord.fromJson(item)).toList();
          _filteredRecords = List.from(_productionRecords);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load production records: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching production records: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _productionRecords.where((record) {
        // Search filter
        final matchesSearch = _searchController.text.isEmpty ||
            record.product.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            record.operator.toLowerCase().contains(_searchController.text.toLowerCase());

        // Status filter
        final matchesStatus = _selectedStatus == null || 
            record.status == _selectedStatus;

        // Quantity range filter
        final minQuantity = int.tryParse(_minQuantityController.text) ?? 0;
        final maxQuantity = int.tryParse(_maxQuantityController.text) ?? double.maxFinite.toInt();
        final matchesQuantity = record.quantityProduced >= minQuantity && 
            record.quantityProduced <= maxQuantity;

        // Value range filter
        final minValue = int.tryParse(_minValueController.text) ?? 0;
        final maxValue = int.tryParse(_maxValueController.text) ?? double.maxFinite.toInt();
        final matchesValue = record.saleValue >= minValue && 
            record.saleValue <= maxValue;

        return matchesSearch && matchesStatus && matchesQuantity && matchesValue;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _minQuantityController.clear();
      _maxQuantityController.clear();
      _minValueController.clear();
      _maxValueController.clear();
      _filteredRecords = List.from(_productionRecords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredRecords.isEmpty
                        ? const Center(child: Text('No production records found'))
                        : _buildProductionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final statuses = _productionRecords.map((e) => e.status).toSet().toList();

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
                labelText: 'Search by product or operator',
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

            // Status and quantity filters
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedStatus,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'All Statuses',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Statuses',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          ...statuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _applyFilters();
                        },
                        dropdownColor: AppColors.background,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Qty',
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
                      labelText: 'Max Qty',
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

            // Value range filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Value',
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
                    controller: _maxValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Value',
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

  Widget _buildProductionList() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
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
              record.product,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Status: ${record.status} • Qty: ${record.quantityProduced}',
              style: TextStyle(
                color: _getStatusColor(record.status),
              ),
            ),
            trailing: Text(
              currencyFormat.format(record.saleValue),
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
                    _buildDetailRow('Production ID', record.id),
                    _buildDetailRow('Status', record.status),
                    _buildDetailRow('Operator', record.operator),
                    _buildDetailRow('Quantity Produced', record.quantityProduced.toString()),
                    _buildDetailRow('Unit Price', currencyFormat.format(record.unitPrice)),
                    _buildDetailRow('Total Value', currencyFormat.format(record.saleValue)),
                    _buildDetailRow('Created At', DateFormat('dd MMM yyyy HH:mm').format(record.createdAt)),
                    _buildDetailRow('Updated At', DateFormat('dd MMM yyyy HH:mm').format(record.updatedAt)),
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
            width: 120,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Sedang Berlangsung':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}

class ProductionRecord {
  final String id;
  final String product;
  final String status;
  final int quantityProduced;
  final int unitPrice;
  final int saleValue;
  final String operator;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductionRecord({
    required this.id,
    required this.product,
    required this.status,
    required this.quantityProduced,
    required this.unitPrice,
    required this.saleValue,
    required this.operator,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductionRecord.fromJson(Map<String, dynamic> json) {
    return ProductionRecord(
      id: json['_id'],
      product: json['product'],
      status: json['status'],
      quantityProduced: json['quantityProduced'],
      unitPrice: json['unitPrice'],
      saleValue: json['saleValue'],
      operator: json['operator'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
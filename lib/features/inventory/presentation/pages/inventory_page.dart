import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mekarjs/core/theme/colors.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://mekarjs-api.vercel.app/api/inventory';
  
  List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _inventoryItems = data.map((item) => InventoryItem.fromJson(item)).toList();
          _filteredItems = List.from(_inventoryItems);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load inventory: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching inventory: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _inventoryItems.where((item) {
        final matchesSearch = _searchController.text.isEmpty ||
            item.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            item.category.toLowerCase().contains(_searchController.text.toLowerCase());

        final matchesCategory = _selectedCategory == null || 
            item.category == _selectedCategory;

        final matchesLocation = _selectedLocation == null || 
            item.location == _selectedLocation;

        final matchesCondition = _selectedCondition == null || 
            item.condition == _selectedCondition;

        return matchesSearch && matchesCategory && matchesLocation && matchesCondition;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedLocation = null;
      _selectedCondition = null;
      _filteredItems = List.from(_inventoryItems);
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
                    : _filteredItems.isEmpty
                        ? const Center(child: Text('No items found'))
                        : _buildInventoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final categories = _inventoryItems.map((e) => e.category).toSet().toList();
    final locations = _inventoryItems.map((e) => e.location).toSet().toList();
    final conditions = _inventoryItems.map((e) => e.condition).toSet().toList();

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(16), // Lebih rounded
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
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
                  borderRadius: BorderRadius.circular(12), // Lebih rounded
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12), // Lebih rounded
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12), // Lebih rounded
                ),
                labelStyle: TextStyle(color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: TextStyle(color: AppColors.textPrimary),
              onChanged: (value) => _applyFilters(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(12), // Lebih rounded
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'All Categories',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Categories',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  category,
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
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
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(12), // Lebih rounded
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedLocation,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'All Locations',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Locations',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          ...locations.map((location) {
                            return DropdownMenuItem(
                              value: location,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  location.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value;
                          });
                          _applyFilters();
                        },
                        dropdownColor: AppColors.background,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(12), // Lebih rounded
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCondition,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'All Conditions',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Conditions',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          ...conditions.map((condition) {
                            return DropdownMenuItem(
                              value: condition,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  condition,
                                  style: TextStyle(
                                    color: condition == 'Rusak' 
                                      ? AppColors.danger 
                                      : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCondition = value;
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(12), // Lebih rounded
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Lebih rounded
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(16), // Lebih rounded
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)), // Lebih rounded
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.condition == 'Rusak' ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${item.category} • ${item.quantity} ${item.unit} • ${item.location.replaceAll('_', ' ')}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Text(
              currencyFormat.format(item.estimatedValue),
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
                    _buildDetailRow('ID', item.id),
                    _buildDetailRow('Condition', item.condition),
                    _buildDetailRow('Estimated Value', currencyFormat.format(item.estimatedValue)),
                    _buildDetailRow('Created At', DateFormat('dd MMM yyyy HH:mm').format(item.createdAt)),
                    _buildDetailRow('Updated At', DateFormat('dd MMM yyyy HH:mm').format(item.updatedAt)),
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
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final String condition;
  final String location;
  final int estimatedValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.condition,
    required this.location,
    required this.estimatedValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
      condition: json['condition'],
      location: json['location'],
      estimatedValue: json['estimatedValue'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
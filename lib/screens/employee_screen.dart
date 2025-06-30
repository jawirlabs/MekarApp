import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mekarjs/core/theme/colors.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://mekarjs-api.vercel.app/api/employee';
  
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWorkPosition;
  String? _selectedRole;
  String? _selectedStatus;
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _employees = data.map((item) => Employee.fromJson(item)).toList();
          _filteredEmployees = List.from(_employees);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load employees: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching employees: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        // Search filter
        final matchesSearch = _searchController.text.isEmpty ||
            employee.fullName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            employee.nationalId.contains(_searchController.text) ||
            employee.email.toLowerCase().contains(_searchController.text.toLowerCase());

        // Position filter
        final matchesPosition = _selectedWorkPosition == null || 
            employee.workPosition == _selectedWorkPosition;

        // Role filter
        final matchesRole = _selectedRole == null || 
            employee.role == _selectedRole;

        // Status filter
        final matchesStatus = _selectedStatus == null || 
            employee.status == _selectedStatus;

        // Salary range filter
        final minSalary = int.tryParse(_minSalaryController.text) ?? 0;
        final maxSalary = int.tryParse(_maxSalaryController.text) ?? double.maxFinite.toInt();
        final matchesSalary = employee.salary >= minSalary && employee.salary <= maxSalary;

        return matchesSearch && matchesPosition && matchesRole && matchesStatus && matchesSalary;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedWorkPosition = null;
      _selectedRole = null;
      _selectedStatus = null;
      _minSalaryController.clear();
      _maxSalaryController.clear();
      _filteredEmployees = List.from(_employees);
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
                    : _filteredEmployees.isEmpty
                        ? const Center(child: Text('No employees found'))
                        : _buildEmployeeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final workPositions = _employees.map((e) => e.workPosition).toSet().toList();
    final roles = _employees.map((e) => e.role).toSet().toList();
    final statuses = _employees.map((e) => e.status).toSet().toList();

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
                labelText: 'Search by name, ID or email',
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

            // Position and Role filters
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
                        value: _selectedWorkPosition,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'All Work Positions',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Work Positions',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          ...workPositions.map((position) {
                            return DropdownMenuItem(
                              value: position,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  position.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkPosition = value;
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedRole,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'All Roles',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Roles',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          ...roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  role.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
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

            // Status and Salary filters
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
                                  status.toUpperCase(),
                                  style: TextStyle(color: AppColors.textPrimary),
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
                    controller: _minSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min Salary',
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
                    controller: _maxSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Salary',
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

  Widget _buildEmployeeList() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
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
              employee.fullName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${employee.role.replaceAll('_', ' ').toUpperCase()} • ${employee.workPosition.replaceAll('_', ' ').toUpperCase()}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Text(
              currencyFormat.format(employee.salary),
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
                    _buildDetailRow('Employee ID', employee.id),
                    _buildDetailRow('National ID', employee.nationalId),
                    _buildDetailRow('Birth Date', DateFormat('dd MMM yyyy').format(employee.birthDate)),
                    _buildDetailRow('Phone', employee.phoneNumber),
                    _buildDetailRow('Email', employee.email),
                    _buildDetailRow('Status', employee.status.toUpperCase()),
                    _buildDetailRow('Salary', currencyFormat.format(employee.salary)),
                    _buildDetailRow('Hire Date', DateFormat('dd MMM yyyy').format(employee.hireDate)),
                    
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    Text(
                      'ADDRESS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildDetailRow('Street', employee.address.street),
                    _buildDetailRow('City', employee.address.city),
                    _buildDetailRow('Province', employee.address.province),
                    _buildDetailRow('Postal Code', employee.address.postalCode),
                    _buildDetailRow('Country', employee.address.country),
                    
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    Text(
                      'BANK ACCOUNT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildDetailRow('Bank Name', employee.bankAccount.bankName),
                    _buildDetailRow('Account Number', employee.bankAccount.accountNumber),
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

class Employee {
  final String id;
  final String fullName;
  final String nationalId;
  final DateTime birthDate;
  final String phoneNumber;
  final String email;
  final String workPosition;
  final String role;
  final DateTime hireDate;
  final String status;
  final int salary;
  final Address address;
  final BankAccount bankAccount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.birthDate,
    required this.phoneNumber,
    required this.email,
    required this.workPosition,
    required this.role,
    required this.hireDate,
    required this.status,
    required this.salary,
    required this.address,
    required this.bankAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'],
      fullName: json['fullName'],
      nationalId: json['nationalId'],
      birthDate: DateTime.parse(json['birthDate']),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      workPosition: json['workPosition'],
      role: json['role'],
      hireDate: DateTime.parse(json['hireDate']),
      status: json['status'],
      salary: json['salary'],
      address: Address.fromJson(json['address']),
      bankAccount: BankAccount.fromJson(json['bankAccount']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Address {
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }
}

class BankAccount {
  final String bankName;
  final String accountNumber;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
    );
  }
}